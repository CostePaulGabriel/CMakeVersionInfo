# <img src="https://upload.wikimedia.org/wikipedia/commons/1/13/Cmake.svg" alt="CMake Logo" width="32" height="32"> CMakeVersionInfo

GenerateVersionInfo is a CMake product info file generator.
It comes with an minimal integration (single file module), 
easy to use function that generates and embeds the resource with informations in a 
shared library or application.

It was designed mostly for Windows, in order to generate a VERSIONINFO file,
on Unix it will embed only the SOVERSION and VERSION, and for now, the Info.plist 
generation on MACOS is work in progress.

[![CMake](https://img.shields.io/badge/CMake-3.5-red)](https://cmake.org/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## Table of Contents

- [Installation](#installation)
- [Examples](#examples)
- [License](#license)

## Installation

To use this module in your CMake project you would simply need to copy the GenerateVersionInfo.cmake file.
After that, you will need to tell CMake where to find this module, I recommend having a directory with all modules,
then tell CMake where your modules are.

You can point CMake to your modules with the 'set(CMAKE_MODULE_PATH "path_to_cmake_modules")' command.

Then you simply include it using 'include(GenerateVersionInfo.cmake)' and call the 'generate_version_info' function.

This repository contains a full example, which you can build using the msvc2022-build.bat.

## Examples

```cmake
# DLL Build.
generate_version_info(
    TARGETS VersionInfoDll           # -> Add your target. Note that you can also pass multiple targets on the same function call if the description is the same !
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

# Executable Build.
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
```

## License

Distributed under the MIT License. See [LICENSE](./LICENSE) for more information.
