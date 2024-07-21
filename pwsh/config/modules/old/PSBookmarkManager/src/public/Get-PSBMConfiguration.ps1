<#
	.SYNOPSIS
	Get configuration file content as a hashtable

	.DESCRIPTION
	Get configuration file content as a hashtable of bookmarks & paths

	.PARAMETER Config
	Configuration file path

	.INPUTS
	System.String

	.OUTPUTS
	System.Collections.Hashtable

	.EXAMPLE
	PS> Get-PSBMConfiguration

	.EXAMPLE
	PS> Get-PSBMConfiguration -Config .\bm.rc

	.EXAMPLE
	PS> @(.\foo.rc, .\bar.rc) | Get-PSBMConfiguration
#>
function Get-PSBMConfiguration {
	[Alias('Get-PSBMBookmarks')]
	[CmdletBinding()]
	param(
		[Parameter(ValueFromPipeline)]
		[ValidateScript({ Test-PSBMConfigPath $_ })]
		[string]
		$Config = (Get-PSBMDefaultConfigPath)
	)

	PROCESS {
		$table = @{}
		switch -regex -file $Config {
			'^\s*([^=]+?)=([^#]*)' {
				$table[$Matches[1].Trim()] = $Matches[2].Trim()
			}
		}
		$table
	}
}