@echo off
setlocal

REM Check if curl is installed
where curl >nul 2>nul
if errorlevel 1 (
    echo curl is not installed. 
    call :install_curl_options
    exit /b
)

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
echo Curl has been installed to C:\curl.

REM Automatically add C:\curl\bin to the PATH environment variable
set "curl_bin_path=C:\curl\bin"
powershell -Command "[System.Environment]::SetEnvironmentVariable('Path', $env:Path + ';%curl_bin_path%', [System.EnvironmentVariableTarget]::Machine)"
echo C:\curl\bin has been added to your PATH environment variable.

echo Please restart the script to continue.
pause

REM Restart the script
powershell -Command "Start-Process -FilePath 'powershell.exe' -ArgumentList '-File %~f0' -Verb RunAs"
exit /b

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
    echo No URL provided for download. Exiting ...
    echo...
    pause
    exit /b
)

echo Downloading %OUTPUT% from %URL%...
powershell -Command "Invoke-WebRequest -Uri %URL% -OutFile %OUTPUT%" 2>nul
if errorlevel 1 (
    echo PowerShell failed to download %OUTPUT%. Trying curl...
    curl -L -o %OUTPUT% %URL%
    if errorlevel 1 (
        echo Error downloading %OUTPUT%. Please check the URL.
        pause
        exit /b
    )
)

echo Installing %OUTPUT%...
if defined SILENT_ARGS (
    start /wait "" "%OUTPUT%" %SILENT_ARGS%
) else (
    start /wait "" "%OUTPUT%"
)

echo %OUTPUT% has been installed successfully.
del "%OUTPUT%"
exit /b

REM Main script execution
echo Checking for installed software...

REM Function to prompt for installation or skip
:prompt_install_or_skip
set "APP_NAME=%~1"
set "APP_URL=%~2"
set "APP_OUTPUT=%~3"
set "APP_ARGS=%~4"

echo Do you want to install %APP_NAME%? (Y/N/Skip)
set /p user_choice="Choose an option (Y/N/Skip): "

if /I "%user_choice%"=="Y" (
    call :install_software "%APP_URL%" "%APP_OUTPUT%" "%APP_ARGS%"
) else if /I "%user_choice%"=="N" (
    echo Skipping %APP_NAME% installation.
) else if /I "%user_choice%"=="Skip" (
    echo Skipping %APP_NAME% installation.
) else (
    echo Invalid choice. Please enter Y, N, or Skip.
    goto prompt_install_or_skip %APP_NAME% %APP_URL% %APP_OUTPUT% %APP_ARGS%
)

call :prompt_install_or_skip "Notepad++" "%NPP_URL%" "%NPP_OUTPUT%" "/S"
call :prompt_install_or_skip "Steam" "%STEAM_URL%" "%STEAM_OUTPUT%" "/S"
call :prompt_install_or_skip "Epic Games Launcher" "%EPIC_URL%" "%EPIC_OUTPUT%" "/quiet"
call :prompt_install_or_skip "Rockstar Games Launcher" "%ROCKSTAR_URL%" "%ROCKSTAR_OUTPUT%" "/S"
call :prompt_install_or_skip "Ubisoft Connect" "%UBISOFT_URL%" "%UBISOFT_OUTPUT%" "/S"
call :prompt_install_or_skip "EA App" "%EA_URL%" "%EA_OUTPUT%" "/S"
call :prompt_install_or_skip "WinRAR" "%WINRAR_URL%" "%WINRAR_OUTPUT%" "/S"

echo All software installations are complete.
pause
exit /b
