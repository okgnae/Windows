### DC-Sysmon-Update
### https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon

###
$SysmonPathZip = "C:\Users\Administrator\Desktop\Sysmon.zip"
$SysmonPath = "C:\Users\Administrator\Desktop\Sysmon"
$SysmonConfig = "C:\users\Administrator\Documents\Sysmon-Config.xml"
$SysmonExe = "$SysmonPath" + "\Sysmon64.exe"
$NetLogON = "\\hq.corp\NETLOGON\"
$NetLogONSysmon = "$NetLogON" + "\Sysmon"


###
Expand-Archive -Path $SysmonPathZip -DestinationPath $SysmonPath -Force -Verbose


###
New-Item -ItemType Directory -Path $NetLogON -Name Sysmon -Force -Verbose
Copy-Item -Path $SysmonExe -Destination $NetLogONSysmon -Force -Verbose
Copy-Item -Path $SysmonConfig -Destination $NetLogONSysmon -Force -Verbose


#############################################
$DCSysmonInstallUpdate = '
### DC-Sysmon-InstallUpdate

$SysmonService = Get-Service -Name Sysmon64 -ErrorAction SilentlyContinue

If ($? -eq $False)
{
    Write-Host "Sysmon Not Installed"
    ### Install Sysmon
    Copy-Item -Path \\hq.corp\NETLOGON\Sysmon\Sysmon64.exe -Destination C:\Windows\System32\config -Force -Verbose
    Copy-Item -Path \\hq.corp\NETLOGON\Sysmon\Sysmon-Config.xml -Destination C:\Windows\System32\config  -Force -Verbose
    Start-Process -FilePath C:\Windows\System32\config\Sysmon64.exe -ArgumentList "-accepteula -i C:\Windows\System32\config\Sysmon-Config.xml"
}

Else
{
    $SysmonNLExe = (Get-ItemProperty -Path \\hq.corp\NETLOGON\Sysmon\Sysmon64.exe -Name LastWriteTime).LastWriteTime
    $SysmonLocalExe = (Get-ItemProperty -Path C:\Windows\System32\config\Sysmon64.exe -Name LastWriteTime).LastWriteTime
    
    If ($SysmonNLExe -gt $SysmonLocalExe)
    {
        ### UnInstall Sysmon
        Start-Process -FilePath C:\Windows\Sysmon64.exe -ArgumentList "-u force"
        ### Install Sysmon
        Copy-Item -Path \\hq.corp\NETLOGON\Sysmon\Sysmon64.exe -Destination C:\Windows\System32\config -Force -Verbose
        Copy-Item -Path \\hq.corp\NETLOGON\Sysmon\Sysmon-Config.xml -Destination C:\Windows\System32\config  -Force -Verbose
        Start-Process -FilePath C:\Windows\System32\config\Sysmon64.exe -ArgumentList "-accepteula -i C:\Windows\System32\config\Sysmon-Config.xml"
    }
    
    Else
    {
        $SysmonNLConf = (Get-ItemProperty -Path \\hq.corp\NETLOGON\Sysmon\Sysmon-Config.xml -Name LastWriteTime).LastWriteTime
        $SysmonLocalConf = (Get-ItemProperty -Path C:\Windows\System32\config\Sysmon-Config.xml -Name LastWriteTime).LastWriteTime
    
        If ($SysmonNLConf -gt $SysmonLocalConf)
        {
            ### Update Sysmon
            Copy-Item -Path \\hq.corp\NETLOGON\Sysmon\Sysmon-Config.xml -Destination C:\Users\Public  -Force -Verbose
            Start-Process -FilePath C:\Windows\Sysmon64.exe -ArgumentList "-c C:\Users\Public\Sysmon-Config.xml"
            Remove-Item -Path "C:\Users\Public\Sysmon-Config.xml" -Force -Verbose
        }
    }

    $SysmonService = Get-Service -Name Sysmon64 -ErrorAction SilentlyContinue

    If ($SysmonService -ne "Running")
    {
        Set-Service -Name Sysmon64 -Status Running
    }
}
'
#############################################

New-Item -ItemType File -Path $NetLogONSysmon -Name DC-Sysmon-InstallUpdate.ps1 -Force -Verbose
Set-Content -Value $DCSysmonInstallUpdate -Path $NetLogONSysmon\DC-Sysmon-InstallUpdate.ps1 -Force -Verbose


###
$NetLogONSysmonAcl = Get-ACL -Path $NetLogONSysmon
$NetLogONSysmonAcl.SetAccessRuleProtection($True, $True)


###
$NetLogONSysmonAcl.Access | ForEach-Object -Process {$NetLogONSysmonAcl.RemoveAccessRule($_)}


###
$NetLogONSysmonAclRules = @()
$NetLogONSysmonAclRules += [System.Security.AccessControl.FileSystemAccessRule]::new("NT AUTHORITY\SYSTEM","FullControl","Allow")
$NetLogONSysmonAclRules += [System.Security.AccessControl.FileSystemAccessRule]::new("hq.corp\Domain Admins","FullControl","Allow")
$NetLogONSysmonAclRules += [System.Security.AccessControl.FileSystemAccessRule]::new("hq.corp\Domain Computers","ReadAndExecute","Allow")
$NetLogONSysmonAclRules += [System.Security.AccessControl.FileSystemAccessRule]::new("hq.corp\Domain Controllers","ReadAndExecute","Allow")
$NetLogONSysmonAclRules | ForEach-Object -Process {$NetLogONSysmonAcl.AddAccessRule($_)}


###
Set-Acl -Path $NetLogONSysmon -AclObject $NetLogONSysmonAcl -Verbose
Get-ChildItem -Path $NetLogONSysmon -Recurse | Set-Acl -AclObject $NetLogONSysmonAcl -Verbose
Get-ACL -Path $NetLogONSysmon | Select-Object -Property *
