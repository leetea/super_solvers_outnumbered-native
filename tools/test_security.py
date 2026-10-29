"""Run with: python3 tools/test_security.py"""
import json
import shutil
import subprocess
import tempfile
import zipfile
from pathlib import Path
from check_privacy import scan_bytes
from sanitize_runtime import sanitize

with tempfile.TemporaryDirectory() as directory:
    path = Path(directory) / 'runtime.zip'
    personal = '/' + 'Users/' + 'fixture/Downloads/video.mkv'
    original = {'reference': personal, 'referenceSHA256': 'unchanged', 'firstDrill': [1, 2]}
    with zipfile.ZipFile(path, 'w') as archive:
        archive.writestr('drill-video-fixtures.json', json.dumps(original))
        archive.writestr('resources/assets/keep.bin', bytes(range(256)))
    assert scan_bytes('zip', path.read_bytes())
    sanitize(path)
    assert not scan_bytes('zip', path.read_bytes())
    with zipfile.ZipFile(path) as archive:
        fixture = json.loads(archive.read('drill-video-fixtures.json'))
        assert fixture == dict(original, reference='local-inputs/OutNumbered Gameplay.mkv')
        assert archive.read('resources/assets/keep.bin') == bytes(range(256))
    assert scan_bytes('utf16', personal.encode('utf-16'))
    assert not scan_bytes('upstream', ('/' + 'Users/swift-ci/build').encode())
    assert scan_bytes('personal', ('/' + 'Users/swift-civilian/build').encode())
    assert scan_bytes('token', ('ghp_' + 'a' * 36).encode())
    assert not scan_bytes('safe', b'7686365+leetea@users.noreply.github.com')
    with zipfile.ZipFile(path, 'w') as archive:
        archive.writestr('other.json', '{}')
    before = path.read_bytes()
    try:
        sanitize(path)
        raise AssertionError('Missing fixture must fail')
    except ValueError:
        assert path.read_bytes() == before
# These guards must exit before compiling or altering a destination.
if shutil.which('zsh'):
    build = Path(__file__).resolve().parents[1] / 'source/build.sh'
    with tempfile.TemporaryDirectory() as directory:
        root = Path(directory)
        existing = root / 'existing.app'
        existing.mkdir()
        marker = existing / 'keep.txt'
        marker.write_text('preserve')
        link = root / 'link.app'
        link.symlink_to(existing, target_is_directory=True)
        for destination in [existing, link, root / 'not-an-app']:
            result = subprocess.run(['zsh', str(build), str(destination)], capture_output=True)
            assert result.returncode == 2, result.stderr
            assert marker.read_text() == 'preserve'
        result = subprocess.run(['zsh', str(build), str(root / 'new.app'), 'distribution'],
                                env={'PATH': '/usr/bin:/bin'}, capture_output=True)
        assert result.returncode == 2 and not (root / 'new.app').exists()
print('Security regression checks passed')
