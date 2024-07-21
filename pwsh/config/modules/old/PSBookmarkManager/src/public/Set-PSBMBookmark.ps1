<#
	.SYNOPSIS
	Add a new bookmark or update an existing one

	.DESCRIPTION
	Add a new bookmark or update an existing one

	.PARAMETER Config
	Configuration file path

	.PARAMETER Name
	Bookmark name

	.PARAMETER Path
	Bookmark path

	.PARAMETER Bookmarks
	Bookmarks table to add/update to configuration

	.INPUTS
	System.Collections.Hashtable

	.EXAMPLE
	PS> Set-PSBMBookmark foo .\bar

	.EXAMPLE
	PS> Set-PSBMBookmark -Name foo -Path .\bar

	.EXAMPLE
	PS> Set-PSBMBookmark -Config .\bm.rc foo .\bar

	.EXAMPLE
	PS> Set-PSBMBookmark -Config .\bm.rc -Name foo -Path .\bar

	.EXAMPLE
	PS> Set-PSBMBookmark @{ foo = '.\bar' }

	.EXAMPLE
	PS> Set-PSBMBookmark -Bookmarks @{ foo = '.\bar' }

	.EXAMPLE
	PS> Set-PSBMBookmark -Config .\bm.rc @{ foo = '.\bar' }

	.EXAMPLE
	PS> Set-PSBMBookmark -Config .\bm.rc -Bookmarks @{ foo = '.\bar' }

	.EXAMPLE
	PS> @{ foo = '.\bar' } | Set-PSBMBookmark

	.EXAMPLE
	PS> @{ foo = '.\bar' } | Set-PSBMBookmark -Config .\bm.rc
#>
function Set-PSBMBookmark {
	[Alias('Add-PSBMBookmark', 'Update-PSBMBookmark')]
	[CmdletBinding(DefaultParameterSetName = 'single')]
	param(
		[Parameter()]
		[ValidateScript({ Test-PSBMConfigPath $_ })]
		[string]
		$Config = (Get-PSBMDefaultConfigPath),

		[Parameter(Mandatory, Position = 0, ParameterSetName = 'single')]
		[string]
		$Name,

		[Parameter(Mandatory, Position = 1, ParameterSetName = 'single')]
		[ValidateScript({ Test-PSBMIsDirectory $_ })]
		[string]
		$Path,

		[Parameter(Mandatory, Position = 0, ValueFromPipeline, ParameterSetName = 'mutli')]
		[hashtable]
		$Bookmarks
	)

	BEGIN {
		$cfg = Get-PSBMConfiguration -Config $Config
	}

	PROCESS {
		switch ($PSCmdlet.ParameterSetName) {
			'single' {
				$cfg[$Name] = $Path
			}
			'multi' {
				foreach ($key in $Bookmarks.Keys) {
					$cfg[$key] = $Bookmarks[$key]
				}
			}
		}
	}

	END {
		Set-PSBMConfiguration -Config $Config -Bookmarks $cfg
	}
}