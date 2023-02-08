<#
    T1489 - Service Stop
    T1562.001 - Impair Defenses: Disable or Modify Tools
    T1562.004 - Impair Defenses: Disable or Modify System Firewall
    Kill splunk or splunkforwarder process, stop and disable service, also block 9997 port for outbound requests on local firewall (Splunk by default use port 9997 TCP to send logs)
    work in progress
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force

function get_status{
    $splunk_process = Get-Process -Name splunkd -Verbose -ErrorAction SilentlyContinue
    $splunkfw_service = Get-Service -Name SplunkForwarder -Verbose -ErrorAction SilentlyContinue | Select-Object Status -ExpandProperty Status
    $splunk_service = Get-Service -Name Splunk -Verbose -ErrorAction SilentlyContinue | Select-Object Status -ExpandProperty Status
    return $splunk_process, $splunkfw_service, $splunk_service
}

function kill_splunk(){
    param (
        [Parameter(Mandatory=$false)]
        [string]$service,
        [Parameter(Mandatory=$false)]
        [string]$process
    )

    if($process){
        Write-Host -ForegroundColor Cyan "Killing $process process"
        Stop-Process -Name $process -Force -Verbose -ErrorAction SilentlyContinue
    }
    if($service){
        Write-Host -ForegroundColor Cyan "Stopping and disabling $service service"
        Stop-Service -Name $service -Force -Verbose -ErrorAction SilentlyContinue
        Set-Service $service -StartupType Disabled -Verbose -ErrorAction SilentlyContinue
    }
    Write-Host -ForegroundColor Cyan "Blocking $service port 9997 on firewall"
    New-NetFirewallRule -DisplayName "Block $service 9997" -Direction Outbound -LocalPort 9997 -Protocol TCP -Action Block -Verbose -ErrorAction SilentlyContinue
    if (Get-NetFirewallPortFilter | Where-Object -Property RemotePort -eq 9997){
        Write-Host -ForegroundColor Green "Success: port 9997 outbound connections are blocked on firewall"
    }
    else {
        Write-Host -ForegroundColor Red "Error: failed to block port 9997 outbound connections on firewall"
    }
}

try {
    get_status
    if ($splunk_process -or $splunkfw_service -eq "Running" -or $splunk_service -eq "Running"){
        if ($splunk_process){
            Write-Host -ForegroundColor Cyan "Splunkd process is running on the system"
            kill_splunk -process splunkd
        }
        if ($splunkfw_service -eq "Running"){
            Write-Host -ForegroundColor Cyan "SplunkForwarder service is running on the system"
            kill_splunk -service SplunkForwarder
        }
        if ($splunk_service -eq "Running"){
            Write-Host -ForegroundColor Cyan "Splunk service is running on the system"
            kill_splunk -service Splunk
        }
        get_status
        if ($splunk_process){
            Write-Host -ForegroundColor Red "Error: Failed to kill $service process"
        }
        elseif ($splunkfw_service -eq "Running"){
            Write-Host -ForegroundColor Red "Error: Failed to stop $service service"
        }
        elseif ($splunk_service -eq "Running"){
            Write-Host -ForegroundColor Red "Error: Failed to stop $service service"
        }
        else {
            Write-Host -ForegroundColor Green "Success: Splunk process or service is now killed and not running on the system"
        }
    }
    else {
        Write-Host -ForegroundColor Green "Splunk is not running on the system"
    }
}
catch {
    Write-Host -ForegroundColor Red "`nErorr: $_"
}

Stop-Transcript
