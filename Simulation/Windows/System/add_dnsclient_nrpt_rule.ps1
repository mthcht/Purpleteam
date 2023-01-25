<# 
    T1584.002 - Compromise Infrastructure: DNS Server
    
   .SYNOPSIS
   Creates a DNS Client NRPT rule.

   .DESCRIPTION
   This script creates a DNS Client NRPT rule using the provided parameters. If no parameters are provided, the script will set default parameters for the namespace and nameservers.

   .PARAMETER Namespace
   The namespace of the DNS Client NRPT rule.

   .PARAMETER NameServers
   The nameservers of the DNS Client NRPT rule.

   .EXAMPLE
   .\Create-DNSCientNRPTRule.ps1 -Namespace "office.com" -NameServers "10.0.13.37"
    Create a NRPT rule that configures the server named 10.0.13.37 as a DNS server for the namespace office.com.
#>

Param( 
    [Parameter(Mandatory=$false)][string]$Namespace = $Namespace,
    [Parameter(Mandatory=$false)][string]$NameServers = $NameServers
)

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append

# Set Default Parameters if no arguments are provided
If (-not $Namespace) {$Namespace = "github.com"}
If (-not $NameServers) {$NameServers = "0.0.0.0"}

# Create DNS Client NRPT Rule
Try
{
    # Create DNS Client NRPT Rule
    $Result = Add-DnsClientNrptRule -Namespace $Namespace -NameServers $NameServers
    Write-Output "DNS Client NRPT Rule successfully created for namespace: $Namespace and nameservers: $NameServers."
}
Catch
{
    # Catch Errors
    Write-Warning -Message "An error occurred creating the DNS Client NRPT Rule for namespace: $Namespace and nameservers: $NameServers."
    Write-Warning -Message $_.Exception
}

Stop-Transcript
