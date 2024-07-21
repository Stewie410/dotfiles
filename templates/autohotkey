; description

#SingleInstance Force
#Persistent
#NoEnv
#Warn All, Off

SetWorkingDir, %A_ScriptDir%
FileEncoding UTF-8
DetectHiddenWindows, On
SendMode, Input
SetBatchLines, -1
SetWinDelay, -1
SetControlDelay, -1

OnExit("cleanup")

init()
main()
return

*Esc::ExitApp

makAdmin() {
    if (A_IsAdmin || DllCall("GetCommandLine", "str") ~= " /restart(?!\S)")
        return

    try {
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" /restart
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
    }

    ExitApp
}

init() {
    global log_file := A_ScriptFullPath "\" A_YYYY "\" A_MM "\" A_DD ".log"
    return
}

log(caller, message) {
    global log_file
    stamp := A_YYYY "-" A_MM "-" A_DD "T" A_Hour ":" A_Min ":" A_Sec
    entry := stamp "|" caller "|" message

    OutputDebug, Text
    FileAppend, %entry%`n, %log_file%
}

stdout(command) {
    hist := ClipboardAll
    RunWait, %ComSpec% /q /c %cmd% | clip,,Hide
    out := Clipboard
    Clipboard := hist
    return out
}

stderr(command) {
    hist := ClipboardAll
    RunWait, %ComSpec% /q /c %cmd% 2>&1 | clip,,Hide
    out := Clipboard
    Clipboard := hist
    return out
}

main() {
    return
}
