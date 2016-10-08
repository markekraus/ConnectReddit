<#
    .SYNOPSIS
        Imports an exported Reddit Application Object
    
    .DESCRIPTION
        Imports an exported Reddit Application Object and retruns a Reddit Application Object.
    
    .PARAMETER Path
        Specifies the XML files where the Reddit Application Object was exported.
    
    .PARAMETER LiteralPath
        Specifies the XML files where the Reddit Application Object was exported. Unlike Path, the value of the LiteralPath parameter is used exactly as it is typed. No characters are interpreted as wildcards. If the path includes escape characters, enclose it in single quotation marks. Single quotation marks tell Windows PowerShell not to interpret any characters as escape sequences.
    
    .EXAMPLE
        		PS C:\> $RedditApp = Import-RedditApplication -Path 'c:\RedditApp.xml'
    
    .NOTES
        See Export-RedditApplication for exporting Redit Application Objects

    .LINK
        Export-RedditApplication
#>
function Import-RedditApplication {
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
        foreach ($ImportFile in $InportFiles) {
            if ($pscmdlet.ShouldProcess($ImportFile)) {
                $Params = @{
                    "$PsCmdlet.ParameterSetName" = $ImportFile
                }
                $InObject = Import-Clixml @Params
                $Params = @{
                    "$($InObject.Type)" = $True
                    Name = $InObject.Name
                    ClientCredential = $InObject.ClienCredential
                    RedirectUri = $InObject.RedirectUri
                    Scope = $InObject.Scope
                    UserAgent = $InObject.UserAgent
                    Description = $InObject.Description
                    GUID = $InObject.GUID
                }
                $OutApplication = New-RedditApplication @Params
                Write-Output $OutApplication
            } #End Should Process
        } #End Foreach
    } #End Process
} #End Function
