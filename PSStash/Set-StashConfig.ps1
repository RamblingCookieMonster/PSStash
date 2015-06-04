Function Set-StashConfig {
    <#
    .SYNOPSIS
        Set Stash module configuration.

    .DESCRIPTION
        Set Stash module configuration, and module $StashConfig variable.

        This data is used as the default for most commands.

    .PARAMETER Uri
        Specify a Uri to use

    .Example
        Set-StashConfig -Uri "https://stash.contoso.com:8443"

    .FUNCTIONALITY
        Stash
    #>
    [cmdletbinding()]
    param(
        [string]$Uri
    )


    If($PSBoundParameters.ContainsKey('Uri'))
    {
        $Script:StashConfig.Uri = $Uri
    }


    $Script:StashConfig | Export-Clixml -Path "$PSScriptRoot\PSStash.xml" -force

}