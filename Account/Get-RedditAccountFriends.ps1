<#
    .SYNOPSIS
        Retrieves the Friends list of the User
    
    .DESCRIPTION
        Returns a list of Reddit.Friends objects for the friends of the account the access token is issued for.
    
    .PARAMETER AccessToken
        Reddit OAuth Access Token returned from Get-RedditOAuthAccessToken
    
    .PARAMETER APIBaseURL
        This is the base URL of the API endpoint. This is provided for use with Reddit clones.
    
    .PARAMETER APIEndPoint
        The API endpoint that will be accessed. This is provided for use with Reddit clones.
        Default:
            /api/v1/me/friends
    
    .PARAMETER UserBaseUrl
        The Base URL for user account. The default is https://www.reddit.com/u/. This is used to construct the user URL and is provided for use with Reddit clones.
    
    .EXAMPLE
        PS C:\> Get-RedditAccountFriends -AccessToken $RedditToken
    
    .OUTPUTS
        System.Management.Automation.PSObject
    
    .NOTES
        For more information about registering Reddit Apps, Reddit's API, or Reddit OAuth see:
            https://github.com/reddit/reddit/wiki/API
            https://github.com/reddit/reddit/wiki/OAuth2
            https://www.reddit.com/prefs/apps
            https://www.reddit.com/wiki/api
#>
function Get-RedditAccountFriends {
    [CmdletBinding(ConfirmImpact = 'Low',
                   HelpUri = 'https://github.com/markekraus/ConnectReddit/wiki/Get%E2%80%90RedditAccountFriends',
                   SupportsShouldProcess = $true)]
    [OutputType([System.Management.Automation.PSObject])]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [pstypename('Reddit.OAuthAccessToken')]
        [Alias('Token')]
        [System.Management.Automation.PSObject]$AccessToken,
        
        [Parameter(Mandatory = $false)]
        [string]$ApiBaseURL = 'https://oauth.reddit.com',
        
        [string]$ApiEndPoint = '/api/v1/me/friends'
    )
    
    Begin {
        #These are the Pstypenames that will be applied to the output objects
        $PsTypnames = @(
            'Reddit.Friend'
        )
    }
    Process {
        # Support Should Process
        if (-not $PSCmdlet.ShouldProcess('Target')) {
            Continue
        }
        
        $Params = @{
            Get = $true
            AccessToken = $AccessToken
            ApiBaseUrl = $ApiBaseUrl
            ApiEndPoint = $ApiEndPoint
        }
        try {
            $Response = Get-RedditApiResponse @Params
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            $Message = "Unable to query account: {0}" -f $ErrorMessage
            Write-Error $Message
            return
        }
        Foreach ($ResponseObject in $Response.data.Children) {
            $ResponseObject.Psobject.TypeNames.Clear()
            foreach ($PsTypname in $PsTypnames) {
                $ResponseObject.Psobject.TypeNames.add($PsTypname)
            }
            Write-Output $ResponseObject
        }
    }
}
