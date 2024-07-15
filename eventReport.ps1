# This script is meant for our Remote Desktop Computer to automatically generate event reports and send them via email - script is set to run via Task Scheduler

# Setting filters for events (can be extended to required number)
$filterHT1=@{
    LogName = "System"
    Level = 2 # 1 = Critical, 2 = Error, 3 = Warning, 4 = Information, 5 = Verbose
    StartTime = (Get-Date).AddHours(-24)
    EndTime = Get-Date
}
$filterHT2=@{
    LogName = "Application"
    Level = 1   # 1 = Critical, 2 = Error, 3 = Warning, 4 = Information, 5 = Verbose
    StartTime = (Get-Date).AddHours(-24)
    EndTime = Get-Date
}

# Set the output file path might need priviliges for certain paths
$outputFile = "C:\EventReport_$(Get-Date -Format 'ddMMyyyy').html"

# Retrieving events based on filters 1&2
$events1 = Get-WinEvent -FilterHashtable $filterHT1
$events2 = Get-WinEvent -FilterHashtable $filterHT2
$allEvents = $events1 + $events2

$filteredEvents = $allEvents | Select-Object TimeCreated, LogName, Id, LevelDisplayName, Message

# Formatting HTML to make the report accesible
$htmlTable = $filteredEvents | ConvertTo-Html -Property TimeCreated, LogName, Id, LevelDisplayName, Message -Fragment
$htmlContent = "
<!DOCTYPE html>
<html>
<head>
    <title>Event Report</title>
    <style>
        
        body {background-color: black; color: yellow; text-align: center}
        table { width: 100%; border-collapse: collapse;}
        th, td { padding: 8px 12px; border: 1px solid yellow; }
        td {text-align: left}
    </style>
</head>
<body>
<h2>Event Report - $(Get-Date -Format 'dd-MM-yyyy')</h2>
<table>
" + $htmlTable + "
</table>
</body>
</html>"
$htmlContent | Out-File -FilePath $outputFile -Encoding utf8

# Sending the report via email (for this to work SMTP server has to allow sending unauthenticated emails), could be configured with credentials as well 

<#

    First Convert password to secure string
    $Username = 'example@company.com'
    $Password = 'yourPassword'
    $securePassword = ConvertTo-SecureString $Password -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($Username, $securePassword)

    Then add Credential = $credential to $emailParameters HashTable
#>

# Setting email parameters
$emailParameters = @{
    From = 'example@company.com'
    To = 'example@company.com'
    Subject = 'Event Report ' + $(Get-Date -Format 'dd-MM-yyyy')
	Body = 'Report generated: '+$(Get-Date -Format 'dd-MM-yyyy hh:mm')
    SMTPServer = 'mail.example.com'
    Port = 25  
    UseSsl = $true
    Attachments = $outputFile
}

Send-MailMessage @emailParameters
