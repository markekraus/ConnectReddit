
<#
    .SYNOPSIS
        Converts Reddit's Date formate to a DateTime object
    
    .DESCRIPTION
        Reddit used Unix Epoch dates. This converts them to datetime objects.
    
    .PARAMETER RedditDate
        The Reddit Date to be converted.
    
    .EXAMPLE
        PS C:\> ConvertFrom-RedditDate -RedditDate $Date
    
    .NOTES
        Additional information about the function.
#>
function ConvertFrom-RedditDate {
    [CmdletBinding(ConfirmImpact = 'None')]
    [OutputType([System.DateTime])]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   HelpMessage = 'Reddit Date (Unix Epoch)')]
        [AllowNull()]
        [Alias('Date')]
        [double[]]$RedditDate
    )
    
    begin {
        $UnixEpoch = Get-Date '1970/1/1'
    }
    Process {
        Foreach ($CurDate in $RedditDate) {
            $OutDate = $UnixEpoch.AddSeconds($CurDate)
            Write-Output $OutDate
        }
    }
}
