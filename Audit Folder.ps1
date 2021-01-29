#Written by Rasmus Holmgaard
#Source: https://devblogs.microsoft.com/scripting/powertip-list-all-subfolders-under-a-target-path-with-powershell/
#Give the script a folder path (local/network share)
#It will check the root and sub folders and list users and groups that have access
#If a group has access, the list of users will be added
#Check for inheritance
<#The output should be a file for each UserX/GroupX:
UserX/GroupX has access to:
C:\This
C:\This\is              Inherited from: C:\This
C:\This\is\a            Inherited from: C:\This
C:\This\is\a\folder     Inherited from: C:\This
#>
#Get-ChildItem -Path C:\ -Recurse -Directory -Force -ErrorAction SilentlyContinue | Select-Object FullName

Write-Host "Paste in the root folder" -ForegroundColor Yellow
$RootFolder = "C:\Users\NHolmgaa\Dropbox\Rasmus Folder 2.0\UNIT4\OneDrive - Unit4"
$Rootname = $RootFolder.Split('\')[-1]
#First get the list of users/groups that have access to the main folder
$RootAcl = Get-Acl $RootFolder

#Create a report for each User/Group
foreach ($AccessObject in $RootAcl.Access) {
    [string]$IdentityReference = ($AccessObject.IdentityReference)
    Write-Host $IdentityReference


}

#Report for each IdentityReference
$Report = new-psobject

$Report | Add-Member -MemberType NoteProperty -Name Domain -Value $IdentityReference.Split('\')[0]
$Report | Add-Member -MemberType NoteProperty -Name User -Value $IdentityReference.Split('\')[1]
$Report | Add-Member -MemberType NoteProperty -Name IsInherited -Value $AccessObject.IsInherited
$Report | Add-Member -MemberType NoteProperty -Name InheritanceFlags -Value $AccessObject.InheritanceFlags
$Report | Add-Member -MemberType NoteProperty -Name FileSystemRights -Value $AccessObject.FileSystemRights
$Report | Add-Member -MemberType NoteProperty -Name Path -Value $AccessObject.FileSystemRights

$Report | Add-Member -MemberType NoteProperty -name Name -Value $User.name

$RootAcl.Path
(Get-Acl $RootFolder).Access | Select IdentityReference, IsInherited, InheritanceFlags, FileSystemRights

#Used for the Sub folders
Get-ChildItem -Path $RootFolder -Recurse -Directory -Force -ErrorAction SilentlyContinue | Select-Object FullName

