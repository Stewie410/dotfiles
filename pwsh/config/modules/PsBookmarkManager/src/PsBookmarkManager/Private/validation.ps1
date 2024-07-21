function Test-IsDirectory {
    param([string] $Path)

    if ($Path.IndexOfAny([System.IO.Path]::GetInvalidPathChars()) -ne -1) {
        throw "Path is not valid: $Path"
    }

    if (!(Test-Path -Path $Path -PathType Container)) {
        throw "Path is not a directory: $Path"
    }

    return $True
}

function Test-ConfigPath {
    param([string] $Path)

    if ($Path.IndexOfAny([System.IO.Path]::GetInvalidPathChars()) -ne -1) {
        throw "Path is invalid: $Path"
    }

    if (!([System.IO.FileInfo] $Path).Exists) {
        New-Item -Path $Path -ItemType File -Force
    }

    return $True
}