@echo off

rem * Create a bootable UBCD memory stick
rem *
rem * UBCD port to USB pioneered by Reblu
rem * http://www.ultimatebootcd.com/forums/viewtopic.php?t=155
rem *
rem * UBCD2USB batch helper authored by Erwin Veermans
rem * Modified by Victor Chew for inclusion in UBCD main distro
rem *
rem * Ultimate Boot CD (UBCD): http://www.ultimatebootcd.com/
rem * syslinux: http://syslinux.zytor.com/

@echo on
@if "%debug%"=="" echo off

setlocal
set VOLUME_ID=UBCD535

set a1=%1
set a1=###%a1%###
set a1=%a1:"###=%
set a1=%a1:###"=%
set a1=%a1:###=%

set a2=%2
set a2=###%a2%###
set a2=%a2:"###=%
set a2=%a2:###"=%
set a2=%a2:###=%

set a3=%3
set a3=###%a3%###
set a3=%a3:"###=%
set a3=%a3:###"=%
set a3=%a3:###=%

if "%a1%"==":" if not "%a2%"=="" goto %a2%
if "%a1%"=="" goto _help
if "%a2%"=="" goto _help

:_startops
echo.
echo UBCD2USB: Creating bootable UBCD memory stick ...
if not "%a3%"=="/f" goto _gomkbt2

:_mkbtft
echo UBCD2USB: *WARNING* YOUR USB KEY IS ABOUT TO BE REFORMATTED!
echo UBCD2USB: *WARNING* YOUR USB KEY CONTENTS WILL BE LOST!
echo Press any key to continue, press 'Ctrl+C' to abort.
pause > nul

:_gomkbt
echo UBCD2USB: Formatting USB KEY...
format "%a2%" /fs:fat32 /v:%VOLUME_ID% /x /q
if errorlevel 0 goto _gomkbt2
%0 : _error 'format.exe' failed
:_gomkbt2
if not exist "%a2%\boot\syslinux\nul" mkdir "%a2%\boot\syslinux\"
echo UBCD2USB: Making USB KEY bootable...
"%~dp0\syslinux" -f -ma -d boot\syslinux %a2%
if errorlevel 0 goto _gomkbt3
%0 : _error 'syslinux.exe' failed
:_gomkbt3
echo UBCD2USB: Copying files to USB KEY...
rmdir /q /s "%a1%\[BOOT]" 2> NUL
rmdir /q /s "%a1%\boot.images" 2> NUL
xcopy "%a1%\*" %a2% /s /h /q /exclude:%~dp0\exclude.lst
if errorlevel 0 goto _gomkbt4
%0 : _error 'xcopy.exe' failed
:_gomkbt4
if not exist "%a2%\ubcd\tools\win32\ubcd2usb\ubcd2usb.cmd" %0 : _error Missing '%a2%\ubcd\tools\win32\ubcd2usb\ubcd2usb.cmd' (script did not run successfully)
echo UBCD2USB: Bootable UBCD memory stick was successfully created
goto _end

:_help
echo.
echo UBCD2USB: Create a bootable UBCD memory stick
echo.
echo Usage:    UBCD2USB (UBCD-path) (USB-drive) [/f]
echo.
echo Examples: UBCD2USB e: x:
echo           (UBCD-CDROM in 'E:', USB-key in 'X:',
echo           do not format target 'X:')
echo.
echo           UBCD2USB "c:\ubcd-extracted" x: /f
echo           (UBCD extracted in dir 'c:\ubcd-extracted',
echo           USB-key in 'X:', format target 'X:')
echo.
echo Requires: W2K/XP/W2K3/Vista/W2K8/W7 and an (optionally extracted) UBCD
echo. 
echo Note:     1) Under Vista/W7, if you are not login as administrator, you
echo           will need to right-click on this script file and select
echo           "Run as administrator" to launch it with the proper rights.
echo.
echo           2) Optionally format the USB memory stick with Windows or
echo           RMPrepUSB before running this script.      
cmd.exe /k pushd "%~dp0"
goto _end

:_error
shift
shift
echo (ERROR) %1 %2 %3 %4 %5 %6 %7 %8
goto _end

:_end
endlocal
