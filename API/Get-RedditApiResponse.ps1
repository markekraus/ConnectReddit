
<#
    .SYNOPSIS
        A brief description of the Get-RedditApiResponse function.
    
    .DESCRIPTION
        A detailed description of the Get-RedditApiResponse function.
    
    .PARAMETER Get
        Sets the request method as GET.
    
    .PARAMETER Post
        Sets the request method as POST
    
    .PARAMETER Patch
        Sets the request method as Patch
    
    .PARAMETER Put
        Sets the request method as PUT
    
    .PARAMETER Delete
        Sets the request method as DELETE
    
    .PARAMETER AccessToken
        Reddit OAuth Access Token Object created by Get-RedditOAuthAccessToken.
    
    .PARAMETER ApiBaseUrl
        The Base URL of the API Endpoint. This is provided for use with Reddit clones.
        Defaults to https://oauth.reddit.com/
    
    .PARAMETER ApiEndPoint
        API Endpoint to be queried. (e.g. '/api/v1/me').
    
    .PARAMETER SubmitObject
        Object containing data that will be submitted to the Reddit API in this request.
        The object will be converted to JSON so it must be an object type that
        ConvertTo-Json can process.
    
    .EXAMPLE
        PS C:\> Get-RedditApiResponse -Get
    
    .OUTPUTS
        System.Management.Automation.PSObject, System.Management.Automation.PSObject, System.Management.Automation.PSObject
    
    .NOTES
        For more information about registering Reddit Apps, Reddit's API, or Reddit OAuth see:
        https://github.com/reddit/reddit/wiki/API
        https://github.com/reddit/reddit/wiki/OAuth2
        https://www.reddit.com/prefs/apps
        https://www.reddit.com/wiki/api
#>
function Get-RedditApiResponse {
    [CmdletBinding(DefaultParameterSetName = 'GET',
                   ConfirmImpact = 'Low',
                   HelpUri = 'https://github.com/markekraus/ConnectReddit/wiki/Get%E2%80%90RedditApiResponse')]
    [OutputType([System.Management.Automation.PSObject])]
    param
    (
        [Parameter(ParameterSetName = 'GET',
                   Mandatory = $true)]
        [switch]$Get,
        
        [Parameter(ParameterSetName = 'POST',
                   Mandatory = $true)]
        [switch]$Post,
        
        [Parameter(ParameterSetName = 'PATCH',
                   Mandatory = $true)]
        [switch]$Patch,
        
        [Parameter(ParameterSetName = 'PUT',
                   Mandatory = $true)]
        [switch]$Put,
        
        [Parameter(ParameterSetName = 'DELETE',
                   Mandatory = $true)]
        [switch]$Delete,
        
        [Parameter(ParameterSetName = 'GET',
                   Mandatory = $true)]
        [Parameter(ParameterSetName = 'PATCH',
                   Mandatory = $true)]
        [Parameter(ParameterSetName = 'POST',
                   Mandatory = $true)]
        [Parameter(ParameterSetName = 'PUT')]
        [Parameter(ParameterSetName = 'DELETE')]
        [pstypename('Reddit.OAuthAccessToken')]
        [System.Management.Automation.PSObject]$AccessToken,
        
        [Parameter(ParameterSetName = 'GET',
                   Mandatory = $false)]
        [Parameter(ParameterSetName = 'PATCH',
                   Mandatory = $false)]
        [Parameter(ParameterSetName = 'POST',
                   Mandatory = $false)]
        [Parameter(ParameterSetName = 'DELETE')]
        [Parameter(ParameterSetName = 'PUT')]
        [string]$ApiBaseUrl = 'https://oauth.reddit.com/',
        
        [Parameter(ParameterSetName = 'GET',
                   Mandatory = $true)]
        [Parameter(ParameterSetName = 'PATCH',
                   Mandatory = $true)]
        [Parameter(ParameterSetName = 'POST',
                   Mandatory = $true)]
        [Parameter(ParameterSetName = 'DELETE',
                   Mandatory = $true)]
        [Parameter(ParameterSetName = 'PUT',
                   Mandatory = $true)]
        [string]$ApiEndPoint,
        
        [Parameter(ParameterSetName = 'PATCH',
                   Mandatory = $true)]
        [Parameter(ParameterSetName = 'POST',
                   Mandatory = $true)]
        [Parameter(ParameterSetName = 'PUT',
                   Mandatory = $true)]
        [System.Object]$SubmitObject
    )
    
    process {
        # Attempt to update the Token if it has expired
        $AccessToken | Update-RedditOAuthAccessToken
        
        # Take a nap if a rate limit is in effect
        $AccessToken | Wait-RedditOAuthAccessTokenRatelimitExpiration
        
        $ApiUri = $($ApiBaseUrl -replace '/$', '') + '/' + $($ApiEndPoint -replace '^/', '')
        Write-Verbose "API Uri: $ApiUri"
        # Paramters hash for the Invoke-WebRequest. 
        # Switch will ad some additional items which is why it is not right by the command
        $Params = @{
            WebSession = $AccessToken.Session
            Uri = $ApiUri
            ErrorAction = 'Stop'
        }
        switch ($PsCmdlet.ParameterSetName) {
            'GET' {
                $Params['Method'] = 'GET'
                break
            }
            'POST' {
                $Params['Method'] = 'POST'
                $Params['Body'] = $SubmitObject | ConvertTo-Json -Compress -Depth 100
                break
            }
            'PATCH' {
                $Params['Method'] = 'PATCH'
                $Params['Body'] = $SubmitObject | ConvertTo-Json -Compress -Depth 100
                break
            }
            'PATCH' {
                $Params['Method'] = 'PUT'
                $Params['Body'] = $SubmitObject | ConvertTo-Json -Compress -Depth 100
                break
            }
            'DELETE' {
                $Params['Method'] = 'DELETE'
                break
            }
        }
        Write-Verbose "Method: $($Params.Method)"
        Write-Verbose "Body: $($Params.Body)"
        # Using Invoke-WebRequest instead of Invoke-RestMethod because we need to capture
        # Response Headers for Rate Limit tracking
        try {
            $RequestTime = Get-Date
            $ApiResponse = Invoke-WebRequest @Params
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            $Message = "Reddit API Query failed: {0}" -f $ErrorMessage
            Write-Error $Message
            return
        }
        Write-Verbose 'Converting JSON to PSObject'
        $OutObj = $ApiResponse.Content | ConvertFrom-Json
        if ($OutObj.error) {
            $Message = "Reddit API Query failed: {0}" -f $OutObj.error
            Write-Error $Message
            return
        }
        Write-Verbose 'Updating Access token'
        $AccessToken.LastRequest = $RequestTime
        $AccessToken.ResponseHeaders = $ApiResponse.Headers
        Write-Output $OutObj
    }
}
