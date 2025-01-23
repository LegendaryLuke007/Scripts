# This is a simple script to execute on a Windows 11 Machine that'll scan ports and provide
# a list of open ports.

<#Write-Host "Scanning ports..."

Write-Host "Scan complete. Here are the open ports:"

Test-NetConnection -ComputerName localhost -Port 80 #HTTP
Test-NetConnection -ComputerName localhost -Port 443 #HTTPS
Test-NetConnection -ComputerName localhost -Port 22 #SSH
Test-NetConnection -ComputerName localhost -Port 25 #SMTP
Test-NetConnection -ComputerName localhost -Port 53 #DNS
Test-NetConnection -ComputerName localhost -Port 110 #POP3
Test-NetConnection -ComputerName localhost -Port 143 #IMAP
Test-NetConnection -ComputerName localhost -Port 465 #SMTPS
Test-NetConnection -ComputerName localhost -Port 993 #IMAPS
Test-NetConnection -ComputerName localhost -Port 995 #POP3S


function Display-OpenPorts {
    Write-Host "Scan complete. Here are the open ports:"
}
#>
Get-NetTCPConnection | #This will show all the listening connections on the machine.
    Where-Object State -eq "Listen" | 
    Select-Object @{Name="Port";Expression={$_.LocalPort}},
                  @{Name="Service";Expression={(Get-Process -Id $_.OwningProcess).ProcessName}},
                  RemoteAddress,
                  RemotePort,
                State |
    Sort-Object Port |
    Format-Table -AutoSize

Get-NetTCPConnection | #This will show all the established connections on the machine.
    Where-Object State -eq "Established" | 
    Select-Object @{Name="Port";Expression={$_.LocalPort}},
                  @{Name="Service";Expression={(Get-Process -Id $_.OwningProcess).ProcessName}},
                  LocalAddress,
                  LocalPort,
                  RemoteAddress,
                  RemotePort,
                  State,
                  OwningProcess,
                  CreationTime,
                  OffloadState,
                  AppliedSetting |   
    Sort-Object Port |
    Format-Table -AutoSize

Get-NetTCPConnection | #This will show all the established connections on the machine.
    Where-Object State -eq "SynSent" | 
    Select-Object @{Name="Port";Expression={$_.LocalPort}},
                  @{Name="Service";Expression={(Get-Process -Id $_.OwningProcess).ProcessName}},
                  LocalAddress,
                  LocalPort,
                  RemoteAddress,
                  RemotePort,
                  State,
                  OwningProcess,
                  CreationTime,
                  OffloadState,
                  AppliedSetting |   
    Sort-Object Port |
    Format-Table -AutoSize


