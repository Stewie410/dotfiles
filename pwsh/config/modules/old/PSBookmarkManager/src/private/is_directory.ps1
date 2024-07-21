<#
	.SYNOPSIS
	Ensure path is a directory

	.DESCRIPTION
	Ensure path is a directory

	.PARAMETER Path
	Path to be tested

	.OUTPUTS
	System.Boolean
	System.Exception

	.EXAMPLE
	PS> Test-PSBMIsDirectory .\path\exists\and\is\directory
	$True

	.EXAMPLE
	PS> Test-PSBMIsDirectory .\path\is\not\directory
	[System.Object.Exception]

	.EXAMPLE
	PS> Test-PSBMIsDirectory .\path\is\directory
	$True
#>
function Test-PSBMIsDirectory {
	param([string]$path)
	if (!(Test-Path -Path $path -IsValid)) {
		throw "Path is not valid: $path"
	} elseif (!(Test-Path -Path $path -PathType Container)) {
		throw "Path is not a directory: $path"
	}
	return $True
}