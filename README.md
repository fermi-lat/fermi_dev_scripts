# fermi_dev_scripts

Fermitools development workflow.

The Fermitools is a composite codebase with numerous external dependencies managed by the conda package manager.
Responsibility for synchronizing tag and version numbers for source repositories and dependencies devolves to the 
Fermitools Azure Pipeline and the Fermi Anaconda Cloud channel.

## Create a conda environment populated with build-time dependencies (Explicit).

Create a conda environment from the exact dependency tarballs used to create the original build environment.

```
export FERMI_REF=TestTag-1.9.9
export FERMI_CONDA_ENV=my_fermi_env
./conda_fermi_deps_explicit.sh
conda activate my_fermi_env
```

## Optional Repoman checkout and scons build

```
export FERMI_REPOMAN_LABEL=TestTag-1.9.9
export CPU_COUNT=32
./build.sh
```


# TODO

## OR Create a conda environment populated with build-time dependencies (Mutable).

Create a conda environment from the loose dependency requirements enforced by conda's SAT solver.


`export FERMI_CONDA_VERSION=1.9.9`
`./conda_fermi_deps.sh`
