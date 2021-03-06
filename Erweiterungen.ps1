"Lade Erweiterungen ..."
"  - Mount-DiskStation"
"  - Load-AdditionalModules"
"  - Find-Interpret"

function Get-Computername
{
    return [System.Environment]::MachineName
}

function Mount-Diskstation()
{
    Param ([string]
           [ValidateSet('music','video','photo')]
           $target = "music",
           [string]
           [ValidateLength(1,1)]
           $drive="Z")
    $fullPath = "\\DISKSTATION\" + $target

    Write-Output $fullPath
    
    New-PSDrive -Name $drive -Root $fullPath -PSProvider FileSystem -Scope Global -Persist
}

function Load-AdditionalModules()
{
    Write-Output "- NASSyncToolPSSnapIn"
    Add-PSSnapin NASSyncToolPSSnapIn
}

Add-Type -Language CSharp @"
public class Album
{
    public string Interpret;
    public string Name;
}
"@;

function Find-Interpret()
{
    Param ([string]$Interpret)

    $NASPathMusic = "\\DISKSTATION\Music"

    foreach($dir in [IO.Directory]::GetDirectories($NASPathMusic))
    {
        if ($dir -match $Interpret)
        {
            $Name = [IO.Path]::GetFileName($dir)

            foreach($albs in [IO.Directory]::GetDirectories($dir))
            {
                $a = New-Object Album
                $a.Interpret = $Name
                $a.Name = [IO.Path]::GetFileName($albs)

                Write-Output $a
            }
        }
    }
}

function Diff-Music()
{
    Param ([string]$source, [string]$target)

    $interprets_source = [IO.Directory]::GetDirectories($source)
    $interprets_target = [IO.Directory]::GetDirectories($target)
        
    foreach($i in $interprets_source)
    {
        if ($i -match $Interpret)
        {
            $Name = [IO.Path]::GetFileName($dir)

            foreach($albs in [IO.Directory]::GetDirectories($dir))
            {
                $a = New-Object Album
                $a.Interpret = $Name
                $a.Name = [IO.Path]::GetFileName($albs)

                Write-Output $a
            }
        }
    }
}
