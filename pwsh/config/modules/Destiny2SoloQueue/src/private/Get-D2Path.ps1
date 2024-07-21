<#
	.SYNOPSIS
	Get path to 'destiny2.exe'

	.DESCRIPTION
	Get path to 'destiny2.exe'

	.OUTPUTS
	System.String

	.EXAMPLE
	PS> Get-D2Path
#>
function Get-D2Path {
	# Steam
	try {
		$game = Get-SteamPath |
			Join-Path -ChildPath 'steamapps' |
			Join-Path -ChildPath 'common' |
			Join-Path -ChildPath 'Destiny 2' |
			Join-Path -ChildPath 'destiny2.exe'

		if (Test-Path -Path $game -PathType Leaf) {
			return $game
		}
	}
	catch {}

	try {
		$game = Get-EpicGamesPath |
			Join-Path -ChildPath 'Destiny 2' |
			Join-Path -ChildPath 'destiny2.exe'

		if (Test-Path -Path $game -PathType Leaf) {
			return $game
		}
	}
	catch {}

	throw "Cannot locate 'destiny2.exe'"
}