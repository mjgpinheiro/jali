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
# Build TPL: CURL 
#

# --- Define all the directories and common external project flags
define_external_project_args(CURL
                             TARGET curl
                             DEPENDS ZLIB)

# add CURL version to the autogenerated tpl_versions.h file
Jali_tpl_version_write(FILENAME ${TPL_VERSIONS_INCLUDE_FILE}
  PREFIX CURL
  VERSION ${CURL_VERSION_MAJOR} ${CURL_VERSION_MINOR} ${CURL_VERSION_PATCH})

# --- Define the configuration parameters
set(CURL_CMAKE_CACHE_ARGS "-DCMAKE_INSTALL_PREFIX:FILEPATH=${TPL_INSTALL_PREFIX}")
list(APPEND CURL_CMAKE_CACHE_ARGS "-DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}")

# specify preferable search path 
list(APPEND CURL_CMAKE_CACHE_ARGS "-DCMAKE_PREFIX_PATH:PATH=${TPL_INSTALL_PREFIX}")

# Search for OpenSSL is done inside CURL's cmake file

# --- Add external project build and tie to the CURL build target
ExternalProject_Add(${CURL_BUILD_TARGET}
                    DEPENDS   ${CURL_PACKAGE_DEPENDS}             # Package dependency target
                    TMP_DIR   ${CURL_tmp_dir}                     # Temporary files directory
                    STAMP_DIR ${CURL_stamp_dir}                   # Timestamp and log directory
                    # -- Download and URL definitions
                    DOWNLOAD_DIR ${TPL_DOWNLOAD_DIR}       
                    URL          ${CURL_URL}               # URL may be a web site OR a local file
                    URL_MD5      ${CURL_MD5_SUM}           # md5sum of the archive file
                    DOWNLOAD_NAME ${CURL_SAVEAS_FILE}      # file name to store (if not end of URL)
                    # -- Configure
                    SOURCE_DIR   ${CURL_source_dir}    
                    CMAKE_CACHE_ARGS ${JALI_CMAKE_CACHE_ARGS}   # Global definitions from root CMakeList
                                     ${CURL_CMAKE_CACHE_ARGS}
                                     -DCMAKE_C_FLAGS:STRING=${Jali_COMMON_CFLAGS}  # Ensure uniform build
                                     -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
                                     -DCMAKE_CXX_FLAGS:STRING=${Jali_COMMON_CXXFLAGS}
                                     -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
                    # -- Build
                    BINARY_DIR        ${CURL_build_dir}           # Build directory 
                    BUILD_COMMAND     $(MAKE)                     # $(MAKE) enables parallel builds through make
                    BUILD_IN_SOURCE   ${CURL_BUILD_IN_SOURCE}     # Flag for in source builds
                    # -- Install
                    INSTALL_DIR      ${TPL_INSTALL_PREFIX}        # Install directory
                    # -- Output control
                    ${CURL_logging_args})

# --- Define the CURL executable  
global_set(CURL_EXECUTABLE ${TPL_INSTALL_PREFIX}/bin/curl)
