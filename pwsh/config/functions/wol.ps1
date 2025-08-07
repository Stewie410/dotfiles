[Alias('wol', 'wakeonlan', 'etherwake')]
function Invoke-WakeOnLan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern('^([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}$')]
        [string[]]
        $MacAddress
    )

    BEGIN {
        Write-Verbose -Message "Initialize UDP Client"
        $UDP = [System.Net.Sockets.UdpClient]::new()
        Write-Debug -Message "UDP Client: $UDP"
    }

    PROCESS {
        foreach ($addr in $MacAddress) {
            try {
                Write-Debug -Message "Convert $addr to byte[]"
                $mac = $addr -split '[:-]' | ForEach-Object {
                    [System.Convert]::ToByte($_, 16)
                }

                Write-Debug -Message "Composing magic packet"
                $packet = [byte[]](,0xFF * 102)
                for ($i = 6; $i -le 101; $i++) {
                    $packet[$i] = $mac[($i % 6)]
                }

                Write-Verbose -Message "Connecting to client: $addr"
                $UDP.Connect(([System.Net.IPAddress]::Broadcast), 4000)

                Write-Verbose -Message "Sending Wake-on-LAN Packet: $addr"
                $UDP.Send($packet, $packet.Length)
            } catch {
                Write-Warning -Message "Unable to send ${addr}: $_"
            }
        }
    }

    END {
        Write-Verbose -Message "Close & Dispose UDP Client"
        $UDP.Close()
        $UDP.Dispose()
    }
}
