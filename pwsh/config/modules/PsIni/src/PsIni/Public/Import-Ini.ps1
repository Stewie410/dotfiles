<#
.SYNOPSIS
Converts INI properties file into a hashtable

.DESCRIPTION
Converts INI properties file into a hashtable of PSObjects, following the format:

@{
    'section_name' = [PSCustomObject]@{
        Comments = @()
        Property = Value
        [...]
    }
}

.PARAMETER Path
Specifies the INI File to be converted

.INPUTS
System.String

.OUTPUTS
System.Collections.Hashtable

.EXAMPLE
PS> Import-Ini -Path .\foo.ini
PS> Import-Ini .\foo.ini

Read contents of .\foo.ini and parse into a hashtable

.EXAMPLE
PS> '.\foo.ini' | Import-Ini

Convert the contents of '.\foo.ini' to an INI hashtable

.COMPONENT
PsIni
#>
function Import-Ini {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [ValidateScript(
            {
                if ($_.IndexOfAny([System.IO.Path]::GetInvalidPathChars()) -ne -1) {
                    throw "Invalid path: $_"
                }

                if (!([System.IO.FileInfo] $_).Exists) {
                    throw "Path does not exist: $_"
                }

                $True
            }
        )]
        [string]
        $Path
    )

    begin {}

    process {
        ConvertFrom-Ini -InputObject (Get-Content -Path $Path)
    }

    end {}
}