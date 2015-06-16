Function Get-StashRepo {
    <#
    .SYNOPSIS
        Get Stash repositories
    
    .DESCRIPTION
        Get Stash repositories

    .PARAMETER Name
        Search for repository by name

    .PARAMETER ProjectName
        Search for repositories under this project

    .PARAMETER Permission
        Search for repositories by your permission to it.

        Valid permissions:
            REPO_ADMIN
            REPO_WRITE
            REPO_READ

    .PARAMETER Visibility
        Search for repositories by whether they have public or private visibility.

    .PARAMETER Uri
        The base Uri for Stash.  Defaults to $StashConfig.Uri
        
        Example: "https://Stash.contoso.com:8443"

    .PARAMETER Raw
        If specified, do not extract the 'Values' attribute of the results.

    .PARAMETER Credential
        A valid PSCredential

    .EXAMPLE
        Get-StashRepo

        #List public repositories on Stash, using the URI from Get-StashConfig/Set-StashConfig

    .EXAMPLE
        Get-StashRepo -Project SystemsInventory -Credential $Cred

        # Get Stash repositories under the SystemsInventory project
        # Authenticates with $Cred
        # Uses the URI from Get-StashConfig/Set-StashConfig

    .EXAMPLE
        Get-StashRepo -Name Inventory -Credential $Cred 

        # Get Stash repository with name Inventory
        # Authenticates with $Cred
        # Uses the URI from Get-StashConfig/Set-StashConfig

    .EXAMPLE
        Get-StashRepo -Permission REPO_ADMIN -Credential $Cred

        # Get Stash repos where $Cred has REPO_ADMIN permissions
        # Uses the URI from Get-StashConfig/Set-StashConfig


    .FUNCTIONALITY
        Stash
    #>
    [cmdletbinding(DefaultParameterSetName = 'Name')]
    param(
        [parameter(ParameterSetName = 'Name')]
        [string]$Name,
        [parameter(ParameterSetName = 'Name')]
        [string]$ProjectName,
        [parameter(ParameterSetName = 'Name')]
        [validateset('REPO_READ','REPO_WRITE','REPO_ADMIN')]
        [string]$Permission,
        [parameter(ParameterSetName = 'Name')]
        [validateset('public','private')]
        [string]$Visibility,
        [string]$Uri = $Script:StashConfig.Uri,
        [System.Management.Automation.PSCredential]$Credential,
        [switch]$Raw
    )

    #Build up URI
        $StashBaseURI = Join-Parts -Separator "/" -Parts $Uri, "/rest/api/1.0"
        $BaseUri = Join-Parts -Separator "/" -Parts $StashBaseURI, 'repos'

    #Build up Invoke-RestMethod and Get-StashData parameters for splatting
        $IRMParams = @{
            ErrorAction = 'Stop'
            Uri = $BaseUri
            Method = 'Get'
        }

        $Body = @{}
        switch($PSBoundParameters.Keys)
        {
            'Credential'
            {
                $IRMParams.Add( 'Headers', @{ Authorization = (Get-StashAuthString -Credential $Credential) } )
            }
            'Name' 
            {
                $Body.Add( 'name', $Name)
            }
            'ProjectName'
            {
                $Body.Add( 'projectname', $ProjectName)
            }
            'Permission'
            {
                $Body.Add( 'permission', $Permission)
            }
            'Visibility'
            {
                $Body.Add( 'visibility', $Visibility)
            }
        }
        if($Body.keys.count -gt 0)
        {
            $IRMParams.Add( 'Body', $Body )
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