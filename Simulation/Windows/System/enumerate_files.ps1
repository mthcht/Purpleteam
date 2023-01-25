# T1083 - File and Directory Discovery

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append

$csvPath = "$env:tmp\enumerated_files.csv"
$dirs = @("C:\Documents and Settings","C:\Windows","C:\Program Files","C:\Program Files (x86)","C:\ProgramData","C:\Users","C:\Documents and Settings","C:\Program Files\Common Files","C:\WINDOWS\system32","C:\WINDOWS\SysWOW64","C:\WINDOWS\Temp","C:\WINDOWS\Prefetch","C:\WINDOWS\system32\drivers","C:\WINDOWS\SoftwareDistribution","C:\WINDOWS\System32\spool\drivers","C:\WINDOWS\system32\config","C:\WINDOWS\Microsoft.NET","C:\Documents and Settings\All Users","C:\Documents and Settings\All Users\Application Data","C:\Documents and Settings\Default User","C:\Documents and Settings\Default User\Application Data")
$data = @()

foreach ($dir in $dirs)
{
    $files = Get-ChildItem -Path $dir -Recurse
    foreach ($file in $files)
    {
        $obj = [pscustomobject]@{
            File = $file.FullName
        }
        $data += $obj
    }
}

$data | Export-Csv -Path $csvPath -NoTypeInformation

Stop-Transcript
