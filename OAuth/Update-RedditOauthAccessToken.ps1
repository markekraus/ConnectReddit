<#
    .SYNOPSIS
        Refreshes aReddit Oauth Access Token
    
    .DESCRIPTION
        Requests a refresh of the Reddit OAuth Access Token from Reddit.
    
    .PARAMETER AccessToken
        Reddit OAUth Access Token Object created by Get-RedditOAuthAccessToken.
    
    .PARAMETER Url
        Url for the OAuth Submission end point. Defaults to 'https://www.reddit.com/api/v1/access_token'.
        Provided for compatibility with reddit clones.
    
    .PARAMETER Force
        By default, a Token will not be renewed if it is not expired. Using force will update the token even if it is not expired.
    
    .PARAMETER PassThru
        Indicates that the cmdlet sends items from the interactive window down the pipeline as input to other commands. By default, this cmdlet does not generate any output.    
    
    .EXAMPLE
        PS C:\> $RedditToken = $RedditToken | Update-RedditOAuthAccessToken
    
    .OUTPUTS
        Reddit.OAuthAccessToken
    
    .NOTES
        For more information about registering Reddit Apps, Reddit's API, or Reddit OAuth see:
            https://github.com/reddit/reddit/wiki/API
            https://github.com/reddit/reddit/wiki/OAuth2
            https://www.reddit.com/prefs/apps
            https://www.reddit.com/wiki/api
#>
function Update-RedditOAuthAccessToken {
    [CmdletBinding(ConfirmImpact = 'Low',
                   HelpUri = 'https://github.com/markekraus/ConnectReddit/wiki/Update%E2%80%90RedditOAuthAccessToken')]
    [OutputType([System.Management.Automation.PSObject])]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [pstypename('Reddit.OAuthAccessToken')]
        [Alias('Token')]
        [System.Management.Automation.PSObject[]]$AccessToken,
        
        [Parameter(Mandatory = $false)]
        [ValidateScript({
                [system.uri]::IsWellFormedUriString(
                    $_, [System.UriKind]::Absolute
                )
            })]
        [string]$Url = 'https://www.reddit.com/api/v1/access_token',
        
        [switch]$Force,
        
        [switch]$PassThru
    )
    
    process {
        Foreach ($RefreshToken in $AccessToken) {
            Write-Verbose "Processing token '$($RefreshToken.GUID.ToString())'"
            If (!$AccessToken.isExpired -and !$Force) {
                Write-Verbose "Token is not expired. Skipping"
                Continue
            }
            $RefreshURL = Get-RedditOAuthAccessTokenURL -Url $Url -AccessToken $RefreshToken
            Write-Verbose "RefreshURL: $RefreshURL"
            $RefreshToken.Session.Headers['Authorization'] = Get-RedditOAuthAuthorizationHeader -AccessToken $RefreshToken
            Write-Verbose "Authorization header: $($RefreshToken.Session.Headers['Authorization'])"
            $Params = @{
                Uri = $RefreshURL
                WebSession = $RefreshToken.Session
                Method = 'POST'
            }
            $RequestTime = Get-Date
            try {
                $WebRequest = Invoke-WebRequest @Params
                $WebRequest | Confirm-RedditOAuthAccessTokenResponse | Out-Null
            }
            catch {
                $ErrorMessage = $_.Exception.Message
                Write-Error "Failed to refresh token: $ErrorMessage"
                continue
            }
            $RefreshToken.TokenObject = $WebRequest.Content | ConvertFrom-Json
            $RefreshToken.Requested = $RequestTime
            $RefreshToken.Session.Headers['Authorization'] = 'bearer {0}' -f $RefreshToken.TokenObject.access_token
            
            if ($PassThru) {
                Write-Verbose "Sending Token to the Pipeline"
                Write-Output $RefreshToken
            }
        }
    }
}
