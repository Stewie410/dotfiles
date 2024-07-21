<#
	.SYNOPSIS
	Push-Location to bookmark path

	.DESCRIPTION
	Push-Location to bookmark path

	.PARAMETER Config
	Configuration file path

	.PARAMETER Name
	Bookmark name

	.INPUTS
	System.String

	.EXAMPLE
	PS> Push-PSBMLocation foo

	.EXAMPLE
	PS> Push-PSBMLocation -Name foo

	.EXAMPLE
	PS> Push-PSBMLocation -Config .\bm.rc foo

	.EXAMPLE
	PS> Push-PSBMLocation -Config .\bm.rc -Name foo
#>
function Push-PSBMLocation {
	[CmdletBinding()]
	param(
		[Parameter()]
		[ValidateScript({ Test-PSBMConfigPath $_ })]
		[string]
		$Config = (Get-PSBMDefaultConfigPath),

		[Parameter(Mandatory, Position = 0)]
		[string]
		$Name
	)

	$cfg = Get-PSBMConfiguration -Config $Config

	if ($cfg.Keys -notcontains $Name) {
		throw "Bookmark is not defined: $Name"
	}

	Push-Location -Path $cfg[$Name]
}