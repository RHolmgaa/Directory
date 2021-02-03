#Written by Rasmus Holmgaard
Write-Host "Paste in the root folder" -ForegroundColor Yellow
$RootFolder = Read-Host
Write-Host "Where should the audit export" -ForegroundColor Yellow
$Export = Read-Host

#First get the list of users/groups that have access to the main folder
$RootAcl = Get-Acl $RootFolder

#Create a report for each User/Group - root folder
foreach ($RootAccessObject in $RootAcl.Access) {
    [string]$IdentityReference = ($AccessObject.IdentityReference)
    Write-Host $RootFolder

    #Report for each IdentityReference
    $Report = New-Object PSObject

    $Report | Add-Member -MemberType NoteProperty -Name Domain -Value $IdentityReference.Split('\')[0]
    $Report | Add-Member -MemberType NoteProperty -Name User -Value $IdentityReference.Split('\')[1]
    $Report | Add-Member -MemberType NoteProperty -Name IsInherited -Value $RootAccessObject.IsInherited
    $Report | Add-Member -MemberType NoteProperty -Name InheritanceFlags -Value $RootAccessObject.InheritanceFlags
    $Report | Add-Member -MemberType NoteProperty -Name FileSystemRights -Value $RootAccessObject.FileSystemRights
    $Report | Add-Member -MemberType NoteProperty -Name Path -Value $RootFolder

    [string]$Path = $Export + "\$($Report.User).csv"
    $Report | Export-Csv -Path $Path -Force -Append -NoTypeInformation
}

#Create a report for each User/Group - subfolder
Get-ChildItem -Path $RootFolder -Directory -Recurse -Force | select FullName | ForEach-Object {
    Write-Host $_.FullName
    $SubAcl = Get-Acl $_.FullName
    foreach ($SubAccessObject in $SubAcl.Access) {
        [string]$IdentityReference = ($SubAccessObject.IdentityReference)

        #Report for each IdentityReference
        $Report = New-Object PSObject
    
        $Report | Add-Member -MemberType NoteProperty -Name Domain -Value $IdentityReference.Split('\')[0]
        $Report | Add-Member -MemberType NoteProperty -Name User -Value $IdentityReference.Split('\')[1]
        $Report | Add-Member -MemberType NoteProperty -Name IsInherited -Value $SubAccessObject.IsInherited
        $Report | Add-Member -MemberType NoteProperty -Name InheritanceFlags -Value $SubAccessObject.InheritanceFlags
        $Report | Add-Member -MemberType NoteProperty -Name FileSystemRights -Value $SubAccessObject.FileSystemRights
        $Report | Add-Member -MemberType NoteProperty -Name Path -Value $_.FullName

        [string]$Path = $Export + "\$($Report.User).csv"
        $Report | Export-Csv -Path $Path -Force -Append -NoTypeInformation
    }
}
