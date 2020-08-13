# Empty array to hold all possible GPO links            
$gPLinks = @()            
$RestrictedGroupsCollection = @()
            
# GPOs linked to the root of the domain            
#  !!! Get-ADDomain does not return the gPLink attribute            
$gPLinks += Get-ADObject -Identity (Get-ADDomain).distinguishedName -Properties name, distinguishedName, gPLink, gPOptions            

# GPOs linked to OUs            
#  !!! Get-GPO does not return the gPLink attribute            
$gPLinks += Get-ADOrganizationalUnit -Filter * -Properties name, distinguishedName, gPLink, gPOptions            

# GPOs linked to sites            
$gPLinks += Get-ADObject -LDAPFilter '(objectClass=site)' -SearchBase "CN=Sites,$((Get-ADRootDSE).configurationNamingContext)" -SearchScope OneLevel -Properties name, distinguishedName, gPLink, gPOptions  

$ADDomain = Get-ADDomain
$GpoGuids = (Get-ChildItem -Path ("\\" + $ADDomain.NetBIOSName + "\sysvol\" + $ADDomain.DNSRoot + "\Policies") | Where-Object -Property Name -Like '{*').Name

#$GpoGuids = "CB8DFB5A-288F-40C5-9FEA-C12245EA9AD7"

foreach ($GpoGuid in $GpoGuids)
{
    $gPLinksOUs = ""
    $Members = ""
    $MembersOf = ""

    $GpoXml = Get-GPOReport -Guid $GpoGuid -ReportType Xml -ErrorAction SilentlyContinue | Select-Xml -XPath /
    $GpoDisplayName = $GpoXml.Node.GPO.Name
    $gPLinksOUs = ($gPLinks | Where-Object -property LinkedGroupPolicyObjects -Like "*$GpoGuid*").DistinguishedName

    $RestrictedGroups_COUNT = 0
    $RestrictedGroups_TOTAL = ($GpoXml.Node.GPO.Computer.ExtensionData.Extension.RestrictedGroups).Count
    
    #$Group
    while ($RestrictedGroups_COUNT -lt $RestrictedGroups_TOTAL)
    {
        $Group = $GpoXml.Node.GPO.Computer.ExtensionData.Extension.RestrictedGroups[$RestrictedGroups_COUNT].GroupName.Name.'#text'
        
        $SplitCount = ($Group -split '\\').count
        if ($SplitCount -eq 1)
           {
                $DomainSplit = ""
                $GroupSplit = ($Group -split '\\')[0]
           }

        else
           {
                $DomainSplit = ($Group -split '\\')[0]
                $GroupSplit = ($Group -split '\\')[1]
           }

        $Members_COUNT = 0
        $Members_TOTAL = ($GpoXml.Node.GPO.Computer.ExtensionData.Extension.RestrictedGroups[$RestrictedGroups_COUNT].Member | Measure-Object).Count
        
        #$Members
        while ($Members_COUNT -lt $Members_TOTAL)
        {
            if ($Members_TOTAL -gt 1)
            {
                $Members = $GpoXml.Node.GPO.Computer.ExtensionData.Extension.RestrictedGroups[$RestrictedGroups_COUNT].Member[$Members_COUNT].Name.'#text'
            }
            
            else
            {
                $Members = $GpoXml.Node.GPO.Computer.ExtensionData.Extension.RestrictedGroups[$RestrictedGroups_COUNT].Member.Name.'#text'
            }

            if ($gPLinksOUs.count -le 1)
            {
                $gPLinksOU = $gPLinksOUs

                $RestrictedGroups = New-Object -TypeName psobject
                $RestrictedGroups | Add-Member -Name GpoDisplayName -MemberType NoteProperty -Value $GpoDisplayName -Force
                $RestrictedGroups | Add-Member -Name Domain -MemberType NoteProperty -Value $DomainSplit -Force
                $RestrictedGroups | Add-Member -Name Group -MemberType NoteProperty -Value $GroupSplit -Force
                $RestrictedGroups | Add-Member -Name Members -MemberType NoteProperty -Value $Members -Force
                $RestrictedGroups | Add-Member -Name MembersOf -MemberType NoteProperty -Value $MembersOf -Force
                $RestrictedGroups | Add-Member -Name GpoGuid -MemberType NoteProperty -Value $GpoGuid -Force
                $RestrictedGroups | Add-Member -Name GpLinkOU -MemberType NoteProperty -Value $gPLinksOU -Force

                $RestrictedGroupsCollection += $RestrictedGroups
                $RestrictedGroups
            }
            
            else
            {
                foreach ($gPLinksOU in $gPLinksOUs)
                {
                    $RestrictedGroups = New-Object -TypeName psobject
                    $RestrictedGroups | Add-Member -Name GpoDisplayName -MemberType NoteProperty -Value $GpoDisplayName -Force
                    $RestrictedGroups | Add-Member -Name Domain -MemberType NoteProperty -Value $DomainSplit -Force
                    $RestrictedGroups | Add-Member -Name Group -MemberType NoteProperty -Value $GroupSplit -Force
                    $RestrictedGroups | Add-Member -Name Members -MemberType NoteProperty -Value $Members -Force
                    $RestrictedGroups | Add-Member -Name MembersOf -MemberType NoteProperty -Value $MembersOf -Force
                    $RestrictedGroups | Add-Member -Name GpoGuid -MemberType NoteProperty -Value $GpoGuid -Force
                    $RestrictedGroups | Add-Member -Name GpLinkOU -MemberType NoteProperty -Value $gPLinksOU -Force

                    $RestrictedGroupsCollection += $RestrictedGroups
                    $RestrictedGroups
                }
            }

            $Members = ""
            $Members_COUNT += 1
        }

        $MembersOf_COUNT = 0
        $MembersOf_TOTAL = ($GpoXml.Node.GPO.Computer.ExtensionData.Extension.RestrictedGroups[$RestrictedGroups_COUNT].Memberof | Measure-Object).Count

        #$MembersOf
        while ($MembersOf_COUNT -lt $MembersOf_TOTAL)
        {
            if ($MembersOf_TOTAL -gt 1)
                {
                    $MembersOf = $GpoXml.Node.GPO.Computer.ExtensionData.Extension.RestrictedGroups[$RestrictedGroups_COUNT].MemberOf[$MembersOf_COUNT].Name.'#text'
                }
            
                else
                {
                    $MembersOf = $GpoXml.Node.GPO.Computer.ExtensionData.Extension.RestrictedGroups[$RestrictedGroups_COUNT].MemberOf.Name.'#text'
                }
            
            if ($gPLinksOUs.count -le 1)
            {
                $gPLinksOU = $gPLinksOUs

                $RestrictedGroups = New-Object -TypeName psobject
                $RestrictedGroups | Add-Member -Name GpoDisplayName -MemberType NoteProperty -Value $GpoDisplayName -Force
                $RestrictedGroups | Add-Member -Name Domain -MemberType NoteProperty -Value $DomainSplit -Force
                $RestrictedGroups | Add-Member -Name Group -MemberType NoteProperty -Value $GroupSplit -Force
                $RestrictedGroups | Add-Member -Name Members -MemberType NoteProperty -Value $Members -Force
                $RestrictedGroups | Add-Member -Name MembersOf -MemberType NoteProperty -Value $MembersOf -Force
                $RestrictedGroups | Add-Member -Name GpoGuid -MemberType NoteProperty -Value $GpoGuid -Force
                $RestrictedGroups | Add-Member -Name GpLinkOU -MemberType NoteProperty -Value $gPLinksOU -Force

                $RestrictedGroupsCollection += $RestrictedGroups
                $RestrictedGroups
            }
            
            else
            {
                foreach ($gPLinksOU in $gPLinksOUs)
                {
                    $RestrictedGroups = New-Object -TypeName psobject
                    $RestrictedGroups | Add-Member -Name GpoDisplayName -MemberType NoteProperty -Value $GpoDisplayName -Force
                    $RestrictedGroups | Add-Member -Name Domain -MemberType NoteProperty -Value $DomainSplit -Force
                    $RestrictedGroups | Add-Member -Name Group -MemberType NoteProperty -Value $GroupSplit -Force
                    $RestrictedGroups | Add-Member -Name Members -MemberType NoteProperty -Value $Members -Force
                    $RestrictedGroups | Add-Member -Name MembersOf -MemberType NoteProperty -Value $MembersOf -Force
                    $RestrictedGroups | Add-Member -Name GpoGuid -MemberType NoteProperty -Value $GpoGuid -Force
                    $RestrictedGroups | Add-Member -Name GpLinkOU -MemberType NoteProperty -Value $gPLinksOU -Force

                    $RestrictedGroupsCollection += $RestrictedGroups
                    $RestrictedGroups
                }
            }
            
            $MembersOf = ""
            $MembersOf_COUNT += 1
        }
        
        $RestrictedGroups_COUNT += 1
    }

}

$RestrictedGroupsCollection.Count
$RestrictedGroupsCollection | Out-GridView
$RestrictedGroupsCollection | Export-Csv -Path C:\Users\d.w.b.da\Desktop\Scripts\RestrictedGroups.csv -NoTypeInformation -Force
###################################################################
