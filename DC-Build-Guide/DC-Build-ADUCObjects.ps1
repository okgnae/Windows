### DC-Build-ADUCObjects


### Create OUs
$Domain = "DC=hq,DC=corp"
New-ADOrganizationalUnit -Name "HQ" -Path $Domain -Verbose
New-ADOrganizationalUnit -Name "Users" -Path ("OU=HQ," + $Domain) -Verbose
New-ADOrganizationalUnit -Name "Groups" -Path ("OU=HQ," + $Domain) -Verbose
New-ADOrganizationalUnit -Name "Servers" -Path ("OU=HQ," + $Domain) -Verbose
New-ADOrganizationalUnit -Name "Workstations" -Path ("OU=HQ," + $Domain) -Verbose


### Create WinMS1 Computer object
$HqServersOU = "OU=Servers,OU=HQ,DC=hq,DC=corp"

$WinMS1 = @{
    Name            = "WINMS1"
    SamAccountName  = "WINMS1"
    Path            = $HqServersOU
}

New-ADComputer @WinMS1 -Verbose

       
### Create WinMS1 Computer object
$WinWEC1 = @{
    Name           = "WINWEC1"
    SamAccountName = "WNIWEC1"
    Path           = $HqServersOU
}

New-ADComputer @WinWEC1 -Verbose


### Create User Objects
### Password 12qw!@QW
$Password = Read-Host -AsSecureString
$HqUsersOU = "OU=Users,OU=HQ,DC=hq,DC=corp"

$HqUser = @{
    Name                 = "User"
    DisplayName          = "User"
    Path                 = $HqUsersOU
    SamAccountName       = "User"
    UserPrincipalName    = "User@hq.corp"
    AccountPassword      = $Password
    PasswordNeverExpires = $True
    Enabled              = $True
    Description          = "HQ User"
}

New-ADUser @HqUser -Verbose
