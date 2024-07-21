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
                NO_SECTION = [PSCustomObject]@{ Comments = @('comment') }
                foo        = [PSCustomObject]@{
                    Comments = @('comment')
                    foo      = 'foo'
                    bar      = 'bar'
                    baz      = 'baz'
                }
            }

            $Expected = [PSCustomObject]@{
                Spaces   = [PSCustomObject]@{
                    Data = @(
                        '[NO_SECTION]',
                        '[foo]',
                        'foo = foo',
                        'bar = bar',
                        'baz = baz'
                    )

                    File = (New-TemporaryFile).FullName
                }

                NoSpaces = [PSCustomObject]@{
                    Data = @(
                        '[NO_SECTION]',
                        '[foo]',
                        'foo=foo',
                        'bar=bar',
                        'baz=baz'
                    )

                    File = (New-TemporaryFile).FullName
                }
            }

            $Expected.Spaces.Data | Add-Content -Path $Expected.Spaces.File
            $Expected.NoSpaces.Data | Add-Content -Path $Expected.NoSpaces.File
        }

        AfterAll {
            Remove-Item -Path @(
                $Expected.Spaces.File,
                $Expected.NoSpaces.File
            ) -Force
        }

        BeforeEach {
            $tempFile = (New-TemporaryFile).FullName
        }

        AfterEach {
            Remove-Item -Path $tempFile -Force
        }

        Context 'Fails on invalid input' {
            It 'Throws when InputObject missing "NO_SECTION" section' {
                {
                    Export-Ini -InputObject @{ foo = $Table['foo'] }
                } | Should -Throw
            }

            It 'Throws when InputObject missing Comments array' {
                {
                    Export-Ini -InputObject @{
                        NO_SECTION = [PSCustomObject]@{}
                        foo        = [PSCustomObject]@{
                            foo = 'foo'
                            bar = 'bar'
                            baz = 'baz'
                        }
                    }
                } | Should -Throw
            }

            It 'Throws when Path contains invalid characters' {
                {
                    Export-Ini -InputObject $Table -Path "$env:TEMP\$([System.IO.Path]::GetInvalidPathChars()).ini"
                } | Should -Throw
            }
        }

        Context 'Fails when file exists & NoClobber' {
            It 'Prevent overwrites with -NoClobber' {
                {
                    Export-Ini -InputObject $Table -Path $tempFile -NoClobber
                } | Should -Throw
            }
        }

        Context 'Overwrites file contents' {
            BeforeEach {
                Set-Content -Path $tempFile -Value 'original content'
            }

            It 'Convert param hashtable to string[] and overwrite file contents' {
                Export-Ini -InputObject $Table -Path $tempFile
                Get-Content -Path $tempFile | Should -Not -Be 'original content'
            }

            It 'Convert pipeline hashtable to string[] and overwrite file contents' {
                $Table | Export-Ini -Path $tempFile
                Get-Content -Path $tempFile | Should -Not -Be 'original content'
            }
        }

        Context 'Overwrites read-only file contents' {
            BeforeEach {
                Set-Content -Path $tempFile -Value 'original content'
                Set-ItemProperty -Path $tempFile -Name 'IsReadOnly' -Value $True
            }

            It 'Convert param hashtable to string[] and overwrite read-only file contents' {
                Export-Ini -InputObject $Table -Path $tempFile -Force
                Get-Content -Path $tempFile | Should -Not -Be 'original content'
            }

            It 'Convert pipeline hashtable to string[] and overwrite read-only file contents' {
                $Table | Export-Ini -Path $tempFile -Force
                Get-Content -Path $tempFile | Should -Not -Be 'original content'
            }
        }

        Context 'Appends to file contents' {
            BeforeEach {
                Set-Content -Path $tempFile -Value '; original content'
            }

            It 'Convert param hashtable to string[] and append to file' {
                Export-Ini -InputObject $Table -Path $tempFile -Append
                Get-Content -Path $tempFile | Should -Contain '; original content'
            }

            It 'Convert pipeline hashtable to string[] and append to file' {
                $Table | Export-Ini -Path $tempFile -Append
                Get-Content -Path $tempFile | Should -Contain '; original content'
            }
        }

        Context 'Appends to read-only file contents' {
            BeforeEach {
                Set-Content -Path $tempFile -Value '; original content'
                Set-ItemProperty -Path $tempFile -Name 'IsReadOnly' -Value $True
            }

            It 'Convert param hashtable to string[] and append to file' {
                Export-Ini -InputObject $Table -Path $tempFile -Append -Force
                Get-Content -Path $tempFile | Should -Contain '; original content'
            }

            It 'Convert pipeline hashtable to string[] and append to file' {
                $Table | Export-Ini -Path $tempFile -Append -Force
                Get-Content -Path $tempFile | Should -Contain '; original content'
            }
        }

        Context 'Converts table with expected format' {
            It 'Converted param hashtable is expected content, with spaces' {
                Export-Ini -InputObject $Table -Path $tempFile
                Get-Content -Path $tempFile | ForEach-Object {
                    $Expected.Spaces | Should -Contain $_
                }
            }

            It 'Converted pipeline hashtable is expected content, with spaces' {
                $Table | Export-Ini -Path $tempFile
                Get-Content -Path $tempFile | ForEach-Object {
                    $Expected.Spaces | Should -Contain $_
                }
            }

            It 'Converted param hashtable is expected content, without spaces' {
                Export-Ini -InputObject $Table -Path $tempFile -NoSpace
                Get-Content -Path $tempFile | ForEach-Object {
                    $Expected.NoSpaces | Should -Contain $_
                }
            }

            It 'Converted pipeline hashtable is expected content, without spaces' {
                $Table | Export-Ini -Path $tempFile -NoSpace
                Get-Content -Path $tempFile | ForEach-Object {
                    $Expected.NoSpaces | Should -Contain $_
                }
            }
        }
    }
}