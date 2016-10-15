<#
    .SYNOPSIS
        Creates a Reddit.OAuthAccessToken Object
    
    .DESCRIPTION
        Creates a Reddit.OAuthAccessToken object only. This does not retrieve an OAuth Access Token from reddit. This can be used to manually create the Reddit OAuthAccessToken objects if the access token has been obtained manually or by external means. See Get-RedditOAuthAccessToken for retrieving an OAuth Access Token from Reddit.
        The Reddit.OAuthAccessToken Object contains the following properties:
        
        AccessToken         The Reddit OAuth Access Token
        RefreshToken        The Reddit OAuth Refresh Token
        TokenType           The Reddit OAuth Token Type (bearer)
        Requested           Date/Time the token was requested
        Expires             Date/Time the token expires
        ValidScopes         OAuth Scopes for which the token is valid
        Application         Redit.Application object for the Application this token is for.
        TokenObject         PSObject Representation of the OAUth Token Resposne
        TokenJSON           Raw JSON of the OAuth Token Response
        Session             Web Sesion variable used for API calls
        ResponseHeaders     Response headers from the most recent API request
        LastRequest         Date/Time of the last API request this token was used
        GUID                GUID for this token
        IsExpired           Boolean to determine if token is expired
        RatelimitUsed       Approximate number of API requests used in this period
        RatelimitRemaining  Approximate number of API requests left to use this period
        RatelimtReset       Approximate Date/Time the ratelimit time perdio resets
        IsRatelimited       Boolean to determin if the token has been ratelimited
    
    .PARAMETER TokenJSON
        JSON OAuth Token response returned from Reddit.
    
    .PARAMETER TokenObject
        A PSObject converted from the JSON response retruned by Reddit OAuth Access Token request.
        
        PS C:\> $TokenObject = $TokenJSON | ConvertFrom-Json
    
    .PARAMETER Requested
        System.DateTime object for the time that the Token was requested. this is used to caluclate the expiration time of the token.
    
    .PARAMETER Session
        Session object returned from  Invoke-WebRequest. The session object is used to manage cookies and headers sent to to reddit API such as the User-Agent and Authorzation headers. The User-Agent header will be overwritten by the UserAgent defined in the Reddit Application object.
    
    .PARAMETER Application
        Reddit Application Object. See New-RedditApplication
    
    .PARAMETER GUID
        A GUID to identify the Reddit OAuth Token Object. If one is not provided, a new GUID will be generated
    
    .PARAMETER ResponseHeaders
        Response Headers from the reddit OAuth Ahccess Token request. This is used to populate the RateLimitUsed, RateLimitRemaining, and RateLimitRest to be used to rate limit tracking.
    
    .PARAMETER LastRequest
        DateTime object for the time of the last request sent to the redit API. If none is supplied, the Requested time is used. This is used for rate limit tracking.
    
    .PARAMETER RefreshToken
        The Refresh Token provided in the initial OAuth Access Token response. This only needs to be provided if it will not be available in the TokenObject or TokenJSON.
    
    .EXAMPLE
        PS C:\> $Params = @{
        Requested = $RequestTime
        TokenJSON = $WebRequest.Content
        Session = $Session
        Application = $RedditApp
        }
        PS C:\> $RedditToken  = New-RedditOAuthAccessToken @Params
    
    .OUTPUTS
        System.Management.Automation.PSObject
    
    .NOTES
        For more information about registering Reddit Apps, Reddit's API, or Reddit OAuth see:
            https://github.com/reddit/reddit/wiki/API
            https://github.com/reddit/reddit/wiki/OAuth2
            https://www.reddit.com/prefs/apps
            https://www.reddit.com/wiki/api
#>
function New-RedditOAuthAccessToken {
    [CmdletBinding(DefaultParameterSetName = 'JSON',
                   ConfirmImpact = 'None')]
    [OutputType([System.Management.Automation.PSObject])]
    param
    (
        [Parameter(ParameterSetName = 'JSON',
                   Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({ $_ | ConvertFrom-Json })]
        [ValidateNotNullOrEmpty()]
        [String]$TokenJSON,
        
        [Parameter(ParameterSetName = 'PsObject',
                   Mandatory = $true)]
        [Alias('Object')]
        [System.Management.Automation.PSObject]$TokenObject,
        
        [Parameter(ParameterSetName = 'JSON',
                   Mandatory = $true)]
        [Parameter(ParameterSetName = 'PsObject',
                   Mandatory = $true)]
        [System.DateTime]$Requested,
        
        [Parameter(ParameterSetName = 'JSON',
                   Mandatory = $false)]
        [Parameter(ParameterSetName = 'PsObject')]
        [Microsoft.PowerShell.Commands.WebRequestSession]$Session,
        
        [Parameter(ParameterSetName = 'JSON',
                   Mandatory = $true)]
        [Parameter(ParameterSetName = 'PsObject',
                   Mandatory = $true)]
        [pstypename('Reddit.Application')]
        [Alias('RedditApp', 'App')]
        [System.Management.Automation.PSObject]$Application,
        
        [Parameter(ParameterSetName = 'JSON',
                   Mandatory = $false)]
        [Parameter(ParameterSetName = 'PsObject')]
        [System.Guid]$GUID = [System.Guid]::NewGuid(),
        
        [Parameter(ParameterSetName = 'JSON',
                   Mandatory = $false)]
        [Parameter(ParameterSetName = 'PsObject',
                   Mandatory = $false)]
        [System.Management.Automation.PSObject]$ResponseHeaders,
        
        [Parameter(ParameterSetName = 'JSON',
                   Mandatory = $false)]
        [Parameter(ParameterSetName = 'PsObject',
                   Mandatory = $false)]
        [System.DateTime]$LastRequest = $Requested,
        
        [Parameter(ParameterSetName = 'JSON',
                   Mandatory = $false)]
        [Parameter(ParameterSetName = 'PsObject',
                   Mandatory = $false)]
        [string]$RefreshToken
    )
    
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'JSON'{
                Write-Verbose "Building TokenObject from TokenJSON."
                $TokenObject = $TokenJSON | ConvertFrom-Json
            }
            'PsObject'{
                Write-Verbose "Building TokenJSON from TokenObject"
                $TokenJSON = $TokenObject | ConvertTo-Json
            }
        }
        Write-Verbose 'Updateing Authorization session header.'
        $Session.Headers['Authorization'] = 'bearer {0}' -f $TokenObject.access_token
        Write-Verbose 'Determing RefreshToken source.'
        if ($RefreshToken) {
            $MyRefreshToken = $RefreshToken
        }
        else {
            $MyRefreshToken = $TokenObject.refresh_token
        }
        Write-Verbose 'Buildon Reddit.OAuthAccessToken object'
        $OutToken = [pscustomobject]@{
            RefreshToken = $MyRefreshToken
            Requested = $Requested
            Application = $Application
            TokenObject = $TokenObject
            TokenJSON = $TokenJSON
            Session = $Session
            ResponseHeaders = $ResponseHeaders
            LastRequest = $LastRequest
            GUID = $GUID
        } 
        Write-Verbose 'Setting custom type name to Reddit.OAuthAccessToken'
        $OutToken.Psobject.TypeNames.Clear()
        # See /Types/Reddit.OAuthAccessToken.ps1 for the magic
        $OutToken.Psobject.TypeNames.Insert(0, 'Reddit.OAuthAccessToken')
        Write-Output $OutToken
    }
}
