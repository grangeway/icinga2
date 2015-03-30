#--------------------------------------------------------
# Copyright (C) 1995-2007 MySQL AB
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of version 2 of the GNU General Public License as
# published by the Free Software Foundation.
#
# There are special exceptions to the terms and conditions of the GPL
# as it is applied to this software. View the full text of the exception
# in file LICENSE.exceptions in the top-level directory of this software
# distribution.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# The MySQL Connector/ODBC is licensed under the terms of the
# GPL, like most MySQL Connectors. There are special exceptions
# to the terms and conditions of the GPL as it is applied to
# this software, see the FLOSS License Exception available on
# mysql.com.

##########################################################################


#-------------- FIND MYSQL_INCLUDE_DIR ------------------
FIND_PATH(SQLSRV_INCLUDE_DIR sqlncli.h
#  $ENV{MYSQL_INCLUDE_DIR}
#  $ENV{MYSQL_DIR}/include
  $ENV{ProgramFiles}/Microsoft\ SQL\ Server/110/SDK/include
#  $ENV{SystemDrive}/MySQL/*/include
)

#----------------- FIND MYSQL_LIB_DIR -------------------
IF (WIN32)
  # Set lib path suffixes
  # dist = for mysql binary distributions
  # build = for custom built tree
  IF (CMAKE_BUILD_TYPE STREQUAL Debug)
    SET(libsuffixDist debug)
    SET(libsuffixBuild Debug)
  ELSE (CMAKE_BUILD_TYPE STREQUAL Debug)
    SET(libsuffixDist opt)
    SET(libsuffixBuild Release)
    ADD_DEFINITIONS(-DDBUG_OFF)
  ENDIF (CMAKE_BUILD_TYPE STREQUAL Debug)

  FIND_LIBRARY(SQLSRV_LIB NAMES sqlncli11
    PATHS
    $ENV{ProgramFiles}/Microsoft\ SQL\ Server/110/SDK/lib/x86
	#${libsuffixDist}
#    $ENV{SystemDrive}/MySQL/*/lib/${libsuffixDist} 
  )
ENDIF (WIN32)

IF(SQLSRV_LIB)
  GET_FILENAME_COMPONENT(SQLSRV_LIB_DIR ${SQLSRV_LIB} PATH)
ENDIF(SQLSRV_LIB)

IF (SQLSRV_INCLUDE_DIR AND SQLSRV_LIB_DIR)
  SET(SQLSRV_FOUND TRUE)

  INCLUDE_DIRECTORIES(${SQLSRV_INCLUDE_DIR})
  LINK_DIRECTORIES(${SQLSRV_LIB_DIR})

#  FIND_LIBRARY(MYSQL_ZLIB zlib PATHS ${MYSQL_LIB_DIR})
#  FIND_LIBRARY(MYSQL_YASSL yassl PATHS ${MYSQL_LIB_DIR})
#  FIND_LIBRARY(MYSQL_TAOCRYPT taocrypt PATHS ${MYSQL_LIB_DIR})
  SET(MYSQL_CLIENT_LIBS mysqlclient_r)
#  IF (MYSQL_ZLIB)
#    SET(MYSQL_CLIENT_LIBS ${MYSQL_CLIENT_LIBS} zlib)
#  ENDIF (MYSQL_ZLIB)
#  IF (MYSQL_YASSL)
#    SET(MYSQL_CLIENT_LIBS ${MYSQL_CLIENT_LIBS} yassl)
#  ENDIF (MYSQL_YASSL)
#  IF (MYSQL_TAOCRYPT)
#    SET(MYSQL_CLIENT_LIBS ${MYSQL_CLIENT_LIBS} taocrypt)
#  ENDIF (MYSQL_TAOCRYPT)
  # Added needed mysqlclient dependencies on Windows
#  IF (WIN32)
#    SET(MYSQL_CLIENT_LIBS ${MYSQL_CLIENT_LIBS} ws2_32)
#  ENDIF (WIN32)

  MESSAGE(STATUS "SQLsrv Include dir: ${SQLSRV_INCLUDE_DIR}  library dir: ${SQLSRV_LIB_DIR}")
  MESSAGE(STATUS "SQLsrv client libraries: ${SQLSRV_CLIENT_LIBS}")
ELSE (SQLSRV_INCLUDE_DIR AND SQLSRV_LIB_DIR)
  MESSAGE(STATUS "Cannot find SQLsrv. Include dir: ${SQLSRV_INCLUDE_DIR}  library dir: ${SQLSRV_LIB_DIR}")
  SET(SQLSRV_FOUND FALSE)
ENDIF (SQLSRV_INCLUDE_DIR AND SQLSRV_LIB_DIR)
