Function New-StashFork {
    <#
    .SYNOPSIS
        Fork a Stash repository
    
    .DESCRIPTION
        Fork a Stash repository

    .PARAMETER Project
        Project key containing the repository you want to fork
        
    .PARAMETER Repo
        Repository you want to fork
        
    .PARAMETER DestinationProject
        Project to create the fork within.
        
        Defaults to your personal 'project'.
    
    .PARAMETER DestinationName
        Fork name.
        
        Defaults to the name of the origin repository

    .PARAMETER Uri
        The base Uri for Stash.  Defaults to $StashConfig.Uri
        
        Example: "https://Stash.contoso.com:8443"

    .PARAMETER Credential
        A valid PSCredential

    .EXAMPLE
        New-StashFork -Credential $cred -Project SYSINV -Repo SystemsInventory 

        # Forks the SYSINV project's SystemsInventory repository into your personal project
        # Maintains the 'SystemInventory' repository name

    .EXAMPLE
        New-StashFork -Credential $cred -Project SYSINV -Repo SystemsInventory -DestinationProject RND
        
        # Forks the SYSINV project's SystemsInventory repository into the project with key RND
        # Maintains the 'SystemInventory' repository name

    .EXAMPLE
        New-StashFork -Credential $cred -Project SYSINV -Repo SystemsInventory -DestinationProject FRK -DestinationRepo Inventory

        # Forks the SYSINV project's SystemsInventory repository into the project with key RND
        # Changes the 'SystemInventory' repository name to 'Inventory'

    .FUNCTIONALITY
        Stash
    #>
    [cmdletbinding()]
    param(    
        [parameter( Mandatory = $True )]
        [string]$Project,
        [parameter( Mandatory = $True )]
        [string]$Repo,
        [string]$DestinationProject,
        [string]$DestinationRepo = $null,
        [string]$Uri = $Script:StashConfig.Uri,
        [System.Management.Automation.PSCredential]$Credential
    )

    #Build up URI
        $StashBaseURI = Join-Parts -Separator "/" -Parts $Uri, "/rest/api/1.0"
        $BaseUri = Join-Parts -Separator "/" -Parts $StashBaseURI, "/projects/$Project/repos/$Repo"

#New-StashObject -body @{name=$null}

    #Build up Invoke-RestMethod and Get-StashData parameters for splatting
        $Body = @{
            name = $DestinationRepo
        }
        if($PSBoundParameters.ContainsKey('DestinationProject'))
        {
            $Body.Add('project', @{key=$DestinationProject})
        }

        $IRMParams = @{
            ErrorAction = 'Stop'
            Uri = $BaseUri
            Method = 'Post'
            Body = $($Body | ConvertTo-JSON)
            ContentType = 'application/json'
        }
        if($PSBoundParameters.ContainsKey('Credential'))
        {
            $IRMParams.Add( 'Headers', @{ Authorization = (Get-StashAuthString -Credential $Credential) } )
        }

        $GSDParams = @{ IRMParams = $IRMParams }

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

