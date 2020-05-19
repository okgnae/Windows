### DC-GPO-Import
$Domain = "hq.corp"
$GpoBackupPath = "C:\Users\Administrator\Desktop\"
$GpoBackupDir = "GpoBackup"
$GpoBackupPathDir = $GpoBackupPath + $GpoBackupDir
$GpoReportFilepaths = (Get-ChildItem -Path ($GpoBackupPathDir + "\*\gpreport.xml")).Fullname

### Loop through each GPO and import them from GPO Backups
foreach ($GpoReportFilepath in $GpoReportFilepaths)
{
    $GpoName = (Select-Xml -Path $GpoReportFilepath -XPath *).Node.Name

Import-GPO `
    -BackupGpoName $GpoName `
    -CreateIfNeeded `
    -Domain $Domain `
    -Path $GpoBackupPathDir `
    -TargetName $GpoName

}


### Import GPO Links, This will only work if you have a matching AD structure
$GpoLinks = Import-Csv -Path "$GpoBackupPathDir\GpoLinks.csv"

foreach ($GpoLink in $GpoLinks)
{
    New-GPLink `
        -Domain $Domain `
        -Name $GpoLink.DisplayName `
        -Target $GpoLink.Target `
        -ErrorAction SilentlyContinue

    if ($? -eq $true)
    {
        Write-Host "Created New GPO Link from" $GpoLink.DisplayName "to" $GpoLink.Target -ForegroundColor Cyan
    }
}

foreach ($GpoLink in $GpoLinks)
{
    Set-GPLink `
        -Domain $Domain `
        -Name $GpoLink.DisplayName `
        -Target $GpoLink.Target `
}
