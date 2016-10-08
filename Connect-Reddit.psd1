@{
	
	# Script module or binary module file associated with this manifest
	ModuleToProcess = 'Connect-Reddit.psm1'
	
	# Version number of this module.
	ModuleVersion = '1.0.0.23'
	
	# ID used to uniquely identify this module
	GUID = 'a1fb1d76-b5c9-4880-9f1c-56d47986e459'
	
	# Author of this module
	Author = 'Mark Kraus'
	
	# Company or vendor of this module
	CompanyName = ''
	
	# Copyright statement for this module
	Copyright = '(c) 2016. All rights reserved. This module is Ilicensed under the Apache License 2.0 http://www.apache.org/licenses/LICENSE-2.0 '
	
	# Description of the functionality provided by this module
	Description = 'Reddit API Wrapper for PowerShell'
	
	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion = '2.0'
	
	# Name of the Windows PowerShell host required by this module
	PowerShellHostName = ''
	
	# Minimum version of the Windows PowerShell host required by this module
	PowerShellHostVersion = ''
	
	# Minimum version of the .NET Framework required by this module
	DotNetFrameworkVersion = '4.0'
	
	# Minimum version of the common language runtime (CLR) required by this module
	CLRVersion = '2.0.50727'
	
	# Processor architecture (None, X86, Amd64, IA64) required by this module
	ProcessorArchitecture = 'None'
	
	# Modules that must be imported into the global environment prior to importing
	# this module
	RequiredModules = @()
	
	# Assemblies that must be loaded prior to importing this module
	RequiredAssemblies = @('System.Web')
	
	# Script files (.ps1) that are run in the caller's environment prior to
	# importing this module
	ScriptsToProcess = @()
	
	# Type files (.ps1xml) to be loaded when importing this module
	TypesToProcess = @()
	
	# Format files (.ps1xml) to be loaded when importing this module
	FormatsToProcess = @()
	
	# Modules to import as nested modules of the module specified in
	# ModuleToProcess
    NestedModules = @(
        # Account
        'Account\Get-RedditAccount.ps1'
        # API
        'API\Get-RedditApiResponse.ps1'
        'API\Get-RedditApiFullname.ps1'
        'API\Get-RedditApiTypeName.ps1'
        'API\Get-RedditApiTypePrefix.ps1'
        # Application
        'Application\Export-RedditApplication.ps1'
        'Application\Import-RedditApplication.ps1'
        'Application\New-RedditApplication.ps1'
        # OAuth
        'OAuth\Confim-RedditOAuthAccessTokenResponse.ps1'
        'OAuth\Export-RedditOAuthAccessToken.ps1'
        'OAuth\Get-RedditOAuthAccessToken.ps1'
        'OAuth\Get-RedditOAuthAccessTokenURL.ps1'
        'OAuth\Get-RedditOAuthAppAuthorizationURL.ps1'
        'OAuth\Get-RedditOAuthAuthorizationHeader.ps1'
        'OAuth\Get-RedditOAuthScope.ps1'
        'OAuth\Import-RedditOAuthAccessToken.ps1'
        'OAuth\New-RedditOAuthAccessToken.ps1'
        'OAuth\Update-RedditOAuthAccessToken.ps1'
        # Public
        'Public\ConvertFrom-RedditDate.ps1'
        'Public\ConvertTo-RedditDate.ps1'
        # Users
        'Users\Get-RedditUser.ps1'
	)
	
	# Functions to export from this module
    FunctionsToExport = @(
        # Account
        'Get-RedditAccount'
        # API
        'Get-RedditApiResponse'
        'Get-RedditApiFullname'
        'Get-RedditApiTypeName'
        'Get-RedditApiTypePrefix'
        # Application
        'Export-RedditApplication'
        'Import-RedditApplication'
        'New-RedditApplication'
        # OAuth
        'Confim-RedditOAuthAccessTokenResponse'
        'Export-RedditOAuthAccessToken'
        'Get-RedditOAuthAccessToken'
        'Get-RedditOAuthAccessTokenURL'
        'Get-RedditOAuthAppAuthorizationURL'
        'Get-RedditOAuthAuthorizationHeader'
        'Get-RedditOAuthScope'
        'Import-RedditOAuthAccessToken'
        'New-RedditOAuthAccessToken'
        'Update-RedditOAuthAccessToken'
        # Public
        'ConvertFrom-RedditDate'
        'ConvertTo-RedditDate'
        # Users
        'Get-RedditUser'
	)
	
	# Cmdlets to export from this module
	CmdletsToExport = ''
	
	# Variables to export from this module
	VariablesToExport = ''
	
	# Aliases to export from this module
	AliasesToExport = '' #For performanace, list alias explicity
	
	# List of all modules packaged with this module
	ModuleList = @()
	
	# List of all files packaged with this module
	FileList = @()
	
	# Private data to pass to the module specified in ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData = @{
		
		#Support for PowerShellGet galleries.
		PSData = @{
			
			# Tags applied to this module. These help with module discovery in online galleries.
			# Tags = @()
			
			# A URL to the license for this module.
			# LicenseUri = ''
			
			# A URL to the main website for this project.
			# ProjectUri = ''
			
			# A URL to an icon representing this module.
			# IconUri = ''
			
			# ReleaseNotes of this module
			# ReleaseNotes = ''
			
		} # End of PSData hashtable
		
	} # End of PrivateData hashtable
}







