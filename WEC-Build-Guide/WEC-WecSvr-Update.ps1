### WEC-WecSvr-Update

# Currently written to only handle a single subscription

# wecutil.exe /?
# wecutil.exe set-subscription /?
# https://support.microsoft.com/en-us/help/4491324/0x57-error-wecutil-command-update-event-forwarding-subscription
# https://blog.ctglobalservices.com/powershell/rja/capture-output-from-command-line-tools-with-powershell/


$WecUtil = "C:\Windows\System32\wecutil.exe"

$WecUtilProcessStartInfo = New-Object System.Diagnostics.ProcessStartInfo
$WecUtilProcessStartInfo.FileName = $WecUtil
$WecUtilProcessStartInfo.RedirectStandardError = $true
$WecUtilProcessStartInfo.RedirectStandardOutput = $true
$WecUtilProcessStartInfo.UseShellExecute = $false
$WecUtilProcessStartInfo.Arguments = "enum-subscription"

$WecUtilProcess = New-Object System.Diagnostics.Process
$WecUtilProcess.StartInfo = $WecUtilProcessStartInfo
$WecUtilProcess.Start() | Out-Null
$WecUtilProcess.WaitForExit()

$Subscription = $WecUtilProcess.StandardOutput.ReadToEnd()

$WecUtilProcess.Dispose()

Start-Process -FilePath $WecUtil -ArgumentList ("delete-subscription " + $Subscription.TrimEnd())
Start-Process -FilePath $WecUtil -ArgumentList "create-subscription C:\users\Administrator.hq\Documents\WEF-Subscription-Baseline.xml"
