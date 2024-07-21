$item_splat = @{
	Filter      = '*.ps1'
	Recurse     = $True
	ErrorAction = 'Stop'
}

try {
	$public = @(Get-ChildItem -Path "$PSScriptRoot\src\public" @item_splat)
	$private = @(Get-ChildItem -Path "$PSScriptRoot\src\private" @item_splat)
} catch {
	Write-Error $_
	throw "Unable to get file information from src/(public|private)"
}

foreach ($file in @($private + $public)) {
	try {
		. $file.FullName
	} catch {
		throw "Unable to dot-source [$($file.FullName)]"
	}
}

Export-ModuleMember -Function $public.Basename -Alias 'd2sq'