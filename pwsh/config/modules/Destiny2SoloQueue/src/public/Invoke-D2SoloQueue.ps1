<#
	.SYNOPSIS
	Get, Enable or Disable D2SoloQueue rules

	.DESCRIPTION
	Get, Enable or Disable D2SoloQueue rules

	.PARAMETER Get
	Get D2SoloQueue rules

	.PARAMETER Enable
	Enable D2SoloQueue rules

	.PARAMETER Disable
	Disable D2SoloQueue rules

	.PARAMETER Toggle
	Invert state of D2SoloQueue rules

	.PARAMETER GamePath
	Path to the 'destiny2.exe' executable.

	If no path specified, will attempt to locate in Steam/EpicGames folders

	.OUTPUTS
	Microsoft.Management.Infrastructure.CimInstance
#>
function Invoke-D2SoloQueue {
	[Alias('d2sq')]
	[CmdletBinding(DefaultParameterSetName = 'get')]
	param(
		[Parameter(ParameterSetName = 'get')]
		[switch]
		$Get,

		[Parameter(Mandatory, ParameterSetName = 'enable')]
		[switch]
		$Enable,

		[Parameter(Mandatory, ParameterSetName = 'disable')]
		[switch]
		$Disable,

		[Parameter(Mandatory, ParameterSetName = 'toggle')]
		[switch]
		$Toggle,

		[Parameter()]
		[ValidateScript({ Test-GamePath -Path $_ })]
		[string]
		$GamePath = (Get-D2Path)
	)

	switch ($PSCmdlet.ParameterSetName) {
		'get' {
			Get-D2SQRules -GamePath $GamePath
		}

		'enable' {
			Enable-D2SoloQueue -GamePath $GamePath
		}

		'disable' {
			Disable-D2SoloQueue -GamePath $GamePath
		}

		'toggle' {
			Switch-D2SoloQueue -GamePath $GamePath
		}
	}
}