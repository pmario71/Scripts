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
        #(Get-Item -Path "$ProjectFolder\*.csproj")[0].FullName
        $prjUser = "$prj.user"
        #(Get-Item -Path "$ProjectFolder\*.csproj.user")[0].FullName

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
                #$node = $userCfg.ImportNode($PropertyGroupDefinition.W.PropertyGroup, $true)
                CreateEmptyPropertyGroup $userCfg $pg.Condition
                                
                #$c = $userCfg.Project.AppendChild($element)
                #$c.Condition = $pg.Condition
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

$PSx64Path = 'C:\WINDOWS\syswow64\WindowsPowerShell\v1.0\powershell.exe'
$PSx86Path = 'c:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe'

$ns = 'http://schemas.microsoft.com/developer/msbuild/2003'

[xml]$PropertyGroupDefinition = @"
<w xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
<PropertyGroup Condition="'`$(Configuration)|`$(Platform)' == 'Debug|AnyCPU'">
    <StartAction>??</StartAction>
    <StartProgram>??</StartProgram>
    <StartArguments>??</StartArguments>
    <StartWorkingDirectory></StartWorkingDirectory>
  </PropertyGroup>
</w>
"@


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

        $propGroup.StartAction = 'Program'
        $propGroup.StartProgram = $PSPath
        $propGroup.StartArguments = "-NoExit -NoProfile -Command `"&{ Import-Module `'.\$target`' }`""
        $propGroup.StartWorkingDirectory = '' # unset
    }
}

function CreatePropertyGroup($root)
{
    $root.AddChild($PropertyGroupDefinition)
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