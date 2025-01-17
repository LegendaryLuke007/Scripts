# This Script is for Checking for Updates on Local Software on a Windows PC through Powershell
# To run, download this script and ./AppUpdateCheck.ps1 in powershell

# Show all possible upgrades to the software on the local computer
winget upgrade --include-unknown
gogotag = 'yes'
# Prompting User based on information

while (gogotag -eq 'yes')
  {
  $UpgradeApplications = Read-Host "Do you want to upgrade your local applications? (yes/no)"

  if ($UpgradeApplications -eq 'yes') #If the user wants to upgrade all applications
    {
      wingget upgrade -all  # Update all applications
    
    }
  
  elseif ($UpgradeApplications -eq 'no')
    {
  
      $SpecificUpgrade = Read-Host "No Problem! Is there any specific application you would like to upgrade? (yes/no)"

      if ($SpecificUpgrade -eq 'yes') #If the User wants to upgrade a specific Application
        {
      
          winget upgrade --include-unkown
          $ApplicationName = Read-Host "Which application on the above list are you wanting to upgrade?"
          $DoubleConfirmation = Read-Host "Are you sure you want to upgrade?"
        
        if ($DoubleConfirmation = -eq 'yes')
          {
            winget upgrade --id $ApplicationName
          }
        }
    }
    gogotag = 'no'
  }
  Read-Host "Great! Have a wonderful Day :)!"
