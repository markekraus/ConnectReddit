<#
    .SYNOPSIS
        Sleeps until ratelimit period hs expired on a Reddit OAuth Access Token
    
    .DESCRIPTION
        Checks if a Reddit OAuth Access Token has exceeded its ratelimit and sleeps untilt the ratelimit period has expired or until the MaxSleepSeconds has been exceeded, which ever comes first. If the Token has not exceeded the ratelimit, it will do nothing and return immediately.
    
    .PARAMETER AccessToken
        Reddit OAuth Access Token returned from Get-RedditOAuthAccessToken
    
    .PARAMETER MaxSleepSeconds
        Maximum number of seconds to sleep. If this is lower than the number of seconds until the end of the ratelimit period, then the sleep period will end before the ratelimit period has ended. The default is 900 seconds (15 minutes).
    
    .EXAMPLE
        		PS C:\> Wait-RedditOAuthAccessTokenRatelimitExpiration -AccessToken $RedditToken
    
    .NOTES
        For more information about registering Reddit Apps, Reddit's API, or Reddit OAuth see:
            https://github.com/reddit/reddit/wiki/API
            https://github.com/reddit/reddit/wiki/OAuth2
            https://www.reddit.com/prefs/apps
            https://www.reddit.com/wiki/api
#>
function Wait-RedditOAuthAccessTokenRatelimitExpiration {
    [CmdletBinding(ConfirmImpact = 'None')]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [pstypename('Reddit.OAuthAccessToken')]
        [System.Management.Automation.psobject]$AccessToken,
        
        [int32]$MaxSleepSeconds = 900
    )
    begin {
        $MaxSleepDate = (Get-date).AddSeconds($MaxSleepSeconds)
    }
    Process {
        If (!$AccessToken.IsRatelimited) {
            Write-Verbose 'Token has not exceeded ratelimit.'
            return
        }
        $Message = 'Rate limit in effect until {0}. Sleeping.' -f $AccessToken.RatelimitReset
        Write-Warning $Message
        while ($AccessToken.IsRatelimited -and (Get-Date) -lt $MaxSleepDate) {
            Start-Sleep -Seconds 1
        }        
    }   
}
