<#
	.SYNOPSIS
	Get the Steam installation path

	.DESCRIPTION
	Get the Steam installation path

	.OUTPUTS
	System.String
#>
function Get-SteamPath {
	$paths = @(
		'HKLM:\SOFTWARE\Valve\Steam',
		'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam'
	)

	foreach ($reg in $paths) {
		if (Test-Path -Path $reg -PathType Container) {
			return (Get-ChildItem -Path $reg | Get-ItemProperty).Path
		}
	}

	throw "Cannot locate Steam install path"
}