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
        Write-Host "Update Sysmon Installation"
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
            Write-Host "Update Sysmon Config"
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
