

<#
    .SYNOPSIS
        Retrieves information about the current Reddit account
    
    .DESCRIPTION
        A detailed description of the Get-RedditAccount function.
    
    .PARAMETER AccessToken
        Reddit OAuth Access Token returned from Get-RedditOAuthAccessToken
    
    .PARAMETER APIBaseURL
        This is the base URL of the API endpoint. This is provided for use with Reddit clones.
    
    .PARAMETER APIEndPoint
        The API endpoint that will be accessed. This is provided for use with Reddit clones.
        Default:
        /api/v1/me
    
    .EXAMPLE
        PS C:\> Get-RedditAccount -AccessToken $value1
    
    .NOTES
        Additional information about the function.
#>
function Get-RedditAccount {
    [CmdletBinding(HelpUri = 'https://github.com/markekraus/ConnectReddit/wiki/Get%E2%80%90RedditAccount')]
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
        
        [string]$ApiEndPoint = '/api/v1/me'
    )
    
    Process {
        $Params = @{
            Get = $true
            AccessToken = $AccessToken
            ApiBaseUrl = $ApiBaseUrl
            ApiEndPoint = $ApiEndPoint
        }
        try {
            $ResponseObject = Get-RedditApiResponse @Params
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            $Message = "Unable to query account: {0}" -f $ErrorMessage
            Write-Error $Message
            return
        }
        Write-Verbose 'Setting Types'
        $ResponseObject.Psobject.TypeNames.Clear()
        Write-Verbose '-Adding type Reddit.User'
        $ResponseObject.Psobject.TypeNames.add('Reddit.User')
        Write-Verbose '-Adding type Reddit.Account'
        $ResponseObject.Psobject.TypeNames.add('Reddit.Account')
        Write-Verbose '-Adding type Reddit.Object'
        $ResponseObject.Psobject.TypeNames.add('Reddit.Object')
        Write-Output $ResponseObject
    }
}
