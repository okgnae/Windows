### WEC-WEF-Service
# https://docs.microsoft.com/en-us/windows/win32/wec/setting-up-a-source-initiated-subscription
# https://docs.microsoft.com/en-us/windows/security/threat-protection/use-windows-event-forwarding-to-assist-in-intrusion-detection#appendix-d---minimum-gpo-for-wef-client-configuration

### Split WEC service to its own process
Start-Process -FilePath C:\Windows\System32\sc.exe -ArgumentList "config wecsvc type=own"
Set-Service wecsvc -StartupType Automatic
Restart-Service -Name Wecsvc -Force


### Forwarded Event Log Config
Start-Process -FilePath C:\Windows\system32\wevtutil.exe -ArgumentList "set-log ForwardedEvents /enabled:true"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\ForwardedEvents" -Name MaxSize -Value 1052704768 -Verbose -Force


### WinRM
Start-Process -FilePath C:\Windows\System32\wecutil.exe -ArgumentList "quick-config /quiet:true"


### WECUTL
# wecutil.exe /?
# wecutil.exe enum-subscription
# wecutil get-subscription WEF-Subscription-Baseline /f:xml > C:\users\Administrator.hq\Documents\WEF-Subscription-Baseline.xml
# wecutil delete-subscription WEF-Subscription-Baseline

Start-Process -FilePath C:\Windows\system32\wecutil.exe -ArgumentList "create-subscription C:\users\Administrator.hq\Documents\WEF-Subscription-Baseline.xml"


### Restart computer
Restart-Computer -Force


### NETSH
# netsh.exe /?
# netsh.exe http /?
# netsh.exe http add urlacl /?
# netsh.exe http show urlacl


### Remove all URL ACLs
$NetSh = "C:\Windows\system32\netsh.exe"

$Urlacls = netsh.exe http show urlacl | Select-String -Pattern "http.*"
foreach ($Urlacl in $Urlacls)
{
    $ArgListUrlacl = "http delete urlacl url=" + $Urlacl.Matches.Value
    Start-Process -FilePath $NetSh -ArgumentList $ArgListUrlacl
}


### Create New URL ACLs
Start-Process -FilePath $NetSh -ArgumentList 'http add urlacl url=http://+:47001/wsman/ sddl="D:(A;;GX;;;S-1-5-80-569256582-2953403351-2909559716-1301513147-412116970)(A;;GX;;;S-1-5-80-4059739203-877974739-1245631912-527174227-2996563517)(A;;GX;;;S-1-5-20)"'
Start-Process -FilePath $NetSh -ArgumentList 'http add urlacl url=http://+:5985/wsman/ sddl="D:(A;;GX;;;S-1-5-80-569256582-2953403351-2909559716-1301513147-412116970)(A;;GX;;;S-1-5-80-4059739203-877974739-1245631912-527174227-2996563517)(A;;GX;;;S-1-5-20)"'
Start-Process -FilePath $NetSh -ArgumentList 'http add urlacl url=https://+:5986/wsman/ sddl="D:(A;;GX;;;S-1-5-80-569256582-2953403351-2909559716-1301513147-412116970)(A;;GX;;;S-1-5-80-4059739203-877974739-1245631912-527174227-2996563517)(A;;GX;;;S-1-5-20)"'


### Restart computer
Restart-Computer -Force
