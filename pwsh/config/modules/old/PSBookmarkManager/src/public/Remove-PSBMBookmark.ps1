<#
	.SYNOPSIS
	Remove a bookmark entry

	.DESCRIPTION
	Remove a bookmark entry

	.PARAMETER Config
	Configuration file path

	.PARAMETER Name
	Bookmark name to remove

	.INPUTS
	System.String

	.EXAMPLE
	PS> Remove-PSBMBookmark foo

	.EXAMPLE
	PS> Remove-PSBMBookmark -Name foo

	.EXAMPLE
	PS> Remove-PSBMBookmark -Config .\bm.rc foo

	.EXAMPLE
	PS> Remove-PSBMBookmark -Config .\bm.rc -Name foo

	.EXAMPLE
	PS> @('foo', 'bar') | Remove-PSBMBookmark

	.EXAMPLE
	PS> @('foo', 'bar') | Remove-PSBMBookmark -Config .\bm.rc
#>
function Remove-PSBMBookmark {
	[CmdletBinding()]
	param(
		[Parameter()]
		[ValidateScript({ Test-PSBMConfigPath $_ })]
		[string]
		$Config = (Get-PSBMDefaultConfigPath),

		[Parameter(Mandatory, ValueFromPipeline, Position = 0)]
		[string]
		$Name
	)

	BEGIN {
		$cfg = Get-PSBMConfiguration -Config $Config
	}

	PROCESS {
		if ($cfg.Keys -notcontains $Name) {
			throw "Bookmark does not exist: $Name"
		}

		$cfg.Remove($Name)
	}

	END {
		Set-PSBMConfiguration -Config $Config -Bookmarks $cfg
	}
}