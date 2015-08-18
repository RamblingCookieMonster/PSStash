Function Remove-StashRepo {
    <#
    .SYNOPSIS
        Delete a Stash repository
    
    .DESCRIPTION
        Delete a Stash repository

    .PARAMETER Project
        Delete the repository from this project.
                
        Takes a project key. Not a project name.

    .PARAMETER Repository
        Name of the repository to delete.

    .PARAMETER Uri
        The base Uri for Stash.  Defaults to $StashConfig.Uri
        
        Example: "https://Stash.contoso.com:8443"

    .PARAMETER Credential
        A valid PSCredential

    .EXAMPLE
        Remove-StashRepo -Credential $cred -Project SYSINV -Repo SystemsInventory

        # Remove the SystemsInventory repository

    .FUNCTIONALITY
        Stash
    #>
    [cmdletbinding()]
    param(    
        [parameter( Mandatory = $True )]
        [string]$Project,
        [parameter( Mandatory = $True )]
        [string]$Repository,
        [string]$Uri = $Script:StashConfig.Uri,
        [parameter( Mandatory = $True )]
        [System.Management.Automation.PSCredential]$Credential
    )

    #Build up Remove-StashObject parameters for splatting
        $RSOParams = @{
            Credential = $Credential
            Object = "/projects/$Project/repos/$Repository"
            Uri = $Uri
        }

    Write-Debug ( "Running $($MyInvocation.MyCommand).`n" +
                    "PSBoundParameters:$( $PSBoundParameters | Format-List | Out-String)" +
                    "Remove-StashObject parameters:`n$($RSOParams | Format-List | Out-String)" )

    Try
    {
        #Remove the stash object
        Remove-StashObject @RSOParams
    }
    Catch
    {
        Throw $_
    }

    Remove-Variable IRMParams -force -ErrorAction SilentlyContinue
}
