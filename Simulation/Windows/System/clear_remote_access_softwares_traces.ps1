<#
    work in progress
    Clear traces for AnyDesk, Teamviewer, LogMeIn,  Go2Assist, AmmyyAdmin, VNC
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force -Verbose

try {
    Write-Host -ForegroundColor Cyan "[Info] Deleting Anydesk traces connections..."
    Get-ChildItem -Path "$env:ProgramData\AnyDesk" -Filter *.trace -Recurse | Remove-Item -Force -Verbose -ErrorAction SilentlyContinue
    Get-ChildItem -Path "$env:ProgramData\AnyDesk" -Filter *.txt -Recurse | Remove-Item -Force -Verbose -ErrorAction SilentlyContinue
}
catch {
    Write-Host -ForegroundColor Red "`n[Error] Exception: $_"
}


Stop-Transcript -Verbose
