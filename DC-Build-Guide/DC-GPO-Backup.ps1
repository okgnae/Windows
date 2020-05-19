### DC-GPO-Backup
$GpoBackupPath = "C:\Users\Administrator\Desktop\"
$GpoBackupDir = "GpoBackup"
$GpoBackupPathDir = $GpoBackupPath + $GpoBackupDir

### Create Back up Directory
if (!(Test-Path $GpoBackupPathDir))
{
    New-Item -ItemType Directory -Path $GpoBackupPath -Name $GpoBackupDir
}

### Remove old Backups
Get-ChildItem $GpoBackupPathDir | Remove-Item -Recurse -Force

### BackUP all GPOs
Backup-GPO -All -Path $GpoBackupPathDir

### BackUP all GPO Links
$GpoInherits = @()
$GpoInherits += (Get-ADDomain).DistinguishedName | Get-GPInheritance
$GpoInherits += (Get-ADOrganizationalUnit -Filter * | Where-Object -Property LinkedGroupPolicyObjects -Like -Value cn=*).DistinguishedName | Get-GPInheritance
$GpoInherits.GpoLinks | Export-Csv -NoTypeInformation -Path "$GpoBackupPathDir\GpoLinks.csv"
