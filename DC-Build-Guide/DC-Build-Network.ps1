### DC-Build-Network
### Administrator 12qw!@QW

### Get Management Network Adapter
$ManagementInterfaceIndex = (Get-NetAdapter).ifIndex[0]

### Define Management Network
$ManagementIPAddress = "192.168.1.111"
$ManagementPrefixLength = "24"
$ManagementDnsServerAddresses = ""

### Add IP, Netmask, Gateway, and DNS to Management NIC
New-NetIPAddress `
	-InterfaceIndex $ManagementInterfaceIndex `
	-IPAddress $ManagementIPAddress `
	-PrefixLength $ManagementPrefixLength

Set-NetIPInterface -InterfaceIndex $ManagementInterfaceIndex -Dhcp Disabled

Set-DNSClientServerAddress –interfaceIndex $ManagementInterfaceIndex –ServerAddresses $ManagementDnsServerAddresses

### Get Service Network Adapter
$ServiceInterfaceIndex = (Get-NetAdapter).ifIndex[1]

### Define Service Network
$ServiceIPAddress = "10.0.0.111"
$ServicePrefixLength = "24"
$ServiceDefaultGateway = "10.0.0.1"
$ServiceServerAddresses = "10.0.0.10"

### Add IP, Netmask, Gateway, and DNS to Service NIC
New-NetIPAddress `
	-InterfaceIndex $ServiceInterfaceIndex `
	-IPAddress $ServiceIPAddress `
	-PrefixLength $ServicePrefixLength `
	-DefaultGateway $ServiceDefaultGateway

Set-NetIPInterface -InterfaceIndex $ServiceInterfaceIndex -Dhcp Disabled

Set-DNSClientServerAddress –interfaceIndex $ServiceInterfaceIndex –ServerAddresses $ServiceServerAddresses

# Disable IPv6 on all NICs
Disable-NetAdapterBinding -Name * -ComponentID ms_tcpip6

### Turn off IPv6 Random & Temporary IP Assignments
Set-NetIPv6Protocol -RandomizeIdentifiers Disabled
Set-NetIPv6Protocol -UseTemporaryAddresses Disabled

### Turn off IPv6 Transition Technologies
Set-Net6to4Configuration -State Disabled
Set-NetIsatapConfiguration -State Disabled
Set-NetTeredoConfiguration -Type Disabled

### Define the Computer Name
$ComputerName = "WINDC1"

### Rename, Reboot
Rename-Computer -NewName $ComputerName -Force
Restart-Computer -Force
