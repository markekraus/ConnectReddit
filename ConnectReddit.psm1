Write-Verbose 'Createig the ConnectRedditSettings Global settings object.'
Set-Variable -Scope Global -Name ConnectRedditSettings -Value $(
    [pscustomobject]@{
        # Base URL for user accounts
        UserBaseUrl = 'https://www.reddit.com/u/'
        ApiTypeNameMapping = [pscustomobject]@{
            'Reddit.User' = 'Account'
            'Reddit.Account' = 'Account'
            'Reddit.Friend' = 'Account'
        }
        ApiTypePrefixMapping = [pscustomobject]@{
            'Reddit.User' = 't2'
            'Reddit.Account' = 't2'
            'Reddit.Friend' = 't2'
        }
    }
)

$TypesPath = Join-Path -Path $PSScriptRoot -ChildPath 'Types'
$TypesScripts = Get-ChildItem -Path $TypesPath -Filter '*.ps1'
$RedditTypeData = foreach ($TypesScript in $TypesScripts) {
    Write-Verbose "Importing Type Data from '$($TypesScript.FullName)'"
    . $TypesScript.FullName
}


Foreach ($RedditType in $RedditTypeData) {
    Write-Verbose "Adding $($RedditType.Name)"
    foreach ($ObjectProperty in $RedditType.Properties) {
        Write-Verbose "-Adding $($ObjectProperty.MemberName) property"
        $Params = @{
            TypeName = $RedditType.Name
            MemberType = $ObjectProperty.MemberType
            MemberName = $ObjectProperty.MemberName
            Value = $ObjectProperty.Value
            ErrorAction = 'SilentlyContinue'
        }
        Update-TypeData @Params
    }
}
