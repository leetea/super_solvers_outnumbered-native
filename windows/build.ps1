param([string]$SDLRoot,[string]$Destination=(Join-Path $PSScriptRoot '../build/windows-x64'))
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$root=Split-Path $PSScriptRoot
$source=Join-Path $root 'source'
if (!$SDLRoot) { throw 'Pass -SDLRoot pointing to the official SDL3 development package.' }
if (Test-Path $Destination) { throw 'Choose a fresh destination; existing packages are preserved.' }
New-Item -ItemType Directory -Force $Destination | Out-Null
$Destination=(Resolve-Path $Destination).Path
$include=Join-Path $SDLRoot 'include'
$lib=Join-Path $SDLRoot 'lib/x64'
& clang-cl /nologo /O2 /MD /c (Join-Path $PSScriptRoot 'bridge/OutnumberedHost.c') "/I$include" "/Fo$Destination/OutnumberedHost.obj"
if ($LASTEXITCODE) { throw 'SDL host compilation failed' }
$files=Get-ChildItem $source -Filter '*.swift' | Where-Object Name -ne 'DecoderTests.swift' | Sort-Object Name | ForEach-Object FullName
& swiftc -swift-version 5 -O -whole-module-optimization -parse-as-library -I (Join-Path $PSScriptRoot 'bridge') @files (Join-Path $Destination 'OutnumberedHost.obj') -L $lib -lSDL3 -o (Join-Path $Destination 'Outnumbered.exe')
if ($LASTEXITCODE) { throw 'Swift Windows compilation failed' }
$pe=[System.IO.File]::ReadAllBytes((Join-Path $Destination 'Outnumbered.exe'))
$peOffset=[BitConverter]::ToInt32($pe,0x3c)
if ([BitConverter]::ToUInt32($pe,$peOffset) -ne 0x4550 -or [BitConverter]::ToUInt16($pe,$peOffset+4) -ne 0x8664) { throw 'Expected native Windows AMD64 PE executable' }
Copy-Item (Join-Path $lib 'SDL3.dll') $Destination
Expand-Archive (Join-Path $source 'runtime-data.zip') (Join-Path $Destination 'data') -Force
Move-Item (Join-Path $Destination 'data/resources/assets') (Join-Path $Destination 'assets') -Force
Copy-Item (Join-Path $Destination 'data/*.json') (Join-Path $Destination 'assets')
Remove-Item (Join-Path $Destination 'data') -Recurse -Force
$target=(& swiftc -print-target-info | ConvertFrom-Json)
if ($LASTEXITCODE) { throw 'Swift target inventory failed' }
$paths=@($target.paths.runtimeLibraryPaths)
$swift=(Get-Command swiftc).Source
$paths+=(Split-Path $swift)
# Foundation/ICU DLLs may live in SDK bin, separate from compiler binaries.
if ($env:SDKROOT) { $paths+=(Join-Path $env:SDKROOT 'usr/bin') }
foreach($path in ($paths | Select-Object -Unique)) {
    if (Test-Path $path) { Get-ChildItem $path -Filter '*.dll' | Copy-Item -Destination $Destination -Force }
}
if ($env:VCToolsRedistDir) {
    Get-ChildItem (Join-Path $env:VCToolsRedistDir 'x64/Microsoft.VC*.CRT') -Filter '*.dll' | Copy-Item -Destination $Destination -Force
}
Copy-Item (Join-Path $PSScriptRoot 'Run-Windows-Checks.cmd') $Destination
Copy-Item (Join-Path $root 'WINDOWS.md') (Join-Path $Destination 'READ-ME.md')
Copy-Item (Join-Path $SDLRoot 'LICENSE.txt') (Join-Path $Destination 'SDL-LICENSE.txt')
& python (Join-Path $PSScriptRoot 'prune_runtime.py') $Destination
if ($LASTEXITCODE) { throw 'Runtime dependency inventory failed' }
& (Join-Path $Destination 'Outnumbered.exe') --self-test | Set-Content (Join-Path $Destination 'self-test.json')
if ($LASTEXITCODE) { throw 'Windows native checks failed' }
$report=Get-Content (Join-Path $Destination 'self-test.json') -Raw | ConvertFrom-Json
if (!$report.passed -or $report.checkCount -ne 1118) { throw 'Windows check count/acceptance mismatch' }
# Do not ship a package that accidentally relies on the build machine PATH.
$env:PATH="$env:SystemRoot\System32;$env:SystemRoot"
$oldLocation=Get-Location
try {
    Set-Location $env:TEMP
    $env:OUTNUMBERED_CHECK_OUTPUT=Join-Path $env:TEMP ('outnumbered-package-'+[guid]::NewGuid())
    & (Join-Path $Destination 'Outnumbered.exe') --self-test | Set-Content (Join-Path $Destination 'portable-self-test.json')
    if ($LASTEXITCODE) { throw 'Clean PATH/foreign working directory checks failed' }
} finally { Set-Location $oldLocation }
Get-ChildItem $Destination -Filter '*.obj' | Remove-Item
Get-ChildItem $Destination -Filter '*.lib' | Remove-Item
Get-ChildItem $Destination -Filter '*.exp' | Remove-Item
$env:SDL_VIDEODRIVER='dummy'
$env:SDL_AUDIODRIVER='dummy'
& (Join-Path $Destination 'Outnumbered.exe') --host-smoke-test | Set-Content (Join-Path $Destination 'host-smoke-test.json')
if ($LASTEXITCODE) { throw 'Native Windows SDL host smoke test failed' }
Remove-Item Env:SDL_VIDEODRIVER
Remove-Item Env:SDL_AUDIODRIVER
Get-FileHash (Join-Path $Destination 'Outnumbered.exe') | ConvertTo-Json | Set-Content (Join-Path $Destination 'binary-sha256.json')
Compress-Archive (Join-Path $Destination '*') (Join-Path (Split-Path $Destination) 'Outnumbered-Windows-x64.zip') -Force
