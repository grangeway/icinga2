# Icinga 2
# Copyright (C) 2012-2015 Icinga Development Team (http://www.icinga.org)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software Foundation
# Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.

find_package(SQLsrv)

if(SQLSRV_FOUND)
  mkclass_target(idosqlsrvconnection.ti idosqlsrvconnection.tcpp idosqlsrvconnection.thpp)

  set(db_ido_sqlsrv_SOURCES
    idosqlsrvconnection.cpp idosqlsrvconnection.thpp
  )

  if(ICINGA2_UNITY_BUILD)
      mkunity_target(db_ido_sqlsrv db_ido_sqlsrv_SOURCES)
  endif()

  add_library(db_ido_sqlsrv SHARED ${db_ido_sqlsrv_SOURCES})

  include_directories(${SQLSRV_INCLUDE_DIR})
  target_link_libraries(db_ido_sqlsrv ${Boost_LIBRARIES} ${SQLSRV_CLIENT_LIBS} base config icinga db_ido odbc32)

  set_target_properties (
    db_ido_sqlsrv PROPERTIES
    INSTALL_RPATH ${CMAKE_INSTALL_FULL_LIBDIR}/icinga2
    FOLDER Components
  )

  install_if_not_exists(
    ${PROJECT_SOURCE_DIR}/etc/icinga2/features-available/ido-sqlsrv.conf
    ${CMAKE_INSTALL_SYSCONFDIR}/icinga2/features-available
  )

  install(
    TARGETS db_ido_sqlsrv
    RUNTIME DESTINATION ${CMAKE_INSTALL_SBINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_FULL_LIBDIR}/icinga2
  )

  install(
    DIRECTORY schema
    DESTINATION ${CMAKE_INSTALL_DATADIR}/icinga2-ido-sqlsrv
    FILES_MATCHING PATTERN "*.sql"
  )

  install(
    DIRECTORY schema/upgrade
    DESTINATION ${CMAKE_INSTALL_DATADIR}/icinga2-ido-sqlsrv/schema
    FILES_MATCHING PATTERN "*.sql"
  )

  set(CPACK_NSIS_EXTRA_INSTALL_COMMANDS "${CPACK_NSIS_EXTRA_INSTALL_COMMANDS}" PARENT_SCOPE)
else()
  message(FATAL_ERROR "You have selected sqlsrv support, but sqlsrv could not be found. You can disable the sqlsrv IDO module using -DICINGA2_WITH_SQLSRV=OFF.")
endif()
