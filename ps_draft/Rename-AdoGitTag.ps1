<#
CmdLet is AI generated and unverified.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter()]
    [string]$OrganizationUrl = "https://dev.azure.com/shs-sw-products",

    [Parameter()]
    [string[]]$ProjectNames,

    [Parameter()]
    [string]$OldTag = "FTR_RemoteReading",

    [Parameter()]
    [string]$NewTag = "RemoteReading",

    [Parameter()]
    [string]$Pat,

    [Parameter()]
    [switch]$DeleteOldWhenTargetExists,

    [Parameter()]
    [switch]$ForceOverwriteTarget
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-AdoAuthHeaders {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PersonalAccessToken
    )

    $tokenBytes = [System.Text.Encoding]::ASCII.GetBytes(":$PersonalAccessToken")
    $tokenBase64 = [System.Convert]::ToBase64String($tokenBytes)

    return @{
        Authorization = "Basic $tokenBase64"
        Accept        = "application/json"
        "Content-Type" = "application/json"
    }
}

function Invoke-AdoGetPaged {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Uri,

        [Parameter(Mandatory = $true)]
        [hashtable]$Headers
    )

    $all = @()
    $continuationToken = $null

    do {
        $requestUri = $Uri
        if ($continuationToken) {
            $separator = if ($requestUri.Contains("?")) { "&" } else { "?" }
            $requestUri = "$requestUri${separator}continuationToken=$([System.Uri]::EscapeDataString($continuationToken))"
        }

        $responseHeaders = $null
        $response = Invoke-RestMethod -Uri $requestUri -Method Get -Headers $Headers -ResponseHeadersVariable responseHeaders

        if ($response.value) {
            $all += @($response.value)
        }

        $continuationToken = $null
        if ($responseHeaders.ContainsKey("x-ms-continuationtoken")) {
            $continuationToken = $responseHeaders["x-ms-continuationtoken"]
        }
    } while ($continuationToken)

    return $all
}

function Get-AdoProjects {
    param(
        [Parameter(Mandatory = $true)]
        [string]$OrgUrl,

        [Parameter(Mandatory = $true)]
        [hashtable]$Headers
    )

    $uri = "$OrgUrl/_apis/projects?`$top=200&api-version=7.1-preview.4"
    return Invoke-AdoGetPaged -Uri $uri -Headers $Headers
}

function Get-AdoRepositories {
    param(
        [Parameter(Mandatory = $true)]
        [string]$OrgUrl,

        [Parameter(Mandatory = $true)]
        [string]$ProjectName,

        [Parameter(Mandatory = $true)]
        [hashtable]$Headers
    )

    $uri = "$OrgUrl/$([System.Uri]::EscapeDataString($ProjectName))/_apis/git/repositories?api-version=7.1-preview.1"
    return Invoke-AdoGetPaged -Uri $uri -Headers $Headers
}

function Get-AdoTagRef {
    param(
        [Parameter(Mandatory = $true)]
        [string]$OrgUrl,

        [Parameter(Mandatory = $true)]
        [string]$ProjectName,

        [Parameter(Mandatory = $true)]
        [string]$RepositoryId,

        [Parameter(Mandatory = $true)]
        [string]$TagName,

        [Parameter(Mandatory = $true)]
        [hashtable]$Headers
    )

    $uri = "$OrgUrl/$([System.Uri]::EscapeDataString($ProjectName))/_apis/git/repositories/$RepositoryId/refs?filter=tags/$([System.Uri]::EscapeDataString($TagName))&api-version=7.1-preview.1"
    $result = Invoke-RestMethod -Uri $uri -Method Get -Headers $Headers
    $expectedName = "refs/tags/$TagName"
    return @($result.value | Where-Object { $_.name -eq $expectedName }) | Select-Object -First 1
}

function Update-AdoRefs {
    param(
        [Parameter(Mandatory = $true)]
        [string]$OrgUrl,

        [Parameter(Mandatory = $true)]
        [string]$ProjectName,

        [Parameter(Mandatory = $true)]
        [string]$RepositoryId,

        [Parameter(Mandatory = $true)]
        [hashtable]$Headers,

        [Parameter(Mandatory = $true)]
        [object[]]$RefUpdates
    )

    $uri = "$OrgUrl/$([System.Uri]::EscapeDataString($ProjectName))/_apis/git/repositories/$RepositoryId/refs?api-version=7.1-preview.1"
    return Invoke-RestMethod -Uri $uri -Method Post -Headers $Headers -Body ($RefUpdates | ConvertTo-Json -Depth 5)
}

if (-not $Pat) {
    $Pat = $env:AZDO_PAT
}

if (-not $Pat) {
    throw "Provide -Pat or set AZDO_PAT environment variable with an Azure DevOps PAT."
}

if ($OldTag -eq $NewTag) {
    throw "Old tag and new tag names must be different."
}

$headers = Get-AdoAuthHeaders -PersonalAccessToken $Pat

$orgUri = [System.Uri]$OrganizationUrl
$orgBase = $OrganizationUrl.TrimEnd("/")

# If a project is embedded in the URL and no -ProjectNames were provided, use that project.
if (-not $ProjectNames -and $orgUri.Segments.Count -ge 3) {
    $possibleProject = $orgUri.Segments[2].Trim("/")
    if ($possibleProject -and $possibleProject -ne "_apis") {
        $ProjectNames = @($possibleProject)
        $orgBase = "$($orgUri.Scheme)://$($orgUri.Host)$($orgUri.Segments[0])$($orgUri.Segments[1].TrimEnd('/'))"
    }
}

if (-not $ProjectNames) {
    Write-Host "Loading projects from $orgBase ..."
    $ProjectNames = @(Get-AdoProjects -OrgUrl $orgBase -Headers $headers | Select-Object -ExpandProperty name)
}

if (-not $ProjectNames -or $ProjectNames.Count -eq 0) {
    throw "No projects found to process."
}

$zeroObjectId = "0000000000000000000000000000000000000000"
$results = New-Object System.Collections.Generic.List[object]

Write-Host "Projects to process: $($ProjectNames -join ', ')"
Write-Host "Tag rename: '$OldTag' -> '$NewTag'"

foreach ($projectName in $ProjectNames) {
    Write-Host "`nProject: $projectName"
    $repos = @(Get-AdoRepositories -OrgUrl $orgBase -ProjectName $projectName -Headers $headers)

    if ($repos.Count -eq 0) {
        Write-Host "  No repositories found."
        continue
    }

    foreach ($repo in $repos) {
        $sourceRef = Get-AdoTagRef -OrgUrl $orgBase -ProjectName $projectName -RepositoryId $repo.id -TagName $OldTag -Headers $headers
        if (-not $sourceRef) {
            $results.Add([pscustomobject]@{
                Project = $projectName
                Repository = $repo.name
                Status = "Skipped"
                Details = "Source tag not found"
            })
            continue
        }

        $targetRef = Get-AdoTagRef -OrgUrl $orgBase -ProjectName $projectName -RepositoryId $repo.id -TagName $NewTag -Headers $headers
        $refUpdates = @()

        if (-not $targetRef) {
            $refUpdates += [pscustomobject]@{
                name = "refs/tags/$NewTag"
                oldObjectId = $zeroObjectId
                newObjectId = $sourceRef.objectId
            }
        }
        elseif ($targetRef.objectId -eq $sourceRef.objectId) {
            if (-not $DeleteOldWhenTargetExists) {
                $results.Add([pscustomobject]@{
                    Project = $projectName
                    Repository = $repo.name
                    Status = "Skipped"
                    Details = "Target tag already exists at same object. Use -DeleteOldWhenTargetExists to remove old tag"
                })
                continue
            }
        }
        else {
            if (-not $ForceOverwriteTarget) {
                $results.Add([pscustomobject]@{
                    Project = $projectName
                    Repository = $repo.name
                    Status = "Skipped"
                    Details = "Target tag exists at different object. Use -ForceOverwriteTarget"
                })
                continue
            }

            $refUpdates += [pscustomobject]@{
                name = "refs/tags/$NewTag"
                oldObjectId = $targetRef.objectId
                newObjectId = $sourceRef.objectId
            }
        }

        # Always delete the old tag when we performed a rename or are explicitly asked to clean up.
        $refUpdates += [pscustomobject]@{
            name = "refs/tags/$OldTag"
            oldObjectId = $sourceRef.objectId
            newObjectId = $zeroObjectId
        }

        $actionLabel = "Repo '$($repo.name)' in project '$projectName'"
        if ($PSCmdlet.ShouldProcess($actionLabel, "Rename tag '$OldTag' to '$NewTag'")) {
            try {
                $updateResult = Update-AdoRefs -OrgUrl $orgBase -ProjectName $projectName -RepositoryId $repo.id -Headers $headers -RefUpdates $refUpdates
                $failed = @($updateResult.value | Where-Object { $_.success -ne $true })
                if ($failed.Count -gt 0) {
                    $results.Add([pscustomobject]@{
                        Project = $projectName
                        Repository = $repo.name
                        Status = "Failed"
                        Details = ($failed | ForEach-Object { $_.updateStatus } | Select-Object -Unique) -join ", "
                    })
                }
                else {
                    $results.Add([pscustomobject]@{
                        Project = $projectName
                        Repository = $repo.name
                        Status = "Updated"
                        Details = "Tag renamed"
                    })
                }
            }
            catch {
                $results.Add([pscustomobject]@{
                    Project = $projectName
                    Repository = $repo.name
                    Status = "Failed"
                    Details = $_.Exception.Message
                })
            }
        }
    }
}

Write-Host "`nSummary"
if ($results.Count -eq 0) {
    Write-Host "No repositories required changes."
}
else {
    $results |
        Sort-Object Project, Repository |
        Format-Table -AutoSize
}

Write-Host "`nDone."
