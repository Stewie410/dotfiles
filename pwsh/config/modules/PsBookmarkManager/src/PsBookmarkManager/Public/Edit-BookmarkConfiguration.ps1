<#
.SYNOPSIS
Open configuration file in a text editor

.DESCRIPTION
Open configuration file in a text editor, by default notepad.exe; prefer $env:EDITOR if defined.

.PARAMETER Path
Path to the configuration file, if none provided assume default path(s).

.PARAMETER Editor
Open file in specified editor, if none provided assume $env:EDITOR or notepad.exe

.EXAMPLE
PS> Edit-BookmarkConfiguration

Open the default configuration file in $env:EDITOR or notepad.exe

.EXAMPLE
PS> Edit-BookmarkConfiguration -Editor nvim.exe

Open the default configuration file in nvim.exe

.EXAMPLE
PS> Edit-BookmarkConfiguration -Path .\config.rc
PS> Edit-BookmarkConfiguration .\config.rc

Open the config file '.\config.rc' in $env:EDITOR or notepad.exe

.EXAMPLE
PS> Edit-BookmarkConfiguration -Path .\config.rc -Editor nvim.exe
PS> Edit-BookmarkConfiguration .\config.rc -Editor nvim.exe

Open the config file '.\config.rc' in nvim.exe

.COMPONENT
PsBookmarkManager
#>
function Edit-BookmarkConfiguration {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [ValidateScript({ Test-ConfigPath $_ })]
        [string]
        $Config = (Get-DefaultConfigPath),

        [Parameter()]
        [ValidateScript({ Get-Command -Name $_ })]
        [string]
        $Editor = (Get-TextEditor)
    )

    & $Editor "$Config"
}