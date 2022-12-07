[CmdletBinding()]
[OutputType([string])]
Param
(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Encrypt', 'Decrypt')]
    [String]$Mode,

    [Parameter(Mandatory = $true)]
    [String]$Key,

    [Parameter(Mandatory = $true)]
    [String]$Path
)

Begin {
    $shaManaged = New-Object System.Security.Cryptography.SHA256Managed
    $aesManaged = New-Object System.Security.Cryptography.AesManaged
    $aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aesManaged.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
    $aesManaged.BlockSize = 128
    $aesManaged.KeySize = 256
}

Process {
    $aesManaged.Key = $shaManaged.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($Key))
    $files = Get-ChildItem -Path $Path -Recurse -Force | Where-Object {!($_.PSIsContainer)}

    switch ($Mode) {
        'Encrypt' {
            try {
                foreach ($file in $files) {
                    $plainBytes = [System.IO.File]::ReadAllBytes($file.FullName)
                    $encryptor = $aesManaged.CreateEncryptor()
                    $encryptedBytes = $encryptor.TransformFinalBlock($plainBytes, 0, $plainBytes.Length)
                    $encryptedBytes = $aesManaged.IV + $encryptedBytes
                    $outPath = $file.FullName + ".mthcht"
                    [System.IO.File]::WriteAllBytes($outPath, $encryptedBytes)
                    (Get-Item $outPath).LastWriteTime = $file.LastWriteTime
                    [System.IO.File]::Delete($file.FullName)
                }
                return "Files encrypted to $Path"
            }
            catch {
                Write-Error -Message "Error encrypting files in $Path"
            }
        }

        'Decrypt' {
            try {
                foreach ($file in $files) {
                    $cipherBytes = [System.IO.File]::ReadAllBytes($file.FullName)
                    $aesManaged.IV = $cipherBytes[0..15]
                    $decryptor = $aesManaged.CreateDecryptor()
                    $decryptedBytes = $decryptor.TransformFinalBlock($cipherBytes, 16, $cipherBytes.Length - 16)
                    $outPath = $file.FullName -replace ".mthcht"
                    [System.IO.File]::WriteAllBytes($outPath, $decryptedBytes)
                    (Get-Item $outPath).LastWriteTime = $file.LastWriteTime
                }
                return "Files decrypted to $Path"
            }
            catch {
                Write-Error -Message "Error decrypting files in $Path"
            }
        }
    }
}

End {
    $shaManaged.Dispose()
    $aesManaged.Dispose()
}
