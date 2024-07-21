<#
	.SYNOPSIS
	Open configuration file in a text editor

	.DESCRIPTION
	Open configuration file in a text editor

	.PARAMETER Config
	Configuration file path

	.PARAMETER Editor
	Text editor, by default $env:EDITOR or notepad.exe

	.EXAMPLE
	PS> Edit-PSBMConfiguration

	.EXAMPLE
	PS> Edit-PSBMConfiguration -Config .\bm.rc

	.EXAMPLE
	PS> Edit-PSBMConfiguration -Editor nvim.exe

	.EXAMPLE
	PS> Edit-PSBMConfiguration -Config .\bm.rc -Editor nvim.exe
#>
function Edit-PSBMConfiguration {
	[CmdletBinding()]
	param(
		[Parameter()]
		[ValidateScript({ Test-PSBMConfigPath $_ })]
		[string]
		$Config = (Get-PSBMDefaultConfigPath),

		[Parameter()]
		[ValidateScript({ Get-Command -Name $_ -ErrorAction Stop })]
		[string]
		$Editor = (if ($null -ne $env:EDITOR) {
			$env:EDITOR
		} else {
			'notepad.exe'
		})
	)

	& $Editor $Config
}