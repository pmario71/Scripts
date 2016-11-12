$PSx64Path = 'C:\WINDOWS\syswow64\WindowsPowerShell\v1.0\powershell.exe'
$PSx86Path = 'c:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe'

$ns = 'http://schemas.microsoft.com/developer/msbuild/2003'

<#
.Synopsis
   Sets the startup program for Visual Studio projects
.DESCRIPTION
   Lange Beschreibung
.EXAMPLE
   Beispiel für die Verwendung dieses Cmdlets
.EXAMPLE
   Ein weiteres Beispiel für die Verwendung dieses Cmdlets
#>
function Update-VSStartupProgram
{
    [CmdletBinding()]
    [Alias()]
    Param
    (
        # Path to csproj (Visual Studio project)
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
                   [ValidateScript( { (Test-Path $_) -and ([System.IO.Path]::GetExtension($_) -match '.csproj') } )]
        $ProjectPath
    )

    Begin
    {
    }
    Process
    {
        $ErrorActionPreference = "Stop"

        $prj = $ProjectPath 
        $prjUser = "$prj.user"

        [xml]$prjCfg = Get-Content $prj
        [xml]$userCfg = Get-Content $prjUser

        $assemblyName = $prjCfg.Project.PropertyGroup[0].AssemblyName

        if ($prjCfg.Project.PropertyGroup[0].OutputType -ne 'Library')
        {
            if(!AskToContinue($assemblyName))
            {
                Write-Host "Aborted by user."
                return
            }
        }

        # add ProjectGroups to user configuration
        $projectConfigurations = $prjCfg.Project.PropertyGroup | where { $_.Condition }
        
        $userGroups = $userCfg.Project.PropertyGroup

        foreach($pg in $projectConfigurations)
        {
            if( ($userGroups -eq $null) -or  # if no projects configure, always add group
                ($userGroups | where { $_.Condition.Trim() -match $pg.Condition.Trim() }).Count -eq 0 )  # otherwise only missing are added
            {
                CreateEmptyPropertyGroup $userCfg $pg.Condition
            }
        }

        SetPS $userCfg "$assemblyName.dll"

        $userCfg.Save($prjUser)

        Write-Host 'If project is currently open in Visual Studio, unloading and reloading the project is required !'
    }
    End
    {
    }
}

function CreateEmptyPropertyGroup ($userCfg, $condition)
{
    $pg = $userCfg.CreateElement('PropertyGroup', $ns);

    $a = $userCfg.CreateAttribute("Condition")
    $a.Value = $condition.Trim()
    $pg.Attributes.Append($a)

    $e1 = $userCfg.CreateElement('StartAction', $ns);
    $e2 = $userCfg.CreateElement('StartProgram', $ns);
    $e3 = $userCfg.CreateElement('StartArguments', $ns);
    $e4 = $userCfg.CreateElement('StartWorkingDirectory', $ns);

    $pg.AppendChild($e1)
    $pg.AppendChild($e2)
    $pg.AppendChild($e3)
    $pg.AppendChild($e4)

    $userCfg.Project.AppendChild($pg)
}

function SetPS ($userCfg, $target)
{
    foreach($propGroup in $userCfg.Project.PropertyGroup)
    {
        if($propGroup.Condition.Contains('x64'))
        {
            $PSPath = $PSx64Path
        }
        else
        {
            $PSPath = $PSx86Path
        }

        AddElem $propGroup 'StartAction' 'Program'
        AddElem $propGroup 'StartProgram' $PSPath
        AddElem $propGroup 'StartArguments' "-NoExit -NoProfile -Command `"&{ Import-Module `'.\$target`' }`""
        AddElem $propGroup 'StartWorkingDirectory' '' # unset
    }
}

function AddElem ($element, [string]$attrName, [string]$value)
{
    $a = $element[$attrName]
    if (!$a)
    {
        $a = $element.OwnerDocument.CreateElement($attrName, $ns)
        $element.AppendChild($a)
    }
    $a.InnerText = $value
}

function AddAttr ($element, [string]$attrName, [string]$value)
{
    $a = $element.GetAttributeNode($attrName)
    if (!$a)
    {
        $a = $element.OwnerDocument.CreateAttribute($attrName)
        $element.Attributes.Append($a)
    }
    $a.Value = $value
}

function AskToContinue($proj)
{
    $title = "Project not a Library"
    $message = "The selected project $proj is not a 'Library'. Do you want to continue?"

    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
        "Modify Startup arguments."

    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
        "Retains current settings."

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

    return $host.ui.PromptForChoice($title, $message, $options, 0) 
}