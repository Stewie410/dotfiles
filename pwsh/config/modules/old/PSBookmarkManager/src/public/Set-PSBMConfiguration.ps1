<#
	.SYNOPSIS
	Write bookmark table to file

	.DESCRIPTION
	Write bookmark table to file

	.PARAMETER Config
	Configuration file path

	.PARAMETER Bookmarks
	Bookmarks hashtable

	.INPUTS
	System.Collections.Hashtable

	.EXAMPLE
	PS> Set-PSBMConfiguration @{ foo = '.\bar' }

	.EXAMPLE
	PS> Set-PSBMConfiguration -Bookmarks @{ foo = '.\bar' }

	.EXAMPLE
	PS> Set-PSBMConfiguration -Config .\bm.rc @{ foo = '.\bar' }

	.EXAMPLE
	PS> Set-PSBMConfiguration -Config .\bm.rc -Bookmarks @{ foo = '.\bar' }

	.EXAMPLE
	PS> @{ foo = '.\bar' } | Set-PSBMConfiguration

	.EXAMPLE
	PS> @{ foo = '.\bar' } | Set-PSBMConfiguration -Config .\bm.rc
#>
function Set-PSBMConfiguration {
	[Alias('Write-PSBMConfiguration')]
	[CmdletBinding()]
	param(
		[Parameter()]
		[ValidateScript({ Test-PSBMConfigPath $_ })]
		[string]
		$Config = (Get-PSBMDefaultConfigPath),

		[Parameter(Mandatory, ValueFromPipeline, Position = 0)]
		[hashtable]
		$Bookmarks
	)

	PROCESS {
		$Bookmarks.GetEnumerator() | ForEach-Object {
			'{0} = {1}' -f $_.Name,$_.Value
		} | Set-Content -Path $Config
	}
}