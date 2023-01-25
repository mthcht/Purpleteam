<#
  T1113 - Screen Capture
  T1056 - Input Capture
  Capture mouse cursor position and buttons actions, take a screenshot for each mouse click and save it in $Directory, works on multiple Screens
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append

$Directory = "$env:USERPROFILE\Pictures\Saved Pictures"
$CaptureQuality = 80

Function Get-CursorClick
{
    $click = [System.Windows.Forms.UserControl]::MouseButtons
    return $click
}

Function Get-CursorPosition
{
    $pos = [System.Windows.Forms.Cursor]::Position
    return $pos
}

Function Capture-Screen($pos){
    Set-StrictMode -Version 2
    Add-Type -AssemblyName System.Windows.Forms

    $ScreenCapture = [System.Windows.Forms.Screen]::AllScreens 

    foreach ($Screen in $ScreenCapture)
    {
        $FileName = Join-Path (Resolve-Path $Directory) ('{0}-{1}-{2}.jpg' -f ($Screen.DeviceName -split "\\")[3], (Get-Date).ToString('yyyyMMdd_HHmmss'), $pos)
        $Bitmap = New-Object System.Drawing.Bitmap($Screen.Bounds.Width, $Screen.Bounds.Height)
        $Graphics = [System.Drawing.Graphics]::FromImage($Bitmap)
        $Graphics.CopyFromScreen($Screen.Bounds.Location, (New-Object System.Drawing.Point(0,0)), $Screen.Bounds.Size)
        $Graphics.Dispose()

        $EncoderParam = [System.Drawing.Imaging.Encoder]::Quality
        $EncoderParamSet = New-Object System.Drawing.Imaging.EncoderParameters(1) 
        $EncoderParamSet.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter($EncoderParam, $CaptureQuality) 
        $JPGCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where{$_.MimeType -eq 'image/jpeg'}
        $Bitmap.Save($FileName ,$JPGCodec, $EncoderParamSet)
        $FileSize = [INT]((Get-Childitem $FileName).Length / 1KB)
        Write-Host ("Display [$($Screen.DeviceName)] ScreenCapture saved to File [$FileName] Size [$FileSize] KB")
    }
}

$pos = Get-CursorPosition

<#
capture screenshot on mouse click at a different position

while($true)
{
    $newpos = Get-CursorPosition
    Write-Host "Current Position $newpos"
    if ($pos -ne $newpos)
    {
       $event = Get-CursorClick
       Write-Host "New Position $newpos"
       if($event -ne "None")
       {
            # Take the screenshot
            Write-Host "Taking screenshot at $newpos"
            Capture-Screen
        }
       $pos = $newpos
    }
}
#>

while($true)
{
    $newpos = Get-CursorPosition
    $event = Get-CursorClick
    Write-Host "New Position $newpos"
    if($event -ne "None")
    {
        # Take the screenshot
        Write-Host "Taking screenshot at $newpos"
        Capture-Screen($newpos)
    }
    $pos = $newpos
}

Stop-Transcript
