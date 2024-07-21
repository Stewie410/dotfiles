<#
.SYNOPSIS
Push-Location to bookmark's path

.DESCRIPTION
Push-Location to bookmark's path

.PARAMETER Path
Specify path to configuration file, if not specified will assume default path

.PARAMETER Name
Bookmark name

.EXAMPLE
PS> Push-BookmarkLocation -Name dev
PS> Push-BookmarkLocation dev

Push-Location to the 'dev' bookmark

.EXAMPLE
PS> Push-BookmarkLocation -Path .\config.rc -Name dev
PS> Push-BookmarkLocation -Path .\config.rc dev

Push-Location to the 'dev' bookmark in the .\config.rc configuration file

.COMPONENT
PsBookmarkManager
#>
function Push-BookmarkLocation {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateScript({ Test-ConfigPath $_ })]
        [string]
        $Path = (Get-DefaultConfigPath),

        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty]
        [string]
        $Name
    )

    $result = (Get-BookmarkConfiguration -Path $Path)[$Name]

    if (!$result) {
        Write-Warning -Message "Bookmark is not defined: $Name"
        return
    }

    Push-Location -Path $result
}