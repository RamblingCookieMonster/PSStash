Function Set-StashProjectPermission {
    <#
    .SYNOPSIS
        Add and set permissions on a Stash project
    
    .DESCRIPTION
        Add and set permissions on a Stash project

        NOTE: There is no output from this function.
              If we don't receive a successful HTTP status code, we throw an error.

    .PARAMETER Key
        Project key
        
    .PARAMETER Name
        Group or User name to provision access for

    .PARAMETER Type
        Specify User or Group.

    .PARAMETER Permission
        Specify permission to grant.
        
        Valid permissions:
            PROJECT_READ
            PROJECT_WRITE
            PROJECT_ADMIN

        See Stash documentation for details:
        https://confluence.atlassian.com/display/STASH/Managing+permissions+for+a+project

    .PARAMETER Uri
        The base Uri for Stash.  Defaults to $StashConfig.Uri
        
        Example: "https://Stash.contoso.com:8443"

    .PARAMETER Credential
        A valid PSCredential

    .EXAMPLE
        Set-StashProjectPermission -Key ser -Name cmonster -Type users -Permission PROJECT_ADMIN -Credential $cred

        # Grant user 'cmonster' PROJECT_ADMIN privileges on the 'ser' project.

    .EXAMPLE
        Set-StashProjectPermission -Key ser -Name 'network admins' -Type groups -Permission PROJECT_READ -Credential $cred

        # Grant group 'network admins' PROJECT_READ privileges on the 'ser' project.

    .FUNCTIONALITY
        Stash
    #>
    [cmdletbinding()]
    param(    
        [parameter( Mandatory = $True,
                    ValueFromPipelineByPropertyName=$True )]
        [string]$Key,
        
        [parameter( Mandatory = $True )]
        [string]$Name,
        
        [parameter( Mandatory = $True )]
        [validateset('groups','users')]
        [string]$Type,
        
        [parameter( Mandatory = $True )]
        [validateset('PROJECT_READ','PROJECT_WRITE','PROJECT_ADMIN')]
        [string]$Permission,

        [string]$Uri = $Script:StashConfig.Uri,
        [System.Management.Automation.PSCredential]$Credential
    )

    #Build up URI
        $StashBaseURI = Join-Parts -Separator "/" -Parts $Uri, "/rest/api/1.0"
        $BaseUri = Join-Parts -Separator "/" -Parts $StashBaseURI, "/projects/$Key/permissions/$Type`?name=$Name&permission=$Permission"

    #Build up Invoke-RestMethod and Get-StashData parameters for splatting
        $IRMParams = @{
            ErrorAction = 'Stop'
            Uri = $BaseUri
            Method = 'Put'
        }
        if($PSBoundParameters.ContainsKey('Credential'))
        {
            $IRMParams.Add( 'Headers', @{ Authorization = (Get-StashAuthString -Credential $Credential) } )
        }

        $GSDParams = @{
            IRMParams = $IRMParams
            Raw = $true
            UseIWR = $True
        }

    Write-Debug ( "Running $($MyInvocation.MyCommand).`n" +
                    "PSBoundParameters:$( $PSBoundParameters | Format-List | Out-String)" +
                    "Invoke-RestMethod parameters:`n$($IRMParams | Format-List | Out-String)" +
                    "Get-StashData parameters:`n$($GSDParams | Format-List | Out-String)" )

    Try
    {
        #Get the data from Stash
        $Output = Get-StashData @GSDParams
        if($Output.StatusCode -like 204)
        {
            Write-Verbose "Success"
        }
        else
        {
            Throw "Something went wrong: Did not receive expected status code 204:`n$($Output | Out-string)"
        }
    }
    Catch
    {
        Throw $_
    }

    Remove-Variable IRMParams -force -ErrorAction SilentlyContinue
}

