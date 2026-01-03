# Creates folder structure to archive images and videos.
function Create-FotoStructure {
    <#
        .SYNOPSIS
            Creates the directory structure for archiving fotos: (/handy, /drohen, /raw) and moves any fotos into the corresponding folders.

        .EXAMPLE
            Create-FotoStructure -Path '/Volumes/Foto_backup/2023/Sommerurlaub Schweiz Mont Blanc' 

            This shows the help for the example function.
    #>
    [CmdletBinding()]

    param (
        # Path to generate folder structure in
        [Parameter()][string]$Path
    )

    [System.IO.Directory]::CreateDirectory($Path)

    $handy = [System.IO.Directory]::CreateDirectory([System.IO.Path]::Combine($Path, "handy"))
    $drohne = [System.IO.Directory]::CreateDirectory([System.IO.Path]::Combine($Path, "drohne"))
    $raw = [System.IO.Directory]::CreateDirectory([System.IO.Path]::Combine($Path, "raw"))

    Push-Location -Path $Path

    Move-Item -Path ./* -Destination $raw -Filter 'DSC*'
    Move-Item -Path ./* -Destination $drohne -Filter 'DJI*'
    Move-Item -Path ./* -Destination $handy -Filter 'IMG_*'

    Pop-Location
}