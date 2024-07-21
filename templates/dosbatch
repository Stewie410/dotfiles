:: description

:: env
@echo off
setlocal EnableExtensions EnableDelayedExpansion

:: globals
set "log=!USERPROFILE!\.log\scripts\%~n0.log"
set "callers=%~nx0"

:: run
call :func :main %*
if not "!err!."=="." (
    call :func :notify "!err!"
    exit /b 1
)
exit /b 0

:: infrastructure
:func <label> [arg [arg ...]]
    set "callers=%1`!callers!"
    call %*
    set "callers=!callers:*`=!"
exit /b

:main
    set "_gather="
    set "remaining="

    for %%a in (%*) do (
        if defined remaining (
            set "remaining=!remaining! %%a"
        ) else if defined _gather (
            set "!_gather!=%%~a"
            set "_gather"
        ) else (
            set "_"="%%~a"
            if "!_!"=="--" (
                set "remaining="
            ) else if "!_:~0,2!"=="--" (
                set "_=!_:~2!"
                if "!_!"=="help" (
                    call :show_help
                    exit /b 0
                )
            ) else if "!_:~0,1!"=="-" (
                set "_=!_:~1!"
                if "!_!"=="h" (
                    call :show_help
                    exit /b 0
                )
            ) else (
                1>&2 echo(ERROR: Unexpected argument: %%~a
            )
        )
    )
    set "_gather="

    call :mkparent "!log!"
    copy nul "!log!"
exit /b

:mkparent <path>
    md "%~dp1"
exit /b

:log <message>
    for /F "delims=`" %%a in ("!callers!") do set "_name=%%a"
    echo(!name:~0,20!^|%*
    >> "!log!" echo(!date:~10,2!-!date:~7,2!-!date:~4,2!T!time!^|!_name:~0,20!^|%*
exit /b

:show_help
    echo(description
    echo(
    echo(USAGE: %~nx0 [OPTIONS]
    echo(
    echo(OPTIONS:
    echo(    -h, --help                Show this help message
exit /b

:: function
