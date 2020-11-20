#!/usr/bin/env python

import os
import subprocess
import argparse

from platform import mac_ver
from multiprocessing import cpu_count


# These are how we define the various envvars in terms of other envvars
FERMI_BASE_DIR_FORMAT = os.path.join('{HOME}', 'software', 'fermi')
FERMI_RELEASE_DIR_FORMAT = os.path.join("{FERMI_BASE_DIR}", "releases", "FT_{FERMI_REL_TAG}{FERMI_REL_SUFFIX}")
FERMI_REF_FORMAT = "{FERMI_REF_PREFIX}{FERMI_REL_TAG}"
FERMI_CONDA_ENV_FORMAT = "fermi-{FERMI_REL_TAG}{FERMI_REL_SUFFIX}"
RECIPE_DIR_FORMAT = os.path.join("{FERMI_RELEASE_DIR}", 'Fermitools-conda')


def format_string(fstr):
    """Format and return a string using environmental variables"""
    return fstr.format(**os.environ)

def format_command(args):
    """Convert a list of args to a command line and return it"""
    s = ""
    for arg in args:
        s += "%s " % arg
    return s

def put_formatted_envvar(varname, fstr):
    """Format a string and declare it as an envvar, if it does not already exist"""
    os.environ.setdefault(varname, format_string(fstr))    

    
def set_system_envvars():
    """Set the system / machine dependent envvars"""
    if os.uname()[0] == 'Darwin':
        os.environ['CONDA_BUILD_SYSROOT']  = '/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk'
        os.environ['MACOSX_DEPLOYMENT_TARGET'] = "10.9"
    
    os.environ['CPU_COUNT'] = "%s" % cpu_count()
    os.environ['FERMI_ADMIN_DIR'] = os.path.dirname(os.path.abspath(__file__))


def set_arg_envvars(args):
    """Set the tag / build dependent from the command line arguments"""
    os.environ['FERMI_REL_TAG'] = args.tag
    os.environ['FERMI_REF_PREFIX'] = args.ref_prefix
    os.environ['FERMI_REL_SUFFIX'] = args.rel_suffix
    if args.rel_dir is not None:
        os.environ['FERMI_RELEASE_DIR'] = os.path.abspath(args.rel_dir)

        
def set_derived_envvars():
    """Set the derived envvars from the system and command line options"""
    put_formatted_envvar('FERMI_BASE_DIR', FERMI_BASE_DIR_FORMAT)
    put_formatted_envvar('FERMI_RELEASE_DIR', FERMI_RELEASE_DIR_FORMAT)
    put_formatted_envvar('FERMI_REF', FERMI_REF_FORMAT)
    put_formatted_envvar('FERMI_CONDA_ENV', FERMI_CONDA_ENV_FORMAT)
    put_formatted_envvar('RECIPE_DIR', RECIPE_DIR_FORMAT)


def print_config_envvars():
    """Print the envvars that control the build configuration"""
    varList = ['FERMI_RELEASE_DIR', 'FERMI_ADMIN_DIR', 'FERMI_REF', 'FERMI_CONDA_ENV', 'RECIPE_DIR']
    for envv in varList:
        print ("%-20s = %s" % (envv, os.environ[envv]))
    print("")

    
def print_conda_activate(dry_run=False):
    """Print the conda activate command"""
    exec_com = ['conda', 'activate', '{FERMI_CONDA_ENV}'.format(**os.environ)]
    print("Activate conda env with: %s" % format_command(exec_com))
    
    
def build_deps_explicit(dry_run=False):
    """Print or run the dependency building command"""
    exec_com = ['{FERMI_ADMIN_DIR}/conda_fermi_deps_explicit.sh'.format(**os.environ)]
    if dry_run:
        print("Build depdendencies with: %s" % format_command(exec_com))
        return
    subprocess.call(exec_com, shell=True)

    
def run_build_script(no_repoman=True, dry_run=False):
    """Print or run the build script command"""
    exec_com = ""
    if no_repoman:
        os.environ['FERMI_NO_CHECKOUT'] = "1"
    else:
        try:
            os.environ.pop('FERMI_NO_CHECKOUT')
        except KeyError:
            pass
    
    reldir = os.environ['FERMI_RELEASE_DIR']
    try:
        os.makedirs(reldir)
    except OSError:
        pass    
    curdir = os.getcwd()
    os.chdir(reldir)

    exec_com = ['{FERMI_ADMIN_DIR}/build.sh'.format(**os.environ)]
    if dry_run:
        print("Build release with: %s" % format_command(exec_com))
        return
    subprocess.call(exec_com, shell=True)
    os.chdir(curdir)


        
if __name__=='__main__':

    parser = argparse.ArgumentParser()

    parser.add_argument('--tag', action='store', required=True,
                            help="Release tag")
    parser.add_argument('--rel_dir', action='store', default=None,
                            help="Path to release directory")
    parser.add_argument('--ref_prefix', action='store', default="TestTag-",
                            help="Prefix on git/conda tag")
    parser.add_argument('--rel_suffix', action='store', default="-dev",
                            help="Suffix on release and conda-env names")
    parser.add_argument('--dry_run', default=False, action='store_true',
                            help="Don't actually run commands")
    parser.add_argument('--no_repoman', default=False, action='store_true',
                            help="Don't check out packages")
    parser.add_argument('--no_deps', default=False,  action='store_true',
                            help="Don't build dependencies")
    parser.add_argument('--no_build', default=False,  action='store_true',
                            help="Don't build fermitools")

    args = parser.parse_args()

    set_system_envvars()
    set_arg_envvars(args)
    set_derived_envvars()
    print_config_envvars()

    if not args.no_deps:
        build_deps_explicit(args.dry_run)
        print_conda_activate(args.dry_run)

    if not args.no_build:
        run_build_script(args.no_repoman, args.dry_run)
