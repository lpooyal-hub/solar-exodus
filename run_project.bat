@echo off
REM Run Solar Exodus with the local Godot 4.6.3 editor.
SET "GODOT_EXE=D:\godot\Godot_v4.6.3-stable_win64_console.exe"
IF NOT EXIST "%GODOT_EXE%" (
    echo Godot executable not found at %GODOT_EXE%
    pause
    exit /b 1
)
SET "PROJECT_DIR=%~dp0."
echo Running %GODOT_EXE% --path "%PROJECT_DIR%" --scene "res://scenes/world/world.tscn"
"%GODOT_EXE%" --path "%PROJECT_DIR%" --scene "res://scenes/world/world.tscn"
if %ERRORLEVEL% NEQ 0 pause
