function Find-Book {
    [CmdletBinding()]
    param(
        # No caching
        [Parameter(HelpMessage='Ignore cached files and rebuild file information.')]
        [switch]
        $NoCachedValues
    )
    
    begin 
    {
        
    }
    
    process 
    {
        $cachedFiles = Get-Variable -Name 'CachedFiles'
        
        if (($cachedFiles -eq $null) -or $NoCachedValues)
        {
            Add-Type -Path 'd:\tools\Scripts\Libraries\eBdb.EpubReader.dll'
            #$path = Z:\Buecher
            $path = 'D:\Todo\Books'

            $files = Get-ChildItem -Path $path -Include @('*.pdf', '*.epub') -Recurse
            
            Set-Variable -Name 'CachedFiles' -Value $files
        }

        $cnt=0
        $filesTotal = $files.Length

        foreach($f in $files)
        {
            $fullName = $f.FullName
            Write-Output ">> $fullName"
            $epub = New-Object eBdb.EpubReader.Epub -ArgumentList @( $fullName )

            if ($epub -eq $null)
            {
                Write-Host "Failed to read: $f"
            }
            else
            {
                $n = $f.Name
                $t = $epub.Title[0]
                Write-Host "$n has title:  Title $t"
            }

            $epub = $null
        
            $cnt = $cnt + 1    
            $percComplete = $cnt / $filesTotal
            Write-Progress -Activity 'Parsing ...' -PercentComplete $percComplete
        }
        Write-Progress -Activity 'Parsing ...' -Completed 
    }
    
    end 
    {
    }
}