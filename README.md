# VS10 Docker Image

This repository contains all the files needed to build a VS10 Docker image for making cool CI with a super antiquated compiler. Giving someone a polished lump of coal is still better than just plain coal!

The published image lives at [`neocass/vs10-build-tools`](https://hub.docker.com/r/neocass/vs10-build-tools).

## What's in it

Built on `mcr.microsoft.com/windows/server:ltsc2022`:

- **Visual Studio 2010** + **SP1** (the `v100` toolset)
- **Visual Studio 2022 Build Tools** — VC++ workload, `v143` toolset, Windows 11 SDK 22621
- **.NET Framework 3.5 and 4.0** (required by the VS2010 installer)
- **CMake** — on the system `PATH`
- **Git** — with the Unix tools on `PATH` and `autocrlf` disabled

Working directory is `C:\build`, default shell is `cmd`.

## Usage

```
docker pull neocass/vs10-build-tools:latest
docker run --rm -it -v %CD%:C:\build neocass/vs10-build-tools
```

Generate with VS2022 and compile with the VS2010 toolset:

```
cmake -A Win32 -T v100 .
cmake --build . --config Release
```

## Requirements

A Windows host running Windows containers.

## Building it yourself

The VS2010 installers are stored with Git LFS, so you need that first:

```
git lfs install
git clone https://github.com/neo-cass/vs10-docker-image.git
cd vs10-docker-image
docker build -t vs10-build-tools .
```

Expect it to take a while — the VS2010 and SP1 installers are slow.

## CI

`.github/workflows/docker-build.yml` builds on every push and publishes to
Docker Hub, tagged with the branch name, the short commit SHA, and `latest`
on the default branch.
