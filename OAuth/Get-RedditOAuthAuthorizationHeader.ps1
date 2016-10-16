<#
    .SYNOPSIS
        Returns an rfc2617 Authorization header
    
    .DESCRIPTION
        Returns an rfc2617 Authorization header.
    
    .PARAMETER UserName
        The username to be enbeded in the Authorization Header.
    
    .PARAMETER Password
        Password to be embeded in the Authorization header.
    
    .PARAMETER ClientCredential
        PSCredential containing the Client ID as the username and the Client Secret as the password
    
    .PARAMETER Application
        Reddit Application object created by New-RedditApplication
    
    .PARAMETER AccessToken
        Reddit OAuth Access Token Object created by New-RedditOAuthAccessToken
    
    .EXAMPLE
        PS C:\> Get-RedditOAuthAuthorizationHeader -UserName 'user' -Password 'p@ssw0rd'
    
    .EXAMPLE
        PS C:\> $ClienCredential= Get-Credential
        PS C:\> $Authorization = $ClientInfo | Get-RedditOAuthAuthorizationHeader
    
    .OUTPUTS
        string, string
    
    .NOTES
        Fore more on rfc2617 Authorzation headers, see
            https://tools.ietf.org/html/rfc2617#section-2
            https://github.com/reddit/reddit/wiki/OAuth2#retrieving-the-access-token
        For more information about registering Reddit Apps, Reddit's API, or Reddit OAuth see:
            https://github.com/reddit/reddit/wiki/API
            https://github.com/reddit/reddit/wiki/OAuth2
            https://www.reddit.com/prefs/apps
            https://www.reddit.com/wiki/api
#>
function Get-RedditOAuthAuthorizationHeader {
    [CmdletBinding(DefaultParameterSetName = 'AccessToken',
                   ConfirmImpact = 'None',
                   HelpUri = 'https://github.com/markekraus/ConnectReddit/wiki/Get%E2%80%90RedditOAuthAuthorizationHeader')]
    [OutputType([System.String])]
    param
    (
        [Parameter(ParameterSetName = 'Plaintext',
                   Mandatory = $true)]
        [Alias('User')]
        [string]$UserName,
        
        [Parameter(ParameterSetName = 'Plaintext',
                   Mandatory = $true)]
        [Alias('Pass')]
        [string]$Password,
        
        [Parameter(ParameterSetName = 'ClientCredential',
                   Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [Alias('Credential')]
        [System.Management.Automation.PSCredential]$ClientCredential,
        
        [Parameter(ParameterSetName = 'Application',
                   Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [pstypename('Reddit.Application')]
        [System.Management.Automation.PSObject]$Application,
        
        [Parameter(ParameterSetName = 'AccessToken',
                   Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [pstypename('Reddit.OAuthAccessToken')]
        [System.Management.Automation.PSObject]$AccessToken
    )
    
    process {
        switch ($PsCmdlet.ParameterSetName) {
            'ClientCredential' {
                $UserName = $ClientCredential.UserName
                $Password = $ClientCredential.GetNetworkCredential().password
            }
            'Application' {
                $UserName = $Application.ClientCredential.UserName
                $Password = $Application.ClientCredential.GetNetworkCredential().password
            }
            'AccessToken'{
                $UserName = $AccessToken.Application.ClientCredential.UserName
                $Password = $AccessToken.Application.ClientCredential.GetNetworkCredential().password
            }
        }
        
        $UserPass = '{0}:{1}' -f $UserName, $Password
        $Bytes = [System.Text.Encoding]::ASCII.GetBytes($UserPass)
        $Auth = [System.Convert]::ToBase64String($Bytes)
        $OutString = 'Basic {0}' -f $Auth
        Write-Output $OutString
    }
}

