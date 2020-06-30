#!/usr/bin/env bash

if [[ -z $FERMI_CONDA_TAG ]]; then
  FERMI_CONDA_TAG=1.3.4
fi

# TODO pattern match python version and add py2 label if necessary
# if [[ -z $PYTHON_VERSION ]]; then
#     PYTHON_VERSION=3.7
# fi


if [[ -z $FERMI_CONDA_ENV ]]; then
    FERMI_CONDA_ENV="fermi-bld-${FERMI_CONDA_TAG}"
fi

if [[ -z $FERMI_CONDA_CHANNELS ]]; then
   FERMI_CONDA_CHANNELS="-c fermi"
fi

if [[ -z $CONDA_CHANNELS ]]; then
   CONDA_CHANNELS="conda-forge"
fi

# echo "PYTHON_VERSION         = ${PYTHON_VERSION}"
# echo "CONDA_PATH             = ${CONDA_PATH}"
echo "FERMI_CONDA_ENV        = ${FERMI_CONDA_ENV}"
echo "FERMI_CONDA_CHANNELS   = ${FERMI_CONDA_CHANNELS}"
echo "CONDA_CHANNELS         = ${CONDA_CHANNELS}"


# Make sure we have conda setup
# . $CONDA_PATH/etc/profile.d/conda.sh

conda create -y --name $FERMI_CONDA_ENV -c $CONDA_CHANNELS $FERMI_CONDA_CHANNELS fermitools-build-deps=$FERMI_CONDA_TAG

# if [[ ! -z $FERMI_CONDA_TAG ]]; then
#     conda install -y --name $FERMI_CONDA_ENV -c $CONDA_CHANNELS $FERMI_CONDA_CHANNELS --only-deps fermitools=$FERMI_CONDA_TAG
# else
#     conda install -y --name $FERMI_CONDA_ENV -c $CONDA_CHANNELS $FERMI_CONDA_CHANNELS --only-deps fermitools
# fi

# conda install -y --name $FERMI_CONDA_ENV -c $CONDA_CHANNELS $FERMI_CONDA_CHANNELS fermi-repoman scons swig
