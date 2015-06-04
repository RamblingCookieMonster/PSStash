function Get-StashData
{
    [cmdletbinding()]
    param (
        $IRMParams,
        [switch]$Raw
    )
    
    $Uri = $IRMParams.Uri
    $NextPageID = "NotStarted"

    do
    {
        if($NextPageID -notlike "NotStarted")
        {
            #What if there is CGI already?
            $IRMParams.Uri = $Uri, "start=$NextPageID" -join "?"
        }

        Try
        {
            $Err = $null
            $TempResult = Invoke-RestMethod @IRMParams -ErrorVariable Err
            Write-Debug "Raw:`n$($TempResult | Out-String)"
        }
        Catch
        {
            Throw $_
        }

        $NextPageID = $TempResult.nextPageStart
        Write-Debug "Page $NextPageID"
        
        if($Raw)
        {
            $TempResult
        }
        elseif($TempResult.Values)
        {
            $TempResult.Values
        }
        else
        {
            $TempResult
        }

    }
    until (
        $TempResult.isLastPage -like 'true' -or
        $Raw -or 
        -not $TempResult.Values
    )
}