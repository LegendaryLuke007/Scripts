# This is a PowerShell Script that intakes a IP given to it, 
# cross references online sources for information, and provides
# that info in a nice and readable format.
# The idea is that you can have this script up and running on the side while you are 
# doing Threat Hunting, and it can help gather information about the IP address.

# This script is designed to be run on a Windows machine, and will require the user to have
# a Windows machine with PowerShell installed.

# The script will take an IP address as input, and then use IP-API to gather information

function GetIPInfo () { #This function will take an IP address as input, and return the information from the API sources   

    param (
        [parameter(Mandatory = $true)] #IP is a required parameter
        [string]$IP, #               
        [string]$IPAPI, #IP-API API Key
    )       

    $url_IPAPI = "http://ip-api.com/json/$IP" #IP-API URL needs to be HTTP to be the free tier

   # $response_AbuseIPDB = Invoke-RestMethod -Uri $url_AbuseIPDB -Headers $headers_AbuseIPDB -Method Get
    $response_IPAPI = Invoke-RestMethod -Uri $url_IPAPI -Method Get
    #$response_AlienVaultOTX = Invoke-RestMethod -Uri $url_AlienVaultOTX -Headers $headers_AlienVaultOTX -Method Get  

    return $response_IPAPI
}


#Main Loop 
while ($true -eq 1)
{
Write-Host "Hello! Please enter an IP address to begin the background check."
$IP = Read-Host #Prompt the user for an IP address

Write-Host "Thank you! We will now begin the background check on $IP"

$response_IPAPI = GetIPInfo -IP $IP  #Call the GetIPInfo function with the IP address and API keys from the config.json file 


Write-Host "`nResults from IP-API:" 
Write-Host "-------------------"
Write-Host "Country: $($response_IPAPI.country)" 
Write-Host "Region: $($response_IPAPI.regionName)"
Write-Host "City: $($response_IPAPI.city)"
Write-Host "ISP: $($response_IPAPI.isp)"
Write-Host "Organization: $($response_IPAPI.org)"
Write-Host "AS: $($response_IPAPI.as)"


Write-Host "Would you like to check another IP? (y/n)"
$Continue = Read-Host

if ($Continue -eq "n")
{
    break 
}   

}
