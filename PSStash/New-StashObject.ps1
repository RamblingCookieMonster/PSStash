Function New-StashObject {
    <#
    .SYNOPSIS
        Create a new object in Stash (POST)
    
    .DESCRIPTION
        Create a new object in Stash (POST)

        POST is generally used to create new objects, but not limited to this. Beware.

        There is no Confirmation or Whatif support for this command. Beware.

    .PARAMETER Object
        Type of object to create. Accepts multiple parts.
        
        Example: 'projects'

    .PARAMETER Uri
        The base Uri for Stash.  Defaults to $StashConfig.Uri
        
        Example: "https://Stash.contoso.com:8443"

    .PARAMETER Body
        Hash table with options for POST

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
        #
        # Encode an avatar:
            $encodedImage = [convert]::ToBase64String((get-content C:\avatar.png -encoding byte))
        
        # Create a test project with the avatar, using creds in $cred
            New-StashObject -Object Projects -Credential $Cred -Body @{
                key = "TSTPRJ"
                name = "Test Project"
                description = "A Project To Delete"
                avatar = "data:image/png;base64,$encodedImage"
            }

    .FUNCTIONALITY
        Stash
    #>
    [cmdletbinding()]
    param(    
        [string]$Object,
        [string]$Uri = $Script:StashConfig.Uri,
        [System.Management.Automation.PSCredential]$Credential,
        [Hashtable]$Body,
        [switch]$Raw
    )

    #Build up URI
        $StashBaseURI = Join-Parts -Separator "/" -Parts $Uri, "/rest/api/1.0"
        $BaseUri = Join-Parts -Separator "/" -Parts $StashBaseURI, $($object.ToLower())

    #Build up Invoke-RestMethod and Get-StashData parameters for splatting
        $IRMParams = @{
            ErrorAction = 'Stop'
            Uri = $BaseUri
            Method = 'Post'
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