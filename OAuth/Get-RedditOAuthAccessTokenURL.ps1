<#
	.SYNOPSIS
		Generates an OAuth Access AccessToken URL
	
	.DESCRIPTION
		Generates an OAuth Access AccessToken URL. This is primarily used by other functions in this module but is provided for those who wish to manually retrieve OAuth tokens.
	
	.PARAMETER Application
		Reddit Application object created by New-RedditApplication
	
	.PARAMETER Code
		The one-time use code that may be exchanged for a bearer AccessToken. This is provided in the OAuth Response. See https://github.com/reddit/reddit/wiki/OAuth2#allowing-the-user-to-authorize-your-application
	
	.PARAMETER AccessToken
		Reddit OAuth Access AccessToken object created by Get-RedditOAuthAccessToken
	
	.PARAMETER Url
		API Endpoint URL To retrieve the OAUth AccessToken from. This is not required and is included only for compatibility with Reddit clones.
	
	.EXAMPLE
		PS C:\> Get-RedditOAuthAccessTokenURL -Application $RedditApplication -Code '12345abcde'
	
	.EXAMPLE
		PS C:\> Get-RedditOAuthAccessTokenURL -AccessToken $RedditToken
	
	.EXAMPLE
		PS C:\> Get-RedditOAuthAccessTokenURL -Application $RedditScriptApp
	
	.OUTPUTS
		System.String
	
	.NOTES
		For more information about registering Reddit Apps, Reddit's API, or Reddit OAuth see:
		https://github.com/reddit/reddit/wiki/API
		https://github.com/reddit/reddit/wiki/OAuth2
		https://www.reddit.com/prefs/apps
		https://www.reddit.com/wiki/api
#>
function Get-RedditOAuthAccessTokenURL {
    [CmdletBinding(DefaultParameterSetName = 'Script',
                   ConfirmImpact = 'None',
                   SupportsShouldProcess = $true)]
    [OutputType([System.String])]
    param
    (
        [Parameter(ParameterSetName = 'Code',
                   Mandatory = $true,
                   ValueFromPipeline = $true)]
        [Parameter(ParameterSetName = 'Script')]
        [Alias('RedditApp', 'App')]
        [pstypename('Reddit.Application')]$Application,
        [Parameter(ParameterSetName = 'Code',
                   Mandatory = $true,
                   HelpMessage = 'code retruned by the OAuth authorization request')]
        [ValidateNotNullOrEmpty()]
        [string]$Code,
        [Parameter(ParameterSetName = 'Refresh',
                   Mandatory = $true,
                   ValueFromPipeline = $true)]
        [Alias('Token')]
        [pstypename('Reddit.OAuthAccessToken')]$AccessToken,
        [Parameter(ParameterSetName = 'Code',
                   Mandatory = $false)]
        [Parameter(ParameterSetName = 'Refresh')]
        [Parameter(ParameterSetName = 'Script')]
        [ValidateScript({
                [system.uri]::IsWellFormedUriString(
                    $_, [System.UriKind]::Absolute
                )
            })]
        [string]$Url = 'https://www.reddit.com/api/v1/access_token'
    )
    
    Process {
        Write-Verbose "Building Query String."
        $Query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
        if ($PsCmdlet.ParameterSetName -eq 'Code') {
            $Query['grant_type'] = 'authorization_code'
            $Query['code'] = $Code
            $Query['redirect_uri'] = $Application.RedirectUri
        }
        if ($PsCmdlet.ParameterSetName -eq 'Refresh' -and $AccessToken.Application.Type -ne 'Script') {
            $Query['grant_type'] = 'refresh_token'
            $Query['refresh_token'] = $AccessToken.RefreshToken
        }
        if ($Application.Type -eq 'Script') {
            $Query['grant_type'] = 'password'
            $Query['username'] = $Application.UserCredential.UserName
            $Query['password'] = $Application.UserCredential.GetNetworkCredential().Password
        }
        if ($AccessToken.Application.Type -eq 'Script') {
            $Query['grant_type'] = 'password'
            $Query['username'] = $AccessToken.Application.UserCredential.UserName
            $Query['password'] = $AccessToken.Application.UserCredential.GetNetworkCredential().Password
        }
        
        Write-Verbose "Create Url Object for parsing with Url Builder."
        $UrlObj = [System.Uri]$Url
        
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
