Function Get-StashObject {
    <#
    .SYNOPSIS
        Get a specified object from Stash
    
    .DESCRIPTION
        Get a specified object from Stash

    .PARAMETER Object
        Type of object to query for. Accepts multiple parts.
        
        Example: 'projects' or 'admin/mail-server'

    .PARAMETER Uri
        The base Uri for Stash.  Defaults to $StashConfig.Uri
        
        Example: "https://Stash.contoso.com:8443"

    .PARAMETER Raw
        If specified, do not extract the 'Values' attribute of the results.

    .PARAMETER Credential
        A valid PSCredential

    .EXAMPLE
        Get-StashObject -Object projects 

        #List public projects on Stash, using the URI from Get-StashConfig/Set-StashConfig

    .EXAMPLE
        Get-StashObject -Object projects/sysinv/repos -Credential $Cred 

        # List repositories under the 'sysinv' project on Stash...
        # Authenticates with $Cred
        # Uses the URI from Get-StashConfig/Set-StashConfig

    .EXAMPLE
        Get-StashObject -Object projects -Uri http://stash.contoso.com

        # List public projects on Stash at http://stash.contoso.com

    .FUNCTIONALITY
        Stash
    #>
    [cmdletbinding()]
    param(    
        [string]$Object = "projects",
        [string]$Uri = $Script:StashConfig.Uri,
        [System.Management.Automation.PSCredential]$Credential,
        [switch]$Raw
    )

    #Build up URI
        $StashBaseURI = Join-Parts -Separator "/" -Parts $Uri, "/rest/api/1.0"
        $BaseUri = Join-Parts -Separator "/" -Parts $StashBaseURI, $($object.ToLower())

    #Build up Invoke-RestMethod and Get-StashData parameters for splatting
        $IRMParams = @{
            ErrorAction = 'Stop'
            Uri = $BaseUri
            Method = 'Get'
        }
        if($PSBoundParameters.ContainsKey('Credential'))
        {
            $IRMParams.Add( 'Headers', @{ Authorization = (Get-StashAuthString -Credential $Credential) } )
        }

        $GSDParams = @{ IRMParams = $IRMParams }
        if($PSBoundParameters.ContainsKey('Raw'))
        {
            $GSDParams.Add( 'Raw', $Raw )
        }

    Write-Debug ( "Running $($MyInvocation.MyCommand).`n" +
                    "PSBoundParameters:$( $PSBoundParameters | Format-List | Out-String)" +
                    "Invoke-RestMethod parameters:`n$($IRMParams | Format-List | Out-String)" +
                    "Get-StashData parameters:`n$($GSDParams | Format-List | Out-String)" )

    Try
    {
        #Get the data from Stash
        Get-StashData @GSDParams
    }
    Catch
    {
        Throw $_
    }

    Remove-Variable IRMParams -force -ErrorAction SilentlyContinue
}