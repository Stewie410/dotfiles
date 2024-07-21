function upn {
    [Alias('upn')]
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline)]
        [int]
        $Count = 0
    )

    $path = '.'
    for ($i = 0; $i -lt $Count; $i++) {
        $path = Join-Path -Path $path -ChildPath '..'
    }

    Set-Location -Path $path
}

function .. {
    upn -Count 1
}

function ... {
    upn -Count 2
}
