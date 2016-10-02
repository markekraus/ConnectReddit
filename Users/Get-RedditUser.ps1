
<#
    .SYNOPSIS
        Returns a Reddit User Object
    
    .DESCRIPTION
        This will retrun a Reddit user object
    
    .PARAMETER AccessToken
        Reddit OAuth Access Token returned from Get-RedditOAuthAccessToken
    
    .PARAMETER Username
        The reddit username to be queried.
        Examples:
        /u/markekraus
        u/markekraus
        markekraus
    
    .PARAMETER APIBaseURL
        This is the base URL of the API endpoint. This is provided for use with Reddit clones.
    
    .PARAMETER APIEndPoint
        The API endpoint that will be accessed. This is provided for use with Reddit clones. Use {0} to indicate the username.
        Default:
        /api/{0}/about
    
    .PARAMETER UserBaseUrl
        The Base URL for user account. The default is https://www.reddit.com/u/. This is used to construct the user URL and is provided for use with Reddit clones.
    
    .PARAMETER AccessToken
        Reddit OAuth Access Token returned from Get-RedditOAuthAccessToken
    
    .EXAMPLE
        PS C:\> Get-RedditUser -AccessToken $RedditToken -Username 'markekraus'
    
    .OUTPUTS
        System.Management.Automation.PSObject
    
    .NOTES
        Additional information about the function.
#>
function Get-RedditUser {
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([System.Management.Automation.PSObject])]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [pstypename('Reddit.OAuthAccessToken')]
        [Alias('Token')]
        [System.Management.Automation.PSObject]$AccessToken,
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('User', 'U')]
        [string[]]$Username,
        
        [Parameter(Mandatory = $false)]
        [string]$ApiBaseURL = 'https://oauth.reddit.com',
        
        [string]$ApiEndPoint = '/user/{0}/about'
    )
    
    Process {
        foreach ($User in $Username) {
            # Support Should ProcessGet-RedditUser
            if (-not $PSCmdlet.ShouldProcess($User)) {
                Continue
            }
            
            $Params = @{
                Get = $true
                AccessToken = $AccessToken
                ApiBaseUrl = $ApiBaseUrl
                ApiEndPoint = $ApiEndPoint -f $($User -replace '^.*/', '')
            }
            try {
                $Response = Get-RedditApiResponse @Params
                $ResponseObject = $Response.data
            }
            catch {
                $ErrorMessage = $_.Exception.Message
                $Message = "Unable to query account: {0}" -f $ErrorMessage
                Write-Error $Message
                return
            }
            Write-Verbose 'Setting types'
            $ResponseObject.Psobject.TypeNames.Clear()
            Write-Verbose '-Adding Reddit.User'
            $ResponseObject.Psobject.TypeNames.add('Reddit.User')
            Write-Verbose '-Adding Reddit.Object'
            $ResponseObject.Psobject.TypeNames.add('Reddit.Object')
            Write-Output $ResponseObject
        }
    }
}
