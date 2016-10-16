<#
    .SYNOPSIS
        Retireve valid Reddit OAuth Scopes.
    
    .DESCRIPTION
        Retrive valid OAuth scope IDs, Names, and Descriptions from Reddit. Default: https://www.reddit.com/api/v1/scopes .
    
    .PARAMETER ScopeURL
        URL for the Reddit App Scope definitions.
    
    .EXAMPLE
        PS C:\> Get-RedditOAuthScope
    
    .NOTES
        For more information about registering Reddit Apps, Reddit's API, or Reddit OAuth see:
            https://github.com/reddit/reddit/wiki/API
            https://github.com/reddit/reddit/wiki/OAuth2
            https://www.reddit.com/prefs/apps
            https://www.reddit.com/wiki/api
#>
function Get-RedditOAuthScope {
    [CmdletBinding(ConfirmImpact = 'None',
                   HelpUri = 'https://github.com/markekraus/ConnectReddit/wiki/Get%E2%80%90RedditOAuthScope',
                   SupportsShouldProcess = $true)]
    [OutputType([System.Management.Automation.PSObject])]
    param
    (
        [Parameter(Mandatory = $false)]
        [ValidateScript({
                [system.uri]::IsWellFormedUriString(
                    $_, [System.UriKind]::Absolute
                )
            })]
        [string]$ScopeURL = 'https://www.reddit.com/api/v1/scopes'
    )
    
    Write-Verbose "Retrieving Scopes from '$ScopeURL'"
    $ScopesObj = Invoke-WebRequest -Uri $ScopeURL |
    Select-Object -ExpandProperty Content |
    ConvertFrom-Json
    
    Write-Verbose "Enumerating scopes."
    $Properties = $ScopesObj |
    Get-Member -MemberType Properties |
    Select-Object -ExpandProperty Name
    
    Write-Verbose "Looping through each scope and return ID, Name, and Description properties."
    foreach ($Property in $Properties) {
        Write-Verbose "Processing '$Property'"
        $OutObj = [pscustomobject][ordered]@{
            Scope = $Property
            Id = $ScopesObj.$Property.id
            Name = $ScopesObj.$Property.Name
            Description = $ScopesObj.$Property.Description
        }
        $OutObj.Psobject.TypeNames.Clear()
        $OutObj.Psobject.TypeNames.Insert(0, 'Reddit.Scope')
        Write-Output $OutObj
    }
}