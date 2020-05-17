### MS-Build-JoinAD

$Credential = Get-Credential -UserName "hq\Administrator" -Message "Provide hq\Administrator Password"

Add-Computer -DomainName hq.corp -Credential $Credential -Restart
