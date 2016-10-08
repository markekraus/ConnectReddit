<#
    .SYNOPSIS
        Refreshes an expired Reddit Oauth Token
    
    .DESCRIPTION
        Requests a refresh of the Reddit OAuth Access Token from Reddit.
    
    .PARAMETER AccessToken
        Reddit OAUth Access Token Object created by Get-RedditOAuthAccessToken.
    
    .PARAMETER Url
        A description of the Url parameter.
    
    .PARAMETER PassThru
        Indicates that the cmdlet sends items from the interactive window down the pipeline as input to other commands. By default, this cmdlet does not generate any output.
    
    .EXAMPLE
        PS C:\> $RedditToken = $RedditToken | Update-RedditOAuthAccessToken
    
    .OUTPUTS
        Reddit.OAuthAccessToken
    
    .NOTES
        Additional information about the function.
#>
function Update-RedditOAuthAccessToken {
    [CmdletBinding(ConfirmImpact = 'Low')]
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
        
        [switch]$PassThru
    )
    
    process {
        Foreach ($RefreshToken in $AccessToken) {
            Write-Verbose "Processing token '$($RefreshToken.GUID.ToString())'"
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
