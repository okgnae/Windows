### DC-Build-DnsSitesTime

### Define DNS and Sites & Services Settings
$IPv4netID = "10.0.0.0/24"
$siteName = "HQ"
$location = "HQ"

### Add DNS Reverse Lookup Zones
Add-DNSServerPrimaryZone -NetworkID $IPv4netID -ReplicationScope 'Forest' -DynamicUpdate 'Secure' -Verbose

### Make Changes to Sites & Services
Rename-ADObject (Get-ADReplicationSite).DistinguishedName -NewName $siteName -Verbose
New-ADReplicationSubnet -Name $IPv4netID -site $siteName -Location $location -Verbose
Get-ADReplicationSubnet -Filter *

### Re-Register DC's DNS Records
Register-DnsClient -Verbose

### Enable Default Aging/Scavenging Settings for All Zones and this DNS Server
Set-DnsServerScavenging –ScavengingState $True –ScavengingInterval 7:00:00:00 –ApplyOnAllZones -Verbose
Get-DnsServerZone | Where-Object {$_.IsAutoCreated -eq $False -and $_.ZoneName -ne 'TrustAnchors'} | Set-DnsServerZoneAging -Aging $True -Verbose

### Create DNS Records for Kafka
Add-DnsServerResourceRecordA -Name "KAFKA0001" -ZoneName "hq.corp" -IPv4Address "10.0.0.101" -CreatePtr
Add-DnsServerResourceRecordA -Name "KAFKA0002" -ZoneName "hq.corp" -IPv4Address "10.0.0.102" -CreatePtr
Add-DnsServerResourceRecordA -Name "KAFKA0003" -ZoneName "hq.corp" -IPv4Address "10.0.0.103" -CreatePtr

######################################################
### Have not set up NTP service in the environment yet
### Define Authoritative Internet Time Servers
# $timePeerList = "0.us.pool.ntp.org 1.us.pool.ntp.org"

### Set Time Configuration
# w32tm /config /manualpeerlist:$timePeerList /syncfromflags:manual /reliable:yes /update
