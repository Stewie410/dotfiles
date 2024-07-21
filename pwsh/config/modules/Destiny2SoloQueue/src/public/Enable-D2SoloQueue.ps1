<#
	.SYNOPSIS
	Enable D2SoloQueue rules

	.DESCRIPTION
	Enable D2SoloQueue rules to block Destiny2 matchmaking services

	.PARAMETER GamePath
	Path to the 'destiny2.exe' executable

	.OUTPUTS
	Microsoft.Management.Infrastructure.CimInstance
#>
function Enable-D2SoloQueue {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory, Position = 0)]
		[ValidateScript({ Test-GamePath -Path $_ })]
		[string]
		$GamePath
	)

	Get-D2SQRules -GamePath $GamePath | Enable-NetFirewallRule
}