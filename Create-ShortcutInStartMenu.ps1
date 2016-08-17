<#
    
#>
function Create-ShortcutInStartMenu {
    [CmdletBinding()]
    param(
        # Path to target of shortcut
        [Parameter(HelpMessage='Full path to target executable of filesystem object.', Mandatory=$true)]
        [ValidateScript({ test-path $_ })]
        [string]$ShortcutTarget,

        # Name of the shortcut (optional)
        [Parameter(Mandatory=$false)]
        [string]$Name,

        # Start menu location
        [Parameter(Mandatory=$true)]
        #[ValidateSet('Tools')]
        [string]$Folder
    )
    
    begin 
    {
        $WScriptShell = New-Object -ComObject WScript.Shell
    }
    
    process 
    {
        if (!$Name) {
            $Name = [System.IO.Path]::GetFileNameWithoutExtension($ShortcutTarget)
        }
        $targetFolder = "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\$Folder"

        if (!(test-path $targetFolder)) {
            [System.IO.Directory]::CreateDirectory($targetFolder)
        }
        $targetFolder = "$targetFolder\$Name.lnk"

        # Create a Shortcut with Windows PowerShell
        $Shortcut = $WScriptShell.CreateShortcut($targetFolder)
        $Shortcut.TargetPath = $ShortcutTarget
        $Shortcut.Save()
    }
    
    end 
    {
        $WScriptShell = $null
    }
}

Create-ShortcutInStartMenu -shortCutTarget D:\Tools\Development\Expresso\Expresso.exe -folder Tools\Dev