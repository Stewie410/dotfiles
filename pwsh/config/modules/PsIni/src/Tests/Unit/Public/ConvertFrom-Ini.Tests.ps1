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
    Describe 'ConvertFrom-Ini Public Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'

            $Lines = @(
                '; comment'
                '[foo]',
                '; comment'
                'foo = foo ; inline-comment',
                'bar = bar',
                'baz = baz'
            )
        }

        Context 'Converts from string[] to hashtable' {
            It 'Converts param array to hashtable' {
                ConvertFrom-Ini -InputObject $lines | Should -BeOfType 'System.Collections.Hashtable'
            }

            It 'Converts pipeline array to hashtable' {
                $Lines | ConvertFrom-Ini | Should -BeOfType 'System.Collections.Hashtable'
            }
        }

        Context 'Converts from string[] to valid hashtable' {
            It 'Converts param array to valid hashtable' {
                $result = ConvertFrom-Ini -InputObject $Lines

                $result['NO_SECTION'] | Should -BeOfType 'psobject'
                $result['NO_SECTION'].Comments | Should -Be 'comment'

                $result['foo'] | Should -BeOfType 'psobject'
                $result['foo'].Comments | Should -Be @('comment', 'inline-comment')
                $result['foo'].foo | Should -Be 'foo'
                $result['foo'].bar | Should -Be 'bar'
                $result['foo'].baz | Should -Be 'baz'
            }

            It 'Converts pipeline array to valid hashtable' {
                $result = $Lines | ConvertFrom-Ini

                $result['NO_SECTION'] | Should -BeOfType 'psobject'
                $result['NO_SECTION'].Comments | Should -Be 'comment'

                $result['foo'] | Should -BeOfType 'psobject'
                $result['foo'].Comments | Should -Be @('comment', 'inline-comment')
                $result['foo'].foo | Should -Be 'foo'
                $result['foo'].bar | Should -Be 'bar'
                $result['foo'].baz | Should -Be 'baz'
            }
        }
    }
}