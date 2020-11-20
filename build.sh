#!/usr/bin/env bash

export condaname="fermitools"

# REPOMAN! #
# Syntax Help:
# To checkout master instead of the release tag add '--develop' after checkout
# To checkout arbitrary other refs (Tag, Branch, Commit) add them as a space
#   e.g. Fermitools-conda highest_priority_commit middle_priority_ref branch1 branch2 ... lowest_priority

if [[ -z $CONDA_PREFIX ]]; then
  echo "No Conda Prefix Variable Set. Aborting." 1>&2
  exit 1
else
  PREFIX=${CONDA_PREFIX}
fi

if [[ -z $CPU_COUNT ]]; then
    echo "Using default CPU Core Count of 1."
    CPU_COUNT=1
fi

if [[ -z $FERMI_REF ]]; then
    FERMI_REF=extensive_tagging
fi

# echo ${FERMI_REF}

if [[ ! -z $FERMI_NO_CHECKOUT ]]; then
    echo "Skipping repoman checkout"
elif [[ "$FERMI_REF" == "master" ]]; then
    echo "master"
    repoman --remote-base https://github.com/fermi-lat checkout --force --develop Fermitools-conda
else
    repoman --remote-base https://github.com/fermi-lat checkout --force --develop Fermitools-conda ${FERMI_REF}
fi



if [[ ! -z $FERMI_NO_BUILD ]]; then
    echo "Skipping BUILD Step."
else
  # Add optimization
  export CFLAGS="${CFLAGS}"
  export CXXFLAGS="-std=c++17 ${CXXFLAGS}"

  # Add rpaths needed for our compilation
  export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib/${condaname}:${PREFIX}/lib"

  if [[ "$(uname)" == "Darwin" ]]; then

      if [[ -z $CONDA_BUILD_SYSTOOT ]]; then
         CONDA_BUILD_SYSROOT="/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
      fi

      if [[ -f $CONDA_BUILD_SYSROOT ]]; then
        echo "\n"
        echo "MacOSX Builds require an Xcode SDK to supply standard library header information, but none was found at ${CONDA_BUILD_SYSROOT}"
        echo "See https://docs.conda.io/projects/conda-build/en/latest/resources/compiler-tools.html#macos-sdk for details and alternatives."
        echo "\n"
        exit 1
      fi

      if [[ -z $MACOSX_DEPLOYMENT_TARGET ]]; then
         MACOSX_DEPLOYMENT_TARGET="10.9"
      fi

      # If Mac OSX then set sysroot flag (see conda_build_config.yaml)
      export CFLAGS="-isysroot ${CONDA_BUILD_SYSROOT} ${CFLAGS}"
      export CXXFLAGS="-isysroot ${CONDA_BUILD_SYSROOT} -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET} ${CXXFLAGS}"
      export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"

  fi


  echo "FERMI_REF      = ${FERMI_REF}"
  echo "CONDA_PREFIX   = ${PREFIX}"
  echo "CPU_COUNT      = ${CPU_COUNT}"
  echo "C Compiler     = ${CC}"
  echo "C++ Compiler   = ${CXX}"
  echo "CFLAGS         = ${CFLAGS}"
  echo "CXXFLAGS       = ${CXXFLAGS}"
  echo "LDFLAGS        = ${LDFLAGS}"


  scons -C ScienceTools \
        --site-dir=../SConsShared/site_scons \
        --conda=${PREFIX} \
        --use-path \
        -j ${CPU_COUNT} \
        --with-cc="${CC}" \
        --with-cxx="${CXX}" \
        --ccflags="${CFLAGS}" \
        --cxxflags="${CXXFLAGS}" \
        --ldflags="${LDFLAGS}" \
        --compile-opt \
        all
fi

# Install in a place where conda will find the ST

if [[ ! -z $FERMI_NO_INSTALL ]]; then
    echo "Skipping Install Step."
else
    # Libraries
    mkdir -p $PREFIX/lib/${condaname}
    if [ -d "lib/debianstretch/sid-x86_64-64bit-gcc75-Optimized" ]; then
        echo "Subdirectory Found! (Lib)"
        pwd
        ls lib/
        ls lib/debianstretch/
        ls lib/debianstretch/sid-x86_64-64bit-gcc75-Optimized/
        cp -R lib/*/*/* $PREFIX/lib/${condaname}
    else
        echo "Subdirectory Not Found! (Lib)"
        cp -R lib/*/* $PREFIX/lib/${condaname}
    fi

    # Headers
    mkdir -p $PREFIX/include/${condaname}
    if [ -d "include/debianstretch/sid-x86_64-64bit-gcc75-Optimized" ]; then
        echo "Subdirectory Found! (Include)"
        cp -R include/*/* $PREFIX/include/${condaname}
    else
        echo "Subdirectory Not Found! (Include)"
        cp -R include/* $PREFIX/include/${condaname}
    fi

    # Binaries
    mkdir -p $PREFIX/bin/${condaname}
    if [ -d "exe/debianstretch/sid-x86_64-64bit-gcc75-Optimized" ]; then
        echo "Subdirectory Found! (bin)"
        cp -R exe/*/*/* $PREFIX/bin/${condaname}
    else
        echo "Subdirectory Not Found! (bin)"
        cp -R exe/*/* $PREFIX/bin/${condaname}
    fi

    # Python packages
    # Figure out the path to the site-package directory
    export sitepackagesdir=$(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")
    # Create our package there
    mkdir -p $sitepackagesdir/${condaname}
    # Making an empty __init__.py makes our directory a python package
    echo "" > $sitepackagesdir/${condaname}/__init__.py
    # Copy all our stuff there
    cp -R python/* $sitepackagesdir/${condaname}
    # There are python libraries that are actually under /lib, so let's
    # add a .pth file so that it is not necessary to setup PYTHONPATH
    # (which is discouraged by conda)
    echo "$PREFIX/lib/${condaname}" > $sitepackagesdir/${condaname}.pth
    # In order to support things like "import UnbinnedAnalysis" instead of
    # "from fermitools import UnbinnedAnalysis" we need to
    # also add the path to the fermitools package
    echo "${sitepackagesdir}/fermitools" >> $sitepackagesdir/${condaname}.pth

    # Pfiles
    mkdir -p $PREFIX/share/${condaname}/syspfiles
    cp -R syspfiles/* $PREFIX/share/${condaname}/syspfiles

    # Xml
    mkdir -p $PREFIX/share/${condaname}/xml
    cp -R xml/* $PREFIX/share/${condaname}/xml

    # Data
    mkdir -p $PREFIX/share/${condaname}/data
    cp -R data/* $PREFIX/share/${condaname}/data

    # fhelp
    mkdir -p $PREFIX/share/${condaname}/help
    cp -R fermitools-fhelp/* $PREFIX/share/${condaname}/help
    rm -f $PREFIX/share/${condaname}/help/README.md #Remove the git repo README

    # Copy also the activate and deactivate scripts
    mkdir -p $PREFIX/etc/conda/activate.d
    mkdir -p $PREFIX/etc/conda/deactivate.d

    # cp $RECIPE_DIR/activate.sh $PREFIX/etc/conda/activate.d/activate_${condaname}.sh
    # cp $RECIPE_DIR/deactivate.sh $PREFIX/etc/conda/deactivate.d/deactivate_${condaname}.sh

    # cp $RECIPE_DIR/activate.csh $PREFIX/etc/conda/activate.d/activate_${condaname}.csh
    # cp $RECIPE_DIR/deactivate.csh $PREFIX/etc/conda/deactivate.d/deactivate_${condaname}.csh
fi

if [[ ! -z $FERMI_NO_ACTIVATE ]]; then
    echo "Skipping activation script"
else
    echo "Sourcing activation script"
    source Fermitools-conda/activate.sh
fi
