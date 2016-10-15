@{
    Name = 'Reddit.Application'
    Properties = @(
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'ClientID'
            Value = {
                $This.ClientCredential.UserName
            }
        }
    )
}