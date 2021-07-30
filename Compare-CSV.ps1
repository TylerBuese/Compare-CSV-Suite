function Compare-CSV() {
    #COMPARE is the newest file
    #AGAINST is the old file you're comparing against
    param (
        [Parameter(Mandatory=$true)]
        [string]$compare,
        [string]$against
    )
    $csv1 = Import-Csv $compare
    $csv2 = Import-Csv $against
    $result = [PSCustomObject]@{
        scanlocation = @()
        grewby = @()
        
    }

    foreach ($item in $csv2) {
        foreach ($object in $csv1) {
            if ($object.scanlocation -eq $item.scanlocation) {
                $bytesResult = $object.RawSizeBytes - $item.RawSizeBytes
                $result.scanlocation += $object.scanlocation
                $result.grewby += ([math]::Round($bytesResult / 1Mb))
            } else {
                
            }
        }
    }
    
    New-Item -ItemType file -Name "Grew By Data.csv" -Path "$env:USERPROFILE\desktop" -force
    $grewbydatacsv = "$env:USERPROFILE\desktop\grew by data.csv"
    $columns = "ScanLocation, GrewBy(MB)"
    Add-Content -Path $grewbydatacsv -Value $columns
    for ($i = 0; $i -lt $csv1.count; $i++) {
        Add-Content -Path $grewbydatacsv -Value "$($result.scanlocation[$i])," -NoNewline
        Add-Content -Path $grewbydatacsv -Value $result.grewby[$i]
    }
    Write-Host("Opening CSV")
    Invoke-Item $grewbydatacsv
}

Compare-CSV