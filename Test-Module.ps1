﻿#Explicitly import the module for testing
Import-Module 'ConnectReddit' -Verbose

$Global:TestsCompleted = @()
#This directory is used for Import/Export tests
$Global:TestExportsDirectory = $ENV:TEMP

$TestFolder = Join-Path -Path $PSScriptRoot -ChildPath 'Tests'
$TestScripts = Get-ChildItem -Path $TestFolder -Filter 'Test-*.ps1' -Recurse
Foreach ($TestScript in $TestScripts) {
    if ($TestScript.Name -notin $TestsCompleted) {
        . $TestScript.FullName
    }
}

Write-Host "Tests completed:"
foreach ($TestCompleted in $Global:TestsCompleted) {
    Write-Host " $TestCompleted"
}