function Get-StashAuthString
{
    <#
    .SYNOPSIS
        Get string for Basic authentication to Stash.
    
    .DESCRIPTION
        Get string for Basic authentication to Stash.

        Takes a PSCredential. Returns the string 'Basic <Base64 encoded Username:Password>'

        IMPORTANT CONSIDERATIONS:
            Base64 is easily reversed.
            Use HTTPS to ensure this insecure string is encrypted.

    .PARAMETER Credential
        A valid PSCredential

    .EXAMPLE
        Get-StashAuthString -Credential $Credential

        # Get a Base64 encoded string of User:Password in the format expected by Stash: 'Basic <EncodedString>'
        
    .EXAMPLE
        Invoke-Restmethod -Uri $StashUri -Header @{
            Authorization = $(Get-StashAuthString $Credential)
        }

        # Send web request with headers in the format expected by Stash

    .NOTES
        # OAUTH is a PITA so we use basic auth; acceptable, given that we are using HTTPS
        # https://developer.atlassian.com/stash/docs/latest/how-tos/example-basic-authentication.html

    .FUNCTIONALITY
        Stash
    #>
    param
    (
        [parameter( ValueFromRemainingArguments=$true )]
        [PSCredential]$Credential = (Get-Credential)
    )
    
    #Authorization header expected by Stash
        $Bytes = [System.Text.Encoding]::UTF8.GetBytes( ('{0}:{1}' -f $Credential.username, $Credential.GetNetworkCredential().password ) )
        $Base64 = [System.Convert]::ToBase64String( $Bytes )
        "Basic $Base64"

}