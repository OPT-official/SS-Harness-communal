@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
title OPT Archive Sync
cd /d "%~dp0"

echo ============================================
echo   OPT Archive - Upload
echo ============================================
echo.

REM ---- find git bash.exe (auto-detect) ----
set "BASH="
for %%P in (
  "%ProgramFiles%\Git\bin\bash.exe"
  "%ProgramFiles(x86)%\Git\bin\bash.exe"
  "%LocalAppData%\Programs\Git\bin\bash.exe"
) do (
  if exist "%%~P" if not defined BASH set "BASH=%%~P"
)
REM fallback: search PATH
if not defined BASH (
  for /f "delims=" %%G in ('where bash 2^>nul') do (
    if not defined BASH set "BASH=%%G"
  )
)
if not defined BASH (
  echo [ERROR] git bash.exe not found. Install Git for Windows.
  echo.
  pause
  exit /b 1
)

echo  Before running:
echo   1) Put .pptx files into the semester folder
echo   2) Close LibreOffice if it is open
echo.
set /p SEM=Semester folder (e.g. 2026-fall):

if "%SEM%"=="" (
  echo.
  echo [Cancelled] No folder name.
  echo.
  pause
  exit /b
)

echo.
echo --- running: sync.sh %SEM% ---
echo.
"%BASH%" sync.sh "%SEM%"

echo.
echo ============================================
echo  Done. Press any key to close.
echo ============================================
pause >nul
