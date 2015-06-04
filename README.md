Stash PowerShell Module
=============

This is a PowerShell module for working with the Atlassian Stash REST API.

This is an quick and dirty implementation based on my environment's configuration, with limited functionality.  Contributions to improve this would be more than welcome!

Chances are high that there will be breaking design changes, this is just a simple POC.

### Examples:

Query for projects:

![Public projects](/Media/PublicProjects.png)

Query for arbitrary objects:

![Objects](/Media/repos.png)

### Instructions:

```PowerShell
# One time setup
    # Download the repository
    # Unblock the zip
    # Extract the PSStash folder to a module path (e.g. $env:USERPROFILE\Documents\WindowsPowerShell\Modules\)

# Import the module.
    Import-Module PSStash    #Alternatively, Import-Module \\Path\To\PSStash

# Get commands in the module
    Get-Command -Module PSStash

# Get help for a command
    Get-Help Get-StashObject -Full
    Get-Help Get-StashConfig -Full

# Set a default Uri
    Set-StashConfig -uri https://stash.contoso.com

# List public projects
    Get-StashProject

# List repositories that user in $cred has access to
    Get-StashObject -Object repos -Credential $cred

# List repositories under the 'sysinv' project
    Get-StashObject -Object projects/sysinv/repos -Credential $cred

```

### References:

* [Stash Developer Docs](https://developer.atlassian.com/stash/docs/latest/)
* [Stash Core REST API](https://developer.atlassian.com/static/rest/stash/3.9.2/stash-rest.html)

### TODO:

Everything. This is in the 'can I get it working' state. Need to identify requirements (e.g. which objects to create functions for, further parameters, whether to pursue OAUTH) for further work.