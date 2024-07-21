$DeferredLoad = {
    . "$env:XDG_CONFIG_HOME\powershell\ps7\functions\gdf.ps1"
    . "$env:XDG_CONFIG_HOME\powershell\ps7\functions\ipinfo.ps1"
    . "$env:XDG_CONFIG_HOME\powershell\ps7\functions\mkcd.ps1"
    . "$env:XDG_CONFIG_HOME\powershell\ps7\functions\ssh.ps1"
    . "$env:XDG_CONFIG_HOME\powershell\ps7\functions\true-false.ps1"
    . "$env:XDG_CONFIG_HOME\powershell\ps7\functions\Update-AllModules.ps1"
    . "$env:XDG_CONFIG_HOME\powershell\ps7\functions\upn.ps1"
    . "$env:XDG_CONFIG_HOME\powershell\ps7\functions\wttr.ps1"

    Set-Alias -Name 'which' -Value 'Get-Command'
    Set-Alias -Name 'unset' -Value 'Remove-Variable'
    Set-Alias -Name 'll' -Value 'Get-ChildItem'
    Set-Alias -Name 'lla' -Value 'Get-ChildItem'
    Set-Alias -Name 'grep' -Value 'Select-String'
    Set-Alias -Name 'man' -Value 'Get-Help'
    Set-Alias -Name 'vim' -Value 'nvim'
    Set-Alias -Name 'hf' -Value 'hyperfine'

    Import-Module -Name "$env:XDG_CONFIG_HOME\powershell\ps7\modules\PsIni\src\PsIni\PsIni.psm1"
    Import-Module -Name "$env:XDG_CONFIG_HOME\powershell\ps7\modules\PsBookmarkManager\src\PsBookmarkManager\PsBookmarkManager.psm1"

    Import-Module -Name 'Terminal-Icons'
    Import-Module -Name 'Microsoft.Winget.Client'
    Import-Module -Name 'posh-git'
    Import-Module -Name 'PSFzf'

    # Chocolatey
    $ChocolateyProfile = "$env:CHOCOLATEYINSTALL\helpers\chocolateyProfile.psm1"
    Import-Module -Name $ChocolateyProfile
}

# PS1
Invoke-Expression (& starship init powershell)

# Zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# async profile -- runs $DeferredLoad asynchronously
. "$env:XDG_CONFIG_HOME\powershell\ps7\async_profile.ps1"
