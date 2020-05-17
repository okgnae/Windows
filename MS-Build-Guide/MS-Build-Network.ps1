### MS-Build-Network
### Administrator 12qw!@QW

### Get Management Network Adapter
$ManagementInterfaceIndex = (Get-NetAdapter | Sort-Object -Property ifIndex).ifIndex[0]
# Remove-NetIPAddress -InterfaceIndex $ManagementInterfaceIndex

### Define Management Network
$ManagementIPAddress = "192.168.1.112"
$ManagementPrefixLength = "24"
$ManagementServerAddresses = ""


### Add IP, Netmask, Gateway, and DNS to Management NIC
New-NetIPAddress `
	-InterfaceIndex $ManagementInterfaceIndex `
	-IPAddress $ManagementIPAddress `
	-PrefixLength $ManagementPrefixLength

Set-NetIPInterface -InterfaceIndex $ManagementInterfaceIndex -Dhcp Disabled

Set-DNSClientServerAddress –interfaceIndex $ManagementInterfaceIndex –ServerAddresses $ManagementServerAddresses

### Get Service Network Adapter
$ServiceInterfaceIndex = (Get-NetAdapter | Sort-Object -Property ifIndex).ifIndex[1]
# Remove-NetIPAddress -InterfaceIndex $ServiceInterfaceIndex

### Define Service Network
$ServiceIPAddress = "10.0.0.112"
$ServicePrefixLength = "24"
$ServiceDefaultGateway = "10.0.0.1"
$ServiceServerAddresses = "10.0.0.111"

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
$ComputerName = "WINMS1"

### Rename, Reboot
Rename-Computer -NewName $ComputerName -Force
Restart-Computer -Force
