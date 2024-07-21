function ipinfo {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateScript({ $_ -as [IPAddress] })]
        [string]
        $IPAddress
    )

    $uri = 'ipinfo.io' + (if ($IPAddress.Length -gt 0) {
            '/' + $IPAddress
        } else {
            ''
        })

    $json = (Invoke-WebRequest -Uri "$uri/json").Content -split "`n"

    return (if (Get-Command -Name 'ConvertFrom-Json' -ErrorAction SilentlyContinue) {
            $json | ConvertFrom-Json
        } else {
            $obj = [PSCustomObject]@{}
            foreach ($line in $json[1..9]) {
                $key, $val = ($line -split ':', 2).Trim()
                $member = @{
                    InputObject = $obj
                    MemberType  = 'NoteProperty'
                    Name        = $key.Trim('"')
                    Value       = ($val -replace ',$').Trim('"')
                    Force       = $True
                }
                Add-Member @member
            }
            $obj
        })
}

function pubip {
    (Invoke-WebRequest -Uri 'ipinfo.io/ip').Content
}
