# Compare-CSV-Suite
Suite of scripts to compare two sets of data against one another (use when comparing drive data).

<h1> How to use </h1>

<p> Place Get-DiskData.ps1 on the server you'd like to gather metrics from. The script will generate a CSV file at C:\Powershell\Scripts\Get-DepartmentData\New-CSVs\*. The script will probably crash if that path doesn't exist. Depending on how much space you're gathering metrics on, this process will take anywhere from 15 minutes to 8 hours. For a server that has 20TB of capacity, to gather all metrics, it takes around 6 hours. </p>
<p> To do something with the metrics, use the Compare-CSV script. Note that you'll have to have Get-DiskData.ps1 running for some time to get good data. Run Compare-CSV.ps1, in the parameter "Compare", insert the path to the newest CSV file, in the parameter "Against", insert the path to the old CSV file you're trying to gather metrics from.</p>
<ul> <li>Eg, Compare-CSV -compare {pathtofile\todayscsv.csv} -against {pathtooldfile\csvfrom3monthsago.csv} </li></ul>
<p> Running this command will give you the past 3 months of data. The idea is to get an understanding of *who* is taking up so much damn space on your NAS. </p>
<h1> NOTE: I understand this is stupid slow, I have no intention of making it faster. I do however want to re-write it in C++, I hope will increase the speed of things. Feel free to fork it. </h1>
 
