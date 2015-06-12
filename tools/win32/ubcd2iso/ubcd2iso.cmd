@echo off

rem * Create a bootable UBCD ISO image
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
if "%a2%"=="" for %%f in (dummy) do set a2=%%~df\%VOLUME_ID%-custom.iso

set BOOTLOADER="boot/grub/grldr"
if "%a3%"=="" set BOOTLOADER="boot/syslinux/isolinux.bin"

echo UBCD2ISO: Creating bootable UBCD ISO image ...

if not exist "%~p0\..\unxutils\bin\mkisofs.exe" %0 : _error Missing file '%~p0\..\unxutils\bin\mkisofs.exe'
if not exist "%a1%\boot\syslinux\isolinux.bin"  %0 : _error Missing file '%a1%\boot\syslinux\isolinux.bin'
if not exist "%a1%\boot\grub\grldr"  %0 : _error Missing file '%a1%\boot\grub\grldr'

del "%a1%\boot\syslinux\boot.catalog" 2> NUL
rmdir /q /s "%a1%\[BOOT]" 2> NUL
rmdir /q /s "%a1%\boot.images" 2> NUL

rem * mkisofs manpage: http://linux.die.net/man/8/mkisofs
rem *
rem * -iso-level 4: Required for Win2K/XP booting to work
rem * -l: Allow full 31 character ISO9660 filenames
rem * -r: Rock Ridge Interchange Protocol allows Unix long filenames up to 255 bytes
rem * -J -joliet-long: Joliet extension allows Windows long filenames up to 103 Unicode chars
rem * -D: Disable deep directory relocation
rem *
rem * Note: UBCD2ISO_ARGS is used to pass user-specific arguments to mkisofs without modifying the script

pushd "%a1%"
"%~p0\..\unxutils\bin\mkisofs.exe" -iso-level 4 -l -r -J -joliet-long -D -V %VOLUME_ID% -o "%a2%" -b %BOOTLOADER% -c "boot/syslinux/boot.catalog" -hide "boot/syslinux/boot.catalog" -hide-joliet "boot/syslinux/boot.catalog" %UBCD2ISO_ARGS% -no-emul-boot -boot-load-size 4 -boot-info-table .
popd
if errorlevel 0 goto _success
%0 : _error 'mkisofs.exe' failed

:_success
echo UBCD2ISO: '%a2%' was successfully created
goto _end

:_help
echo.
echo UBCD2ISO: Create bootable UBCD ISO image
echo.
echo Usage:    UBCD2ISO (UBCD-path) [output-image] [/g]
echo           (/g: use grub4dos as the bootloader)
echo.
echo Example:  UBCD2ISO "c:\ubcd-extracted" "c:\%VOLUME_ID%-custom.iso"
echo           (UBCD extracted in dir 'c:\ubcd-extracted',
echo            ISO image written to 'c:\%VOLUME_ID%-custom.iso')
echo.
echo Requires: W2K/XP/W2K3/Vista/W2K8/W7 and UBCD extracted to local storage
cmd.exe /k pushd "%~dp0"
goto _end

:_error
shift
shift
echo (ERROR) %1 %2 %3 %4 %5 %6 %7 %8
goto _end

:_end
ENDLOCAL
