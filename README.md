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

## Disable Repoman checkout

```
export FERMI_NO_CHECKOUT=true
./build.sh
```


# TODO

## OR Create a conda environment populated with build-time dependencies (Mutable).

Create a conda environment from the loose dependency requirements enforced by conda's SAT solver.


`export FERMI_CONDA_VERSION=1.9.9`
`./conda_fermi_deps.sh`
