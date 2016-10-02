<#
    .SYNOPSIS
        Checks a Reddit OAuth Access Token Request Response
    
    .DESCRIPTION
        Verifies no erros were fone and that the expected fields are present. If an error is found, an exception will be thrown.
    
    .PARAMETER Response
        Reddit OAuth Access Token Response  object from Invoke-WebRequest
    
    .EXAMPLE
        		PS C:\> Confirm-RedditOAuthAccessTokenResponse -Response $Response
    
    .NOTES
        For more information about registering Reddit Apps, Reddit's API, or Reddit OAuth see:
            https://github.com/reddit/reddit/wiki/API
            https://github.com/reddit/reddit/wiki/OAuth2
            https://www.reddit.com/prefs/apps
            https://www.reddit.com/wiki/api
#>
function Confirm-RedditOAuthAccessTokenResponse {
    [CmdletBinding(ConfirmImpact = 'None')]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [Microsoft.PowerShell.Commands.HtmlWebResponseObject]$Response
    )
    Begin {
        # https://github.com/reddit/reddit/wiki/OAuth2#retrieving-the-access-token
        $ErrorCodes = @{
            'unsupported_grant_type' = 'grant_type parameter was invalid or Http Content type was not set correctly.'
            'invalid_request' = 'The request was invalid. Malform4ed request, Missing Code, invalid code, or unknown error.'
            'invalid_grant' = 'The code has expired or already been used.'
        }
    }
    Process {
        Write-Verbose 'Checking for invalide client credentials.'
        if ($Response.StatusCode -like '401') {
            Write-Output $False
            Throw "Client credentials sent as HTTP Basic Authorization were invalid"
        }
        Write-Verbose 'Client credentials ok.'
        Write-Verbose 'Converting Content to Object'
        $TokenObject = $Response.Content | ConvertFrom-Json
        Write-Verbose 'Checking if error present'
        if ($TokenObject.error) {
            Write-Output $false
            If ($ErrorCodes."$($TokenObject.error)") {
                $Message = "Error '{0}': {1}" -f $TokenObject.error, $ErrorCodes."$($TokenObject.error)"
                throw $Message
            }
            else {
                $Message = "Uknknown error code: {0}" -f $TokenObject.error
                Throw 
            }
        }
        Write-Verbose 'No error found.'
        Write-Verbose 'Verifying Access Token was retruned.'
        if (!$TokenObject.access_token) {
            $Message = "access_token not found. response: {0}" -f $($TokenObject | ConvertTo-Json -Compress)
        }
        Write-verbose 'Access Token found.'
        Write-Output $True
    }    
}
