<#
    .SYNOPSIS
        Exports a Reddit OAuth Access Token object to a file.
    
    .DESCRIPTION
        Used to Export a Reddit OAuth Access Token object to a file so it can later be imported.
    
    .PARAMETER Path
        Specifies the path to the file where the XML representation of the Reddit AcessToken object will be stored
    
    .PARAMETER LiterlPath
        Specifies the path to the file where the XML representation of the Reddit AcessToken object will be stored. Unlike Path, the value of the LiteralPath parameter is used exactly as it is typed. No characters are interpreted as wildcards. If the path includes escape characters, enclose it in single quotation marks. Single quotation marks tell Windows PowerShell not to interpret any characters as escape sequences.
    
    .PARAMETER Encoding
        Specifies the type of encoding for the target file. The acceptable values for this parameter are:
        
        -- ASCII
        -- UTF8
        -- UTF7
        -- UTF32
        -- Unicode
        -- BigEndianUnicode
        -- Default
        -- OEM
        
        The default value is Unicode.
    
    .PARAMETER AcessToken
        Reddit OAuth Acess Token Object to be exported.
    
    .EXAMPLE
        PS C:\> $RedditApp | Export-RedditOAuthAccessToken -Path 'c:\RedditToken.xml'
    
    .OUTPUTS
        System.IO.FileInfo, System.IO.FileInfo
    
    .NOTES
        This is an Export-Clixml wrapper.
        See Import-RedditOauthAccessToken for importing exported Reddit AcessToken Objects
    
    .LINK
        Import-RedditOauthAccessToken
#>
function Export-RedditOAuthAccessToken {
    [CmdletBinding(DefaultParameterSetName = 'Path',
                   ConfirmImpact = 'Low',
                   HelpUri = 'https://github.com/markekraus/ConnectReddit/wiki/Export%E2%80%90RedditOAuthAccessToken',
                   SupportsShouldProcess = $true)]
    [OutputType([System.IO.FileInfo])]
    param
    (
        [Parameter(ParameterSetName = 'Path',
                   Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        
        [Parameter(ParameterSetName = 'LiteralPath',
                   Mandatory = $true,
                   ValueFromRemainingArguments = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$LiterlPath,
        
        [Parameter(ParameterSetName = 'LiteralPath',
                   Mandatory = $false,
                   ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'Path',
                   Mandatory = $false,
                   ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('ASCII', 'UTF8', 'UTF7', 'UTF32', 'Unicode', 'BigEndianUnicode', 'Default', 'OEM')]
        [string]$Encoding = 'Unicode',
        
        [Parameter(ParameterSetName = 'LiteralPath',
                   Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'Path',
                   Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [pstypename('Reddit.OAuthAccessToken')]
        [Alias('Token')]
        [System.Management.Automation.PSObject]$AcessToken
    )
    
    Process {
        switch ($PsCmdlet.ParameterSetName) {
            'Path' {
                $Params = @{
                    Encoding = $Encoding
                    Path = $Path
                    InputObject = $AcessToken
                }
                $Target = $Path
            }
            'LiteralPath' {
                $Params = @{
                    Encoding = $Encoding
                    LiteralPath = $LiterlPath
                    InputObject = $AcessToken
                }
                $Target = $LiteralPath
            }
        }
        if ($pscmdlet.ShouldProcess("Target")) {
            Export-Clixml @Params
        }
    }
}
