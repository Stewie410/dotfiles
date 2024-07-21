<#
.SYNOPSIS
Get configuration file content as a hashtable

.DESCRIPTION
Get configuration file content as a hashtable (bookmark: path)

.PARAMETER Path
Specify the configuration file path, if none provided assume default paths

.OUTPUTS
System.Collections.Hashtable

.EXAMPLE
PS> Get-BookmarkConfiguration

Get contents of the default configuration file path as a hashtable, if it exists

.EXAMPLE
PS> Get-BookmarkConfiguration -Path .\config.rc
PS> Get-BookmarkConfiguration .\config.rc

Get the contents of .\config.rc as a hashtable, if it exists

.COMPONENT
PsBookmarkManager
#>
function Get-BookmarkConfiguration {
    [Alias('Get-Bookmarks')]
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [ValidateScript({ Test-ConfigPath $_ })]
        [string]
        $Path = (Get-DefaultConfigPath)
    )

    $table = @{}

    switch -regex -file $Path {
        '^\s*([^=]+?)=([^#]*)' {
            $table[$Matches[1].Trim()] = $Matches[2].Trim()
        }
    }

    return $table
}