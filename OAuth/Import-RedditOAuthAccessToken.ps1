<#
    .SYNOPSIS
        Imports an exported Reddit OAuth Access Token Object
    
    .DESCRIPTION
        Imports an exported Reddit OAuth Access Token Object and retruns a Reddit  OAuth Access Token Object.
    
    .PARAMETER Path
        Specifies the XML files where the Reddit Application Object was exported.
    
    .PARAMETER LiteralPath
        Specifies the XML files where the Reddit Application Object was exported. Unlike Path, the value of the LiteralPath parameter is used exactly as it is typed. No characters are interpreted as wildcards. If the path includes escape characters, enclose it in single quotation marks. Single quotation marks tell Windows PowerShell not to interpret any characters as escape sequences.
    
    .EXAMPLE
        PS C:\> $RedditApp = Import-RedditOAuthAccessToken -Path 'c:\RedditToken.xml'
    
    .NOTES
        See Export-RedditOauthAccessToken for exporting Reddit AcessToken Objects

    .LINK
        Export-RedditOauthAccessToken
#>
function Import-RedditOAuthAccessToken {
    [CmdletBinding(DefaultParameterSetName = 'Path',
                   ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([System.Management.Automation.PSObject])]
    param
    (
        [Parameter(ParameterSetName = 'Path',
                   Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,
        
        [Parameter(ParameterSetName = 'LiteralPath',
                   Mandatory = $true,
                   ValueFromRemainingArguments = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$LiteralPath
    )
    
    Process {
        Switch ($PsCmdlet.ParameterSetName) {
            'Path' {
                $ImportFiles = $Path
            }
            'LiteralPath' {
                $ImportFiles = $LiteralPath
            }
        }
        foreach ($ImportFile in $ImportFiles) {
            if ($pscmdlet.ShouldProcess($ImportFile)) {
                Write-Verbose "Processing $($ImportFile)."
                $Params = @{
                    "$($PsCmdlet.ParameterSetName)" = $ImportFile
                }
                $InObject = Import-Clixml @Params
                Write-Verbose "Import Reddit Application"
                Write-Verbose "Name '$($InObject.Application.Name)' Id '$($InObject.Application.GUID)'"
                $Params = @{
                    "$($InObject.Application.Type)" = $True
                    Name = $InObject.Application.Name
                    ClientCredential = $InObject.Application.ClientCredential
                    RedirectUri = $InObject.Application.RedirectUri
                    Scope = $InObject.Application.Scope
                    UserAgent = $InObject.Application.UserAgent
                    Description = $InObject.Application.Description
                    GUID = $InObject.Application.GUID
                }
                $Application = New-RedditApplication @Params
                
                Write-Verbose 'Import Session'
                $Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
                $Session.Certificates = $InObject.Session.Certificates
                $Session.Credentials = $InObject.Session.Credentials
                $InObject.Session.Headers.GetEnumerator() | ForEach-Object {
                    $Session.Headers[$_.key] = $_.value
                }
                $Session.MaximumRedirection = $InObject.Session.MaximumRedirection
                $Session.Proxy = $InObject.Session.Proxy
                $Session.UseDefaultCredentials = $InObject.Session.UseDefaultCredentials
                $Session.UserAgent = $Application.UserAgent
                
                Write-Verbose 'Create Reddit Token Object'
                $Params = @{
                    TokenObject = $InObject.TokenObject
                    Requested = $InObject.Requested
                    Application = $Application
                    Session = $Session
                    ResponseHeaders = $InObject.ResponseHeaders
                    GUID = $InObject.GUID
                    LastRequest = $InObject.LastRequest
                    RefreshToken = $InObject.RefreshToken
                }
                $OutToken = New-RedditOAuthAccessToken @Params
                Write-Output $OutToken
            } #End Should Process
        } #End Foreach
    } #End Process
} #End Function
