#!/usr/bin/env bash

if [[ -z $FERMI_CONDA_TAG ]]; then
  FERMI_CONDA_TAG=1.3.4
fi

FERMI_GIT_TAG="TestTag-${FERMI_CONDA_TAG}"

# TODO pattern match python version and add py2 label if necessary
# if [[ -z $PYTHON_VERSION ]]; then
#     PYTHON_VERSION=3.7
# fi


if [[ -z $FERMI_CONDA_ENV ]]; then
    FERMI_CONDA_ENV="fermi-bld-explicit-${FERMI_CONDA_TAG}"
fi

if [[ -z $FERMI_CONDA_CHANNELS ]]; then
   FERMI_CONDA_CHANNELS="-c fermi"
fi

if [[ -z $CONDA_CHANNELS ]]; then
   CONDA_CHANNELS="conda-forge"
fi

EXPLICIT_DEPS_REPO="Fermitools-explicit-build-deps"

if [ "$(uname)" == "Darwin" ]; then
  EXPLICIT_DEPS_REPO="${EXPLICIT_DEPS_REPO}-macosx"
else
  EXPLICIT_DEPS_REPO="${EXPLICIT_DEPS_REPO}-linux"
fi

# echo "PYTHON_VERSION         = ${PYTHON_VERSION}"
# echo "CONDA_PATH             = ${CONDA_PATH}"
echo "FERMI_CONDA_ENV        = ${FERMI_CONDA_ENV}"
echo "FERMI_CONDA_CHANNELS   = ${FERMI_CONDA_CHANNELS}"
echo "CONDA_CHANNELS         = ${CONDA_CHANNELS}"
echo "EXPLICIT_DEPS_REPO     = ${EXPLICIT_DEPS_REPO}"

# Make sure we have conda setup
# . $CONDA_PATH/etc/profile.d/conda.sh

git clone --quiet --branch $FERMI_GIT_TAG "https://github.com/fermi-lat/${EXPLICIT_DEPS_REPO}.git"

conda create -y --name $FERMI_CONDA_ENV --file "${EXPLICIT_DEPS_REPO}/explicit-deps.txt"

rm -rf ${EXPLICIT_DEPS_REPO}

echo "#
# To activate this environment, use
#
#     $ conda activate ${FERMI_CONDA_ENV}
#
# To deactivate an active environment, use
#
#     $ conda deactivate
"
