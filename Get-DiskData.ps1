#This script comes with a companion script, Compare-CSV. 

function Get-DepartmentData {
    #GETS DISKS SIZE
    Start-Transcript -Path "C:\Powershell\Scripts\Get-DepartmentData\Logs\scan.txt"
    $global:disks = Get-Volume
    $diskSize = @()
    for ($i = 0; $i -lt $disks.count; $i++) {
        $sizeConvertedTotal = [math]::round($disks[$i].size / 1Gb) #displays total size of disk
        $sizeConvertedRemaining = [math]::round($disks[$i].sizeRemaining / 1Gb) #displays remaining space of disk
        $diskSize += $disks[$i].size
    }

    $runContainer = [PSCustomObject]@{
        daterun      = @()
        sizeGB       = @()
        rawSize      = @()
        scanlocation = @()
        disk         = @()
    }

    $placesToScan = @()
    $placesToScanData = @()

    foreach ($disk in $disks.DriveLetter) {
        #GETS SCANNABLE FOLDERS (ONLY LOOKING FOR DATA AND USER FOLDER)
        if ($null -eq $disk) {
            $null
        }
        else {
            $disk = $disk + ":\"
            Write-Host("Getting locations to scan...")
            $placesToScanData += Get-ChildItem -Depth 0 -Path $disk | ? { $_.name -match "data" -or $_.name -match "user" }
            
        }
    }

    foreach ($item in $placesToScanData) {
        if ($item.Extension -eq ".log" -or $item.Extension -eq ".bat" -or $item.Extension -eq ".pdf" -or $item.Extension -eq ".txt" -or $item.Extension -eq ".docx" -or $item.Extension -eq ".xlsx" -or $item.Extension -eq ".csv") {

        }
        else {
            $placesToScan += Get-ChildItem $item.FullName -Recurse -Depth 0
            Write-Host("Adding " + $item.FullName + " to the places to scan.")
        }
    }
    
    foreach ($item in $placesToScan) {
        #SCANS FOLDERS
        if ($item.FullName -match "C:\\") { #TO SCAN C DRIVE, COMMENT OUT LOGIC IF
            Write-Host("Unable to scan - illegal disk found in path.")
        }
        else {
            try {
            Write-Host("Scanning " + $item.FullName)
            $dataRun = Get-ChildItem -path $item.FullName -Recurse
            $dataRunSum = $datarun | Measure-Object -Sum Length
            $size = [math]::Round($dataRunSum.Sum / 1Gb)
            $global:dateRan = Get-Date
            $scanLocation = $item
            $runContainer.sizeGB += $size.ToString()
            $runContainer.scanlocation += $scanLocation.FullName
            $runContainer.daterun += $dateRan.toString()
            $runContainer.disk += $item.Root.Name
            $runContainer.rawSize += $dataRunSum.Sum
            } catch {
                Write-Host("Unable to scan " + $item)
            }
        }
    }
    

    #ENDING VALUES
    $totalBytes = @()
    $totalGB = @()

    

    #CREATE CSV
    Write-Host("Copying old CSV to C:\Powershell\Scripts\Get-DepartmentData\Old-CSVs")
    Copy-Item -Path C:\Powershell\Scripts\Get-DepartmentData\New-CSVs\* -Destination C:\Powershell\Scripts\Get-DepartmentData\Old-CSVs
    $file = ("C:\Powershell\Scripts\Get-DepartmentData\New-CSVs\" + ("$($dateRan.Month.ToString() + $dateRan.Day.toString() + $dateRan.Year.toString())_" + "DiskDataGrabber.csv"))
    Write-Host("Removed " + $file)
    $csv = New-Item -ItemType File -Name ("$($dateRan.Month.ToString() + $dateRan.Day.toString() + $dateRan.Year.toString())_" + "DiskDataGrabber.csv") -Path "C:\Powershell\Scripts\Get-DepartmentData\New-CSVs" -Force
    $columns = "DateRan,SizeGB,RawSizeBytes,ScanLocation,Disk"
    Add-Content -Value $columns -Path $csv
    for ($i = 0; $i -lt $runContainer.rawSize.count; $i++) {
        Add-Content -Path $csv -Value "$($runContainer.daterun[$i])," -NoNewline
        Add-Content -Path $csv -Value "$($runContainer.sizeGB[$i])," -NoNewline
        Add-Content -Path $csv -Value "$($runContainer.rawSize[$i])," -NoNewline
        Add-Content -Path $csv -Value "$($runContainer.scanLocation[$i])," -NoNewline
        Add-Content -Path $csv -Value "$($runContainer.disk[$i])"
    }

    Import-Csv $csv | ConvertTo-Html > C:\Powershell\Scripts\Get-DepartmentData\New-CSVs\thing.html
    $sum = $totalBytes | Measure-Object -Sum
    $GB = $size = [math]::Round($sum.Sum / 1Gb)

    Add-Content -Path C:\Powershell\Scripts\Get-DepartmentData\New-CSVs\thing.html -Value "<p> Total used GB of this disk: $GB </p>"
    $6monthData = Get-ChildItem "C:\Powershell\Scripts\Get-DepartmentData\New-CSVs"
    foreach ($item in $6monthData) {
        if ($item.LastWriteTime -lt $dateRan.addMonths(-6)) {
            Remove-Item -Path $item.FullName
        }
    }
    Stop-Transcript 
}

Get-DepartmentData
