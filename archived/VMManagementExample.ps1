<#
.Synopsis
   Kurzbeschreibung
.DESCRIPTION
   Lange Beschreibung
.EXAMPLE
   Beispiel für die Verwendung dieses Cmdlets
.EXAMPLE
   Ein weiteres Beispiel für die Verwendung dieses Cmdlets
#>
function Verb-Noun
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Hilfebeschreibung zu Param1
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Param1,

        # name and location of new differencing disk
        [string]
        $newDiffDisk
    )

    Begin
    {
    }
    Process
    {
        $disk = '<some file.vhdx>'
        $newDiffDisk = '<diff disk name.vhdx>'
        
        # get VM object to which disk is attached to
        $VM = (Get-VM | select -Index 1)

        # list harddrives
        $VM.HardDrives

        # remove disk from VM
        Remove-VMHardDiskDrive -VMHardDiskDrive $VM.HardDrives[0]
        
        # set base image to read only
        Set-ItemProperty -Path $disk -Name IsReadOnly -Value $true
        
        #create new diff disk linked to the underlying readonly disk
        New-VHD –Path $newDiffDisk –ParentPath $disk –Differencing

        # add disk back to VM (boot drive on controller 0)
        Add-VMHardDiskDrive -VM $VM -ControllerNumber 0
    }
    End
    {
    }
}