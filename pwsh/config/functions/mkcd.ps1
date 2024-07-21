function mkcd {
    [CmdletBinding(DefaultParameterSetName = 'normal')]
    param(
        [Parameter(Position = 0, ParameterSetName = 'working')]
        [DateTime]
        $Date,

        [Alias('Working')]
        [Parameter(ParameterSetName = 'working')]
        [ValidateScript({ Test-Path -Path $_ -IsValid })]
        [string]
        $WorkingPath,

        [Parameter(Position = 0, ParameterSetname = 'normal')]
        [string]
        $Path
    )

    if ($PSCmdlet.ParameterSetName -eq 'working') {
        if ($null -eq $WorkingPath) {
            $WorkingPath = if ($null -eq $env:WORKING_DIR) {
                Join-Path -Path $HOME -ChildPath 'working'
            } else {
                $env:WORKING_DIR
            }
        }

        $Path = Join-Path -Path $WorkingPath -ChildPath (
            Get-Date -Date $Date -UFormat '+%F'
        )
    }

    New-Item -Path $Path -ItemType Directory -Force -ErrorAction SilentlyContinue
    Set-Location -Path $Path
}

function mdot {
    Set-NewLocation -Date ([DateTime]::Today)
}

function mdoy {
    Set-NewLocation -Date ([DateTime]::Today).AddDays(-1)
}
