### DC-Build-ADDSForest

### Install Directory Services 
Install-WindowsFeature AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools

### Create the domain
Import-Module ADDSDeployment

### Set Domain NetBios Name and Domain Name
$DomainName = "hq.corp"
$DomainNetbiosName = "hq"

Install-ADDSForest `
    -DatabasePath "C:\Windows\NTDS" `
    -DomainMode "WinThreshold" `
    -DomainName $DomainName `
    -DomainNetbiosName $DomainNetbiosName `
    -ForestMode "WinThreshold" `
    -InstallDns `
    -LogPath "C:\Windows\NTDS" `
    -SysvolPath "C:\Windows\SYSVOL" `
    -Force
