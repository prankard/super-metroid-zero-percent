@echo off
echo %cd%
cd %cd%

:: Config
SET ASAR=tools\asar171\asar.exe
SET FLOATING_IPS=tools\flips.exe

:: Copy
md build
xcopy /y rom.sfc build

for %%f in (src/*.asm) do (
    echo src/%%f
    %ASAR% src/%%f build/rom.sfc
)

for %%f in (ips/*.ips) do (
    echo ips/%%f
    %FLOATING_IPS% ips/%%f build/rom.sfc
)

pause