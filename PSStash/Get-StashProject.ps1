Function Get-StashProject {
    <#
    .SYNOPSIS
        Get Stash Projects
    
    .DESCRIPTION
        Get Stash Projects

    .PARAMETER Key
        Search for project by Key

    .PARAMETER Name
        Search for project by Name

    .PARAMETER Permission
        Search for project by your permission to it.

        Valid permissions:
            PROJECT_ADMIN
            PROJECT_WRITE
            PROJECT_READ

    .PARAMETER Uri
        The base Uri for Stash.  Defaults to $StashConfig.Uri
        
        Example: "https://Stash.contoso.com:8443"

    .PARAMETER Raw
        If specified, do not extract the 'Values' attribute of the results.

    .PARAMETER Credential
        A valid PSCredential

    .EXAMPLE
        Get-StashProject

        #List public projects on Stash, using the URI from Get-StashConfig/Set-StashConfig

    .EXAMPLE
        Get-StashProject -Key SYSINV -Credential $Cred 

        # Get Stash project with key SYSINV
        # Authenticates with $Cred
        # Uses the URI from Get-StashConfig/Set-StashConfig

    .EXAMPLE
        Get-StashProject -Permission PROJECT_ADMIN -Credential $Cred

        # Get Stash projects where $Cred has PROJECT_ADMIN permissions
        # Uses the URI from Get-StashConfig/Set-StashConfig


    .FUNCTIONALITY
        Stash
    #>
    [cmdletbinding(DefaultParameterSetName = 'Name')]
    param(
        [parameter(ParameterSetName = 'Name')]
        [string]$Name,
        [parameter(ParameterSetName = 'Name')]
        [validateset('PROJECT_READ','PROJECT_WRITE','PROJECT_ADMIN')]
        [string]$Permission,
        [parameter(ParameterSetName = 'Key')]
        [string]$Key,
        [string]$Uri = $Script:StashConfig.Uri,
        [System.Management.Automation.PSCredential]$Credential,
        [switch]$Raw
    )

    #Build up URI
        $StashBaseURI = Join-Parts -Separator "/" -Parts $Uri, "/rest/api/1.0"
        $BaseUri = Join-Parts -Separator "/" -Parts $StashBaseURI, 'projects', $key

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
            'Permission'
            {
                $Body.Add( 'permission', $Permission)
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
        Get-StashData @GSDParams | Foreach-Object {
            
            #Custom types and display stuff
            if($_.PSObject.Properties.Name -contains 'key')
            {
                Add-TypeDetail -InputObject $_ -TypeName 'PSStash.Project'
            }
            else
            {
                $_
            }

        }
    }
    Catch
    {
        Throw $_
    }

    Remove-Variable IRMParams -force -ErrorAction SilentlyContinue
}