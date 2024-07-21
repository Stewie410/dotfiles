<#
.SYNOPSIS
Remove one or more bookmarks

.DESCRIPTION
Remove one or more bookmarks from configuration file

.PARAMETER Path
Specify path to configuration file, if not specified will assume default path

.PARAMETER Name
Bookmark name(s)

.EXAMPLE
PS> Remove-Bookmark -Name dev
PS> Remove-Bookmark dev

Remove the 'dev' bookmark from the default configuration file

.EXAMPLE
PS> Remove-Bookmark -Config .\config.rc -Name dev
PS> Remove-Bookmark -Config .\config.rc dev

Remove the 'dev' bookmark from the '.\config.rc' configuration file

.EXAMPLE
PS> Remove-Bookmark -Name dev,test,prod
PS> Remove-Bookmark dev,test,prod

Remove the 'dev', 'test' & 'prod' bookmarks from the default configuration file

.EXAMPLE
PS> Remove-Bookmark -Path .\config.rc -Name dev,test,prod
PS> Remove-Bookmark -Path .\config.rc dev,test,prod

Remove the 'dev', 'test' & 'prod' bookmarks from the '.\config.rc' configuration file

.COMPONENT
PsBookmarkManager
#>
function Remove-Bookmark {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateScript({ Test-ConfigPath $_ })]
        [string]
        $Path,

        [Parameter(Mandatory, Position = 0)]
        [ValidateScript({ $_ -as [string[]] })]
        [string[]]
        $Name
    )

    $config = Get-BookmarkConfiguration -Path $Path

    foreach ($key in $Name) {
        if ($config.Keys -notcontains $key) {
            Write-Warning -Message "Bookmark is not defined: $key"
            continue
        }

        $config.Remove($key)
    }

    Set-BookmarkConfiguration -Path $Path -Bookmarks $config
}