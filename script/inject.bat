@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ============================================================
REM inject.bat
REM
REM Static DLL injection helper using setdll.exe
REM
REM Behavior:
REM - Can be executed from any working directory
REM - Resolves paths relative to inject.bat
REM - Copies the DLL into the target executable directory
REM - Changes directory to the target executable directory
REM - Uses relative paths for setdll.exe invocation
REM - Restores the original working directory on exit
REM
REM Usage:
REM   inject.bat <target_exe_path>
REM
REM Example:
REM   inject.bat "C:\Path\To\app_demo.exe"
REM ============================================================

REM ------------------------------------------------------------
REM Argument validation
REM ------------------------------------------------------------
if "%~1"=="" (
echo Usage:
echo     inject.bat ^<target_exe_path^>
echo.
echo Example:
echo     inject.bat "C:\Path\To\app_demo.exe"
exit /b 1
)

REM ------------------------------------------------------------
REM Resolve script directory (location-independent)
REM ------------------------------------------------------------
set SCRIPT_DIR=%~dp0

REM ------------------------------------------------------------
REM Tool and DLL paths (relative to inject.bat)
REM ------------------------------------------------------------
set SETDLL_EXE=%SCRIPT_DIR%..\tools\setdll.exe
set DLL_SRC=%SCRIPT_DIR%..\release\dll_detours_hook.dll

REM ------------------------------------------------------------
REM Resolve target executable
REM ------------------------------------------------------------
set TARGET_EXE_PATH=%~1
set TARGET_DIR=%~dp1
set TARGET_EXE=%~nx1

REM ------------------------------------------------------------
REM Validation checks
REM ------------------------------------------------------------
if not exist "%TARGET_EXE_PATH%" (
echo [!] Error: Target executable not found:
echo     %TARGET_EXE_PATH%
exit /b 1
)

if not exist "%DLL_SRC%" (
echo [!] Error: Source DLL not found:
echo     %DLL_SRC%
exit /b 1
)

if not exist "%SETDLL_EXE%" (
echo [!] Error: setdll.exe not found:
echo     %SETDLL_EXE%
exit /b 1
)

REM ------------------------------------------------------------
REM Status output
REM ------------------------------------------------------------
echo.
echo [*] Static DLL Injection
echo [*] Target directory : %TARGET_DIR%
echo [*] Target executable: %TARGET_EXE%
echo [*] Source DLL       : %DLL_SRC%
echo.

REM ------------------------------------------------------------
REM Enter target directory
REM ------------------------------------------------------------
pushd "%TARGET_DIR%"
if errorlevel 1 (
echo [!] Error: Failed to change to target directory
exit /b 1
)

REM ------------------------------------------------------------
REM Copy DLL into target directory
REM ------------------------------------------------------------
echo [*] Copying DLL to target directory...
copy /Y "%DLL_SRC%" ".\dll_detours_hook.dll" >nul
if errorlevel 1 (
echo [!] Error: Failed to copy DLL
popd
exit /b 1
)

REM ------------------------------------------------------------
REM Perform injection (relative paths only)
REM ------------------------------------------------------------
echo [*] Injecting DLL...
"%SETDLL_EXE%" /d:"dll_detours_hook.dll" "%TARGET_EXE%"
if errorlevel 1 (
echo [!] Error: Injection failed
popd
exit /b 1
)

REM ------------------------------------------------------------
REM Restore original working directory
REM ------------------------------------------------------------
popd

echo.
echo [+] Injection completed successfully
exit /b 0
