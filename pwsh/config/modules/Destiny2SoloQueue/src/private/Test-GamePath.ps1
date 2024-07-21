<#
	.SYNOPSIS
	Ensure game path exists & points to 'destiny2.exe'

	.DESCRIPTION
	Ensure game path exists & points to 'destiny2.exe'

	.PARAMETER Path
	Game Path to check

	.OUTPUTS
	System.Boolean
#>

function Test-GamePath {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory, Position = 0)]
		[string]
		$Path
	)

	if (!(Test-Path -Path $Path -IsValid)) {
		throw "GamePath is not valid: $Path"
	}

	if (!(Test-Path -Path $Path -PathType Leaf)) {
		throw "GamePath must be a file"
	}

	if ((Split-Path -Path $Path -Leaf) -ne 'destiny2.exe') {
		throw "GamePath must point to 'destiny2.exe'"
	}

	return $True
}