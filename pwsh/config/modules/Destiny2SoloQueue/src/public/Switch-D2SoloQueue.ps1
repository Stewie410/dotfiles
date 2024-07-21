<#
	.SYNOPSIS
	Toggle D2SoloQueue rules

	.DESCRIPTION
	Toggle D2SoloQueue rules to allow/block Destiny2 matchmaking services

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

	$rules = Get-D2SQRules -GamePath $GamePath

	if ($rules.Enabled -contains 'False') {
		$rules | Enable-NetFirewallRule
	}
	else {
		$rules | Disable-NetFirewallRule
	}
}