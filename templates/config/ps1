<#
.SYNOPSIS
synopsis

.Description
Description
#>

# [CmdletBinding(DefaultParameterSetName = 'Default')]
# param ()

function Write-Log {
    [CmdletBinding(DefaultParameterSetName = 'info')]
    param(
        [Parameter(ParameterSetName = 'info')]
        [switch]
        $Info,

        [Parameter(Mandatory, ParameterSetName = 'warn')]
        [switch]
        $Warn,

        [Parameter(Mandatory, ParameterSetName = 'error')]
        [switch]
        $Err,

        [Parameter(Mandatory, ParameterSetName = 'verbose')]
        [switch]
        $Verb,

        [Parameter(Mandatory, ParameterSetName = 'debug')]
        [switch]
        $Dbug,

        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        $Message,

        [Parameter()]
        [switch]
        $Log
    )

    BEGIN {
        $stamp = Get-Date -UFormat '+%Y-%m-%dT%T%Z'
        $caller = (Get-PSCallStack)[1].Command
        $level = $PSCmdlet.ParameterSetName.ToUpper()
    }

    PROCESS {
        $parts = @(
            $stamp,
            $level,
            $caller,
            $Message.ToString()
        )

        $full = $parts -join '|'
        $short = $parts[2..3] -join '|'

        if ($Log) {
            Add-Content -Path $script:LogFile -Value $full
        }

        $write = @{
            Message = $short
            ErrorAction = 'Continue'
        }

        switch ($level) {
            'INFO' {
                Write-Host $short
            }
            'WARN' {
                Write-Warning @write
            }
            'ERROR' {
                Write-Warning @write
            }
            'DEBUG' {
                Write-Debug @write
            }
            'VERBOSE' {
                Write-Verbose @write
            }
        }
    }
}

function New-LogFile {
    param(
        [Parameter()]
        [string]
        $Parent = "$HOME\.log\scripts"
    )

    $opts = @{
        Path = $Parent
        ItemType = 'File'
        Name = [System.IO.Path]::GetFileNameWithoutExtension($PSCommandPath) + ".log"
        Force = $True
        ErrorAction = 'Ignore'
    }

    $p = Join-Path -Path $opts.Path -ChildPath $opts.Name

    if (Test-Path -Path $p -PathType Leaf) {
        return (Get-Item -Path $p)
    }

    New-Item @opts
}

function Invoke-Main {
    # ...
}

[string] $script:LogFile = (New-LogFile).FullName

Invoke-Main
