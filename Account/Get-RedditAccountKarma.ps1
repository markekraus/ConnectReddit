<#
    .SYNOPSIS
        Retrieves a Karam breakdown for the User
    
    .DESCRIPTION
        Returns a a list of Reddit.KarmaList objects with a break down of the link and comment karma per subreddit for the user the Access Token is issued.
    
    .PARAMETER AccessToken
        Reddit OAuth Access Token returned from Get-RedditOAuthAccessToken
    
    .PARAMETER APIBaseURL
        This is the base URL of the API endpoint. This is provided for use with Reddit clones.
    
    .PARAMETER APIEndPoint
        The API endpoint that will be accessed. This is provided for use with Reddit clones.
        Default:
        /api/v1/me/karma
    
    .PARAMETER UserBaseUrl
        The Base URL for user account. The default is https://www.reddit.com/u/. This is used to construct the user URL and is provided for use with Reddit clones.
    
    .EXAMPLE
        PS C:\> Get-RedditAccountKarma-AccessToken $RedditToken
    
    .OUTPUTS
        System.Management.Automation.PSObject
    
    .NOTES
        Additional information about the function.
#>
function Get-RedditAccountKarma {
    [CmdletBinding(ConfirmImpact = 'Low',
                   HelpUri = 'https://github.com/markekraus/ConnectReddit/wiki/Get%E2%80%90RedditAccountKarma',
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
        
        [string]$ApiEndPoint = '/api/v1/me/karma'
    )
    
    Begin {
        Write-Verbose "Defining Typenames"
        $PsTypnames = @(
            'Reddit.KarmaList'
        )
    }
    Process {
        # Support Should Process
        if (-not $PSCmdlet.ShouldProcess('')) {
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
        Foreach ($ResponseObject in $Response.data) {
            $ResponseObject.Psobject.TypeNames.Clear()
            foreach ($PsTypname in $PsTypnames) {
                $ResponseObject.Psobject.TypeNames.add($PsTypname)
            }
            Write-Output $ResponseObject
        }
    }
}
