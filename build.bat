@echo off
echo %cd%
cd %cd%

:: User Config
SET ASAR=tools\asar171\asar.exe
SET FLOATING_IPS=tools\flips.exe

:: FileConfig
SET VERSION=0.8.1
SET FILENAME=Super_Metroid_Zero-Percent-%VERSION%.sfc

:: Copy
::md build
copy "./rom.sfc" "./build/%FILENAME%"

for %%f in (src/*.asm) do (
    echo src/%%f
    %ASAR% src/%%f build/%FILENAME%
)

for %%f in (ips/*.ips) do (
    echo ips/%%f
    %FLOATING_IPS% ips/%%f build/%FILENAME%
)

pause