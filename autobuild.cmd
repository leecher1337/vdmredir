@echo off
rem Automated build script for WinXP VDMREDIR
rem -----------------------------------------
rem Madantory requirements:
rem 
rem   MinNT-20170416-85fac4faadc77203db8ddc66af280a75c1b717b0.zip
rem   nt5src.7z
rem
rem Optional environment vars:
rem
rem   PREREQ    Directory, where prerequired files are found. Default is current dir
rem   SRCDIR    Directory, where current ntvdmpatch source folder can be found.
rem             Not useful for end-users, just for automated testing on dev machine
rem   KEEPPAT   Internal use, does not demand refresh of ntvdmpatch
rem   WKDIR     Working directory for build process, default is %CD%\w
rem   DBGSTP    If set, pause is issued after every step, useful for testing build
rem   SIZ_NTBLD [chk, fre] Checked of free build, default is free
rem   NOPAUSE   Do not pause before cleanup
rem   KEEPWD    Keep working directory so that subsequent builds will run through 
rem             faster when run with KEEPPAT
rem

echo ----------------------------------------------------
echo Autobuild VDMREDIR
echo ----------------------------------------------------
echo.


rem There seem to be some strange constellations where even on syswow64
rem cmd.exe, PROCESSOR_ARCHITECTURE is AMD64 for unknown reasons. Overwrite it
if not "%PROCESSOR_ARCHITECTURE%"=="x86" set PROCESSOR_ARCHITECTURE=x86

if "%SIZ_NTBLD%"=="" set SIZ_NTBLD=fre
set LANG=usa
setlocal enableDelayedExpansion
if exist "%ProgramFiles%\7-Zip" set PATH=%PATH:)=^)%;"%ProgramFiles%\7-Zip"
7z >nul 2>&1
if errorlevel 255 (
for /F "tokens=2*" %%r in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\7-zip" /v Path 2^>nul') do set ZPATH=%%s
if "!ZPATH!"=="" for /F "tokens=2*" %%r in ('reg query "HKEY_CURRENT_USER\SOFTWARE\7-zip" /v Path 2^>nul') do set ZPATH=%%s
if not "!ZPATH!"=="" set PATH=%PATH:)=^)%;!ZPATH!
7z >nul 2>&1
if errorlevel 255 (
echo Please install 7zip first, then run again
start http://www.7-zip.de
pause
exit /b
)
)
endlocal & set PATH=%PATH%

set ABPATH=%CD%
if "%PREREQ%"=="" set PREREQ=%CD%\
if "%WKDIR%"=="" set WKDIR=%CD%\w
if exist "%WKDIR%\nul" (
  echo Working directory %WKDIR% exists.
  echo As it gets deleted after build, please remove it prior to executing this script.
  pause
  exit /B
)
md %WKDIR%
if not exist "%WKDIR%" (
  pause
  exit /B
)

echo Preparing...
call :fetchprq

rem -- Path contains spaces, bad, do subst
set NEEDSUBST=
if not "%WKDIR%"=="%WKDIR: =%" (
  echo [!] Consider using a pathname without space in it
  SET NEEDSUBST=1
)

rem -- Path contains a hyphen, bad, do subst
if not "%WKDIR%"=="%WKDIR:-=%" (
  echo [!] Consider using a pathname without - in it
  SET NEEDSUBST=1
)

rem -- Path is too long, bad, do subst
setlocal enableDelayedExpansion
if not [%WKDIR:~0,-30%]==[] SET NEEDSUBST=1
if not "%NEEDSUBST%"=="" (
  set "drives=WDEFGHIJKLMNOPQRSTUVXYZABC"
  for /f "delims=:" %%A in ('wmic logicaldisk get caption') do set "drives=!drives:%%A=!"
  set "WORKDRV=!drives:~0,1!"

  if "!WORKDRV!"=="" (
    echo No free drive letter found, aborting, sorry...
    pause
    exit /b
  )
  subst !WORKDRV!: %WKDIR%
  set BLDDIR=!WORKDRV!:
) else (
  set BLDDIR=%WKDIR%
)
endlocal & set "WORKDRV=%WORKDRV%" & set BLDDIR=%BLDDIR%

pushd %BLDDIR%
set BLDDIR=
if "%KEEPPAT%"=="" (
  call :setupbe
  call :buildthis
) else (
  call :dlntvdmx64
  rmdir /s /q minnt 2>nul
  call :unpack MinNT-20170416-85fac4faadc77203db8ddc66af280a75c1b717b0.zip
  ren MinNT-master minnt
  pushd ntvdmpatch\minnt
  if "%DBGSTP%"=="" (call patch batch) else call patch
  popd
  call :buildthis
)
popd
rmdir /s /q release 2>nul
mkdir release
mkdir release\dos
set BINDIR=%WKDIR%\Binaries\x86%SIZ_NTBLD%
for %%I in (NetRap.dll xactsrv.dll vdmredir.dll) do xcopy /Y %BINDIR%\%%I release\dos\
xcopy /Y %WKDIR%\ntvdmpatch\vdmredir\release\*.* release\
copy /y install.bat release\
if not "%WORKDRV%"=="" subst %WORKDRV%: /d
set WORKDRV=
set ABPATH=
if not exist release\nul (
  echo Was unable to move releases directory, please go to %BINDIR% manually and get it from there.
  pause
) else (
  if "%NOPAUSE%"=="" pause
  echo Cleaning up...
  if "%KEEPWD%"=="" (rmdir /s /q %WKDIR%) else rmdir /s /q %WKDIR%\ntvdmpatch\minnt\work 2>nul
  echo Autobuild completed, check releases-directory
)
exit /b

:buildthis
cd NTOSBE-master
call sizzle_minnt.cmd cmdwindow
call buildrepoidw -y 
cd %NTROOT%\..\ntvdmpatch\vdmredir\
call bld.cmd
exit /B

:fetchprq
call :dlprq GRMWDK_EN_7600_1.ISO https://download.microsoft.com/download/4/A/2/4A25C7D5-EFBE-4182-B6A9-AE6850409A78/GRMWDK_EN_7600_1.ISO
call :dlprq NTOSBE-master.zip http://web.archive.org/web/20210804144408/https://codeload.github.com/stephanosio/NTOSBE/zip/master
exit /b

:setupbe
call :unpack NTOSBE-master.zip
if "%DBGSTP%"=="" (
  type NTOSBE-master\buildlocaltools.cmd | findstr /V pause >buildlocaltools.cmd
  move /y buildlocaltools.cmd NTOSBE-master\buildlocaltools.cmd
)
rmdir /s /q minnt 2>nul
call :unpack MinNT-20170416-85fac4faadc77203db8ddc66af280a75c1b717b0.zip
ren MinNT-master minnt
call :dlntvdmx64
call :cpyprq GRMWDK_EN_7600_1.ISO 
for %%I in (nt5src.7z Win2K3.7z 3790src2.cab 3790src4.cab) do if exist %PREREQ%\%%I call :cpyprq %%I
pushd ntvdmpatch\vdmredir\
if "%DBGSTP%"=="" (call prepare batch) else call prepare
popd
pushd ntvdmpatch\minnt
call patch.cmd vdmredir
popd
echo Build environment ready
exit /b

:dlntvdmx64
if not "%KEEPPAT%"=="" exit /B
if "%SRCDIR%"=="" (
  del %PREREQ%\ntvdmx64.zip 2>nul
  rmdir /s /q ntvdmpatch 2>nul
  call :dlprq ntvdmx64.zip https://github.com/leecher1337/ntvdmx64/archive/master.zip
  7z x -y  %PREREQ%\ntvdmx64.zip
  del %PREREQ%\ntvdmx64.zip
  move /y ntvdmx64-master\ntvdmpatch .
  rmdir /s /q ntvdmx64-master
) else (
  xcopy /s /Y %SRCDIR% ntvdmpatch\
)
exit /B

:dlprq
if not exist %PREREQ%\%1 (
  rem -- wget.exe is preferred, as it also works on Windows XP 
  rem -- bitsadmin fails for some urls and thus is the least preferred solution
  rem
  if exist %ABPATH%\wget.exe (
    %ABPATH%\wget --no-check-certificate %2 -O %PREREQ%\%1
  ) else (
    if exist %ABPATH%\dwnl.exe (
      %ABPATH%\dwnl %2 %PREREQ%\%1
    ) else (
      bitsadmin /transfer %1 /download /priority normal %2 %PREREQ%\%1
    )
  )
)
if not exist %PREREQ%\%1 (
  echo Prerequisite %1 not found in %PREREQ%, FAILED!
  pause
  exit
)
exit /b

:cpyprq
if not exist %PREREQ%\%1 (
  echo Prerequisite %1 not found in %PREREQ%, FAILED!
  pause
  exit
)
copy /y %PREREQ%\%1 ntvdmpatch\minnt\work\
exit /B

:unpack
if not exist %PREREQ%\%1 (
  echo Prerequisite %1 not found in %PREREQ%, FAILED!
  pause
  exit
)
7z x -y %PREREQ%\%1
exit /B
