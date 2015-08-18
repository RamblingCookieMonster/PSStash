Function New-StashRepo {
    <#
    .SYNOPSIS
        Create a new Stash repository
    
    .DESCRIPTION
        Create a new Stash repository

    .PARAMETER Project
        Create repository in this Project

        Takes a project key. Not a project name.

        If not specified, we use the Credential user's personal project.
                
    .PARAMETER Repository
        Name of the repository to create.

    .PARAMETER Forkable
        Whether to set the repository as forkable. Default is True

    .PARAMETER Uri
        The base Uri for Stash.  Defaults to $StashConfig.Uri
        
        Example: "https://Stash.contoso.com:8443"

    .PARAMETER Credential
        A valid PSCredential

        If no project is specified, we create the repository in this user's personal project

    .EXAMPLE
        New-StashRepo -Credential $cred -Repo MyRepo

        # Create a MyRepo repository in the personal project for wframe (project key '~wframe')
        # $Cred has the username 'wframe'

    .EXAMPLE
        New-StashRepo -Credential $cred -Project SYSINV -Repo SystemsInventory

        # Create a SystemsInventory repository in the SYSINV project

    .FUNCTIONALITY
        Stash
    #>
    [cmdletbinding()]
    param(    
        [string]$Project,
        [parameter( Mandatory = $True )]
        [string]$Repository,
        [boolean]$Forkable = $true,
        [string]$Uri = $Script:StashConfig.Uri,
        [System.Management.Automation.PSCredential]$Credential
    )

    #Default is to pick the user's personal repo
    if(-not $PSBoundParameters.ContainsKey('Project'))
    {
        if($PSBoundParameters.ContainsKey('Credential'))
        {
            $Project = "~$($Credential.UserName)"
            Write-Verbose "Defaulting to personal project '$Project'"
        }
        else
        {
            Throw "You must specify a project. If you do not, you must specify a credential that we can extract your username from"
        }
    }

    #Build up New-StashObject parameters for splatting
        $Body = @{
            name = $Repository
            scmId = 'git'
            forkable = $Forkable
        }

        $NSOParams = @{
            Credential = $Credential
            Body = $Body
            Object = "/projects/$Project/repos"
            Uri = $Uri
        }

    Write-Debug ( "Running $($MyInvocation.MyCommand).`n" +
                    "PSBoundParameters:$( $PSBoundParameters | Format-List | Out-String)" +
                    "New-StashObject parameters:`n$($NSOParams | Format-List | Out-String)" )

    Try
    {
        #Create the stash object
        New-StashObject @NSOParams
    }
    Catch
    {
        Throw $_
    }

    Remove-Variable IRMParams -force -ErrorAction SilentlyContinue
}

