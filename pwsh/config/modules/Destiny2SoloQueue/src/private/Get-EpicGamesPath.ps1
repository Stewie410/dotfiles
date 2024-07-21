<#
	.SYNOPSIS
	Get the EpicGames installation path

	.DESCRIPTION
	Get the EpicGames installation path

	.OUTPUTS
	System.String
#>
function Get-EpicGamesPath {
	$paths = @(
		'HKLM:\SOFTWARE\EpicGames',
		'HKLM:\SOFTWARE\WOW6432Node\EpicGames'
	)

	foreach ($reg in $paths) {
		if (Test-Path -Path $reg -PathType Container) {
			return (Get-ChildItem -Path $reg | Get-ItemProperty).INSTALLDIR
		}
	}

	throw "Cannot locate EpicGames install path"
}