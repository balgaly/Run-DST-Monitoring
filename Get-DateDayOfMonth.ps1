function Get-DateDayOfMonth {
<#
    .SYNOPSIS
        Return the date of the nearest "X day of a month"

    .PARAMETER  DayOfWeek
        The Day of the week you with to find

    .PARAMETER  Month
        In which month this day at

    .PARAMETER  Relative
        Which relative day this day should be in that month

    .PARAMETER  NextYear
        No need to touch this variable. Please keep it false

    .EXAMPLE
        PS C:\> Get-DateDayOfMonth -DayOfWeek Tuesday -Month 5 -Relative Second

#>

    # Params Section
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$true)] 
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday')] 
        [String]
        $DayOfWeek,

        [Parameter(Position=1, Mandatory=$true)]  
        [ValidateNotNullOrEmpty()]
        [ValidateRange(1,12)]
        [Int] 
        $Month,

        [Parameter(Position=2, Mandatory=$true)]  
        [ValidateNotNullOrEmpty()]
        [ValidateSet('First','Last','Second','Third','Fourth')] 
        [String]
        $Relative,

        [Parameter(Position=3, Mandatory=$false)]  
        [ValidateNotNullOrEmpty()]
        [Boolean] 
        $NextYear = $false
    )

    # Swtiches the relative string to an Int.
    switch ($Relative)
    {
        "First"     {$RelativeAsInt = 0}
        "Second"    {$RelativeAsInt = 1}
        "Third"     {$RelativeAsInt = 2}
        "Fourth"    {$RelativeAsInt = 3}
        "Last"      {$RelativeAsInt = 4}
    }

    # Define the current date and the requested date
    $CurrDate = Get-Date 
    $RequestDate = [DateTime] "$Month/01/$($CurrDate.year)"
    $Counter = 0
    $FirstRun = $true

    # If the requested date is next year
    if ($NextYear)
    {
        $RequestDate = $RequestDate.AddYears(1)
    }

    # Adding days until the requested date
    while ($RelativeAsInt -ge $Counter)
    {
        if (!$FirstRun)
        {
            $RequestDate = $RequestDate.AddDays(1)
        }
        while (($RequestDate.DayOfWeek -ne $DayOfWeek))
        {
            $RequestDate = $RequestDate.AddDays(1)
        }
        ++$Counter
        $FirstRun = $false
    }
    
    # If it passes to next month it goes back to one week
    if ($RequestDate.Month -ne $Month)
    {
        $RequestDate = $RequestDate.AddDays(-7)
    }

    # If the requested date is in the past then run again but in next year
    if ($RequestDate.AddDays(1) -le $CurrDate)
    {
        Get-DateDayOfMonth -DayOfWeek $DayOfWeek -Month $Month -Relative $Relative -NextYear $true
    } 
    else
    {
        return $RequestDate
    } 
}