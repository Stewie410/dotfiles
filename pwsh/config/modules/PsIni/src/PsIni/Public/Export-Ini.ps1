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