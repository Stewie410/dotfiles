<#
	.SYNOPSIS
	Test if current session has administrator priviledges

	.DESCRIPTION
	Test if current session has administrator priviledges

	.OUTPUTS
	System.Boolean

	.EXAMPLE
	PS> Test-IsAdmin
#>
function Test-IsAdmin {
	$result = $False

	try {
		$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
		$principal = [Security.Principal.WindowsPrincipal]::new($identity)
		$admin = [Security.Principal.WindowsBuiltInRole]::Administrator
		$result = $principal.IsInRole($admin)
	} catch {
		throw $_
	}

	return $result
}