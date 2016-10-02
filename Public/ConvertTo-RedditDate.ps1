<#
    .SYNOPSIS
        Converts a DateTime object to a Reddit Date String
    
    .DESCRIPTION
        Reddit uses UNix Epoch time stamps for dates. This will take a DateTime object and return a properly formated Reddit Date string.
    
    .PARAMETER Date
        DateTime object that will be converted.
    
    .EXAMPLE
        PS C:\> ConvertTo-RedditDate -Date $RedditDate
    
#>
function ConvertTo-RedditDate {
    [CmdletBinding(ConfirmImpact = 'None')]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [DateTime[]]$Date
    )
    begin {
        $UnixEpoch = Get-Date '1970/1/1'
    }
    Process {
        Foreach ($CurDate in $Date) {
            $Difference = $CurDate - $UnixEpoch
            $RedditDate = $Difference.TotalSeconds
            Write-Output $RedditDate
        }
    }
}
