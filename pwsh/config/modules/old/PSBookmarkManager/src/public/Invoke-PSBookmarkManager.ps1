<#
    .SYNOPSIS
    Wrapper for PSBookmarkManager functions

    .DESCRIPTION
    Wrapper for PSBookmarkManager functions

    .PARAMETER Config
    Configuration file path

    .PARAMETER CD
    Set-Location to bookmark path

    .PARAMETER Push
    Push-Location to bookmark path

    .PARAMETER Set
    Add/Update bookmark

    .PARAMETER Remove
    Remove bookmark

    .PARAMETER List
    Get configuration as hashtable

    .PARAMETER Edit
    Open configuration file in a text editor

    .PARAMETER Name
    Bookmark name

    .PARAMETER Path
    Bookmark path

    .PARAMETER Editor
    Text editor

    .INPUTS
    System.String
    System.Collections.Hashtable

    .OUTPUTS
    System.Collections.Hashtable
#>
function Invoke-PSBookmarkManager {
    [Alias('bm')]
    [CmdletBinding(DefaultParameterSetName = 'cd')]
    param(
        [Parameter()]
        [ValidateScript({ Test-PSBMConfigPath $_ })]
        [string]
        $Config = (Get-PSBMDefaultConfigPath),

        [Parameter(ParameterSetName = 'cd')]
        [switch]
        $CD,

        [Parameter(Mandatory, ParameterSetName = 'push')]
        [switch]
        $Push,

        [Alias('Add', 'Update')]
        [Parameter(Mandatory, ParameterSetName = 'set')]
        [switch]
        $Set,

        [Parameter(Mandatory, ParameterSetName = 'remove')]
        [switch]
        $Remove,

        [Parameter(Mandatory, ParameterSetName = 'list')]
        [switch]
        $List,

        [Parameter(Mandatory, ParameterSetName = 'edit')]
        [switch]
        $Edit,

        [Parameter(Mandatory, Position = 0, ParameterSetName = 'cd')]
        [Parameter(Mandatory, Position = 0, ParameterSetName = 'push')]
        [Parameter(Mandatory, Position = 0, ParameterSetName = 'set')]
        [Parameter(Mandatory, Position = 0, ParameterSetName = 'remove')]
        [string]
        $Name,

        [Parameter(Mandatory, Position = 1, ParameterSetName = 'set')]
        [ValidateScript({ Test-PSBMIsDirectory $_ })]
        [string]
        $Path,

        [Parameter(ParameterSetName = 'edit')]
        [ValidateScript({ Get-Command -Command $_ -ErrorAction Stop })]
        [string]
        $Editor = "$(if ($null -ne $env:EDITOR) { $env:EDITOR } else { 'notepad.exe' })"
    )

    if (!(Test-Path -Path $Config -PathType Leaf)) {
        New-Item -Path $Config -ItemType File -Force
    }

    switch ($PSCmdlet.ParameterSetName) {
        'cd' {
            Set-PSBMLocation -Config $Config -Name $Name
        }

        'push' {
            Push-PSBMLocation -Config $Config -Name $Name
        }

        'list' {
            Get-PSBMConfiguration -Config $Config
        }

        'set' {
            Set-PSBMBookmark -Config $Config -Name $Name -Path $Path
        }

        'remove' {
            Remove-PSBMBookmark -Config $Config -Name $Name
        }

        'edit' {
            Edit-PSBMConfiguration -Config $Config -Editor $Editor
        }
    }
}
