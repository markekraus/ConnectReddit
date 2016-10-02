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
        $OutToken = New-Object -TypeName System.Management.Automation.PSObject
        # Add-Memver used to ensure property order since this object has a fair amount of ScriptProperties
        $OutToken | Add-Member -MemberType ScriptProperty -Name AccessToken -Value { $This.TokenObject.access_token }
        $OutToken | Add-Member -MemberType NoteProperty -Name RefreshToken -Value $MyRefreshToken
        $OutToken | Add-Member -MemberType ScriptProperty -Name TokenType -Value { $this.TokenObject.token_type }
        $OutToken | Add-Member -MemberType NoteProperty -Name Requested -Value $Requested
        # Expiration is determined by adding the exxpires_in secoins tot he Requested time
        # Assume the toekn is expired now if a Requested Date is not available in the object
        $OutToken | Add-Member -MemberType ScriptProperty -Name Expires -Value {
            if ($This.Requested) {
                $This.Requested.AddSeconds($this.TokenObject.expires_in)
            }
            else {
                Get-Date
            }
        }
        # Simple bool if "now" is equal to or grater than the Expires time
        $OutToken | Add-Member -MemberType ScriptProperty -Name IsExpired -Value { $(get-date) -ge $this.Expires }
        #Build an array from the Scope string
        $OutToken | Add-Member -MemberType ScriptProperty -Name ValidScope -Value { $This.TokenObject.Scope -split ' ' }
        $OutToken | Add-Member -MemberType NoteProperty -Name Application -Value $Application
        $OutToken | Add-Member -MemberType NoteProperty -Name TokenObject -Value $TokenObject
        $OutToken | Add-Member -MemberType NoteProperty -Name TokenJSON -Value $TokenJSON        
        $OutToken | Add-Member -MemberType NoteProperty -Name Session -Value $Session
        $OutToken | Add-Member -MemberType NoteProperty -Name ResponseHeaders -Value $ResponseHeaders
        $OutToken | Add-Member -MemberType ScriptProperty -Name RatelimitUsed -Value { $This.ResponseHeaders.'X-Ratelimit-Used' }
        $OutToken | Add-Member -MemberType ScriptProperty -Name RatelimitRemaining -Value { $This.ResponseHeaders.'X-Ratelimit-Remaining' }
        $OutToken | Add-Member -MemberType NoteProperty -Name LastRequest -Value $LastRequest
        # Calculate the Ratelimit Perio reset date/time by adding X-Ratelimit-Reset seconds to LastRequest
        # If those are not set, assume the resetime is now
        $OutToken | Add-Member -MemberType ScriptProperty -Name RatelimitReset -Value {
            if ($This.ResponseHeaders.'X-Ratelimit-Reset' -and $This.LastRequest) {
                $This.LastRequest.AddSeconds($This.ResponseHeaders.'X-Ratelimit-Reset')
            }
            else {
                Get-Date
            }
        }
        # Boolean to determine if ratelimit has been imposted.
        # If the RatelimitReset is in the future and RatelimitRemaining is less than 1, the next request would be rate limited
        $OutToken | Add-Member -MemberType ScriptProperty -Name IsRatelimited -Value {
            if ($This.RatelimitReset -gt (get-date) -and $This.RatelimitRemaining -lt 1) {
                $True
            }
            else {
                $False
            }
        }
        $OutToken | Add-Member -MemberType NoteProperty -Name GUID -Value $GUID
        Write-Verbose 'Setting custom type name to Reddit.OAuthAccessToken'
        $OutToken.Psobject.TypeNames.Clear()
        $OutToken.Psobject.TypeNames.Insert(0, 'Reddit.OAuthAccessToken')
        # Not entirely sure this will be used, but registering it just in case.
        Write-Verbose "Registering the Global variable `${$($GUID.ToString())}."
        Try {
            New-Variable -Scope Global -Name $GUID.ToString() -Value $OutToken -ErrorAction Stop | Out-Null
        }
        Catch {
            try {
                Set-Variable -Scope Global -Name $GUID.ToString() -Value $OutToken -ErrorAction Stop | OUt-Null
            }
            catch {
                Write-Warning "Unable to register Global variable."
            }            
        }
        # Send the token object to the pipe
        Write-Output $OutToken
    }
}
