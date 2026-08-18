# vs10-build-tools

Visual Studio 2010 in a Windows container, so you can build ancient C++ in CI
without keeping an ancient machine alive.

Source: https://github.com/neo-cass/vs10-docker-image

## Contents

Based on `mcr.microsoft.com/windows/server:ltsc2022`:

- Visual Studio 2010 + SP1 (`v100` toolset)
- Visual Studio 2022 Build Tools — VC++ workload, `v143` toolset, Windows 11 SDK 22621
- .NET Framework 3.5 and 4.0
- CMake and Git, both on `PATH`

Working directory `C:\build`, default shell `cmd`.

## Tags

| Tag | Meaning |
| --- | --- |
| `latest` | Newest build of the default branch (main) |
| `<branch>` | Latest build of `<branch>` |
| `sha-<short>` | A specific commit |

## Quick start

```
docker run --rm -it -v %CD%:C:\build neocass/vs10-build-tools
```

Generate with VS2022 and compile with the VS2010 toolset:

```
cmake -A Win32 -T v100 .
cmake --build . --config Release
```

## Requirements

A Windows host running Windows containers.
