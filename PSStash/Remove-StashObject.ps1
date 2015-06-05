Function Remove-StashObject {
    <#
    .SYNOPSIS
        Remove an object in Stash (DELETE)
    
    .DESCRIPTION
        Remove an object in Stash (DELETE)

    .PARAMETER Object
        Type of object to delete. Accepts multiple parts.
        
        Example: 'projects'

    .PARAMETER Uri
        The base Uri for Stash.  Defaults to $StashConfig.Uri
        
        Example: "https://Stash.contoso.com:8443"

    .PARAMETER Body
        Hash table with options for DELETE

        NOTE:
            These are case sensitive
            We convert this to JSON

        Example for projects:
            -Body @{
                key = "PRJ"
                name = "My Cool Project"
                description = "The description for my cool project."
                avatar = "data:image/png;base64,<base64-encoded-image-data>"
            }

    .PARAMETER Raw
        If specified, do not extract the 'Values' attribute of the results.

    .PARAMETER Credential
        A valid PSCredential

    .EXAMPLE        
        Remove-StashObject -Object Projects/TSTPRJ -Credential $Cred
        
        # Remove TSTPRJ project

    .FUNCTIONALITY
        Stash
    #>
    [cmdletbinding(SupportsShouldProcess=$true, ConfirmImpact="High")]
    param(    
        [string]$Object,
        [string]$Uri = $Script:StashConfig.Uri,
        [System.Management.Automation.PSCredential]$Credential,
        [Hashtable]$Body,
        [switch]$Raw
    )
    Begin
    {
        $RejectAll = $false            
        $ConfirmAll = $false  
    }
    Process
    {
        #Build up URI
            $StashBaseURI = Join-Parts -Separator "/" -Parts $Uri, "/rest/api/1.0"
            $BaseUri = Join-Parts -Separator "/" -Parts $StashBaseURI, $($object.ToLower())

        #Build up Invoke-RestMethod and Get-StashData parameters for splatting
            $IRMParams = @{
                ErrorAction = 'Stop'
                Uri = $BaseUri
                Method = 'Delete'
            }
            if($PSBoundParameters.ContainsKey('Credential'))
            {
                $IRMParams.Add( 'Headers', @{ Authorization = (Get-StashAuthString -Credential $Credential) } )
            }
            if($PSBoundParameters.ContainsKey('Body'))
            {
                $IRMParams.Add( 'Body', $($Body | ConvertTo-JSON) )
                $IRMParams.Add( 'ContentType', 'application/json')
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

        if( $PSCmdlet.ShouldProcess( "DELETED the object '$object'",            
                                     "DELETE the object '$object'?",            
                                     "DELETING object" ))
        {
            if($Force -Or $PSCmdlet.ShouldContinue("Are you REALLY sure you want to DELETE '$object'?", "DELETING '$object'", [ref]$ConfirmAll, [ref]$RejectAll)) { 
                Try
                {
                    #Get the data from Stash
                    Get-StashData @GSDParams
                }
                Catch
                {
                    Throw $_
                }
            }
        }

        Remove-Variable IRMParams -force -ErrorAction SilentlyContinue
    }
}