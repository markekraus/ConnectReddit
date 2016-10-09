
<#
    .SYNOPSIS
        Creates a Reddit Application object
    
    .DESCRIPTION
        Creates a Reddit Application object containing data used by various cmdltes to define the parameters of the App registered on Reddit. This does not make any calls to Reddit or perform any online lookups. The Application will be inbeded in the Reddit OAuthToken objects.
        The Reddit.Application object contains the following properties:
        Name             Name of the Application
        Description      Description of the Application
        Type             Type of Application (WebApp, IntsalledApp, Script)
        UserAgent        The User-Agent header the Application will use to access the Reddit API
        ClientID         The Client ID of the Registered reddit App
        RedirectUri      The Redirect URI of the Registered Reddit App
        ClientCredential A PS Crednetial containing the Client ID as the username and the Client Secret as teh password
        UserCredential   The Reddit Username and password of the developer account used for a Script application
        Scope            An array of scopes the application requires
        GUID             A GUID to identitfy the application
    
    .PARAMETER Script
        Use if the Reddit App is registered as a Script.
    
    .PARAMETER WebApp
        Use if the Reddit App is registered as a WebApp
    
    .PARAMETER InstalledApp
        Use if Reddit App is registered as an Installed App.
    
    .PARAMETER Name
        Name of the Reddit App. This does not need to match the name registered on Reddit. It is used for convenient identification and ducomentation purposes only.
    
    .PARAMETER ClientCredential
        A PScredential object containging the Client ID as the Username and the Client Secret as the password. For 'Installed' Apps which have no Client Secret, the password will be ignored.
    
    .PARAMETER RedirectUri
        Redirect URI as registered on Reddit for the App. This must match exactly as entered in the App definition or authentication will fail.
    
    .PARAMETER UserAgent
        The User-Agent header that will be used for all Calls to Reddit. This should be in the following format:
        
        <platform>:<app ID>:<version string> (by /u/<reddit username>)
        
        Example:
        
        windows:connect-reddit:v0.0.0.1 (by /u/makrkeraus)
    
    .PARAMETER Scope
        Array of OAuth Scopes that this Reddit App requires. You can see the available scopes with Get-ReddOauthScopes
    
    .PARAMETER Description
        Description of the Reddit App. This is not required or used for anything. It is provided for convenient identification and documentation purposes only.
    
    .PARAMETER UserCredential
        PScredential containing the Reddit Username and Password for the Developer of a Script App.
    
    .PARAMETER GUID
        A GUID to identify the application. If one is not perovided, a new GUID will be generated.
    
    .EXAMPLE
        PS C:\> $ClientCredential = Get-Credential
        PS C:\> $Scope = Get-RedditOAuthScope | Where-Object {$_.Scope -like '*wiki*'} | Select-Object -ExpandProperty Scope
        PS C:\> $Params = @{
        WebApp = $True
        Name = 'Connect-Reddit'
        Description = 'My Reddit Bot!'
        ClientCredential = $ClientCredential
        RedirectUri = 'https://adataum/ouath?'
        UserAgent = 'windows:connect-reddit:v0.0.0.1 (by /u/makrkeraus)'
        Scope = $Scope
        }
        PS C:\> $RedditApp = New-RedditApplication @Params
    
    .OUTPUTS
        System.Management.Automation.PSObject
    
    .NOTES
        For more information about registering Reddit Apps, Reddit's API, or Reddit OAuth see:
        https://github.com/reddit/reddit/wiki/API
        https://github.com/reddit/reddit/wiki/OAuth2
        https://www.reddit.com/prefs/apps
        https://www.reddit.com/wiki/api
#>
function New-RedditApplication {
    [CmdletBinding(DefaultParameterSetName = 'WebApp',
                   ConfirmImpact = 'None')]
    [OutputType([System.Management.Automation.PSObject])]
    param
    (
        [Parameter(ParameterSetName = 'Script',
                   Mandatory = $true)]
        [switch]$Script,
        
        [Parameter(ParameterSetName = 'WebApp',
                   Mandatory = $true)]
        [switch]$WebApp,
        
        [Parameter(ParameterSetName = 'InstalledApp',
                   Mandatory = $true)]
        [switch]$InstalledApp,
        
        [Parameter(ParameterSetName = 'InstalledApp',
                   Mandatory = $true)]
        [Parameter(ParameterSetName = 'Script',
                   Mandatory = $true)]
        [Parameter(ParameterSetName = 'WebApp',
                   Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('AppName')]
        [string]$Name,
        
        [Parameter(ParameterSetName = 'InstalledApp',
                   Mandatory = $true)]
        [Parameter(ParameterSetName = 'Script',
                   Mandatory = $true)]
        [Parameter(ParameterSetName = 'WebApp',
                   Mandatory = $true)]
        [Alias('ClientInfo')]
        [System.Management.Automation.PSCredential]$ClientCredential,
        
        [Parameter(ParameterSetName = 'InstalledApp',
                   Mandatory = $true)]
        [Parameter(ParameterSetName = 'WebApp',
                   Mandatory = $true)]
        [Parameter(ParameterSetName = 'Script',
                   Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({
                [system.uri]::IsWellFormedUriString(
                    $_, [System.UriKind]::Absolute
                )
            })]
        [string]$RedirectUri,
        
        [Parameter(ParameterSetName = 'InstalledApp',
                   Mandatory = $true)]
        [Parameter(ParameterSetName = 'WebApp')]
        [Parameter(ParameterSetName = 'Script',
                   Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$UserAgent,
        
        [Parameter(ParameterSetName = 'InstalledApp',
                   Mandatory = $true)]
        [Parameter(ParameterSetName = 'Script',
                   Mandatory = $true)]
        [Parameter(ParameterSetName = 'WebApp',
                   Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Scope,
        
        [Parameter(ParameterSetName = 'InstalledApp',
                   Mandatory = $false)]
        [Parameter(ParameterSetName = 'Script',
                   Mandatory = $false)]
        [Parameter(ParameterSetName = 'WebApp',
                   Mandatory = $false)]
        [string]$Description,
        
        [Parameter(ParameterSetName = 'Script',
                   Mandatory = $true)]
        [Parameter(ParameterSetName = 'WebApp',
                   Mandatory = $false)]
        [Alias('Credential')]
        [System.Management.Automation.PSCredential]$UserCredential,
        
        [Parameter(ParameterSetName = 'InstalledApp')]
        [Parameter(ParameterSetName = 'Script')]
        [Parameter(ParameterSetName = 'WebApp')]
        [System.Guid]$GUID = [system.guid]::NewGuid()
    )
    
    Process {
        switch ($PSCmdlet.ParameterSetName) {
            'InstalledApp' {
                $AppType = 'InstalledApp'
                $UserCredential = [System.Management.Automation.PSCredential]::Empty
            }
            'WebApp' {
                $AppType = 'WebApp'
                $UserCredential = [System.Management.Automation.PSCredential]::Empty
            }
            'Script' {
                $AppType = 'Script'
            }
        }
        
        $OutApplication = New-Object -TypeName System.Management.Automation.PSObject -Property $Properties
        $OutApplication | Add-Member -MemberType NoteProperty -Name Name -Value $Name
        $OutApplication | Add-Member -MemberType NoteProperty -Name Description -Value $Description
        $OutApplication | Add-Member -MemberType NoteProperty -Name Type -Value $AppType
        $OutApplication | Add-Member -MemberType NoteProperty -Name UserAgent -Value $UserAgent
        $OutApplication | Add-Member -MemberType ScriptProperty -Name ClientID -Value { $This.ClientCredential.UserName }
        $OutApplication | Add-Member -MemberType NoteProperty -Name ClientCredential -Value $ClientCredential
        $OutApplication | Add-Member -MemberType NoteProperty -Name UserCredential -Value $UserCredential
        $OutApplication | Add-Member -MemberType NoteProperty -Name RedirectUri -Value $RedirectUri
        $OutApplication | Add-Member -MemberType NoteProperty -Name Scope -Value $Scope
        $OutApplication | Add-Member -MemberType NoteProperty -Name GUID -Value $GUID
        $OutApplication.Psobject.TypeNames.Clear()
        $OutApplication.Psobject.TypeNames.Insert(0, 'Reddit.Application')
        # Not sure this will be needed
        Write-Verbose "Registering Global variable `${$($GUID.ToString())}"
        try {
            New-Variable -Scope Global -Name $GUID.ToString() -Value $OutApplication -ErrorAction Stop | Out-Null
        }
        catch {
            try {
                Set-Variable -Scope Global -Name $GUID.ToString() -Value $OutApplication -ErrorAction Stop | Out-Null
            }
            catch {
                Write-Warning 'Unable to set global variable.'
            }
        }
        Write-Output $OutApplication
    }
}
