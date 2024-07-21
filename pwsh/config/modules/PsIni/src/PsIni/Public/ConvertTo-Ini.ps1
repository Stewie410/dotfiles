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