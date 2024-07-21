function wttr {
    (Invoke-WebRequest -Uri 'wttr.in').Content
}
