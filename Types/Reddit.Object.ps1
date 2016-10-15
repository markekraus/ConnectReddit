@{
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