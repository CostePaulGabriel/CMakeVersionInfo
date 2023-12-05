cmake_minimum_required (VERSION 3.8)

project(CMakeVersionInfo VERSION "1.0.0" DESCRIPTION "Crossplatform CMake Product Info Generator." LANGUAGES CXX)

# Project CMake module.
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR})

# CMake dependencies.
include(GNUInstallDirs)
include(GenerateVersionInfo.cmake)

# Compiler options.
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# CMake options.
set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_BUILD_TYPE Release)

# Add source to this project's executable and libraries.
add_executable(VersionInfoExe     "CMakeVersionInfo.cpp" "CMakeVersionInfo.h")
add_library(VersionInfoDll SHARED "CMakeVersionInfo.cpp" "CMakeVersionInfo.h")
add_library(VersionInfoLib STATIC "CMakeVersionInfo.cpp" "CMakeVersionInfo.h")

# Use case examples -> Windows DLL
generate_version_info(
    TARGETS VersionInfoDll           # -> Add your target. Note, that you can also pass multiple targets on the same function call if the description is similar.
    DEVELOPER "Developer"            # -> Add the developer name.
    COMPANY "MyCompany"              # -> Add the company name.
    DESCRIPTION "Best library ever!" # -> Add a description, like this one !
	# COPYRIGHT                      # -> Your custom copyright description, If not provided it uses a default copyright message.
    # LEGALTRADEMARKS1               # -> Provide the first trademark, if not use a default message.
    # LEGALTRADEMARKS2               # -> Provide a second trademark, if not use a default message.
    # LANGUAGE                       # -> Provide a language for your library, the default one is "U.S. English". Note, if you need other language name see the languages supported by Microsoft VERSIONINFO. 
    # COMMENT                        # -> Maybe add some comments.
    # ADDITIONAL_INFO                # -> Add additional info to the library.
	# ICON                           # -> Provide an image path. The image is embedded only on executables, libraries will ignore it !
    # DESTINATION                    # -> Where to put the generated resource file, if not provided it's in the ${CMAKE_CURRENT_BINARY_DIR} ! 
)

# Another use case examples -> Windows Executable.
generate_version_info(
    TARGETS VersionInfoExe
    DEVELOPER "Developer"
    COMPANY "MyCompany"
    DESCRIPTION "Best exe ever!"
    # COPYRIGHT       
    # LEGALTRADEMARKS1
    # LEGALTRADEMARKS2
    # LANGUAGE        
    # COMMENT         
    # ADDITIONAL_INFO 
    ICON "${CMAKE_CURRENT_SOURCE_DIR}/test.ico" # -> Before you pass an icon file, check that the icon is correctly formatted and the path is right, otherwise the RC compiler won't be happy !
    # DESTINATION     
)