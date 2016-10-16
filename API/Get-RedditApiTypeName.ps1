<#
    .SYNOPSIS
        Returns the Reddit API Type Name of reddit Objects
    
    .DESCRIPTION
        Determines the Object Type and returns the Reddit APY Type Name
    
    .PARAMETER RedditObject
        The Reddit Object to be used to determing the TypeName
    
    .EXAMPLE
        PS C:\> Get-RedditApiTypeName -RedditObject $RedditUser
    
    .NOTES
        For more information about registering Reddit Apps, Reddit's API, or Reddit OAuth see:
            https://github.com/reddit/reddit/wiki/API
            https://github.com/reddit/reddit/wiki/OAuth2
            https://www.reddit.com/prefs/apps
            https://www.reddit.com/wiki/api
#>
function Get-RedditApiTypeName {
    [CmdletBinding(ConfirmImpact = 'None',
                   HelpUri = 'https://github.com/markekraus/ConnectReddit/wiki/Get%E2%80%90RedditApiTypeName')]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [AllowNull()]
        [System.Management.Automation.PSObject[]]$RedditObject
    )
    
    Process {
        Foreach ($CurObject in $RedditObject) {
            # Get the primary PStype for the object
            # This way will return null if there is non instead of failing
            $PsType = $CurObject.psobject.typenames | Select-Object -First 1
            Write-Verbose "PSType: $PsType"
            # Again, returns null if there is no match which is what we want
            $TypeName = $Global:ConnectRedditSettings.ApiTypeNameMapping.$PsType
            Write-Output $TypeName
        }
    }
}
