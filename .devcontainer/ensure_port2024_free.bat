@echo off
REM ensure_port2024_free.bat
REM Usage: ensure_port2024_free.bat [--yes]
REM Checks whether host port 2024 is free and stops/removes Docker containers using it.

setlocal enabledelayedexpansion
set AUTO_YES=0
if "%1"=="--yes" set AUTO_YES=1

REM Check if port 2024 is in use
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :2024') do set PID=%%a
if defined PID (
    echo ERROR: Host port 2024 is already in use by process ID %PID%.
    echo Please stop that process before proceeding.
    exit /b 2
) else (
    echo Host port 2024 is free. Checking Docker containers for mappings to container port 2024...
)

REM Check Docker containers for port 2024 mapping
for /f "tokens=1,2,3* delims= " %%a in ('docker ps --format "{{.ID}} {{.Names}} {{.Ports}}"') do (
    echo %%d | findstr /C:"->2024" >nul && (
        echo Found container publishing to container port 2024: %%a %%b %%c %%d
        set FOUND=1
        set CONTAINERS=!CONTAINERS! %%a
    )
)
if not defined FOUND (
    echo No Docker containers are publishing container port 2024. You're good to rebuild the devcontainer.
    exit /b 0
)

if %AUTO_YES%==0 (
    set /p ans=Stop and remove these containers so the devcontainer can bind host:2024? [y/N] 
    if /i not "%ans%"=="y" if /i not "%ans%"=="Y" (
        echo Aborting. Stop/remove containers manually or re-run with --yes to force.
        exit /b 3
    )
)

for %%c in (%CONTAINERS%) do (
    echo Stopping container %%c...
    docker stop %%c
    echo Removing container %%c...
    docker rm %%c
)

echo Containers removed. Host port 2024 should now be available for Docker to publish as 2024:2024 when VS Code recreates the devcontainer.
exit /b 0
