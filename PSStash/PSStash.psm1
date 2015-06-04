#Get public and private function definition files.
    $Public  = Get-ChildItem $PSScriptRoot\*.ps1 -ErrorAction SilentlyContinue 
    $Private = Get-ChildItem $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue 

#Dot source the files
    Foreach($import in @($Public + $Private))
    {
        Try
        {
            . $import.fullname
        }
        Catch
        {
            Write-Error "Failed to import function $($import.fullname)"
        }
    }

#Create / Read config
    if(-not (Test-Path -Path "$PSScriptRoot\PSStash.xml" -ErrorAction SilentlyContinue))
    {
        Try
        {
            Write-Warning "Did not find config file $PSScriptRoot\PSStash.xml, attempting to create"
            [pscustomobject]@{
                Uri = $null
            } | Export-Clixml -Path "$PSScriptRoot\PSStash.xml" -Force -ErrorAction Stop
        }
        Catch
        {
            Write-Warning "Failed to create config file $PSScriptRoot\Stash.xml: $_"
        }
    }
    
#Initialize the config variable.  I know, I know...
    Try
    {
        #Import the config
        $StashConfig = $null
        $StashConfig = Get-StashConfig -Source PSStash.xml -ErrorAction Stop | Select -Property Uri

    }
    Catch
    {   
        Write-Warning "Error importing PSStash config: $_"
    }

#Create some aliases, export public functions
    Export-ModuleMember -Function $($Public | Select -ExpandProperty BaseName) -Alias *