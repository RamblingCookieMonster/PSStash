#Function used to join URL.
#Credit to http://stackoverflow.com/questions/9593535/best-way-to-join-parts-with-a-separator-in-powershell

#example:
#Join-Parts -Separator "/" this //should /work/ /well
#Join-Parts -Parts this, //should, /work/, /wel
#Join-Parts -Separator "?" this ?should work ???well

function Join-Parts
{
    param
    (
    [string]$Separator = "/",

    [parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Parts = $null
        
    )

    ($Parts | Where { $_ } | Foreach { ([string]$_).trim($Separator) } | ? { $_ } ) -join $Separator
}