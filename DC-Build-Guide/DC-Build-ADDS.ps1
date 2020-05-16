### DC-Build-ADDS

### Set Domain NetBios Name and Domain Name
$DomainName = "hq.corp"
$DomainNetbiosName = "hq"

### Install Directory Services 
Install-WindowsFeature AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools

### Create the domain
Import-Module ADDSDeployment

Install-ADDSForest `
    -DomainName $DomainName `
    -DomainNetbiosName $DomainNetbiosName `
    -ForestMode "WinThreshold" `
    -DomainMode "WinThreshold" `
    -InstallDns $true `
    -DatabasePath "C:\Windows\NTDS" `
    -LogPath "C:\Windows\NTDS" `
    -SysvolPath "C:\Windows\SYSVOL" `
    -NoRebootOnCompletion $false `
    -Force

### Define DNS and Sites & Services Settings
$NetworkID = "10.0.0.0/24"
$siteName = "HQCORP"
$location = "HQCORP"

# Add DNS Reverse Lookup Zones
Add-DNSServerPrimaryZone -NetworkID $NetworkID -ReplicationScope 'Forest' -DynamicUpdate 'Secure'

# Make Changes to Sites & Services
$defaultSite = Get-ADReplicationSite | Select-Object  DistinguishedName
Rename-ADObject $defaultSite.DistinguishedName -NewName $siteName
New-ADReplicationSubnet -Name $NetworkID -site $siteName -Location $location

# Re-Register DC's DNS Records
Register-DnsClient

# Enable Default Aging/Scavenging Settings for All Zones and this DNS Server
Set-DnsServerScavenging –ScavengingState $True –ScavengingInterval 7:00:00:00 –ApplyOnAllZones
$Zones = Get-DnsServerZone | Where-Object {$_.IsAutoCreated -eq $False -and $_.ZoneName -ne 'TrustAnchors'}
$Zones | Set-DnsServerZoneAging -Aging $True
