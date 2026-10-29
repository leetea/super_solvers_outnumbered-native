"""Scan files and ZIP members without printing matched personal data. Python stdlib only."""
import io
import re
import sys
import zipfile
from pathlib import Path

PATTERNS = {
    'personal home path': re.compile(rb'(?:/(?:Users|home)/[A-Za-z0-9_.-]+|[A-Za-z]:\\+(?:Users|Documents and Settings)\\+[A-Za-z0-9_.-]+)'),
    'personal email domain': re.compile(rb'[A-Za-z0-9._%+-]+@sbcglobal[.]net', re.I),
    'private key': re.compile(rb'-----BEGIN (?:RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----'),
    'access token': re.compile(rb'(?:gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,}|AKIA[A-Z0-9]{16})'),
}
MAX_FILE = 256 * 1024 * 1024

def scan_bytes(label, data, depth=0):
    findings = []
    # UTF-16 text is common in Windows build metadata.
    samples = [data]
    if data.startswith((b'\xff\xfe', b'\xfe\xff')):
        samples.append(data.decode('utf-16').encode('utf-8'))
    for name, pattern in PATTERNS.items():
        matches = [match.group() for sample in samples for match in pattern.finditer(sample)]
        if name == 'personal home path':
            # Official Swift DLLs embed this generic upstream build account.
            # Exempt only that exact account, not the rest of the file.
            matches = [value for value in matches if re.split(rb'[/\\]+', value)[-1] != b'swift-ci']
        if matches:
            findings.append(f'{label}: {name}')
    if zipfile.is_zipfile(io.BytesIO(data)):
        if depth >= 3:
            raise ValueError(f'{label}: archive nesting limit')
        with zipfile.ZipFile(io.BytesIO(data)) as archive:
            if sum(member.file_size for member in archive.infolist()) > MAX_FILE:
                raise ValueError(f'{label}: expanded archive exceeds scan limit')
            for member in archive.infolist():
                if not member.is_dir():
                    findings += scan_bytes(f'{label}!{member.filename}', archive.read(member), depth + 1)
    return findings

def scan(path):
    if path.is_symlink():
        raise ValueError(f'{path}: symlink must be reviewed separately')
    if path.stat().st_size > MAX_FILE:
        raise ValueError(f'{path}: file exceeds scan limit')
    return scan_bytes(str(path), path.read_bytes())

if __name__ == '__main__':
    findings = []
    try:
        for argument in sys.argv[1:]:
            path = Path(argument)
            files = path.rglob('*') if path.is_dir() else [path]
            for file in files:
                if '.git' not in file.parts and (file.is_file() or file.is_symlink()):
                    findings += scan(file)
        if len(sys.argv) < 2:
            raise ValueError('Pass one or more files or directories to scan')
    except (OSError, ValueError, zipfile.BadZipFile, UnicodeError) as error:
        print(error, file=sys.stderr)
        sys.exit(2)
    print('\n'.join(findings) if findings else 'Privacy scan passed')
    sys.exit(bool(findings))
