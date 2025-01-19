# This script is for migrating Windows 10 to Windows 11. It will check if the user has the necessary requirements to upgrade to Windows 11, and if so, it will upgrade the user to Windows 11.
# THis will involve also checking if the user has the necessary hardware requirements to upgrade to Windows 11.

$user_response = Read-Host "`nHello! This is the Windows 10 to Windows 11 Migration Script. Are you trying to upgrade to Windows 11? (y/n)"

if ($user_response -eq "y") {
    Write-Host "`nOk Cool! Let me check to see if you have the necessary requirements to upgrade to Windows 11."
    
    $windows_version = Get-WmiObject -Class Win32_OperatingSystem | Select-Object -WindowsProductName
    if ($windows_version -like "11.*") 
    {
        Write-Host "`nYou are currently running Windows 11. There is no need to upgrade. Have a great day!"
        exit 0
    }

    else {
        Write-Host "`nYou are currently running Windows $windows_version. Would you like to upgrade to Windows 11? (y/n)"
        $upgrade = Read-Host
        if ($upgrade -eq "y") {
            Write-Host "`nGreat! Checking your hardware requirements now..."
        }
        else {
            Write-Host "`nThank you for using the Windows 10 to Windows 11 Migration Script. Have a great day!"
            exit 0  
        }
    }

    $processor = Get-WmiObject -Class Win32_Processor
    $tpm = Get-Tpm
    $ram = Get-WmiObject -Class Win32_ComputerSystem
    $disk = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'"
    $secureBootStatus = Confirm-SecureBootUEFI
    
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
    foreach ($requirement in $requirements) {
        Write-Host "$($requirement.Key): $($requirement.Value.Current) ($($requirement.Value.Status))"
    }





}
else {
    Write-Host "`nThank you for using the Windows 10 to Windows 11 Migration Script. Have a great day!"
    exit 0
}
