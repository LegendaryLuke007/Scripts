# This script is for migrating Windows 10 to Windows 11. It will check if the user has the necessary requirements to upgrade to Windows 11, and if so, it will upgrade the user to Windows 11.
# THis will involve also checking if the user has the necessary hardware requirements to upgrade to Windows 11.
# NOTE: Must run script as admin.

$user_response = Read-Host "`nHello! This is the Windows 10 to Windows 11 Migration Script. Are you trying to upgrade to Windows 11? (y/n)"

if ($user_response -eq "y") {
    Write-Host "`nOk Cool! Let me check to see if you have the necessary requirements to upgrade to Windows 11."
    
    $osinfo = Get-WmiObject -Class Win32_OperatingSystem   
    $buildnumber = [System.Environment]::OSVersion.Version.Build
    $ComputerInfo = Get-ComputerInfo
    

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
        Write-Host "`nYou are currently running" $reginfo.ProductName". Would you still like to upgrade to Windows 11? (y/n)"
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
    if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "`nThis script requires administrator privileges." -ForegroundColor Red
        Start-Process PowerShell -Verb RunAs -ArgumentList "-File `"$($MyInvocation.MyCommand.Path)`""
        exit
    }

    try { #These two commands require admin privileges, if they don't work, the script will exit.
        $SecureBootStatus = Confirm-SecureBootUEFI
        $tpm = Get-Tpm

    }

    catch {
        Write-Host "`nAn error occurred while checking the Secure Boot status or TPM." -ForegroundColor Red
        exit 1
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
            Current = if ($tpm) { $tpm.TpmVersion } else { "Not Found" }
            Status = if ($tpm) { $tpm.TpmVersion -ge 2.0 } else { $false }
        }
        "Secure Boot" = @{
            Required = "Enabled"
            Current = if ($null -ne $secureBootStatus) { "Enabled" } else { "Disabled" }
            Status = $null -ne $secureBootStatus
        }
    }

    #Display the results
    Write-Host "`n  Results:"
    foreach ($requirement in $requirements.GetEnumerator()) {
        Write-Host "$($requirement.Key): $($requirement.Value.Current) ($($requirement.Value.Status))"
    }


    if ($requirements.Values.Status -eq $false) {
        Write-Host "`nYou do not meet the requirements to upgrade to Windows 11."
        
        $requirements.GetEnumerator() | Where-Object {$_.Value.Status -eq $false} | ForEach-Object {
            Write-Host "❌ Failed: $($_.Key)" -ForegroundColor Red
        }       
        exit 1 
    }

    else {
        Write-Host "`nThank you for using the Windows 10 to Windows 11 Migration Script. Have a great day!"
        exit 0
    }
}

