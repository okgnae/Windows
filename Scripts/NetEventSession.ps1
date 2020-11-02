$Session = "SyslogPcap"
$OutFilePath = "C:\Windows\Temp\$Session.etl"

Get-NetEventSession -ErrorAction SilentlyContinue | Stop-NetEventSession
Get-NetEventSession -ErrorAction SilentlyContinue | Remove-NetEventSession

Remove-Item -Path $OutFilePath -Force -Verbose

New-NetEventSession -Name $Session -CaptureMode SaveToFile -LocalFilePath $OutFilePath -MaxFileSize 10240
Add-NetEventProvider -Name “Microsoft-Windows-TCPIP” -SessionName $Session -Level 0x4
#Add-NetEventWFPCaptureProvider -SessionName $Session -TCPPorts 389
Start-NetEventSession -Name $Session

Get-NetEventSession

# (Get-ChildItem -Path $OutFilePath | Select-Object Length).Length / 1GB

Get-WinEvent -Oldest -Path $OutFilePath | Where-Object -Property Message -Match "UDP:"






# Get-NetTCPConnection -LocalPort 5985
# Get-NetTCPConnection -RemotePort 389 
# Get-Process -Id 2688 | Select-Object -Property *
