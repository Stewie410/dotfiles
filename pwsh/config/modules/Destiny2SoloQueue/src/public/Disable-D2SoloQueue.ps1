<#
	.SYNOPSIS
	Disable D2SoloQueue rules

	.DESCRIPTION
	Disable D2SoloQueue rules to allow Destiny2 matchmaking services

	.PARAMETER GamePath
	Path to the 'destiny2.exe' executable

	.OUTPUTS
	Microsoft.Management.Infrastructure.CimInstance
#>
function Disable-D2SoloQueue {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory, Position = 0)]
		[ValidateScript({ Test-GamePath -Path $_ })]
		[string]
		$GamePath
	)

	Get-D2SQRules -GamePath $GamePath | Disable-NetFirewallRule
}