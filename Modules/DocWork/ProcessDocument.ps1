<#
.SYNOPSIS
    Ecapsulates the entire workflow of OCR, tagging, indexing and storing a document in its correct location.
.DESCRIPTION
    Long description
.EXAMPLE
    Example of how to use this cmdlet
.INPUTS
    Inputs to this cmdlet (if any)
.OUTPUTS
    Output from this cmdlet (if any)
.NOTES
    General notes
.COMPONENT
    The component this cmdlet belongs to
.ROLE
    The role this cmdlet belongs to
.FUNCTIONALITY
    The functionality that best describes this cmdlet
#>
function Process-Document {
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1',
                   SupportsShouldProcess=$true,
                   PositionalBinding=$false,
                   HelpUri = 'http://www.microsoft.com/',
                   ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    Param (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromRemainingArguments=$false, 
                   ParameterSetName='Explicit Filename')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ [System.IO.File]::Exists($_) })]
        $filename,
        
        # folder to find newly scanned documents in
        [Parameter(Mandatory=$true, ParameterSetName='PresetFolders')]
        [ValidateSet("\\DISKSTATION\Dokumente\Scan")]
        [string]
        $folder
    )
    
    begin {
        #\\DISKSTATION\Dokumente\Scan
        $app_bcedit = 'D:\Tools\Allgemein\BeCyPDFMetaEdit.exe'
        
    }
    
    process {
        if ($pscmdlet.ShouldProcess("Target", "Operation")) {
            
        }
    }
    
    end {
    }
}