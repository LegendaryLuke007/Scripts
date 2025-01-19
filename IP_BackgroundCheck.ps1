# This is a PowerShell Script that intakes a IP given to it, 
# cross references online sources for information, and provides
# that info in a nice and readable format.
# The idea is that you can have this script up and running on the side while you are 
# doing Threat Hunting, and it can help gather information

# This script is designed to be run on a Windows machine, and will require the user to have
# a Windows machine with PowerShell installed.

# The script will take an IP address as input, and then use the following sources to gather information:
# - AbuseIPDB
# - IP-API
# - AlienVault OTX


try {
    $config = Get-Content -Path "config.json" | ConvertFrom-Json    
}

catch { #If the config.json file is not found, prompt the user to create one
    Write-Host "Error: Failed to load config.json"
    exit 1
}

# Import API Keys
function Get-APIKey
{
    return @{ #Return a hashtable with the API keys for each source 
        AlienVault = $env:ALIENVAULT_API_KEY 
        AbuseIPDB = $env:ABUSEIPDB_API_KEY 
        IPAPI = $env:IP_API_KEY 
    }
}

function GetIPInfo () { #This function will take an IP address as input, and return the information from the API sources   

    param (
        [parameter(Mandatory = $true)] #IP is a required parameter
        [string]$IP, #
        [string]$AbuseIDDB, #AbuseIPDB API Key                  
        [string]$IPAPI, #IP-API API Key
        [string]$AlienVaultOTX #AlienVault OTX API Key
    )       

    $url_AbuseIPDB = "https://api.abuseipdb.com/api/v2/check"
    $url_IPAPI = "https://ip-api.com/json/$IP"
    $url_AlienVaultOTX = "https://otx.alienvault.com/api/v1/indicators/ip/$IP/general"

    $header = @{ #Create a hashtable for the headers
        "AbuseIPDB-Key" = $AbuseIDDB #AbuseIPDB API Key
        "IP-API-Key" = $IPAPI #IP-API API Key
        "X-OTX-API-Key" = $AlienVaultOTX #AlienVault OTX API Key
        "Accept" = "application/json" #Accept header is required for all requests   
    }  

    $response_AbuseIPDB = Invoke-RestMethod -Uri $url_AbuseIPDB -Headers $header -Method Get
    $response_IPAPI = Invoke-RestMethod -Uri $url_IPAPI -Headers $header -Method Get
    $response_AlienVaultOTX = Invoke-RestMethod -Uri $url_AlienVaultOTX -Headers $header -Method Get  
}


#Main Loop 
while ($true -eq 1)
{
echo "Hello! Please enter an IP address to begin the background check."
$IP = Read-Host #

echo "Thank you! We will now begin the background check on $IP"

#Call the GetIPInfo function with the IP address and API keys from the config.json file 
GetIPInfo -IP $IP -AbuseIDDB $config.AbuseIDDB -IPAPI $config.IPAPI -AlienVaultOTX $config.AlienVaultOTX 

#Display the information in a nice and readable format
Write-Host "`nResults from AbuseIPDB:"
Write-Host "------------------------"
Write-Host "Abuse Confidence Score: $($response_AbuseIPDB.data.abuseConfidenceScore)%"
Write-Host "Total Reports: $($response_AbuseIPDB.data.totalReports)"
Write-Host "Country: $($response_AbuseIPDB.data.countryName)"
Write-Host "ISP: $($response_AbuseIPDB.data.isp)"
Write-Host "Domain: $($response_AbuseIPDB.data.domain)"
Write-Host "Last Reported: $($response_AbuseIPDB.data.lastReportedAt)"

Write-Host "`nResults from IP-API:" 
Write-Host "-------------------"
Write-Host "Country: $($response_IPAPI.country)" 
Write-Host "Region: $($response_IPAPI.regionName)"
Write-Host "City: $($response_IPAPI.city)"
Write-Host "ISP: $($response_IPAPI.isp)"
Write-Host "Organization: $($response_IPAPI.org)"
Write-Host "AS: $($response_IPAPI.as)"

Write-Host "`nResults from AlienVault OTX:"
Write-Host "--------------------------"
Write-Host "Reputation: $($response_AlienVaultOTX.reputation)"
Write-Host "Number of Pulses: $($response_AlienVaultOTX.pulse_info.count)"
Write-Host "First Seen: $($response_AlienVaultOTX.first_seen)"
Write-Host "Last Seen: $($response_AlienVaultOTX.last_seen)"
Write-Host "Country: $($response_AlienVaultOTX.country_name)"
Write-Host "City: $($response_AlienVaultOTX.city)"
Write-Host "`n"


echo "Would you like to check another IP? (y/n)"
$Continue = Read-Host



if ($Continue -eq "n")
{
    break 
}   

}
