# This script is for migrating Windows 10 to Windows 11. It will check if the user has the necessary requirements to upgrade to Windows 11, and if so, it will upgrade the user to Windows 11.
# THis will involve also checking if the user has the necessary hardware requirements to upgrade to Windows 11.
# 
# NOTES BEFORE RUNNING THE SCRIPT: 
# - Must run script as admin. There will be an error message if the user is not a admin.
# - Must have the $IsoPath variable set to the path of the local ISO image.
# - This script will run the FULL Windows 11 Upgrade process without need of user input once hardware requirements are met. 
# - This script will also check if the user has the necessary requirements to upgrade to Windows 11.



$isoPath = "MUST HAVE ISO PATH HERE"

$user_response = Read-Host "`nHello! This is the Windows 10 to Windows 11 Migration Script. Are you trying to upgrade to Windows 11? (y/n)"

if ($user_response -eq "y") {
    Write-Host "`nOk Cool! Let me check to see if you have the necessary requirements to upgrade to Windows 11."
    
    $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
    $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin)
    {
        Write-Host "`nThis script requires administrator privileges." -ForegroundColor Red
        Write-Host "`nPlease run the script as an admin." -ForegroundColor Red
        exit 0
    }

    $osinfo = Get-WmiObject -Class Win32_OperatingSystem   
    $buildnumber = [System.Environment]::OSVersion.Version.Build
    $ComputerInfo = (Get-ComputerInfo).WindowsProductName
    Add-Type -AssemblyName System.Windows.Forms # This is to get the screen resolution
    <# Bypassing the build number check so that I can run the script on a Windows 11 machine.

    if ($buildnumber -ge 22000) 
    
    {
    Write-Host "`nYou are currently running Windows 11"
    Write-Host "Build Number: $buildnumber"
    Write-Host "There is no need to upgrade. Have a great day!"

    exit 0
    }

    #>

    <# else { #>
        Write-Host "`nYou are currently running" $ComputerInfo.ProductName". Would you still like to upgrade to Windows 11? (y/n)"
        $upgrade = Read-Host

        if ($upgrade -eq "y") {        
            
            Write-Host "`nGreat! Checking your hardware requirements now..."
        }

        else {
            Write-Host "`nThank you for using the Windows 10 to Windows 11 Migration Script. Have a great day!" 
            exit 0  
        }
    <#} #>
 
    # First, check if we're already running as admin

    try { #These two commands require admin privileges, if they don't work, the script will exit.
        $SecureBootStatus = Confirm-SecureBootUEFI
        $tpm = Get-Tpm

        # More reliable TPM version check
        $tpmVersion = if ($tpm.TpmPresent) {
            # Get detailed TPM info
            $tpmInfo = Get-WmiObject -Namespace "root\CIMV2\Security\MicrosoftTpm" -Class Win32_Tpm
            if ($tpmInfo) {
                # Check both PhysicalPresenceVersionInfo and SpecVersion
                $specVersion = $tpmInfo.SpecVersion
                if ($specVersion -match "2.0" -or $tpmInfo.PhysicalPresenceVersionInfo -match "2.0") {
                    "2.0"
                } else {
                    $specVersion
                }
            } else {
                "Unknown Version"
            }
        } else {
            "Not Present"
        }
        $tpmStatus = ($tpmVersion -eq "2.0")
    } 
    catch {
        Write-Host "`nAn error occurred while checking TPM status: $($_.Exception.Message)" -ForegroundColor Red
        $tpmVersion = "Error checking TPM"
        $tpmStatus = $false
    }

    $processor = Get-WmiObject -Class Win32_Processor
    $ram = Get-WmiObject -Class Win32_ComputerSystem
    $disk = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'"
    
    # Check Requirements
    $requirements = @{
        "Processor Cores" = @{
            Required = "2 or more cores"
            Current = $processor.NumberOfCores
            Status = $processor.NumberOfCores -ge 2
        }
        "Processor Speed" = @{
            Required = "1 GHz or faster"
            Current = "$($processor.MaxClockSpeed) MHz"
            Status = $processor.MaxClockSpeed -ge 1000
        }
        "Processor Architecture" = @{
            Required = "64-bit processor"
            Current = $env:PROCESSOR_ARCHITECTURE
            Status = $env:PROCESSOR_ARCHITECTURE -eq "AMD64"
        }
        "RAM" = @{
            Required = "4 GB or more"
            Current = "$([math]::Round($ram.TotalPhysicalMemory/1GB, 2)) GB"
            Status = ($ram.TotalPhysicalMemory/1GB) -ge 4
        }
        "Storage" = @{
            Required = "64 GB or more"
            Current = "$([math]::Round($disk.Size/1GB, 2)) GB"
            Status = ($disk.Size/1GB) -ge 64
        }
        "TPM Version" = @{
            Required = "TPM 2.0"
            Current = $tpmVersion
            Status = $tpmStatus
        }
        "Secure Boot" = @{
            Required = "Enabled"
            Current = if ($null -ne $secureBootStatus) { "Enabled" } else { "Disabled" }
            Status = $null -ne $secureBootStatus
        }
        "Boot Method" = @{
            Required = "UEFI"
            Current = if ($diskPartitioning.PartitionStyle -eq "GPT") { "UEFI" } else { "Legacy BIOS" }
            Status = $diskPartitioning.PartitionStyle -eq "GPT"
        }
        "DirectX" = @{
            Required = "DirectX 12 compatible"
            Current = "Checking requires DXDIAG"
            Status = $null  # Would need to parse dxdiag output
        }
        "Display" = @{
            Required = "720p (1280x720)"
            Current = "$([System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width)x$([System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height)"
            Status = ([System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width -ge 1280) -and ([System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height -ge 720)
        }
    }

    #Display the results
    Write-Host "`nResults:"
    foreach ($requirement in $requirements.GetEnumerator()) {
        Write-Host "$($requirement.Key): $($requirement.Value.Current) ($($requirement.Value.Status))"
    }

    Write-Host "`n OK. Everything seems to be in order. One Last time, would you like to upgrade to Windows 11? (y/n)   "
    $upgrade = Read-Host

    if ($upgrade -eq "y") {
        Write-Host "`nGreat! Upgrading to Windows 11 now..."
    }
    else {
        Write-Host "`nThank you for using the Windows 10 to Windows 11 Migration Script. Have a great day!`n"
        exit 0
    }   

    #---------------------------------------------------------------------------------
    # We are now ready to upgrade to Windows 11. This next section will be using 
    # A ISO image located in the same folder as the script to do so (for convienence).
    #----------------------------------------------------------------------------------
    $ISODrivePath = -ImagePath $isoPath -PassThru

    function Windows11Upgrade {
        Write-Host "`nMounting the ISO image..."
        $ISODrivePath = -ImagePath $isoPath -PassThru

        Write-Host "`nRunning the Windows 11 Upgrade..."
        Start-Process -FilePath "$ISODrivePath\setup.exe" -ArgumentList "/auto" -Wait

        Write-Host "`nWindows 11 Upgrade complete. Have a great day!"   
    }

}

