#A few basic tests, will add more, contributions would be appreciated!

#Variables used in the tests
    $ModuleRoot = "$PSScriptRoot\..\PSStash"
    $StashXml = "$PSScriptRoot\..\PSStash\PSStash.xml"
    
    $ReferenceConfig = @{
        Uri = "stash.contoso.com"
    }

    $Credential = New-Object -TypeName PSCredential -ArgumentList user, $(ConvertTo-SecureString -asPlainText -Force -String "password")

Remove-Item $StashXml -Force -ErrorAction SilentlyContinue
Import-Module $ModuleRoot -ErrorAction Stop -force

Describe 'Import-Module PSStash' {
    Context 'Strict mode' { 
        Set-StrictMode -Version latest

        It 'Should create a persistent configuration file' {
                                    
            #It should have the right properties
                $Properties = @( (Import-Clixml -Path $StashXml -ErrorAction Stop ).PSObject.Properties.Name )
                $Comparison = Compare-Object -ReferenceObject Uri -DifferenceObject $Properties -IncludeEqual
            
                $Properties.Count | Should Be 1
                @($Comparison | Where-Object {$_.SideIndicator -eq "=="} ).Count | Should Be 1
        }
    }
}

Describe 'Set-StashConfig' {
    
    Context 'Strict mode' { 

        Set-StrictMode -Version latest

        It 'Should change PSStash.xml' {
            
            Set-StashConfig @ReferenceConfig
            $Config = Import-Clixml -Path $StashXml
            $Config.Uri | Should Be $ReferenceConfig.Uri
            
            Set-StashConfig -Uri ""
            $Config = Import-Clixml -Path $StashXml
            $Config.Uri | Should BeNullOrEmpty

        }
        It 'Should change $Script:PSStash' {

            Set-StashConfig @ReferenceConfig
            $Config = Get-StashConfig -Source StashConfig
            $Config.Uri | Should Be $ReferenceConfig.Uri

            Set-StashConfig -Uri ""
            $Config = Get-StashConfig -Source StashConfig
            $Config.Uri | Should BeNullOrEmpty
        }
    }
}

Describe 'Get-StashConfig' {
    
    Context 'Strict mode' { 

        Set-StrictMode -Version latest

        It 'Should retrieve data from PSStash.xml' {
            
            Set-StashConfig @ReferenceConfig
            $Config = Get-StashConfig -Source PSStash.xml
            $Config.Uri | Should Be $ReferenceConfig.Uri
            
            Set-StashConfig -Uri ""
            $Config = Get-StashConfig -Source PSStash.xml
            $Config.Uri | Should BeNullOrEmpty

        }
        It 'Should retrieve data from $Script:StashConfig' {
            
            Set-StashConfig @ReferenceConfig
            $Config = Get-StashConfig -Source StashConfig
            $Config.Uri | Should Be $ReferenceConfig.Uri

            Set-StashConfig -Uri ""
            $Config = Get-StashConfig -Source StashConfig
            $Config.Uri | Should BeNullOrEmpty

        }
    }
}

#TODO We set IBSession as a string above.  That's a no-no we should handle in module later.  Reset the XML...
Remove-Item $StashXml -Force
Import-Module $ModuleRoot -Force

Describe 'Get-StashObject' {

    Mock -ModuleName PSStash -CommandName Invoke-RestMethod {}

    Context 'Strict mode' { 

        Set-StrictMode -Version latest
        
        It 'Should not error out' {

            Get-StashObject -Object projects -Credential $Credential
        
        }
    }
}

Remove-Item $StashXml -force -ErrorAction SilentlyContinue