
<#
    .SYNOPSIS
        Returns a Reddit API Fullname
    
    .DESCRIPTION
        generates a Reddit Api fullname based on the given Type and Reddit ID. Reddit fullnames are used to identify objects in the Reddit API.
    
    .PARAMETER Type
        The Reddit API "thing" type. Valid types:
            t1
            t2
            t3
            t4
            t5
            t6
            t8
            Comment
            Account
            Link
            Message
            Subreddit
            Award
            PromoCampaign
    
    .PARAMETER RedditId
        The Id of the Reddit API "thing"
    
    .EXAMPLE
        PS C:\> Get-RedditApiFullname -Type 'Account' -RedditId '11fmvc'
    
    .NOTES
        For more information about registering Reddit Apps, Reddit's API, or Reddit OAuth see:
        https://github.com/reddit/reddit/wiki/API
        https://github.com/reddit/reddit/wiki/OAuth2
        https://www.reddit.com/prefs/apps
        https://www.reddit.com/wiki/api
#>
function Get-RedditApiFullname {
    [CmdletBinding(ConfirmImpact = 'None',
                   HelpUri = 'https://github.com/markekraus/ConnectReddit/wiki/Get%E2%80%90RedditApiFullname')]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('t1', 't2', 't3', 't4', 't5', 't6', 't8', 'Comment', 'Account', 'Link', 'Message', 'Subreddit', 'Award', 'PromoCampaign')]
        [Alias('TypePrefix', 'Kind')]
        [string]$Type,
        
        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('Id')]
        [string]$RedditId
    )
    
    Begin {
        # https://www.reddit.com/dev/api/
        
        $TypePrefixes = @{
            t1 = 't1'
            Comment = 't1'
            t2 = 't2'
            Account = 't2'
            t3 = 't3'
            Link = 't3'
            t4 = 't4'
            Message = 't4'
            t5 = 't5'
            Subreddit = 't5'
            t6 = 't6'
            Award = 't6'
            # There is apparently no 't7' or it was removed from the API at some point
            t8 = 't8'
            PromoCampaign = 't8'
        }
    }
    Process {
        $RedditFullname = "{0}_{1}" -f $TypePrefixes.$type, $RedditId
        Write-Output $RedditFullname
    }
}
