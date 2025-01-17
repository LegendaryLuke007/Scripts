# This Script is for Checking for Updates on Local Software on a Windows PC through Powershell
# To run, download this script and .\AppUpdateCheck.ps1 in powershell

# Show all possible upgrades to the software on the local computer
winget upgrade --include-unknown

$gogotag = "yes"
$Checkout = ""
# Prompting User based on information

while (gogotag -eq "yes") #Loop runs continuously as long as the user isn"t finished with upgrading applications.
  {
  $UpgradeApplications = Read-Host "Do you want to upgrade ALL of your local applications? (yes/no)"

  if ($UpgradeApplications -eq "yes") #If the user wants to upgrade all applications
    {
      wingget upgrade -all  # Update all applications
    
    }
  
  elseif ($UpgradeApplications -eq "no")
    {
  
      $SpecificUpgrade = Read-Host "No Problem! Is there any specific application you would like to upgrade? (yes/no)" #If not all applications, maybe a few specific ones?

      if ($SpecificUpgrade -eq "yes") #If the User wants to upgrade a specific Application
        {
      
          winget upgrade --include-unknown #Shows full List of applications that are out of date
          $ApplicationName = Read-Host "Which application on the above list are you wanting to upgrade?"
          $ApplicationExists = winget list --query $ApplicationName #Checking to see if the ApplicationName exists on the list
          
          if ($ApplicationExists) #Check to see if application referenced actually exists
            {
              $DoubleConfirmation = Read-Host "Are you sure you want to upgrade?"  #Double check that they want to upgrade
            
            if ($DoubleConfirmation = -eq "yes") 
              {
              
                winget upgrade --id $ApplicationName #Application is upgraded
                $Checkout = Read-Host "OK!, $ApplicationName Should be upgraded, do you need to upgrade something else?" #Asks to see if that is all that is needed?
              }
              
            }
        }
    }
    
    if ($Checkout -eq "") #If the user doesn"t upgrade anything then it should come here
      {
      $Checkout = Read-Host "OK!, $ApplicationName Should be upgraded, do you need to upgrade something else?"
      }
      
    if ($Checkout -eq "no")
    {
    gogotag = "no" #Turns off while loop and stops the program from running any more times
    }
  }
  Read-Host "Great! Have a wonderful Day :)!"
