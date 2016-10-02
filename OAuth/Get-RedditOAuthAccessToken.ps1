<#
	.SYNOPSIS
		Retrieves an OAuth Access Token
	
	.DESCRIPTION
		Submits a OAUth2 Access Token Request to Reddit and retruns a token object used by other cmdlets for autthenticated Reddit API calls.
	
	.PARAMETER Application
		Reddit Application created with New-RedditApplication
	
	.PARAMETER Code
		The one-time use code that may be exchanged for a bearer token. This is provided in the OAuth Authorzation Response.
	
	.PARAMETER Url
		API Endpoint URL To retrieve the OAUth token from. This is not required and is included only for compatibility with Reddit clones.
	
	.EXAMPLE
		PS C:\> $RedditToken = Get-RedditOAuthAccessToken -Code '86thkqvjsvj` -Application $RedditApp
	
	.OUTPUTS
		System.Management.Automation.PSCredential
	
	.NOTES
		For more information about registering Reddit Apps, Reddit's API, or Reddit OAuth see:
		https://github.com/reddit/reddit/wiki/API
		https://github.com/reddit/reddit/wiki/OAuth2
		https://www.reddit.com/prefs/apps
		https://www.reddit.com/wiki/api
#>
function Get-RedditOAuthAccessToken {
    [CmdletBinding(DefaultParameterSetName = 'Script',
                   ConfirmImpact = 'Low',
                   SupportsShouldProcess = $false)]
    [OutputType([System.Management.Automation.PSCredential])]
    param
    (
        [Parameter(ParameterSetName = 'Code',
                   Mandatory = $true,
                   ValueFromPipeline = $true)]
        [Parameter(ParameterSetName = 'Script',
                   Mandatory = $true)]
        [Alias('RedditApp', 'App')]
        [pstypename('Reddit.Application')]
        [System.Management.Automation.PSObject]$Application,
        [Parameter(ParameterSetName = 'Code',
                   Mandatory = $true,
                   HelpMessage = 'code retruned by the OAuth authorization request')]
        [ValidateNotNullOrEmpty()]
        [string]$Code,
        [Parameter(ParameterSetName = 'Code',
                   Mandatory = $false)]
        [Parameter(ParameterSetName = 'Script')]
        [ValidateScript({
                [system.uri]::IsWellFormedUriString(
                    $_, [System.UriKind]::Absolute
                )
            })]
        [string]$Url = 'https://www.reddit.com/api/v1/access_token'
    )
    
    Process {
        switch ($Application.Type) {
            'Installed' {
                #I was unable to figure out how to get this working
                #Earmarked for later support
                Write-Error 'OAuth Token not supported for Installed Apps at this time'
                Return
            }
            'Script' {
                $RequestURL = Get-RedditOAuthAccessTokenURL -Application $Application -Url $Url
            }
            'WebApp'{
                $RequestURL = Get-RedditOAuthAccessTokenURL -Application $Application -Code $Code -Url $Url
            }
        }
        Write-Verbose "RequestURL: '$RequestURL''"
        $Authorization = Get-RedditOAuthAuthorizationHeader -Application $Application
        Write-Verbose "Authorization: $Authorization"
        $Params = @{
            Uri = $RequestURL
            SessionVariable = 'Session'
            Headers = @{
                'User-Agent' = $Application.UserAgent
                'Authorization' = $Authorization
            }
            Method = 'POST'
            ErrorAction = 'Stop'
        }
        $RequestTime = Get-Date        
        try {
            $WebRequest = Invoke-WebRequest @Params
            $WebRequest | Confirm-RedditOAuthAccessTokenResponse | Out-Null
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Error "Token Request Failed: $ErrorMessage"
            return
        }
        $Params = @{
            Requested = $RequestTime
            TokenJSON = $WebRequest.Content
            Session = $Session
            Application = $Application
            ResponseHeaders = $WebRequest.Headers
        }
        $OutToken = New-RedditOAuthAccessToken @Params
        Write-Output $OutToken
    }
}
