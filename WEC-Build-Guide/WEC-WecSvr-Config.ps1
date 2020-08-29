### WEC-WecSvr-Config
# https://docs.microsoft.com/en-us/windows/win32/wec/setting-up-a-source-initiated-subscription
# https://docs.microsoft.com/en-us/windows/security/threat-protection/use-windows-event-forwarding-to-assist-in-intrusion-detection


### Split WEC service to its own process
Start-Process -FilePath 'C:\Windows\System32\sc.exe' -ArgumentList 'config wecsvc type=own' -NoNewWindow -Wait
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Wecsvc' -Name 'Start' -Type 'DWord' -Value '2' -Verbose
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Wecsvc' -Name 'DelayedAutostart' -Type 'DWord' -Value '1' -Verbose
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Wecsvc' -Name 'DependOnService' -Type 'MultiString' -Value ('HTTP', 'Eventlog', 'WinRM') -Verbose
Restart-Service -Name 'Wecsvc' -Force


### Enable Forwarded Event Log Channel and set max size to 1GB
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\ForwardedEvents' -Name 'Enabled' -Value '1' -Verbose
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\ForwardedEvents' -Name 'MaxSize' -Value '1024000000' -Verbose


### WinRM
# winrm /?
# winrm get /?
# winrm get winrm/config
# winrm enumerate /?
# winrm enumerate winrm/config/Listener
# winrm set /?
# winrm set winrm/config/Listener?Address=*+Transport=HTTP '@{ListeningOn="10.0.0.113"}'
Start-Process -FilePath 'C:\Windows\System32\winrm.cmd' -ArgumentList 'quickconfig'


### NETSH
# netsh.exe /?
# netsh.exe http /?
# netsh.exe http delete urlacl /?
# netsh.exe http add urlacl /?
# netsh.exe http show urlacl
### Create Netsh.exe Process Start Info
$NetSHProcStartInfo = New-Object System.Diagnostics.ProcessStartInfo -Property @{
    FileName = 'C:\Windows\system32\netsh.exe'
    RedirectStandardError = $true
    RedirectStandardOutput = $true
    UseShellExecute = $false
    Arguments = 'http show urlacl'
}

### Create Netsh.exe Process with Start Info
$NetShProc = New-Object System.Diagnostics.Process -Property @{
    StartInfo = $NetSHProcStartInfo
}

### Start the NetSH Process
$NetShProc.Start() | Out-Null
$NetShProc.WaitForExit()
### Capture NetSH Process StdOut
$NetShProcStdOut = $NetShProc.StandardOutput.ReadToEnd()
### Dispose of the NetSH process
$NetShProc.Dispose()

### Get URL strings for ws-man 
$Urlacls = ($NetShProcStdOut.Split('\r') | Select-String -Pattern "http.*").Matches.Value.TrimEnd()
### Get SDDL string for ws-man
$SDDL_OLD = (($NetShProcStdOut.Split('\r') | Select-String -Pattern 'SDDL: (.*)').Matches.Value[0].Replace('SDDL: ','')).TrimEnd()
### Add A;;GX;;;S-1-5-20 NETWORK SERVICE Account SID to SDDL
$SDDL_NEW = $SDDL_OLD + '(A;;GX;;;S-1-5-20)'

### Remove URL ACLs
foreach ($Urlacl in $Urlacls)
{
    Start-Process -FilePath 'C:\Windows\system32\netsh.exe' -ArgumentList ('http delete urlacl url=' + $Urlacl) -Wait -NoNewWindow
}

### Create New URL ACLs
foreach ($Urlacl in $Urlacls)
{
    Start-Process -FilePath 'C:\Windows\system32\netsh.exe' -ArgumentList ('http add urlacl url=' + $Urlacl + ' sddl=' + $SDDL_NEW) -Wait -NoNewWindow
}

### Restart computer
Restart-Computer -Force

### After the Restart Create the WEF subscriptions
### WECUTL
# wecutil.exe /?
# wecutil.exe enum-subscription
# wecutil get-subscription WEF-Subscription-Baseline /f:xml > C:\users\Administrator.hq\Documents\WEF-Subscription-Baseline.xml
# wecutil delete-subscription WEF-Subscription-Baseline
Start-Process -FilePath 'C:\Windows\System32\wecutil.exe' -ArgumentList 'quick-config /quiet:true'
Start-Process -FilePath 'C:\Windows\system32\wecutil.exe' -ArgumentList 'create-subscription C:\users\Administrator.hq\Documents\WEF-Subscription-Baseline.xml'
