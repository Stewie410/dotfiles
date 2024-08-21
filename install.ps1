#!/usr/bin/env pwsh

<#
.SYNOPSIS
Install dotfiles

.DESCRIPTION
Install dotfiles

.PARAMETER Modules
List of modules (or globs) to be installed

.EXAMPLE
PS> .\install.ps1 -Modules @("NuGet", "powershell")

Install the NuGet and PowerShell configurations

.EXAMPLE
PS> .\install.ps1 *

Install all available modules
#>

#Requires -RunAsAdministrator
#Requires -Version 7

[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0)]
    [string[]] $Modules
)

function Get-DotfileModules {
    $Modules |
        Get-ChildItem -Path (Split-Path -Path $PSCommandPath -Parent) -Directory -Filter $_ |
        Select-Object -ExpandProperty 'FullName' |
        Sort-Object -Unique
}

function Get-Platform {
    if ($IsLinux) {
        if ($null -ne $env:WSL_DISTRO_NAME) {
            return 'wsl'
        }
        return 'linux'
    }

    return 'win32'
}

function Get-DotfileConfig {
    param([string] $yml)

    $platform = Get-Platform
    $cfg = @{}

    switch -Regex ($yml) {
        '^([^:]+?):\s+$' {
            $item = $Matches[1]
        }

        '^\s+([^:]+?): (.+?)+' {
            if ($null -ne $item) {
                $key = $Matches[1]
                $path = $Mathes[2].Trim().Trim(@('"'))

                while ($path -match '\$\{\{ ([^\s]+) \}\}') {
                    $path = $path.Replace(
                        '${{' + $Matches[1] + '}}',
                        [Environment]::GetEnvironmentVariable($Matches[1])
                    )
                }

                if ($key -eq $platform) {
                    $cfg.Add($item, $path)
                }
            }
        }
    }

    return $cfg
}

function Install-DotfileModule {
    param([string] $repo)

    $err = false
    $name = Split-Path -Path $repo -Leaf

    if (!(Test-Path -Path "$repo/dots.yml" -PathType Leaf)) {
        throw "[$name] No yaml (config) in module: $(Split-Path -Path $repo -Leaf)"
    }

    $config = Get-DotfileConfig "$repo/dots.yml"
    if ($config.Keys.Count -eq 0) {
        throw "[$name] No compatible paths in config."
    }

    foreach ($k in $config.Keys) {
        Write-Host -NoNewLine "[$name] Installing ""$k"": "
        $ni = @{
            Path = $config[$k]
            Target = "$repo/$k"
            ItemType = 'SymbolicLink'
            Force = $True
            ErrorAction = 'SilentlyContinue'
        }

        if (!(New-Item @ni)) {
            '[{0}{1}{2}]' -f "`e[31m","FAIL","`e[0m"
            $err = $True
        } else {
            '[{0}{1}{2}]' -f "`e[32m","OK","`e[0m"
        }
    }

    if ($err) {
        throw "Failed to install one or more $name items."
    }
}

$ModuleList = @(Get-Modules)
if ($ModuleList.Count -eq 0) {
    Write-Error -Message "Cannot locate any matching modules"
}

foreach ($m in $ModuleList) {
    try {
        Install-DotfileModule $m
    } catch {
        Write-Error -Message $_.Exception -ErrorAction Continue
    }
}
