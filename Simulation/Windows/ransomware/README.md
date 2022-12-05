- replace path variable in the script by the path folder containing the files you want to crypt.
$path = "C:\Users\FIXME\Documents\test_ransom"

Execute the powershell script: powershell -ExecutionPolicy Bypass -File '.\test_ransom.ps1'

TODO:
- Add arguments to set the path, static key, decrypt and crypt option
