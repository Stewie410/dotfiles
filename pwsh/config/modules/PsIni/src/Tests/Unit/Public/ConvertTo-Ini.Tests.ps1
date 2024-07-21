#-------------------------------------------------------------------------
Set-Location -Path $PSScriptRoot
#-------------------------------------------------------------------------
$ModuleName = 'PsIni'
$PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
#-------------------------------------------------------------------------
if (Get-Module -Name $ModuleName -ErrorAction 'SilentlyContinue') {
    #if the module is already in memory, remove it
    Remove-Module -Name $ModuleName -Force
}
Import-Module $PathToManifest -Force
#-------------------------------------------------------------------------

InModuleScope 'PsIni' {
    Describe 'ConvertTo-Ini Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'

            $Table = @{
                NO_SECTION = [PSCustomObject]@{
                    Comments = @('comment')
                }

                foo        = [PSCustomObject]@{
                    Comments = @('comment', 'inline-comment')
                    foo      = 'foo'
                    bar      = 'bar'
                    baz      = 'baz'
                }
            }

            $Expected = [PSCustomObject]@{
                Spaces   = @(
                    '[NO_SECTION]',
                    '[foo]',
                    'foo = foo',
                    'bar = bar',
                    'baz = baz'
                )

                NoSpaces = @(
                    '[NO_SECTION]',
                    '[foo]',
                    'foo=foo',
                    'bar=bar',
                    'baz=baz'
                )
            }
        }

        Context 'Fails on invalid input' {
            It 'Throws when InputObject does not contain a "NO_SECTION" key' {
                { ConvertTo-Ini -InputObject @{ foo = $Table['foo'] } } | Should -Throw
            }

            It 'Throws when InputObject keys do not contain a Comments array' {
                $tbl = @{
                    NO_SECTION = [PSCustomObject]@{}

                    foo        = [PSCustomObject]@{
                        foo = 'foo'
                        bar = 'bar'
                        baz = 'baz'
                    }
                }

                { ConvertTo-Ini -InputObject $tbl } | Should -Throw
            }
        }

        Context 'Converts from hashtable to string[]' {
            It 'Converts param hashtable to array' {
                $result = ConvertTo-Ini -InputObject $Table
                $result | Should -BeOfType 'System.String'
                $result.Count | Should -BeGreaterOrEqual 1
            }

            It 'Converts pipeline hashtable to array' {
                $result = $Table | ConvertTo-Ini
                $result | Should -BeOfType 'System.String'
                $result.Count | Should -BeGreaterOrEqual 1
            }
        }

        Context 'Converts from hashtable to valid array' {
            It 'Converts param table to valid array with spaces' {
                $results = [PSCustomObject]@{
                    Spaces   = ConvertTo-Ini -InputObject $Table
                    NoSpaces = ConvertTo-Ini -InputObject $Table -NoSpace
                }

                for ($i = 0; $i -lt $Expected.Spaces.Count; $i++) {
                    $results.Spaces | Should -Contain $Expected.Spaces[$i]
                    $results.NoSpaces | Should -Contain $Expected.NoSpaces[$i]
                }
            }

            It 'Converts pipeline table to valid array' {
                $results = [PSCustomObject]@{
                    Spaces   = $Table | ConvertTo-Ini
                    NoSpaces = $Table | ConvertTo-Ini -NoSpace
                }

                for ($i = 0; $i -lt $Expected.Spaces.Count; $i++) {
                    $results.Spaces | Should -Contain $Expected.Spaces[$i]
                    $results.NoSpaces | Should -Contain $Expected.NoSpaces[$i]
                }
            }
        }
    }
}