function Update-AllModules {
	Get-Module -ListAvailable |
		Select-Object -ExpandProperty 'Name' |
		ForEach-Object {
			Update-Module -Name $_ -ErrorAction SilentlyContinue
		}
}