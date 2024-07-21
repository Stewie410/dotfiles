<#
	.SYNOPSIS
	Get Destiny 2 Firewall Rules to allow/block matchmaking

	.DESCRIPTION
	Get Destiny 2 Firewall Rules to allow/block matchmaking

	.PARAMETER GamePath
	Path to the 'destiny2.exe' executable

	.OUTPUTS
	Microsoft.Management.Infrastructure.CimInstance
#>
function Get-D2SQRules {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory, Position = 0)]
		[ValidateScript({ Test-GamePath -Path $_ })]
		[string]
		$GamePath
	)

	$rules = @()

	try {
		$basename = 'D2SoloQueue'
		$rules = @(Get-NetFirewallRule | Where-Object {
				$_.DisplayName -match $basename
			})

		foreach ($direction in @('Out', 'In')) {
			foreach ($protocol in @('TCP', 'UDP')) {
				$rule = @{
					DisplayName = "$basename-$direction-$protocol"
					Description = "Block Destiny2's matchmaking services (" + $protocol + ": " + $direction + ")"
					Program     = $GamePath
					Directorion	= $direction
					RemotePort  = @('27000-27200', '3097')
					Protocol    = $protocol
					Action      = 'Block'
					Enabled     = 'False'
				}

				if ($rule.DisplayName -notin $rules.DisplayName) {
					$rules += @(New-NetFirewallRule @rule)
				}
			}
		}
	}
 catch {
		throw $_
	}

	return $rules
}