function Get-DefaultConfigPath {
    $root = if (!$env:XDG_CONFIG_HOME) {
        $env:LOCALAPPDATA
    } else {
        $env:XDG_CONFIG_HOME
    }
    $path = [System.IO.Path]::Combine($root, 'bookmarks', 'bm.rc')

    if (!(Test-Path -Path $path -File)) {
        New-Item -Path $path -ItemType File -Force
    }

    return $path
}

function Get-TextEditor {
    if ($env:EDITOR) {
        return $env:EDITOR
    }

    return 'notepad.exe'
}