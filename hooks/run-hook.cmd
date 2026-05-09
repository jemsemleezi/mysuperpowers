: << 'CMDBLOCK'
@echo off
REM Cross-platform polyglot wrapper for hook scripts.
REM On Windows: cmd.exe runs the batch portion, which finds and calls bash.
REM On Unix: the shell interprets this as a script (: is a no-op in bash).
REM
REM Hook scripts use extensionless filenames (e.g. "session-start" not
REM "session-start.sh") so Claude Code's Windows auto-detection -- which
REM prepends "bash" to any command containing .sh -- doesn't interfere.
REM
REM Usage: run-hook.cmd <script-name> [args...]

REM Check if a hook script name was passed as the first argument
if "%~1"=="" (
    echo run-hook.cmd: missing script name >&2
    exit /b 1
)

REM Get the directory containing this batch file (trailing backslash included)
set "HOOK_DIR=%~dp0"

REM Try Git for Windows bash from the standard 64-bit install location
if exist "C:\Program Files\Git\bin\bash.exe" (
    "C:\Program Files\Git\bin\bash.exe" "%HOOK_DIR%%~1" %2 %3 %4 %5 %6 %7 %8 %9
    exit /b %ERRORLEVEL%
)
REM Try Git for Windows bash from the standard 32-bit install location
if exist "C:\Program Files (x86)\Git\bin\bash.exe" (
    "C:\Program Files (x86)\Git\bin\bash.exe" "%HOOK_DIR%%~1" %2 %3 %4 %5 %6 %7 %8 %9
    exit /b %ERRORLEVEL%
)

REM Try bash from PATH (covers user-installed Git Bash, MSYS2, Cygwin, WSL)
where bash >nul 2>nul
if %ERRORLEVEL% equ 0 (
    bash "%HOOK_DIR%%~1" %2 %3 %4 %5 %6 %7 %8 %9
    exit /b %ERRORLEVEL%
)

REM No bash found — exit silently instead of erroring
REM The plugin still works, just without SessionStart context injection
exit /b 0
CMDBLOCK  # End of batch portion; below is the Unix shell polyglot portion

# Unix: run the named script directly via bash
# Resolve absolute path to the hooks/ directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# Extract the hook script name (first argument)
SCRIPT_NAME="$1"
# Remove script name from $@, leaving only hook arguments
shift
# Replace current process with bash running the target hook script
exec bash "${SCRIPT_DIR}/${SCRIPT_NAME}" "$@"
