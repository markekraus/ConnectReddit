<#
    .SYNOPSIS
        Gets a URL to authorize a reddit APP.
    
    .DESCRIPTION
        Generated a URL baed on the Client ID, OAuth Scope, and Redirect URI to be used by a user to authorized an App.
    
    .PARAMETER Application
        Reddit Application Object created by New-RedditApplication
    
    .PARAMETER State
        State is an string defined by the application. A new GUID will be generated if no State is provided.
    
    .PARAMETER AuthURL
        Reddit OAuth Authorization URL. Dfeault is  'https://www.reddit.com/api/v1/authorize' . Parameter added for support with Reddit clones, but is not neccesary for Reddit Apps.
    
    .PARAMETER ResponseType
        Can be either Code or Token. Use Code for Web Apps and Token for Installed apps (https://github.com/reddit/reddit/wiki/OAuth2)
    
    .PARAMETER Duration
        Indicates whether or not your app needs a permanent or temporary token. The implicit grant flow does not allow permanent tokens. (https://github.com/reddit/reddit/wiki/OAuth2)
    
    .EXAMPLE
        PS C:\> $AuthURL = Get-RedditAppAuthorzationURL -Application $Reddit -State $GUID -ResponseType Code
    
    .OUTPUTS
        System.String
    
    .NOTES
        For more information about registering Reddit Apps, Reddit's API, or Reddit OAuth see:
            https://github.com/reddit/reddit/wiki/API
            https://github.com/reddit/reddit/wiki/OAuth2
            https://www.reddit.com/prefs/apps
            https://www.reddit.com/wiki/api
#>
function Get-RedditOAuthAppAuthorizationURL {
    [CmdletBinding(ConfirmImpact = 'None',
                   HelpUri = 'https://github.com/markekraus/ConnectReddit/wiki/Get%E2%80%90RedditOAuthAppAuthorizationURL',
                   SupportsShouldProcess = $true)]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [pstypename('Reddit.Application')]
        [Alias('RedditApp', 'App')]
        $Application,
        
        [Parameter(Mandatory = $false)]
        [string]$State = [guid]::NewGuid(),
        
        [Parameter(Mandatory = $false)]
        [string]$AuthURL = 'https://www.reddit.com/api/v1/authorize',
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('code', 'token')]
        [Alias('response_type')]
        [string]$ResponseType = 'code',
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('permanent', 'temporary')]
        [string]$Duration = 'permanent'
    )
    
    process {
        Write-Verbose "Building Query String."
        $Query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
        $Query['client_id'] = $Application.ClientId
        $Query['response_type'] = $ResponseType
        $Query['state'] = $State
        $Query['redirect_uri'] = $Application.RedirectUri
        $Query['duration'] = $Duration
        $Query['scope'] = $Application.Scope -Join ','
        
        Write-Verbose "Create Url Object for parsing with Url Builder."
        $UrlObj = [System.Uri]$AuthUrl
        
        Write-Verbose "Create a URL Builder and poplate it with the Url and Query."
        $URLBuilder = New-Object -TypeName System.UriBuilder
        $UrlBuilder.Host = $UrlObj.Host
        $UrlBuilder.Scheme = $UrlObj.Scheme
        $UrlBuilder.Port = $UrlObj.Port
        # Split the userinfo, if supplied in the URL, at the : to get the user and password
        $UrlBuilder.UserName = $($UrlObj.UserInfo -split ':')[0]
        $UrlBuilder.Password = $($UrlObj.UserInfo -split ':')[1]
        $UrlBuilder.Path = $UrlObj.AbsolutePath
        $URLBuilder.Query = $Query.ToString()
        
        Write-Verbose "Write the constructed URL to output."
        Write-Output $URLBuilder.ToString()
    }
}