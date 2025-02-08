@echo off
setlocal

REM Function to display curl installation options
:install_curl_options
cls
echo ===========================
echo      Curl Installation
echo ===========================
echo Please select the version of curl to install:
echo 1. Win64 ARM64 (https://curl.se/windows/latest.cgi?p=win64-mingw.zip)
echo 2. Win64 (https://curl.se/windows/latest.cgi?p=win64a-mingw.zip)
echo 3. Win32 (https://curl.se/windows/latest.cgi?p=win32-mingw.zip)
echo 4. Exit
echo ===========================
set /p curl_choice="Choose an option (1-4): "

if "%curl_choice%"=="1" (
    set "curl_url=https://curl.se/windows/latest.cgi?p=win64-mingw.zip"
    set "curl_output=curl-win64-mingw.zip"
) else if "%curl_choice%"=="2" (
    set "curl_url=https://curl.se/windows/latest.cgi?p=win64a-mingw.zip"
    set "curl_output=curl-win64a-mingw.zip"
) else if "%curl_choice%"=="3" (
    set "curl_url=https://curl.se/windows/latest.cgi?p=win32-mingw.zip"
    set "curl_output=curl-win32-mingw.zip"
) else (
    exit /b
)

echo Downloading curl from %curl_url%...
powershell -Command "Invoke-WebRequest -Uri %curl_url% -OutFile %curl_output%" 2>nul
if errorlevel 1 (
    echo Error downloading curl. Please check the URL.
    pause
    exit /b
)

echo Extracting curl...
powershell -Command "Expand-Archive -Path %curl_output% -DestinationPath C:\curl; Remove-Item %curl_output%"
echo Curl has been installed to C:\curl. Please add C:\curl\bin to your PATH environment variable.

echo Please restart the script to continue.
pause
powershell -Command "Start-Process -FilePath 'powershell.exe' -ArgumentList '-File %~f0' -Verb RunAs"
exit /b

REM Check if curl is installed
where curl >nul 2>nul
if errorlevel 1 (
    echo curl is not installed. 
    call :install_curl_options
)

REM Define URLs for the installers
set "NPP_URL=https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.7.7/npp.8.7.7.Installer.x64.exe"
set "STEAM_URL=https://cdn.fastly.steamstatic.com/client/installer/SteamSetup.exe"
set "EPIC_URL=https://launcher-public-service-prod06.ol.epicgames.com/launcher/api/installer/download/EpicGamesLauncherInstaller.msi"
set "ROCKSTAR_URL=https://gamedownloads.rockstargames.com/public/installer/Rockstar-Games-Launcher.exe"
set "UBISOFT_URL=https://ubi.li/4vxt9"
set "EA_URL=https://origin-a.akamaihd.net/EA-Desktop-Client-Download/installer-releases/EAappInstaller.exe"
set "WINRAR_URL=https://www.win-rar.com/fileadmin/winrar-versions/winrar/winrar-x64-701.exe"

REM Define output file names
set "NPP_OUTPUT=NotepadPlusPlusInstaller.exe"
set "STEAM_OUTPUT=SteamSetup.exe"
set "EPIC_OUTPUT=EpicGamesLauncherInstaller.msi"
set "ROCKSTAR_OUTPUT=RockstarGamesLauncher.exe"
set "UBISOFT_OUTPUT=UbisoftConnectInstaller.exe"
set "EA_OUTPUT=EAappInstaller.exe"
set "WINRAR_OUTPUT=WinRARInstaller.exe"

REM Function to download and install software
:install_software
set "URL=%~1"
set "OUTPUT=%~2"
set "SILENT_ARGS=%~3"

REM Check if URL is empty
if "%URL%"=="" (
    echo No URL provided for download. Exiting...
    pause
    exit /b
)

echo Downloading %OUTPUT% from %URL%...
powershell -Command "Invoke-WebRequest -Uri %URL% -OutFile %OUTPUT%" 2>nul
if errorlevel 1 (
    echo PowerShell failed to download %OUTPUT%. Trying curl...
    curl -L -o %OUTPUT% %URL% 2>nul
    if errorlevel 1 (
        echo Error downloading %OUTPUT% using curl. Please check the URL.
        pause
        exit /b
    )
)

if exist %OUTPUT% (
    echo Download completed successfully.
    
    echo Installing %OUTPUT%...
    if defined SILENT_ARGS (
        start /wait %OUTPUT% %SILENT_ARGS%
    ) else (
        start /wait %OUTPUT%
    )
    
    echo Installation completed.
) else (
    echo Download failed for %OUTPUT%. Please check the URL.
)

REM Clean up
del %OUTPUT% 2>nul
exit /b

REM Function to display menu
:menu
cls
echo ===========================
echo      Software Installer
echo ===========================
echo 1. Notepad++
echo 2. Steam
echo 3. Epic Games Launcher
echo 4. Rockstar Games Launcher
echo 5. Ubisoft Connect
echo 6. EA App
echo 7. WinRAR
echo 8. Exit
echo ===========================
set /p app_choice="Choose an application to install (1-8): "

REM Set the URL and output file based on user choice
if "%app_choice%"=="1" (
    set "SELECTED_URL=%NPP_URL%"
    set "SELECTED_OUTPUT=%NPP_OUTPUT%"
) else if "%app_choice%"=="2" (
    set "SELECTED_URL=%STEAM_URL%"
    set "SELECTED_OUTPUT=%STEAM_OUTPUT%"
) else if "%app_choice%"=="3" (
    set "SELECTED_URL=%EPIC_URL%"
    set "SELECTED_OUTPUT=%EPIC_OUTPUT%"
) else if "%app_choice%"=="4" (
    set "SELECTED_URL=%ROCKSTAR_URL%"
    set "SELECTED_OUTPUT=%ROCKSTAR_OUTPUT%"
) else if "%app_choice%"=="5" (
    set "SELECTED_URL=%UBISOFT_URL%"
    set "SELECTED_OUTPUT=%UBISOFT_OUTPUT%"
) else if "%app_choice%"=="6" (
    set "SELECTED_URL=%EA_URL%"
    set "SELECTED_OUTPUT=%EA_OUTPUT%"
) else if "%app_choice%"=="7" (
    set "SELECTED_URL=%WINRAR_URL%"
    set "SELECTED_OUTPUT=%WINRAR_OUTPUT%"
) else (
    exit /b
)

call :install_software "%SELECTED_URL%" "%SELECTED_OUTPUT%"
goto menu
