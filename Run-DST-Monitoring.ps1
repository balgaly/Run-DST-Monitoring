#===================================================
# Run-DST-Monitoring.ps1 v1.0 
#
# The Script counts how many days until DST Change
# and alert zabbix
#
# Created by: Snir Balgaly
# Last Update: 25/12/2018
#===================================================

# Imports and definitions
$CurrDate = Get-Date

# Time Defeinitions
$DSTLocations = @{
    Europe = @{
        Start = @{
            Day = "Sunday"
            Month = 3
            Relative = "last"
        }
        End = @{
            Day = "Sunday"
            Month = 10
            Relative = "last"
        }
    }
    Australia = @{
        Start = @{
            Day = "Sunday"
            Month = 4
            Relative = "first"
        }
        End = @{
            Day = "Sunday"
            Month = 10
            Relative = "first"
        }
    }
    US = @{
        Start = @{
            Day = "Sunday"
            Month = 3
            Relative = "second"
        }
        End = @{
            Day = "Sunday"
            Month = 11
            Relative = "first"
        }
    }
}

# Running for each location
$DSTLocations.GetEnumerator() | ForEach-Object {

    # Definitions
    $LocationName = $_.Key
    $LocationData = $_.Value

    # Calculating the start and end of DST
    $StartDate = Get-DateDayOfMonth $LocationData.Start.Day $LocationData.Start.Month $LocationData.Start.Relative
    $EndDate = Get-DateDayOfMonth $LocationData.End.Day $LocationData.End.Month $LocationData.End.Relative

    # Calculating the days until the DST start and end times and adding the data to the array
    $LocationData.Add("DaysToStart",(New-TimeSpan -Start $CurrDate -End $StartDate).Days)
    $LocationData.Add("DaysToEnd",(New-TimeSpan -Start $CurrDate -End $EndDate).Days)

    # Message definition
    $StartMessage = "Days left to the start of DST in $LocationName`: $($LocationData.DaysToStart)"
    $EndMessage = "Days left to the end of DST in $LocationName`: $($LocationData.DaysToEnd)"

    # Writing to log file and send to zabbix
    Write-Log -Message $StartMessage
    if ($($LocationData.DaysToStart) -lt 15)
    {
        Send-Zabbix -Message $StartMessage -Key DST.$LocationName -HostName "Monitoring Server"
        Write-Log -Message "Message Sent to zabbix"
    }
    Write-Log -Message $EndMessage

    if ($($LocationData.DaysToEnd) -lt 15)
    {
        Send-Zabbix -Message $EndMessage -Key DST.$LocationName -HostName "Monitoring Server"
        Write-Log -Message "Message Sent to zabbix" 
    }
}