<#
.SYNOPSIS
Converts INI properties format into a hashtable

.DESCRIPTION
Converts INI properties format into a hashtable of PSObjects, following the format:

@{
    'section_name' = [PSCustomObject]@{
        Comments = @()
        Property = Value
        [...]
    }
}

.PARAMETER InputObject
Specifies the INI string(s) to be converted

.INPUTS
System.String[]

.OUTPUTS
System.Collections.Hashtable

.EXAMPLE
PS> ConvertFrom-Ini -InputObject @('[foo]', 'bar = baz')
PS> ConvertFrom-Ini @('[foo]', 'bar = baz')

Convert an array directly to an INI hashtable.

.EXAMPLE
PS> Get-Content .\foo.ini | ConvertFrom-Ini

Convert the contents of '.\foo.ini' to an INI hashtable.

.COMPONENT
PsIni
#>
function ConvertFrom-Ini {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [ValidateScript({ $_ -as [string[]] })]
        [string[]]
        $InputObject
    )

    begin {
        $section = 'NO_SECTION'
        $ini = @{
            $section = [PSCustomObject]@{
                Comments = @()
            }
        }
    }

    process {
        foreach ($str in $InputObject) {
            switch -regex ($str) {
                '^\s*\[([^\]]+?)\]\s*$' {
                    $section = $Matches[1].Trim()
                    $ini[$section] = [PSCustomObject]@{
                        Comments = @()
                    }
                }

                '^\s*;' {
                    $ini[$section].Comments += @(($str -replace '^\s*;', '').Trim())
                }

                '^([^=]+?)=(.*)$' {
                    $member = @{
                        InputObject = $ini[$section]
                        MemberType  = 'NoteProperty'
                        Name        = $Matches[1].Trim()
                        Value       = $Matches[2].Trim()
                        Force       = $True
                    }

                    if ($Matches[2].IndexOfAny(';') -ne -1) {
                        $ini[$section].Comments += @(($member['Value'] -replace '^[^;]+?;', '').Trim())
                        $member['Value'] = ($member['Value'] -replace ';.*', '').Trim()
                    }

                    Add-Member @member
                }
            }
        }
    }

    end {
        $ini
    }
}