"""Keep PE import closure and dynamically loaded Swift/Foundation runtimes only."""
from pathlib import Path
import json, struct, sys
root=Path(sys.argv[1]).resolve()
def imports(path):
    data=path.read_bytes()
    pe=struct.unpack_from('<I',data,0x3c)[0]
    assert data[pe:pe+4]==b'PE\0\0',path
    machine,sections=struct.unpack_from('<HH',data,pe+4)
    assert machine==0x8664,(path,machine)
    optional_size=struct.unpack_from('<H',data,pe+20)[0]
    optional=pe+24
    assert struct.unpack_from('<H',data,optional)[0]==0x20b,path
    def offset(rva):
        for i in range(sections):
            pos=optional+optional_size+i*40
            size,base,rawsize,raw=struct.unpack_from('<IIII',data,pos+8)
            if base<=rva<base+max(size,rawsize):return raw+rva-base
        if rva<struct.unpack_from('<I',data,optional+60)[0]:return rva
        raise ValueError(f'Unmapped PE RVA {rva:x}: {path}')
    def name(rva):
        pos=offset(rva);return data[pos:data.index(0,pos)].decode('ascii').lower()
    result=[]
    for index,stride,name_offset in [(1,20,12),(13,32,4)]:
        rva,length=struct.unpack_from('<II',data,optional+112+index*8)
        if not rva:continue
        pos=offset(rva)
        while any(data[pos:pos+stride]):
            value=struct.unpack_from('<I',data,pos+name_offset)[0]
            if index==13 and not struct.unpack_from('<I',data,pos)[0]&1:
                value-=struct.unpack_from('<Q',data,optional+24)[0]
            result.append(name(value));pos+=stride
    return result
files={p.name.lower():p for p in root.glob('*.dll')}
roots={'outnumbered.exe'}
# These may be loaded dynamically, without an import-table edge.
roots.update(n for n in files if (n.startswith(('swiftcore','swift_','swiftdispatch','foundation','_foundation')) and n!='foundationmacros.dll') or n in {'dispatch.dll','blocksruntime.dll'})
queue=list(roots);keep=set();external=set()
while queue:
    name=queue.pop()
    if name in keep:continue
    keep.add(name)
    path=root/'Outnumbered.exe' if name=='outnumbered.exe' else files[name]
    for dependency in imports(path):
        if dependency in files:queue.append(dependency)
        else:external.add(dependency)
removed=[]
for name,path in files.items():
    if name not in keep:removed.append({'name':path.name,'bytes':path.stat().st_size});path.unlink()
report={'architecture':'AMD64','keptDLLs':sorted(keep-{'outnumbered.exe'}),'systemImports':sorted(external),'removedBuildLibraries':removed}
(root/'runtime-dependencies.json').write_text(json.dumps(report,indent=2)+'\n')
print(f'Kept {len(keep)-1} runtime DLLs; removed {len(removed)} build libraries ({sum(x["bytes"] for x in removed):,} bytes)')
