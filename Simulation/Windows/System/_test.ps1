$script:Counter = 0

While($script:Counter -lt 10)
{
    Write-Host "Hello World"
    Sleep 1
    $script:Counter++
}
