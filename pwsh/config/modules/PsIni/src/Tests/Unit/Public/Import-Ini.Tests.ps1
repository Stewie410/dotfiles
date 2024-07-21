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
    Describe 'Import-Ini Public Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'

            $tempFile = (New-TemporaryFile).FullName
            @(
                '; comment'
                '[foo]',
                '; comment'
                'foo = foo ; inline-comment',
                'bar = bar',
                'baz = baz'
            ) | Add-Content -Path $tempFile
        }

        AfterAll {
            Remove-Item -Path $tempFile -Force
        }

        Context 'Fails on invalid path' {
            It 'Throws when Path contains invalid characters' {
                { Import-Ini -Path "$env:TEMP\$([System.IO.Path]::GetInvalidPathChars()).ini" } | Should -Throw
            }

            It 'Throws when Path does not exist' {
                { Import-Ini -Path ([System.IO.Path]::Combine($env:TEMP, (New-Guid).Guid)) } | Should -Throw
            }
        }

        Context 'Reads contents of Path and converts to hashtable' {
            It 'Reads param file path and converts to hashtable' {
                Import-Ini -Path $tempFile | Should -BeOfType 'System.Collections.Hashtable'
            }

            It 'Reads pipeline file path and converts to hashtable' {
                $tempFile | Import-Ini | Should -BeOfType 'System.Collections.Hashtable'
            }
        }

        Context 'Reads contents of Path and converts to a valid hashtable' {
            It 'Converts Path param contents to valid hashtable' {
                $result = Import-Ini -Path $tempFile

                $result['NO_SECTION'] | Should -BeOfType 'psobject'
                $result['NO_SECTION'].Comments | Should -Be 'comment'

                $result['foo'] | Should -BeOfType 'psobject'
                $result['foo'].Comments | Should -Be @('comment', 'inline-comment')
                $result['foo'].foo | Should -Be 'foo'
                $result['foo'].bar | Should -Be 'bar'
                $result['foo'].baz | Should -Be 'baz'
            }

            It 'Converts Path pipeline contents to valid hashtable' {
                $result = $tempFile | Import-Ini

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