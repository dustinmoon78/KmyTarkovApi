# KmyTarkovApi — SPT 4.1.6 port

A community port of [kmyuhkyuk's KmyTarkovApi](https://github.com/kmyuhkyuk/KmyTarkovApi),
adapted to **SPT 4.1.6**. Hard dependency of
[GamePanelHUD](https://github.com/dustinmoon78/GamePanelHUD).

Upstream last published **1.5.0** for SPT 4.0. No 4.1 build has ever been released upstream.

> **This branch — `spt-4.1-port` — is the source of every published binary.**
> If you are reading `master` and see `ToolsVersion 15.0` / `net472` project files,
> you are looking at upstream's 4.0 code.

---

## Modules

| Project | Ships as | Purpose |
|---|---|---|
| `KmyTarkovApi` | `KmyTarkovApi.dll` | EFT session/player/trader helpers |
| `KmyTarkovReflection` | `KmyTarkovReflection.dll` | Reflection helpers (field/method refs) |
| `KmyTarkovUtils` | `KmyTarkovUtils.dll` | Update manager, MonoBehaviour utils |
| `KmyTarkovConfiguration` | `KmyTarkovConfiguration.dll` | In-game F12 configuration UI |

`Build/` and `ConfigurationTest/` are kept in the repository unchanged from upstream but
are **not** part of `KmyTarkovApi.sln`: they are still `ToolsVersion 15.0` / `net472`
projects (upstream's packer and a dev tool) and produce nothing that ships.

---

## How to build

### 1. Requirements

| Tool | Version |
|---|---|
| .NET SDK | 8.0 or newer (the projects target `netstandard2.1`) |
| SPT | **4.1.6** client, installed (for reference assemblies only) |

### 2. Collect the reference assemblies

`refs/` is **git-ignored**: it holds the game vendor's copyrighted assemblies
(`Assembly-CSharp.dll`, `UnityEngine.*`) plus other authors' DLLs (BepInEx, Harmony,
MonoMod, HtmlAgilityPack, Crc32.NET). None of them may be redistributed.

```powershell
pwsh -File tools\collect-refs.ps1 -GameRoot "C:\SPT"
```

| Reference | Source |
|---|---|
| `Assembly-CSharp.dll`, `UnityEngine*.dll`, `Unity.TextMeshPro.dll`, `Newtonsoft.Json.dll`, `Comfort.dll`, `AnimationSystem.Types.dll` | `<GameRoot>\EscapeFromTarkov_Data\Managed\` |
| `BepInEx.dll`, `0Harmony.dll`, `Mono.Cecil.dll`, `MonoMod.RuntimeDetour.dll`, `MonoMod.Utils.dll` | `<GameRoot>\BepInEx\core\` |
| `Crc32.NET.dll`, `HtmlAgilityPack.dll` | `<GameRoot>\BepInEx\plugins\kmyuhkyuk-KmyTarkovApi\` |

The script reports anything it cannot find and exits non-zero.

### 3. Build

```powershell
dotnet build KmyTarkovApi.sln -c Release
```

Output: `<Project>\bin\Release\*.dll`.

### 4. Install

Copy the four DLLs into `BepInEx/plugins/kmyuhkyuk-KmyTarkovApi/`.

---

## What this port changes

| Area | Change |
|---|---|
| Target framework | `net472` → `netstandard2.1`; SDK-style project files |
| Plugin GUIDs | `com.kmyuhkyuk.*` → `com.dustinmoon78.*` (lowercase; the Forge requires lowercase and the upstream namespace is taken) |
| Game API | Adapted to 4.1.6 (`IEftSession`, `ITradingSession`, `QuestController`, …) |

---

## License and attribution

Upstream KmyTarkovApi is **GPL-3.0**; the original `LICENSE` is kept unchanged.
Source availability is satisfied by this repository.

The 4.1 port was submitted upstream as
[kmyuhkyuk/KmyTarkovApi#3](https://github.com/kmyuhkyuk/KmyTarkovApi/pull/3) and merged
on 2026-09-06 without review comments.

Authorization from the original author (2026-11-14, PR #12):

> "I authorize dustinmoon78 to maintain and release version 4.1.6 of GamePanelHUD and
> KmyTarkovApi source, pending the time when I can rewrite the entire GamePanelHUD."
> — kmyuhkyuk, https://github.com/kmyuhkyuk/GamePanelHUD/pull/12#issuecomment-6875707053
