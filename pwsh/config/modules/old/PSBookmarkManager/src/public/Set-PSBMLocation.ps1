<#
	.SYNOPSIS
	Set-Location to bookmark path

	.DESCRIPTION
	Set-Location to bookmark path

	.PARAMETER Config
	Configuration file path

	.PARAMETER Name
	Bookmark name

	.INPUTS
	System.String

	.EXAMPLE
	PS> Set-PSBMLocation foo

	.EXAMPLE
	PS> Set-PSBMLocation -Name foo

	.EXAMPLE
	PS> Set-PSBMLocation -Config .\bm.rc foo

	.EXAMPLE
	PS> Set-PSBMLocation -Config .\bm.rc -Name foo
#>
function Set-PSBMLocation {
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

	Set-Location -Path $cfg[$Name]
}