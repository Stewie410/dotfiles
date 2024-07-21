# This is a locally sourced Imports file for local development.
# It can be imported by the psm1 in local development to add script level variables.
# It will merged in the build process. This is for local development only.

# region script variables
# $script:resourcePath = "$PSScriptRoot\Resources"


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

<#
.SYNOPSIS
Convert INI hashtables to an INI formatted properties

.DESCRIPTION
Convert INI hashtables to an INI formatted properties.  Comments are not included in the output

.PARAMETER InputObject
Hashtable to be converted

.PARAMETER NoSpace
Write properties as 'property=value', instead of 'property = value'

.INPUTS
System.Collections.Hashtable

.OUTPUTS
System.String[]

.EXAMPLE
PS> ConvertTo-Ini -InputObject @{ 'NO_SECTION' = [PSCustomObject]@{ Comments = @(); Property = 'Value' }}
PS> ConvertTo-Ini @{ 'NO_SECTION' = [PSCustomObject]@{ Comments = @(); Property = 'Value' }}

Convert the inline INI hashtable into a INI formatted properties list, ready to write to a file; with a leading/trailing space around the '=' in section properties

.EXAMPLE
PS> ConvertTo-Ini -NoSpace -InputObject @{ 'NO_SECTION' = [PSCustomObject]@{ Comments = @(); Property = 'Value' }}
PS> ConvertTo-Ini -NoSpace @{ 'NO_SECTION' = [PSCustomObject]@{ Comments = @(); Property = 'Value' }}

Convert the inline INI hashtable into a INI formatted properties list, ready to write to a file; without a leading/trailing space around the '=' in section properties

.EXAMPLE
PS> @{ 'NO_SECTION' = [PSCustomObject]@{ Comments = @(); Property = 'Value' }} | ConvertTo-Ini

Convert the pipeled hashtable into a INI formatted properties list, ready to write to a file; with a leading/trailing space around the '=' in section properties

.EXAMPLE
PS> @{ 'NO_SECTION' = [PSCustomObject]@{ Comments = @(); Property = 'Value' }} | ConvertTo-Ini -NoSpace

Convert the pipelined hashtable into a INI formatted properties list, ready to write to a file; without a leading/trailing space around the '=' in section properties

.COMPONENT
PsIni
#>
function ConvertTo-Ini {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [ValidateScript(
            {
                if (!$_['NO_SECTION']) {
                    throw "InputObject is missing 'NO_SECTION' section"
                }

                foreach ($key in $_.Keys) {
                    if (!$_[$key].Comments) {
                        throw "InputObject[$key] is missing Comments array"
                    }
                }

                $true
            }
        )]
        [hashtable]
        $InputObject,

        [Parameter()]
        [switch]
        $NoSpace
    )

    begin {
        $format = if ($NoSpace) {
            '{0}={1}'
        } else {
            '{0} = {1}'
        }
    }

    process {
        foreach ($key in $InputObject.Keys) {
            "[$key]"

            foreach ($prop in @(Get-Member -InputObject $InputObject[$key] -MemberType 'NoteProperty')) {
                if ($prop.Name -eq 'Comments') {
                    continue
                }

                $format -f @(
                    $prop.Name,
                    (Select-Object -InputObject $InputObject[$key] -ExpandProperty $prop.Name)
                )
            }
        }
    }

    end {}
}

<#
.SYNOPSIS
Converts hashtables into an INI format, and writes content to file

.DESCRIPTION
Converts hashtables into an INI format, and writes content to file

.PARAMETER InputObject
Hashtable to be converted

.PARAMETER Path
Specifies the INI File to be converted

.PARAMETER NoSpace
Write properties as 'property=value', instead of 'property = value'

.PARAMETER NoClobber
Do not overwrite an existing file

.PARAMETER Append
Add INI content to the end of the specified file, instead of overwriting

.PARAMETER Force
Set/Add content to a read-only file

.INPUTS
System.Collections.Hashtable

.EXAMPLE
PS> Import-Ini -Path .\foo.ini
PS> Import-Ini .\foo.ini

Read contents of .\foo.ini and parse into a hashtable

.EXAMPLE
PS> '.\foo.ini' | Import-Ini

Convert the contents of '.\foo.ini' to an INI hashtable

.EXAMPLE
PS> Export-Ini -InputObject @{ 'NO_SECTION' = [PSCustomObject]@{ Comments = @();  Property = 'Value' }} -Path '.\foo.ini'
PS> Export-Ini @{ 'NO_SECTION' = [PSCustomObject]@{ Comments = @();  Property = 'Value' }} '.\foo.ini'

Convert inline hashtable to an INI format, then write/overwrite the contents of .\foo.ini

.EXAMPLE
PS> Export-Ini -InputObject @{ 'NO_SECTION' = [PSCustomObject]@{ Comments = @();  Property = 'Value' }} -Path '.\foo.ini' -NoSpace
PS> Export-Ini @{ 'NO_SECTION' = [PSCustomObject]@{ Comments = @();  Property = 'Value' }} '.\foo.ini' -NoSpace

Convert inline hashtable to an INI format, then write/overwrite the contents of .\foo.ini.  Write property listings as 'property=value', instead of 'property = value'

.EXAMPLE
PS> @{ 'NO_SECTION' = [PSCustomObject]@{ Comments = @();  Property = 'Value' }} | Export-Ini -Path '.\foo.ini'
PS> @{ 'NO_SECTION' = [PSCustomObject]@{ Comments = @();  Property = 'Value' }} | Export-Ini '.\foo.ini'

Convert pipelined hashtable to an INI format, then write/overwrite the contents of .\foo.ini

.EXAMPLE
PS> @{ 'NO_SECTION' = [PSCustomObject]@{ Comments = @();  Property = 'Value' }} | Export-Ini -Path '.\foo.ini' -NoSpace
PS> @{ 'NO_SECTION' = [PSCustomObject]@{ Comments = @();  Property = 'Value' }} | Export-Ini '.\foo.ini' -NoSpace

Convert pipelined hashtable to an INI format, then write/overwrite the contents of .\foo.ini.  Write property listings as 'property=value', instead of 'property = value'

.EXAMPLE
PS> Export-Ini -InputObject $table -Path '.\foo.ini' -NoClobber

Write contents of $table as INI format if the file does not already exist

.EXAMPLE
PS> Export-Ini -InputObject $table -Path '.\foo.ini' -Append

Append contents of $table as INI format to '.\foo.ini', instead of overwriting

.EXAMPLE
PS> Export-Ini -InputObject $table -Path '.\read-only.ini' -Force -Append

Forcibly append contents of $tabl as INI format to '.\read-only.ini', instead of overwriting

.COMPONENT
PsIni
#>
function Export-Ini {
    [CmdletBinding(DefaultParameterSetName = 'overwrite')]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [ValidateScript(
            {
                if (!$_['NO_SECTION']) {
                    throw "InputObject is missing 'NO_SECTION' section"
                }

                foreach ($key in $_.Keys) {
                    if (!$_[$key].Comments) {
                        throw "InputObject[$key] is missing Comments array"
                    }
                }

                $true
            }
        )]
        [hashtable]
        $InputObject,

        [Parameter(Mandatory, Position = 1)]
        [ValidateScript(
            {
                if ($_.IndexOfAny([System.IO.Path]::GetInvalidPathChars()) -gt -1) {
                    throw "Path contains invalid characters"
                }

                $True
            }
        )]
        [string]
        $Path,

        [Parameter()]
        [switch]
        $NoSpace,

        [Parameter(ParameterSetName = 'overwrite')]
        [switch]
        $NoClobber,

        [Parameter(ParameterSetName = 'append')]
        [switch]
        $Append,

        [Parameter()]
        [switch]
        $Force
    )

    begin {
        if ($PSCmdlet.ParameterSetName -eq 'overwrite') {
            if (([System.IO.FileInfo] $Path).Exists -and $NoClobber) {
                throw "Output file already exists: $Path"
            }
        }

        $write_splat = @{
            Path      = $Path
            Force     = $Force
            NoNewLine = $True
        }

        $content = @()
    }

    process {
        $convert_splat = @{
            InputObject = $InputObject
            NoSpace     = $NoSpace
        }

        $content += @(ConvertTo-Ini @convert_splat)
    }

    end {
        if ($Append) {
            $result | Add-Content @write_splat
        } else {
            $result | Set-Content @write_splat
        }
    }
}

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


