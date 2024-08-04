#!/usr/bin/env pwsh

#. "$PSScriptRoot/Imports.ps1"

$gci = @{
    Filter = '*.ps1'
    Recurse = $true
    ErrorAction = 'Stop'
}

try {
    $Public = @(Get-ChildItem -Path "$PSScriptRoot/Public" @gci)
    $Private = @(Get-ChildItem -Path "$PSScriptRoot/Private" @gci)
} catch {
    Write-Error $_
    throw "Unable to get file information from public & private sources"
}

foreach ($file in @($public + $private)) {
    try {
        . $file.FullName
    } catch {
        throw "Unable to dot-source [$($file.FullName)]"
    }
}

Export-ModuleMember -Function $public.Basename
