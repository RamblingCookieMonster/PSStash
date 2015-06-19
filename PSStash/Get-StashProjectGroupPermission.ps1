Function Get-StashProjectGroupPermission {
    <#
    .SYNOPSIS
        Get Stash project group permissions
    
    .DESCRIPTION
        Get Stash project group permissions

    .PARAMETER Key
        Get permissions for project with this key

    .PARAMETER Group
        Filter permissions to groups matching this

        Example: -User RO would match 'GROUP'

    .PARAMETER Uri
        The base Uri for Stash.  Defaults to $StashConfig.Uri
        
        Example: "https://Stash.contoso.com:8443"

    .PARAMETER Raw
        If specified, do not extract the 'Values' attribute of the results.

    .PARAMETER Credential
        A valid PSCredential

    .EXAMPLE
        Get-StashProjectGroupPermission -Key SYSINV

        # List group permissions for the project with key SYSINV
        # Uses the URI from Get-StashConfig/Set-StashConfig

    .EXAMPLE
        Get-StashProjectGroupPermission -Uri $uri -Credential $cred -key SYSINV -Group security

        # Get Stash group permissions for the SYSINV project
        # Authenticates with $Cred
        # Filters for groups that match 'security'

    .EXAMPLE
        Get-StashProject -Name Inventory | Get-StashProjectGroupPermission

        # Get Stash group permissions from any project retrieved from Get-StashProject
        # Uses the URI from Get-StashConfig/Set-StashConfig

    .FUNCTIONALITY
        Stash
    #>
    [cmdletbinding()]
    param(
        [parameter( Mandatory=$true,
                    ValueFromPipelineByPropertyName=$True)]
        [string[]]$Key,
        [string]$Group,
        [string]$Uri = $Script:StashConfig.Uri,
        [System.Management.Automation.PSCredential]$Credential,
        [switch]$Raw
    )
    Begin
    {
        #Build up URI
        $StashBaseURI = Join-Parts -Separator "/" -Parts $Uri, "/rest/api/1.0"
    }
    Process
    {
        foreach($ProjectKey in $Key)
        {
            $BaseUri = Join-Parts -Separator "/" -Parts $StashBaseURI, "projects/$ProjectKey/permissions/groups"

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
                    'Group'
                    {
                        $Body.Add( 'filter', $Group)
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
                    if($_.PSObject.Properties.Name -contains 'group')
                    {
                        #Add some props and a type
                        Add-TypeDetail -InputObject $_ -TypeName 'PSStash.Project.GroupPermission' -Properties @{
                            ProjectKey =$ProjectKey
                            Name = $_.group.name
                        }
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
    }
}