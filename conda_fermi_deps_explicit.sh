#!/usr/bin/env bash

## Default Fermi Version if none is given.
if [[ -z $FERMI_CONDA_VERSION ]]; then
  FERMI_CONDA_VERSION=1.9.9
  FERMI_GIT_TAG="TestTag-${FERMI_CONDA_VERSION}"
fi

## Fermitools Reference (Tag, Branch or SHA). Defaults to conda-version if blank
if [[ -z $FERMI_REF ]]; then
  FERMI_REF=${FERMI_GIT_TAG}
fi

if [[ -z $FERMI_CONDA_ENV ]]; then
    FERMI_CONDA_ENV="fermi-bld-${FERMI_REF}"
fi

EXPLICIT_DEPS_REPO="Fermitools-explicit-build-deps"

if [ "$(uname)" == "Darwin" ]; then
  EXPLICIT_DEPS_REPO="${EXPLICIT_DEPS_REPO}-macosx"
else
  EXPLICIT_DEPS_REPO="${EXPLICIT_DEPS_REPO}-linux"
fi

echo "FERMI_REF              = ${FERMI_REF}"
echo "FERMI_CONDA_ENV        = ${FERMI_CONDA_ENV}"
echo "EXPLICIT_DEPS_REPO     = ${EXPLICIT_DEPS_REPO}"

# Make sure we have conda setup
# . $CONDA_PATH/etc/profile.d/conda.sh

git clone --quiet --branch $FERMI_REF "https://github.com/fermi-lat/${EXPLICIT_DEPS_REPO}.git"

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
