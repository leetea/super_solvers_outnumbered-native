"""Remove the known reference-video path while preserving every other ZIP member."""
import json
import os
import sys
import tempfile
import zipfile
from pathlib import Path


def sanitize(path):
    fd, temporary = tempfile.mkstemp(dir=path.parent, suffix='.zip')
    os.close(fd)
    found = 0
    try:
        with zipfile.ZipFile(path) as source, zipfile.ZipFile(temporary, 'w') as target:
            if sum(item.file_size for item in source.infolist()) > 256 * 1024 * 1024:
                raise ValueError('Runtime archive exceeds size limit')
            for item in source.infolist():
                data = source.read(item)
                if Path(item.filename).name == 'drill-video-fixtures.json':
                    fixture = json.loads(data)
                    fixture['reference'] = 'local-inputs/OutNumbered Gameplay.mkv'
                    data = (json.dumps(fixture, indent=2) + '\n').encode()
                    found += 1
                target.writestr(item, data)
        if found != 1:
            raise ValueError('Expected exactly one reference fixture; archive unchanged')
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)

if __name__ == '__main__':
    sanitize(Path(sys.argv[1]))
