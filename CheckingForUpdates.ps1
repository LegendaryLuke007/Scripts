# Install Windows if it isn't present
Install-Module -Name PSWindowsUpdate -Force -Confirm: false

# Import Module 
Import-Module PSWindowsUpdate

# Show all possible Updates
Get-WindowsUpdate

# Show all possible upgrades to the software on the local computer
winget upgrade --include-unknown

# Prompting User based on information
$UpgradeApplications = Read-Host "Do you want to upgrade your local applications? (yes/no)"

if ($UpgradeApplications -eq 'yes') 
  {
    wingget upgrade -all  # Update all applications
    
  }
  
if ($UpgradeApplications = Read-Host 'no')
  {
  
    $SpecificUpgrade = Read-Host "Is there any specific application you would like to upgrade? (yes/no)"

    if ($SpecificUpgrade -eq 'yes')
    {
      
      winget upgrade --include-unkown
      $ApplicationName = "Which application on the above list are you wanting to upgrade?"
      $DoubleConfirmation = "Are you sure you want to upgrade?"

      if ($DoubleConfirmation = 'yes')
      {
        winget delete $ApplicationName
      }
    }
  }
