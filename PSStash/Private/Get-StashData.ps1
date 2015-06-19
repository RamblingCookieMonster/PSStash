function Get-StashData
{
    [cmdletbinding()]
    param (
        $IRMParams,
        [switch]$Raw,
        $UseIWR
    )
    
    $Uri = $IRMParams.Uri
    $NextPageID = "NotStarted"

    do
    {
        if($NextPageID -notlike "NotStarted")
        {
            if(-not $IRMParams.containskey('Body'))
            {
                $IRMParams.Add( 'Body', @{} )
            }
            $IRMParams.Body.start = $NextPageID
        }

        Try
        {
            $Err = $null
            write-debug "Final $($IRMParams | Out-string)"
            
            #We might want to track the HTTP status code to verify success for non-gets...
            if($UseIWR)
            {   
                $TempResult = Invoke-WebRequest @IRMParams
            }
            else
            {
                $TempResult = Invoke-RestMethod @IRMParams -ErrorVariable Err
            }
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
        elseif($TempResult.PSObject.Properties.Name -contains 'values')
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