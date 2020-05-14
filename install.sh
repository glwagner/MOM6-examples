#!/bin/bash

# The make file and include paths
# 
# Note that this file is very important and may need to be tailored to your system.
# I am running on a MacOSX and installed open-mpi and netcdf using homebrew.
# Due to this, my netcdf libraries are located in 
#
# /usr/local/Cellar/netcdf/4.7.4/include
#
# To "include" these files during compilation, I added the following line to 
# line 95 of osx-gnu.mk in /src/mkmf/templates/
#
# FFLAGS += -I/usr/local/Cellar/netcdf/4.7.4/include
#
# Note that this line is specific to the version number of netcdf.
#
makefile=osx-gnu.mk
netcdf_include_path=/usr/local/Cellar/netcdf/4.7.4/include

# Make a path for the build
mkdir -p build/intel/shared/repro/

# Change into the directory of the build for the Flexible Modeling System (FMS)
cd build/intel/shared/repro/

# Some cleanup?
rm -f path_names
../../../../src/mkmf/bin/list_paths -l ../../../../src/FMS
../../../../src/mkmf/bin/mkmf -t ../../../../src/mkmf/templates/$makefile -p libfms.a -c "-Duse_libMPI -Duse_netCDF -DSPMD" path_names $netcdf_include_path

# Build FMS
make NETCDF=3 REPRO=1 libfms.a -j

# Change back to root
cd ../../../../

mkdir -p build/intel/ocean_only/repro/

cd build/intel/ocean_only/repro/

# Some cleanup?
rm -f path_names
../../../../src/mkmf/bin/list_paths -l ./ ../../../../src/MOM6/{config_src/dynamic,config_src/solo_driver,src/{*,*/*}}/
../../../../src/mkmf/bin/mkmf -t ../../../../src/mkmf/templates/$makefile -o '-I../../shared/repro' -p MOM6 -l '-L../../shared/repro -lfms' -c '-Duse_libMPI -Duse_netCDF -DSPMD' path_names $netcdf_include_path

# Build
cd build/intel/ocean_only/repro/
make NETCDF=3 REPRO=1 MOM6 -j
