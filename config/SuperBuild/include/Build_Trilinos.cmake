# Copyright (c) 2017, Los Alamos National Security, LLC
# All rights reserved.

# Copyright 2017. Los Alamos National Security, LLC. This software was
# produced under U.S. Government contract DE-AC52-06NA25396 for Los
# Alamos National Laboratory (LANL), which is operated by Los Alamos
# National Security, LLC for the U.S. Department of Energy. The
# U.S. Government has rights to use, reproduce, and distribute this
# software.  NEITHER THE GOVERNMENT NOR LOS ALAMOS NATIONAL SECURITY,
# LLC MAKES ANY WARRANTY, EXPRESS OR IMPLIED, OR ASSUMES ANY LIABILITY
# FOR THE USE OF THIS SOFTWARE.  If software is modified to produce
# derivative works, such modified software should be clearly marked, so
# as not to confuse it with the version available from LANL.
 
# Additionally, redistribution and use in source and binary forms, with
# or without modification, are permitted provided that the following
# conditions are met:

# 1.  Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
# 2.  Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
# 3.  Neither the name of Los Alamos National Security, LLC, Los Alamos
# National Laboratory, LANL, the U.S. Government, nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
 
# THIS SOFTWARE IS PROVIDED BY LOS ALAMOS NATIONAL SECURITY, LLC AND
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL LOS
# ALAMOS NATIONAL SECURITY, LLC OR CONTRIBUTORS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.



#
# Build TPL: Trilinos
#    
# --- Define all the directories and common external project flags
set(trilinos_depend_projects ${MPI_PROJECT} NetCDF ExodusII Boost)
if(ENABLE_HYPRE)
  list(APPEND trilinos_depend_projects HYPRE)
endif()
define_external_project_args(Trilinos
                             TARGET trilinos
                             DEPENDS ${trilinos_depend_projects})

# add version version to the autogenerated tpl_versions.h file
Jali_tpl_version_write(FILENAME ${TPL_VERSIONS_INCLUDE_FILE}
  PREFIX Trilinos
  VERSION ${Trilinos_VERSION_MAJOR} ${Trilinos_VERSION_MINOR} ${Trilinos_VERSION_PATCH})
  
# --- Define the configuration parameters   

#  - Trilinos Package Configuration

#if(Trilinos_Build_Config_File)
#  message(STATUS "Including Trilinos build configuration file ${Trilinos_Build_Config_File}")
#  if ( NOT EXISTS ${Trilinos_Build_Config_File} )
#    message(FATAL_ERROR "File ${Trilinos_Build_Config_File} does not exist.")
#  endif()
#  include(${Trilinos_Build_Config_File})
#endif()

# List of packages enabled in the Trilinos build
set(Trilinos_PACKAGE_LIST Epetra)
#if ( ENABLE_STK_Mesh )
#  list(APPEND Trilinos_PACKAGE_LIST STK)
#endif()
if ( ENABLE_MSTK_Mesh )
  set(ENABLE_ZOLTAN TRUE)
  list(APPEND Trilinos_PACKAGE_LIST Zoltan)
endif()


# Generate the Trilinos Package CMake Arguments
set(Trilinos_CMAKE_PACKAGE_ARGS "-DTrilinos_ENABLE_ALL_PACKAGES:BOOL=OFF")
foreach(package ${Trilinos_PACKAGE_LIST})
  list(APPEND Trilinos_CMAKE_PACKAGE_ARGS "-DTrilinos_ENABLE_${package}:STRING=ON")
endforeach()

# Trilinos 11.0.3 has some C++ compile errors in it that we can sidestep by 
# defining HAVE_TEUCHOS_ARRAY_BOUNDSCHECK.
#list(APPEND Trilinos_CMAKE_PACKAGE_ARGS "-DTeuchos_ENABLE_ABC:BOOL=ON")

# Remove SEACAS from the build and force STK to use external Exodus
if ( ENABLE_STK_Mesh )
  list(APPEND Trilinos_CMAKE_PACKAGE_ARGS "-DTrilinos_ENABLE_SEACAS:STRING=OFF")
  list(APPEND Trilinos_CMAKE_PACKAGE_ARGS "-DSTK_ENABLE_SEACASExodus:STRING=OFF")
  list(APPEND Trilinos_CMAKE_PACKAGE_ARGS "-DSTK_ENABLE_SEACASNemesis:STRING=OFF")
endif()

# Disable Pamgen ( doesn't compile with gnu++14 standard )
list(APPEND Trilinos_CMAKE_PACKAGE_ARGS "-DTrilinos_ENABLE_Pamgen:STRING=OFF")

#  - Trilinos TPL Configuration

set(Trilinos_CMAKE_TPL_ARGS)

# MPI
list(APPEND Trilinos_CMAKE_TPL_ARGS "-DTPL_ENABLE_MPI:BOOL=ON")

# Pass the following MPI arguments to Trilinos if they are set 
set(MPI_CMAKE_ARGS DIR EXEC EXEC_NUMPROCS_FLAG EXE_MAX_NUMPROCS C_COMPILER)
foreach (var ${MPI_CMAKE_ARGS} )
  set(mpi_var "MPI_${var}")
  if ( ${mpi_var} )
    list(APPEND Trilinos_CMAKE_TPL_ARGS "-D${mpi_var}:STRING=${${mpi_var}}")
  endif()
endforeach() 

# BLAS
if ( BLAS_LIBRARIES )
  list(APPEND Trilinos_CMAKE_TPL_ARGS
              "-DTPL_ENABLE_BLAS:BOOL=TRUE")
  list(APPEND Trilinos_CMAKE_TPL_ARGS
              "-DTPL_BLAS_LIBRARIES:STRING=${BLAS_LIBRARIES}")
  message(STATUS "Trilinos BLAS libraries: ${BLAS_LIBRARIES}")    
else()
  message(WARNING "BLAS libraies not set. Trilinos will perform search.") 
endif()            
 
# LAPACK
if ( LAPACK_LIBRARIES )
  list(APPEND Trilinos_CMAKE_TPL_ARGS
              "-DTPL_LAPACK_LIBRARIES:STRING=${LAPACK_LIBRARIES}")
            message(STATUS "Trilinos LAPACK libraries: ${LAPACK_LIBRARIES}")    
else()
  message(WARNING "LAPACK libraies not set. Trilinos will perform search.") 
endif()

# Boost
list(APPEND Trilinos_CMAKE_TPL_ARGS
            "-DTPL_ENABLE_BoostLib:BOOL=ON" 
            "-DTPL_ENABLE_Boost:BOOL=ON" 
            "-DTPL_ENABLE_GLM:BOOL=OFF" 
            "-DTPL_BoostLib_INCLUDE_DIRS:FILEPATH=${TPL_INSTALL_PREFIX}/include"
            "-DBoostLib_LIBRARY_DIRS:FILEPATH=${TPL_INSTALL_PREFIX}/lib"
            "-DTPL_Boost_INCLUDE_DIRS:FILEPATH=${TPL_INSTALL_PREFIX}/include"
            "-DBoost_LIBRARY_DIRS:FILEPATH=${TPL_INSTALL_PREFIX}/lib")

# NetCDF
list(APPEND Trilinos_CMAKE_TPL_ARGS
            "-DTPL_ENABLE_Netcdf:BOOL=ON"
            "-DTPL_Netcdf_INCLUDE_DIRS:FILEPATH=${NetCDF_INCLUDE_DIRS}"
            "-DTPL_Netcdf_LIBRARIES:STRING=${NetCDF_C_LIBRARIES}")


# HYPRE
if( ENABLE_HYPRE )
  list(APPEND Trilinos_CMAKE_TPL_ARGS
              "-DTPL_ENABLE_HYPRE:BOOL=ON"
              "-DTPL_HYPRE_LIBRARIES:STRING=${HYPRE_LIBRARIES}"
              "-DTPL_HYPRE_INCLUDE_DIRS:FILEPATH=${TPL_INSTALL_PREFIX}/include")
endif()

#  - Addtional Trilinos CMake Arguments
set(Trilinos_CMAKE_EXTRA_ARGS
    "-DTrilinos_VERBOSE_CONFIGURE:BOOL=ON"
    "-DTrilinos_ENABLE_TESTS:BOOL=OFF"
    "-DTrilinos_ENABLE_Gtest:BOOL=OFF"
    "-DCMAKE_VERBOSE_MAKEFILE:BOOL=ON"
    )

if ( CMAKE_BUILD_TYPE )
  list(APPEND Trilinos_CMAKE_EXTRA_ARGS
              "-DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}")

  if ( ${CMAKE_BUILD_TYPE} STREQUAL "Debug" )
    list(APPEND Trilinos_CMAKE_EXTRA_ARGS
              "-DEpetra_ENABLE_FATAL_MESSAGES:BOOL=ON")
  endif()
  #message(DEBUG ": Trilinos_CMAKE_EXTRA_ARGS = ${Trilinos_CMAKE_EXTRA_ARGS}")
endif()

if ( BUILD_SHARED_LIBS )
  list(APPEND Trilinos_CMAKE_EXTRA_ARGS
    "-DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}")
  #message(DEBUG ": Trilinos_CMAKE_EXTRA_ARGS = ${Trilinos_CMAKE_EXTRA_ARGS}")
endif()


#  - Add CMake configuration file
if(Trilinos_Build_Config_File)
    list(APPEND Trilinos_Config_File_ARGS
        "-C${Trilinos_Build_Config_File}")
    message(STATUS "Will add ${Trilinos_Build_Config_File} to the Trilinos configure")    
    message(DEBUG "Trilinos_CMAKE_EXTRA_ARGS = ${Trilinos_CMAKE_EXTRA_ARGS}")
endif()    


#  - Final Trilinos CMake Arguments 
set(Trilinos_CMAKE_ARGS 
   ${Trilinos_CMAKE_PACKAGE_ARGS}
   ${Trilinos_CMAKE_TPL_ARGS}
   ${Trilinos_CMAKE_EXTRA_ARGS}
   )

# - Final language ARGS
set(Trilinos_CMAKE_LANG_ARGS
                   ${Jali_CMAKE_C_COMPILER_ARGS}
		           -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER_USE}
                   ${Jali_CMAKE_CXX_COMPILER_ARGS}
		           -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER_USE}
                   ${Jali_CMAKE_Fortran_COMPILER_ARGS}
                   -DCMAKE_Fortran_COMPILER:FILEPATH=${CMAKE_Fortran_COMPILER_USE})

#  --- Define the Trilinos patch step
#

# Trilinos patches
set(ENABLE_Trilinos_Patch ON)
if (ENABLE_Trilinos_Patch)
  set(Trilinos_patch_file trilinos-finite-value.patch)
  configure_file(${SuperBuild_TEMPLATE_FILES_DIR}/trilinos-patch-step.sh.in
                 ${Trilinos_prefix_dir}/trilinos-patch-step.sh
                 @ONLY)
  set(Trilinos_PATCH_COMMAND bash ${Trilinos_prefix_dir}/trilinos-patch-step.sh)
  message(STATUS "Applying trilinos patches")
else()
  set(Trilinos_PATCH_COMMAND)
  message(STATUS "Patch NOT APPLIED for trilinos")
endif()

# --- Define the Trilinos location
set(Trilinos_install_dir ${TPL_INSTALL_PREFIX}/${Trilinos_BUILD_TARGET}-${Trilinos_VERSION})

# --- Add external project build and tie to the Trilinos build target
ExternalProject_Add(${Trilinos_BUILD_TARGET}
                    DEPENDS   ${Trilinos_PACKAGE_DEPENDS}             # Package dependency target
                    TMP_DIR   ${Trilinos_tmp_dir}                     # Temporary files directory
                    STAMP_DIR ${Trilinos_stamp_dir}                   # Timestamp and log directory
                    # -- Download and URL definitions
                    DOWNLOAD_DIR ${TPL_DOWNLOAD_DIR}                  # Download directory
                    URL          ${Trilinos_URL}                      # URL may be a web site OR a local file
                    URL_MD5      ${Trilinos_MD5_SUM}                  # md5sum of the archive file
                    # -- Patch
                    PATCH_COMMAND ${Trilinos_PATCH_COMMAND}
                    # -- Configure
                    SOURCE_DIR    ${Trilinos_source_dir}           # Source directory
                    CMAKE_ARGS          ${Trilinos_Config_File_ARGS}
                    CMAKE_CACHE_ARGS    ${Trilinos_CMAKE_ARGS} 
                                        -DCMAKE_C_FLAGS:STRING=${Jali_COMMON_CFLAGS}  # Ensure uniform build
                                        -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
                                        -DCMAKE_CXX_FLAGS:STRING=${Jali_COMMON_CXXFLAGS}
                                        -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
                                        -DCMAKE_Fortran_FLAGS:STRING=${Jali_COMMON_FCFLAGS}
                                        -DCMAKE_Fortran_COMPILER:FILEPATH=${CMAKE_Fortran_COMPILER}
                                        -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
                                        -DTrilinos_ENABLE_Stratimikos:BOOL=FALSE
                                        -DTrilinos_ENABLE_SEACAS:BOOL=FALSE
                                        -DCMAKE_INSTALL_RPATH:PATH=${Trilinos_install_dir}/lib
                                        -DCMAKE_INSTALL_NAME_DIR:PATH=${Trilinos_install_dir}/lib
                    # -- Build
                    BINARY_DIR        ${Trilinos_build_dir}        # Build directory 
                    BUILD_COMMAND     $(MAKE)                      # $(MAKE) enables parallel builds through make
                    BUILD_IN_SOURCE   ${Trilinos_BUILD_IN_SOURCE}  # Flag for in source builds
                    # -- Install
                    INSTALL_DIR      ${Trilinos_install_dir}        # Install directory
                    # -- Output control
                    ${Trilinos_logging_args}
		    )

# --- Useful variables for packages that depends on Trilinos
global_set(Trilinos_INSTALL_PREFIX  ${Trilinos_install_dir})
global_set(Zoltan_INSTALL_PREFIX "${Trilinos_install_dir}")
