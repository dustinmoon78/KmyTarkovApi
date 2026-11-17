<#
.SYNOPSIS
    Collect the reference assemblies needed to build KmyTarkovApi for SPT 4.1.6.

.DESCRIPTION
    This repository does not ship refs/: the assemblies it references are either the
    game vendor's copyrighted files (Assembly-CSharp.dll, UnityEngine.*) or other
    authors' work (BepInEx, Harmony, MonoMod, HtmlAgilityPack, ...). They cannot be
    redistributed, so refs/ is git-ignored and must be generated from your own install.

.PARAMETER GameRoot
    SPT install root (the folder containing EscapeFromTarkov.exe). Example: -GameRoot "C:\SPT"

.EXAMPLE
    pwsh -File tools\collect-refs.ps1 -GameRoot "C:\SPT"
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$GameRoot
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$refs = Join-Path $repoRoot 'refs'

if (-not (Test-Path $GameRoot)) { throw "GameRoot not found: $GameRoot" }

$managed = Join-Path $GameRoot 'EscapeFromTarkov_Data\Managed'
$bepCore = Join-Path $GameRoot 'BepInEx\core'
$bepPlugins = Join-Path $GameRoot 'BepInEx\plugins'

New-Item -ItemType Directory -Force -Path $refs | Out-Null

# Reference name -> where to look. 'managed' = game Managed folder, 'core' = BepInEx/core
$required = @(
    @{ Name = 'Assembly-CSharp.dll';                  Root = 'managed' },
    @{ Name = 'UnityEngine.dll';                      Root = 'managed' },
    @{ Name = 'UnityEngine.CoreModule.dll';           Root = 'managed' },
    @{ Name = 'UnityEngine.UI.dll';                   Root = 'managed' },
    @{ Name = 'UnityEngine.UIModule.dll';             Root = 'managed' },
    @{ Name = 'UnityEngine.AnimationModule.dll';      Root = 'managed' },
    @{ Name = 'UnityEngine.AssetBundleModule.dll';    Root = 'managed' },
    @{ Name = 'UnityEngine.AudioModule.dll';          Root = 'managed' },
    @{ Name = 'UnityEngine.ImageConversionModule.dll';Root = 'managed' },
    @{ Name = 'UnityEngine.InputLegacyModule.dll';    Root = 'managed' },
    @{ Name = 'UnityEngine.UnityWebRequestModule.dll';Root = 'managed' },
    @{ Name = 'UnityEngine.UnityWebRequestAudioModule.dll'; Root = 'managed' },
    @{ Name = 'UnityEngine.UnityWebRequestTextureModule.dll'; Root = 'managed' },
    @{ Name = 'UnityEngine.UnityWebRequestWWWModule.dll'; Root = 'managed' },
    @{ Name = 'Unity.TextMeshPro.dll';                Root = 'managed' },
    @{ Name = 'Newtonsoft.Json.dll';                  Root = 'managed' },
    @{ Name = 'Comfort.dll';                          Root = 'managed' },
    @{ Name = 'AnimationSystem.Types.dll';            Root = 'managed' },
    @{ Name = 'BepInEx.dll';                          Root = 'core' },
    @{ Name = '0Harmony.dll';                         Root = 'core' },
    @{ Name = 'Mono.Cecil.dll';                       Root = 'core' },
    @{ Name = 'MonoMod.RuntimeDetour.dll';            Root = 'core' },
    @{ Name = 'MonoMod.Utils.dll';                    Root = 'core' }
)

# These ship with their own mods, so they live somewhere under plugins/
$fromPlugins = @(
    @{ Name = 'Crc32.NET.dll';        Hint = 'kmyuhkyuk-KmyTarkovApi' },
    @{ Name = 'HtmlAgilityPack.dll';  Hint = 'kmyuhkyuk-KmyTarkovApi' }
)

$missing = @()
$copied = 0

function Copy-Ref {
    param([string]$Source, [string]$Name)
    Copy-Item $Source (Join-Path $refs $Name) -Force
    Write-Host ("  + {0}" -f $Name) -ForegroundColor Green
    $script:copied++
}

foreach ($entry in $required) {
    $name = $entry.Name
    $dir = switch ($entry.Root) {
        'managed' { $managed }
        'core'    { $bepCore }
        default   { throw "unknown root: $($entry.Root)" }
    }
    $path = Join-Path $dir $name
    if (Test-Path $path) { Copy-Ref $path $name }
    else { $missing += "$name  (expected in $dir)" }
}

foreach ($entry in $fromPlugins) {
    $name = $entry.Name
    $direct = Join-Path $bepPlugins $name
    if (Test-Path $direct) { Copy-Ref $direct $name; continue }

    $hint = Join-Path $bepPlugins $entry.Hint
    if (Test-Path $hint) {
        $found = Get-ChildItem $hint -Recurse -File -Filter $name -ErrorAction SilentlyContinue |
            Select-Object -First 1
        if ($found) { Copy-Ref $found.FullName $name; continue }
    }

    $missing += "$name  (expected in $bepPlugins\$($entry.Hint) or $bepPlugins)"
}

Write-Host ""
Write-Host ("Copied {0} references into {1}" -f $copied, $refs) -ForegroundColor Cyan

if ($missing.Count -gt 0) {
    Write-Host ""
    Write-Host "Missing (build will fail):" -ForegroundColor Yellow
    $missing | ForEach-Object { Write-Host ("  - {0}" -f $_) -ForegroundColor Yellow }
    exit 1
}

Write-Host ""
Write-Host "Done. Next:" -ForegroundColor Cyan
Write-Host "  dotnet build KmyTarkovApi.sln -c Release"
Write-Host ""
Write-Host "refs/ is git-ignored on purpose: those assemblies are not redistributable."
