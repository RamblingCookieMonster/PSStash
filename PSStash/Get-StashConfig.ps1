Function Get-StashConfig {
    <#
    .SYNOPSIS
        Get Stash module configuration

    .DESCRIPTION
        Get Stash module configuration

    .PARAMETER Source
        Config source:
        StashConfig to view module variable
        PSStash.xml to view PSStash.xml

    .FUNCTIONALITY
        Stash
    #>
    [cmdletbinding()]
    param(
        [ValidateSet('StashConfig','PSStash.xml')]
        [string]$Source = "StashConfig"
    )

    if($Source -eq "StashConfig")
    {
        $Script:StashConfig
    }
    else
    {
        Import-Clixml -Path "$PSScriptRoot\PSStash.xml"
    }

}