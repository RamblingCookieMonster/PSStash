# Borrowed from Shay Levy
# http://blogs.microsoft.co.il/scriptfanatic/2012/04/13/custom-objects-default-display-in-powershell-30/
function Add-TypeDetail
{
    [CmdletBinding()] 
    param(
           [Parameter( Mandatory = $true,
                       Position=0,
                       ValueFromPipeline=$true )]
           [ValidateNotNullOrEmpty()]
           [psobject[]]$InputObject,
           
           [System.Collections.Hashtable]$Properties,

           [Parameter( Mandatory = $false,
                       Position=1)]
           [string]$TypeName,
    
           [Parameter( Mandatory = $false,
                       Position=2)]
           [ValidateNotNullOrEmpty()]
           [Alias('dp')]
           [System.String[]]$DefaultProperties
    )
    
    Begin
    {
        if($PSBoundParameters.ContainsKey('DefaultProperties'))
        {
            # define a subset of properties
            $ddps = New-Object System.Management.Automation.PSPropertySet DefaultDisplayPropertySet,$DefaultProperties
            $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]$ddps
        }
    }

    Process
    {
        foreach($object in $InputObject)
        {

            if($PSBoundParameters.ContainsKey('Properties'))
            {
                foreach($Key in $Properties.Keys)
                {
                    #Add specified type
                    $Object.PSObject.Properties.Add( ( New-Object PSNoteProperty($Key, $Properties.$Key) ) )   
                }
            }
            
            if($PSBoundParameters.ContainsKey('TypeName'))
            {
                #Add specified type
                [void]$object.PSObject.TypeNames.Insert(0,$TypeName)
            }

            # Attach default display property set
            if($PSBoundParameters.ContainsKey('DefaultProperties'))
            {
                $object | Add-Member -MemberType MemberSet -Name PSStandardMembers -Value $PSStandardMembers -PassThru
            }
            else
            {
                $object
            }
        }
    }
}