function ssha {
    ssh -o "User=root" $Args
}

function sshw {
    ssh -F "$HOME\.ssh\work\config" $Args
}

function sshwa {
    ssh -o "User=root" -F "$HOME\.ssh\work\config" $Args
}
