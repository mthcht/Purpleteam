<#
    T1082 - System Information Discovery
    T1124 - System Time Discovery
    T1056.001 - Input Capture: Keylogging
    Get idle time, if idle time is higher than X seconds:
    - log activity
    - or wake up the user with voice speach
#>

 Param(
    [Parameter(Mandatory = $false)]
    [switch]$log,
    [Parameter(Mandatory = $false)]
    [int]$spytime,
    [Parameter(Mandatory = $false)]
    [switch]$wake,
    [Parameter(Mandatory = $false)]
    [switch]$help
)

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force

function Log_activity(){
    while(1){
        $endtime = Get-Date
        $away = ([TimeSpan]::FromMilliseconds([uint32][Environment]::TickCount - [uint32]([System.Runtime.InteropServices.Marshal]::ReadInt32(0x7ffe02e4)))).TotalSeconds
        $elapsedtime = ($endtime - $starttime)
        if ($elapsedtime.Seconds -gt $spytime){
            Write-Host -ForegroundColor Cyan "The time limit has been reached, Activity moniroted time:" $elapsedtime.Seconds "seconds from $starttime to $endtime, ending monitoring."
            exit 1
        }
        if ($away -gt 60){
            Write-Host -ForegroundColor Green (Get-Date -UFormat %s)": The user has been away since $away seconds"
            sleep 60
        }
        else{
            Write-Host -ForegroundColor Red (Get-Date -UFormat %s)": The user is actively using the computer"
            sleep 60
        }
    }
}

function Wakemeup(){
    # The user is probably away from the computer, do any malicious actions or just wake him up ^^
    Add-Type -AssemblyName System.Speech 
    $synth = New-Object -TypeName System.Speech.Synthesis.SpeechSynthesizer
    $synth.Volume = 100
    $voices = $synth.GetInstalledVoices() | Select-Object -ExpandProperty VoiceInfo | Select-Object Name,Culture
    while(1){
        $away = ([TimeSpan]::FromMilliseconds([uint32][Environment]::TickCount - [uint32]([System.Runtime.InteropServices.Marshal]::ReadInt32(0x7ffe02e4)))).TotalSeconds
        if ($away -gt $spytime){
            foreach($voice in $voices){
                $synth.SelectVoice($voice.Name)
                if($voice.Culture -like "en-*"){
                    $synth.Speak("wake up")
                }
                elseif($voice.Culture -like "fr-*"){
                    $synth.Speak("réveillez vous")
                }
                elseif($voice.Culture -like "pt-*"){
                    $synth.Speak("Accorda seu cuzao")
                }
            }
        }
    }
}

function gethelp(){
    Write-Host -ForegroundColor Cyan "Description: Get idle time, if idle time is higher than X seconds: log activity or wake up the user with voice speach"
    Write-Host -ForegroundColor Cyan "Arguments:`n`n-wake wake up the user if idle time is > `$spytime`n-log monitor and log user activity`n-spytime idle time in seconds (if not provided = 3600 seconds) can be used with -wake and -log`n`nExamples:`n"
    Write-Host -ForegroundColor Yellow "Monitor user activity for 6 hours:`n powershell -ep Bypass -File .\get_idle_time.ps1 -log -spytime 21600`n"
    Write-Host -ForegroundColor Yellow "Monitor user activity and wake up the user if idle for more than 5 minutes:`n powershell -ep Bypass -File .\get_idle_time.ps1 -wake -spytime 300`n"
    Write-Host -ForegroundColor Yellow "Monitor user activity with default time (1 hour):`n powershell -ep Bypass -File .\get_idle_time.ps1 -log`n"
    Write-Host -ForegroundColor Yellow "Monitor user activity and wake up the user if idle for more than 1 hour (default time):`n powershell -ep Bypass -File .\get_idle_time.ps1 -wake`n"
    exit 1
}

if($help){gethelp}
$starttime = Get-Date
if($wake -and $log){Write-Host -ForegroundColor Red "Error: You cannot use both argument -wake and -log, use one of them";gethelp;exit 1}
if(-not $wake -and -not $log){Write-Host -ForegroundColor Red "Error: You provide an argument`n"; gethelp;exit 1}
if($help){gethelp}

if($wake){
    Write-Host -ForegroundColor Cyan (Get-Date -UFormat %s)": Waking up user if AFK..."
    if(-not ($spytime)){
        Write-Host -ForegroundColor Cyan "-spytime not provided, will set default monitoring time to 3600 seconds"
        $spytime = 3600
    }
    wakemeup
}
if($log){
    Write-Host -ForegroundColor Cyan (Get-Date -UFormat %s)": Logging user activity..."
    if(-not ($spytime)){
        Write-Host -ForegroundColor Cyan "-spytime not provided, will set default monitoring time to 3600 seconds"
        $spytime = 3600
    }
    Log_activity
}

Stop-Transcript
