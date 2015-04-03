project("inputstation")

set(ES_HEADERS
    ${CMAKE_CURRENT_SOURCE_DIR}/src/InputStation.h
    ${CMAKE_CURRENT_SOURCE_DIR}/src/components/TextListComponent.h

    # Animations
    ${CMAKE_CURRENT_SOURCE_DIR}/src/animations/LaunchAnimation.h
    ${CMAKE_CURRENT_SOURCE_DIR}/src/animations/MoveCameraAnimation.h
)

set(ES_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp
)

#-------------------------------------------------------------------------------
# define target
include_directories(${COMMON_INCLUDE_DIRS} ${CMAKE_CURRENT_SOURCE_DIR}/src)
add_executable(inputstation ${ES_SOURCES} ${ES_HEADERS})
target_link_libraries(inputstation ${COMMON_LIBRARIES} is-core)

#-------------------------------------------------------------------------------
# set up CPack install stuff so `make install` does something useful

install(TARGETS inputstation
    RUNTIME
    DESTINATION bin)

INCLUDE(InstallRequiredSystemLibraries)

SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "A front-end for creating game controller configuration files.")
SET(CPACK_PACKAGE_DESCRIPTION "InputStation is a graphical front-end designed for keyboardless configuration of game controller configuration files.")

SET(CPACK_RESOURCE_FILE LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE.md")
SET(CPACK_RESOURCE_FILE README "${CMAKE_CURRENT_SOURCE_DIR}/README.md")

SET(CPACK_DEBIAN_PACKAGE_MAINTAINER "Florian Müller <contact@petrockblock.com>")
SET(CPACK_DEBIAN_PACKAGE_SECTION "misc")
SET(CPACK_DEBIAN_PACKAGE_PRIORITY "extra")
SET(CPACK_DEBIAN_PACKAGE_DEPENDS "libc6, libsdl2-2.0-0, libboost-system1.54.0, libboost-filesystem1.54.0, libfreeimage3, libfreetype6, libcurl3, libasound2")
SET(CPACK_DEBIAN_PACKAGE_BUILDS_DEPENDS "debhelper (>= 8.0.0), cmake, g++ (>= 4.8), libsdl2-dev, libboost-system-dev, libboost-filesystem-dev, libboost-date-time-dev, libfreeimage-dev, libfreetype6-dev, libeigen3-dev, libcurl4-openssl-dev, libasound2-dev, libgl1-mesa-dev")

SET(CPACK_PACKAGE_VENDOR "petrockblock.com")
SET(CPACK_PACKAGE_VERSION "1.0.0")
SET(CPACK_PACKAGE_VERSION_MAJOR "1")
SET(CPACK_PACKAGE_VERSION_MINOR "0")
SET(CPACK_PACKAGE_VERSION_PATCH "0")
SET(CPACK_PACKAGE_INSTALL_DIRECTORY "inputstation_${CMAKE_PACKAGE_VERSION}")
SET(CPACK_PACKAGE_EXECUTABLES "inputstation" "inputstation")

SET(CPACK_GENERATOR "TGZ;DEB")

INCLUDE(CPack)
