echo off
rem upload_hex.bat
rem
rem This batch file (the windows equivalent of a shell script) uploads a .hex file to the
rem ATmega2560 board. You may need to change the path to the avrdude.exe
rem program, as well as the PORT variable (which may be any value from COM1 - COM6 depending
rem on your machine).
rem
rem B. Bird - 07/15/2018

set PORT=COM4
set INPUTFILE=%1
for /F %%i in ("%INPUTFILE%") do set DRIVE=%%~di 
for /F %%i in ("%INPUTFILE%") do set DRIVEPATH=%%~pi 
for /F %%i in ("%INPUTFILE%") do set HEXFILENAME=%%~ni.hex
%DRIVE%
cd %DRIVEPATH%
"C:\Program Files (x86)\Arduino\hardware\tools\avr\bin\avrdude.exe" -C "C:\Program Files (x86)\Arduino\hardware\tools\avr\etc\avrdude.conf" -p atmega2560 -c wiring -P %PORT% -b 115200 -D -F -U flash:w:%HEXFILENAME%


rem If you want the window to close automatically, add "rem " before the following line
pause