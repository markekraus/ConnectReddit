Write-Verbose 'Createig the ConnectRedditSettings Global settings object.'
Set-Variable -Scope Global -Name ConnectRedditSettings -Value $(
    [pscustomobject]@{
        # Base URL for user accounts
        UserBaseUrl = 'https://www.reddit.com/u/'
        ApiTypeNameMapping = [pscustomobject]@{
            'Reddit.User' = 'Account'
            'Reddit.Account' = 'Account'
        }
        ApiTypePrefixMapping = [pscustomobject]@{
            'Reddit.User' = 't2'
            'Reddit.Account' = 't2'
        }
    }
)

$RedditTypeData = @()
$RedditTypeData += @{
    Name = 'Reddit.User'
    Properties = @(
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'CreatedDate'
            Value = {
                $This.Created | ConvertFrom-RedditDate
            }
        }
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'CreatedUtcDate'
            Value = {
                $This.Created_utc | ConvertFrom-RedditDate
            }
        }
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'UserURL'
            Value = {
                "{0}{1}" -f $global:ConnectRedditSettings.UserBaseUrl, $This.Name
            }
        }
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'RedditName'
            Value = {
                '/u/{0}' -f $This.name
            }
        }
    )
}

$RedditTypeData += @{
    Name = 'Reddit.Account'
    Properties = @(
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'SuspensionExpirationUtcDate'
            Value = {
                $This.suspension_expiration_utc | ConvertFrom-RedditDate
            }
        }
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'GoldExpirationDate'
            Value = {
                $This.gold_expiration | ConvertFrom-RedditDate
            }
        }
    )
}

$RedditTypeData += @{
    Name = 'Reddit.Object'
    Properties = @(
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'RedditApiTypeName'
            Value = {
                $This | Get-RedditApiTypeName
            }
        }
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'RedditApiTypePrefix'
            Value = {
                $This | Get-RedditApiTypePrefix
            }
        }
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'RedditApiFullName'
            Value = {
                Get-RedditApiFullname -Type $This.RedditApiTypeName -RedditId $This.Id
            }
        }
    )
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
