# # https://seeminglyscience.github.io/powershell/2017/09/30/invocation-operators-states-and-scopes
$GlobalState = [PSModuleInfo]::new($false)
$GlobalState.SessionState = $ExecutionContext.SessionState

# async runspace
$Runspace = [RunspaceFactory]::CreateRunspace($Host)
$Powershell = [Powershell]::Create($Runspace)
$Runspace.Open()
$Runspace.SessionStateProxy.PSVariable.Set("GlobalState", $GlobalState)

# arg-cmp
$Private = [System.Reflection.BindingFlags] "Instance, NonPublic"
$ContextField = [System.Management.Automation.EngineIntrinsics].GetField("_context", $Private)
$GlobalContext = $ContextField.GetValue($ExecutionContext)

$ContextCACProperty = $GlobalContext.GetType().GetProperty("CustomArgumentCompleters", $Private)
$ContextNACProperty = $GlobalContext.GetType().GetProperty("NativeArgumentCompleters", $Private)
$CAC = $ContextCACProperty.GetValue($GlobalContext)
$NAC = $ContextNACProperty.GetValue($GlobalContext)

if ($null -eq $CAC) {
    $CAC = [System.Collections.Generic.Dictionary[string, scriptblock]]::new()
    $ContextCACProperty.SetValue($GlobalContext, $CAC)
}

if ($null -eq $NAC) {
    $NAC = [System.Collections.Generic.Dictionary[string, scriptblock]]::new()
    $ContextNACProperty.SetValue($GlobalContext, $NAC)
}

# automation engine & exec context
$RSEngineField = $Runspace.GetType().GetField("_engine", $Private)
$RSEngine = $RSEngineField.GetValue($Runspace)
$EngineContextField = $RSEngine.GetType().GetFields($Private) |
    Where-Object { $_.FieldType.Name -eq "ExecutionContext" }
$RSContext = $EngineContextField.GetValue($RSEngine)

# set runspace to use global arg-cmp
$ContextCACProperty.SetValue($RSContext, $CAC)
$ContextNACProperty.SetValue($RSContext, $NAC)

Remove-Variable -ErrorAction Ignore -Name @(
    "Private",
    "GlobalContext",
    "ContextField",
    "ContextCACProperty",
    "ContextNACProperty",
    "CAC",
    "NAC",
    "RSEngineField",
    "RSEngine",
    "EngineContextField",
    "RSContext",
    "Runspace"
)

$Wrapper = {
    # sleep to prevent "issues"
    Start-Sleep -Milliseconds 200

    . $GlobalState {
        . $DeferredLoad
        Remove-Variable -Name "DeferredLoad"
    }
}

$AsyncResult = $Powershell.AddScript($Wrapper.ToString()).BeginInvoke()

$roe = @{
    MessageData = $AsyncResult
    InputObject = $Powershell
    EventName = "InvocationStateChanged"
    SourceIdentifier = "__DeferredLoaderCleanup"
    Action = {
        $AsyncResult = $Event.MessageData
        $Powershell = $Event.Sender

        if ($Powershell.Steams.Error) {
            $Powershell.Streams.Error | Out-String | Write-Host -ForegroundColor "Red"
        }

        try {
            # swallow output
            $null = $Powershell.EndInvoke($AsyncResult)
        } catch {
            $_ | Out-String | Write-Host -ForegroundColor "Red"
        }

        $h1 = Get-History -Id 1 -ErrorAction Ignore
        if ($h1.CommandLine -match '\bcode\b.*shellIntegration\.ps1') {
            Write-Host -ForegroundColor Yellow -Message @"
VSCode shell integration is enabled, which may cause problems with deferred loading.
To disable this feature, set "terminal.integrated.shellIntegration.enabled" to "false" in VSCode settings
"@
        }

        $Powershell.Dispose()
        $Runspace.Dispose()
        Unregister-Event -SourceIdentifier "__DeferredLoaderCleanup"
        Get-Job -Name "__DeferredLoaderCleanup" | Remove-Job
    }
}

$null = Register-ObjectEvent @roe

Remove-Variable -Name @("Wrapper", "Powershell", "AsyncResult", "GlobalState", "roe")
