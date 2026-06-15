@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ============================================================
:: DJH Folder Tree Size Lister
:: Version        : v1.0
:: Author         : DJH
:: Creation Date  : 2026-06-15
:: Encoding       : UTF-8 (Code Page 65001)
:: Purpose        : Recursively list folders/files with size report
:: Output         : Timestamped TXT file with tree structure
:: ============================================================

:: Ask for folder path
set /p folder="Enter the full folder path to list: "

:: Validate folder path
if not exist "%folder%" (
    echo Folder does not exist!
    pause
    exit /b
)

:: Create output file with timestamp
for /f "tokens=1-6 delims=:-/ " %%a in ("%date% %time%") do (
    set timestamp=%%a%%b%%c-%%d%%e%%f
)
set output=FileList_!timestamp!.txt

:: Start writing
echo Listing for %folder% > "%output%"
echo. >> "%output%"

:: Recursive function to list files and folders
call :ListFolder "%folder%" 0

echo Done! Output saved to "%output%"
pause
exit /b

:: ============================================================
:: Function: ListFolder
:: Purpose : Recursively scans directories and calculates sizes
:: ============================================================
:ListFolder
set "currentFolder=%~1"
set "level=%~2"

:: Indentation for tree structure
set "indent="
for /l %%i in (1,1,%level%) do set "indent=!indent!    "

:: Initialize folder size accumulator
set /a folderSize=0

:: ------------------------------------------------------------
:: List files in current folder with size in MB
:: ------------------------------------------------------------
for %%F in ("%currentFolder%\*") do (
    if exist "%%F" (
        if not exist "%%F\" (
            set "size=%%~zF"
            set /a folderSize+=size
            set /a mb=size/1048576
            if !mb! lss 1 set mb=1
            echo !indent!    %%~nxF [!mb! MB] >> "%output%"
        )
    )
)

:: ------------------------------------------------------------
:: Recurse into subfolders
:: ------------------------------------------------------------
for /d %%D in ("%currentFolder%\*") do (
    if exist "%%D\" (
        call :ListFolder "%%D" !level!+1
        set /a folderSize+=subFolderSize
    )
)

:: Convert total size to MB
set /a folderMB=folderSize/1048576
if !folderMB! lss 1 set folderMB=1

:: Write folder total size
echo !indent!!currentFolder! [Total: !folderMB! MB] >> "%output%"

:: Return size to parent call
set subFolderSize=!folderSize!
exit /b
