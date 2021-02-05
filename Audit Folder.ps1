Write-Host "Paste in the root folder" -ForegroundColor Yellow
$RootFolder = Read-Host
Write-Host "Where should the audit export" -ForegroundColor Yellow
$Export = Read-Host

$Report = @()
$Cache = @()

#First collect all the folders that we need to get permissions from
$FolderPath = Get-ChildItem -Directory -Path $RootFolder -Recurse -Force
Write-Host "Folders Collected"
foreach ($Folder in $FolderPath) {

    #Check each for permissions
    $Acl = Get-Acl -Path $Folder.FullName
    foreach ($Access in $Acl.Access) {

        #I dont't want to see entries from BUILTIN\Administrators, NT AUTHORITY\SYSTEM, CREATOR OWNER, BUILTIN\Users
        if (!($Access.IdentityReference -eq "BUILTIN\Administrators") -and !($Access.IdentityReference -eq "NT AUTHORITY\SYSTEM") -and !($Access.IdentityReference -eq "CREATOR OWNER") -and !($Access.IdentityReference -eq "BUILTIN\Users")) {
            $User = $null

            #We want to cache the users for better performance and to avoid ased AD for users 100k times
            if (!($Cache.SID -contains $Access.IdentityReference)) {
                try {
                    $User = Get-ADUser -Identity "$($Access.IdentityReference)"
                    Write-Host $User.Name -ForegroundColor Green
                    $Cache += [PSCustomObject]@{
                        SID  = $User.SID
                        Name = $User.Name
                    }
                }
                catch {
                    $Cache += [PSCustomObject]@{
                        SID  = $Access.IdentityReference
                        Name = $null
                    }
                    #This will only fail if it gets an SID from a user that is deleted.
                    Write-Host "Failed" $Access.IdentityReference
                }
            }
            
            #Make it so the users can only be pulled from the cache when put into the report.
            elseif ($Cache.SID -contains $Access.IdentityReference) {
                Write-Host $Access.IdentityReference "Found in cache"
                $Properties = [ordered]@{
                    'FolderName'        = $RootFolder
                    'IdentityReference' = $Cache.where{ ($_.SID -eq $Access.IdentityReference) }.SID
                    'AD Group or User'  = $Cache.where{ ($_.Name -eq $Access.IdentityReference) }.Name
                    'Permissions'       = $Access.FileSystemRights
                }
            }
            else {
                #Just in case the user doesn't get pulled from the cache we want to know, mistakes happen
                Write-Host "ESCAPED CACHE" $Access.IdentityReference -ForegroundColor Red
            }
            $Report += New-Object -TypeName PSObject -Property $Properties
        }
    }
    Write-host $Folder.FullName "Done" -ForegroundColor Green
}
$Path = $Export + "\Report.csv"
$Report | Export-Csv -path $Path -Force -Append -NoTypeInformation
