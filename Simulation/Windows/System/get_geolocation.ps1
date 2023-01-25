<#
  T1430 - Location Tracking
  T1614 - System Location Discovery
  Simple script to get the latitude an longitude from a windows machine
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append

function Get-GeoLocation{
	try {
        #Add an assembly from the .Net framework (System.Device)
        Add-Type -AssemblyName System.Device 

        #Create a new instance of the GeocoordinateWatcher object
        $Watcher = New-Object System.Device.Location.GeoCoordinateWatcher 

        #Start the GeoCoordinateWatcher
        $Watcher.Start() 

        #Pause the script until the GeoCoordinateWatcher is ready and permission is not denied
        while (($Watcher.Status -ne 'Ready') -and ($Watcher.Permission -ne 'Denied')) {
	        Start-Sleep -Milliseconds 100 
        }  

        #If permission is denied, write an error
        if ($Watcher.Permission -eq 'Denied'){
	        return "[failed] Error: Permission Access Denied to use GeoCoordinateWatcher "
        }
        #Else, select the relevant results and manipulate them to get the latitude, longitude and link
        else {
	        $location = $Watcher.Position.Location | Select Latitude,Longitude
	        $location = $location -split " "
	        $latitude = $location[0].Substring(11) -replace ".$"
	        $longitude = $location[1].Substring(10) -replace ".$" 
	        $link = "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude"
	        return $latitude, $longitude, $link
        }

	}
    #Catch any errors
    catch {
        return "[failed] Error: $_"
    } 
}

Get-GeoLocation


<# 
    todo: something to work on (without using API)

# Create a web request
$request = [System.Net.WebRequest]::Create("https://www.google.com/maps/search/?api=1&query=$latitude,$longitude")

# Set Request Method
$request.Method = "GET"

# Create a response object
$response = $request.GetResponse()

# Get the response stream
$stream = $response.GetResponseStream()

# Create a Stream Reader Object
$reader = New-Object System.IO.StreamReader($stream)

# Read the response
$response = $reader.ReadToEnd()

# Create a regex pattern
$pattern_country = '\,\[\"([a-z]|[A-Z])([a-z]|[A-Z])\"\,.+?(?=\,)\,\"(?<3>.+?(?=\"))\"\]'
$pattern_city = '\[\[\[1\,\[\[\\\"(?<1337>.+?(?=\\))\\\"\]\]\]\,'

# Execute the regex
$match_country = [RegEx]::Matches($response, $pattern_country)
$match_city = [RegEx]::Matches($response, $pattern_city)

# Display the result
$country = $match_country.Groups[3].Value
$city = ($match_city.Groups[0].Value).Split('\"')[2]

Write-Host "$city --- $country"
#>

Stop-Transcript
