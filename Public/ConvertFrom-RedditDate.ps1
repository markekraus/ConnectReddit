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
         For more information about registering Reddit Apps, Reddit's API, or Reddit OAuth see:
            https://github.com/reddit/reddit/wiki/API
            https://github.com/reddit/reddit/wiki/OAuth2
            https://www.reddit.com/prefs/apps
            https://www.reddit.com/wiki/api
#>
function ConvertFrom-RedditDate {
    [CmdletBinding(ConfirmImpact = 'None',
                   HelpUri = 'https://github.com/markekraus/ConnectReddit/wiki/ConvertFrom%E2%80%90RedditDate')]
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
