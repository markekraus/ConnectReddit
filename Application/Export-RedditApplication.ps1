<#
    .SYNOPSIS
        Exports a Reddit Application object to a file.
    
    .DESCRIPTION
        Used to Export a Reddit Application object to a file so it can later be imported.
    
    .PARAMETER Path
        Specifies the path to the file where the XML representation of the Reddit Application object will be stored
    
    .PARAMETER LiterlPath
        Specifies the path to the file where the XML representation of the Reddit Application object will be stored. Unlike Path, the value of the LiteralPath parameter is used exactly as it is typed. No characters are interpreted as wildcards. If the path includes escape characters, enclose it in single quotation marks. Single quotation marks tell Windows PowerShell not to interpret any characters as escape sequences.
    
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
    
    .PARAMETER Application
        Reddit Application Object to be exported.
    
    .EXAMPLE
        PS C:\> $RedditApp | Export-RedditApplication -Path 'c:\RedditApp.xml'
    
    .OUTPUTS
        System.IO.FileInfo, System.IO.FileInfo
    
    .NOTES
        This is an Export-Clixml wrapper.
        See Import-RedditApplication for importing exported Reddit Application Objects
        For more information about registering Reddit Apps, Reddit's API, or Reddit OAuth see:
            https://github.com/reddit/reddit/wiki/API
            https://github.com/reddit/reddit/wiki/OAuth2
            https://www.reddit.com/prefs/apps
            https://www.reddit.com/wiki/api
    
    .LINK
        Import-RedditApplication
#>
function Export-RedditApplication {
    [CmdletBinding(DefaultParameterSetName = 'Path',
                   ConfirmImpact = 'Low',
                   HelpUri = 'https://github.com/markekraus/ConnectReddit/wiki/Export%E2%80%90RedditApplication',
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
        [pstypename('Reddit.Application')]
        [Alias('App', 'RedditApplication')]
        [System.Management.Automation.PSObject]$Application
    )
    
    Process {
        switch ($PsCmdlet.ParameterSetName) {
            'Path' {
                $Params = @{
                    Encoding = $Encoding
                    Path = $Path
                    InputObject = $Application
                }
                $Target = $Path
            }
            'LiteralPath' {
                $Params = @{
                    Encoding = $Encoding
                    LiteralPath = $LiterlPath
                    InputObject = $Application
                }
                $Target = $LiteralPath
            }
        }
        if ($pscmdlet.ShouldProcess("Target")) {
            Export-Clixml @Params
        }
    }
}
