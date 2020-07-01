# fermi_dev_scripts

Fermitools development workflow.

The Fermitools is a composite codebase with numerous external dependencies managed by the conda package manager.
Responsibility for synchronizing tag and version numbers for source repositories and dependencies devolves to the 
Fermitools Azure Pipeline and the Fermi Anaconda Cloud channel.

## Set needed Environment Variables

The development scripts read variables from the user's environment. These may be customized for your target REF, environment and hardware, etc.

```
# Linux
export FERMI_REF=TestTag-1.9.9
export FERMI_CONDA_ENV=my_fermi_env
export CPU_COUNT=4
```

```
# MacOSX
export FERMI_REF=TestTag-1.9.9
export FERMI_CONDA_ENV=my_fermi_env
export CPU_COUNT=4
```

Optionally on MacOSX you can set your `CONDA_BUILD_SYSROOT` and `MACOSX_DEPLOYMENT_TARGET` variables. If left unset they will be defaulted to the values below.
[MacOSX builds require an Xcode SDK file.](https://docs.conda.io/projects/conda-build/en/latest/resources/compiler-tools.html#macos-sdk)

```
export CONDA_BUILD_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk  
export MACOSX_DEPLOYMENT_TARGET=10.9
```

## Create a conda environment populated with build-time dependencies (Explicit).

Create a conda environment from the exact dependency tarballs used to create the original build environment.

```
./conda_fermi_build_deps_explicit.sh
conda activate my_fermi_env
```

## Optional Repoman checkout and scons build

```
./build.sh
```

## Disable Repoman checkout during the build

```
export FERMI_NO_CHECKOUT=true
./build.sh
```

## Disable SCONS Install step during the build

```
export FERMI_NO_INSTALL=true
./build.sh
```
