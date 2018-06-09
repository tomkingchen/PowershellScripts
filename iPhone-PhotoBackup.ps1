Param(
    [Parameter(Mandatory=$true)] 
	[String]$Name
)

# Harsh table for month
$monthMap = @{
    1 = 'Jan'
    2 = 'Feb'
    3 = 'Mar'
    4 = 'Apr'
    5 = 'May'
    6 = 'Jun'
    7 = 'Jul'
    8 = 'Aug'
    9 = 'Sep'
    10 = 'Oct'
    11 = 'Nov'
    12 = 'Dec'
}

# Assign source folder
If ($Name -eq "tina") {
    $BkFolder = "C:\Users\Tom\Dropbox\Photos\Tina iPhone photo backup"
}
else{
    $BkFolder = "C:\Users\Tom\Dropbox\Photos\Tom iPhone photo backup"
}


Function Backup-Photos($SourceFolder){
    
    # Get all the files from the source folder
    Get-ChildItem -Path $SourceFolder |
    ForEach-Object {    
        # If the file name is not Latest Backup
        If ($_.BaseName -ne "Latest Backup"){
            $photoPath = $_.FullName
            $photoSize = $_.Length
            $photoFileName = $_.Name
            
            $createTime = $_.LastWriteTime
            $year = $createTime.Year
            $monthNum = $createTime.month
            $month = $monthMap[$monthNum]
            $TargetFolder = "P:\Photos\"+$year+"\"+$month
            $TargetFilePath = $TargetFolder+"\"+$photoFileName

            If (Test-Path $TargetFolder){
                # Check if file with same name exist on target
                If (Test-Path $TargetFilePath){
                    $TargetFile = Get-Item $TargetFilePath
                    # Check file size
                    If($TargetFile.Length -eq $PhotoSize){
                        Write-Host "$photofileName already exist" -ForegroundColor red
                        Remove-Item $photoPath -Force # Delete photo from source folder if the file size is the same
                        Write-Host "Deleted $photoFileName from $Name iPhone photo backup folder" -ForegroundColor red
                    }Else{
                        Move-Item -path $photoPath -Destination $TargetFolder"\"$Name"-"$photoFileName
                        Write-Host "Renamed $photoFileName to $Name-$photoFileName and moved it to $TargetFolder" -ForegroundColor yellow
                    }
                }
                Else{
                        # File does not exist at Target folder
                        Move-Item -Path $photoPath -Destination $TargetFolder
                        Write-Host "Moved $photoFileName to $TargetFolder successfully" -ForegroundColor green
                }
           }Else{
                New-Item -Path $TargetFolder # Create folder
                Write-Host "Created $TargetFolder"
                Move-Item -Path $photoPath -Destination $TargetFolder # Move the photo
                Write-Host "Moved $photoFileName to $TargetFolder successfully" -ForegroundColor green
           }
        }#If Name is not latest backup.txt
    }#Foreach
    
    # Update Latest Backup.txt file
    $UpdateRecord = $BkFolder+"\Latest Backup.txt"
    $Now = Get-Date
    Add-Content $UpdateRecord $Now

}

Backup-Photos -SourceFolder $BkFolder


