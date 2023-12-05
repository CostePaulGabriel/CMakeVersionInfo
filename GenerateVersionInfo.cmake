# Distributed under the MIT License.
# Copyright (c) 2023 PaulCG.

#[=======================================================================[.rst:
GenerateVersionInfo
----------

GenerateVersionInfo, comes with an minimal integration (single file module), 
easy to use function that generates and embeds a resource with informations in a 
shared library or an application.

It was designed mostly for Windows, in order to generate a VERSIONINFO file,
on Unix it will embed only the SOVERSION and VERSION, and for now, the Info.plist 
generation on MACOS is not written.

----------
The module comes along with these arguments:

TARGETS
^^^^^^^^^^^^^^^^

This function can accept multiple targets, and it`s recommended to
pass them when the description is the same for all products.

A basic example could be TARGETS MySharedLibrary MyApplicationExe.

ARGUMENTS FOR DESCRIPTIONS
^^^^^^^^^^^^^^^^

These arguments should be straightforward.

COMPANY              -> Add the company name.
DEVELOPER            -> Add the developer name.
DESCRIPTION          -> Add a description, like this one !
COPYRIGHT            -> Your custom copyright description, If not provided it uses a default copyright message.
LEGALTRADEMARKS1     -> Provide the first trademark, if not it will use a default message.
LEGALTRADEMARKS2     -> Provide a second trademark, if not it will use a default message.
LANGUAGE             -> Provide a language for your library, the default one is "U.S. English". Note, if you need other language name see the languages supported by Microsoft VERSIONINFO.
COMMENT              -> Maybe add some comments.
ADDITIONAL_INFO      -> Add additional info to the library.


ICON
^^^^^^^^^^^^^^^^

Provide an image path. The image is embedded only on executables, libraries will ignore it !
Before you pass an icon file, make sure that the icon is correctly formatted and the path 
is right, otherwise the RC compiler won't be happy !

DESTINATION
^^^^^^^^^^^^^^^^

Where to put the generated resource file, if not provided it's in the ${CMAKE_CURRENT_BINARY_DIR} !


COMPATIBILITY
^^^^^^^^^^^^^^^^

  This works on Windows with both GCC and MSVC and GCC on Linux.
  The MACOS Info.plist generation is work in progress.

#]=======================================================================]

cmake_minimum_required(VERSION 3.5)

function(generate_version_info)

    set(options)
    set(multiValueArgs TARGETS)
    set(singleValueArgs
        COMPANY
        DEVELOPER
        DESCRIPTION
        COPYRIGHT
        LEGALTRADEMARKS1
        LEGALTRADEMARKS2
        LANGUAGE
        COMMENT
        ADDITIONAL_INFO
        ICON
        DESTINATION
    )
    cmake_parse_arguments(VERSIONINFO "${options}" "${singleValueArgs}" "${multiValueArgs}" ${ARGN})

    # Check if targets are valid and generate the info.
    foreach(VERSIONINFO_TARGET IN LISTS VERSIONINFO_TARGETS)
        if(NOT TARGET ${VERSIONINFO_TARGET})
            message(FATAL_ERROR "Target \"${VERSIONINFO_TARGET}\" not found.\n"
                                "At least one target must be specified !\n" 
                                "Make sure that you call this function after creating the TARGETS !")
            return()
        endif()

        get_target_property(TARGET_NAME ${VERSIONINFO_TARGET} NAME)
        get_target_property(TARGET_VERSION ${VERSIONINFO_TARGET} VERSION)
        get_target_property(TARGET_VERSION_MAJOR ${VERSIONINFO_TARGET} VERSION_MAJOR)
        get_target_property(TARGET_TYPE ${VERSIONINFO_TARGET} TYPE)
        get_target_property(TARGET_LANGUEGE ${VERSIONINFO_TARGET} LANGUAGE)

        # Timestamp
        string(TIMESTAMP VERSIONINFO_TIMESTAMP "%Y-%m-%d %H:%M:%S")
        string(SUBSTRING "${VERSIONINFO_TIMESTAMP}" 0 4 RC_BUILD_YEAR)

        set(VERSIONINFO_PRODUCT_NAME ${TARGET_NAME})

        if(TARGET_VERSION STREQUAL "TARGET_VERSION-NOTFOUND")
            set(VERSIONINFO_PRODUCT_VERSION "1.0.0")
            message(WARNING "The version must be specified for '${VERSIONINFO_TARGET}' target before calling this function. You may use 'set_target_properties(<TARGET_NAME> PROPERTIES VERSION \"<VERSION_MAJOR.VERSION_MINOR.VERSION_PATCH.VERSION_BUILD>\")'.")
        else()
            set(VERSIONINFO_PRODUCT_VERSION ${TARGET_VERSION})
        endif()

        if(TARGET_TYPE STREQUAL "SHARED_LIBRARY")
            set(VERSIONINFO_FILETYPE "VFT_DLL")
        elseif(TARGET_TYPE STREQUAL "EXECUTABLE")
            set(VERSIONINFO_FILETYPE "VFT_APP")
        elseif(TARGET_TYPE STREQUAL "STATIC_LIBRARY")
            set(VERSIONINFO_FILETYPE "VFT_STATIC_LIB")
        else() 
            set(VERSIONINFO_FILETYPE "VFT_UNKNOWN")
            # message(STATUS "TARGET_TYPE=${TARGET_TYPE}") # MODULE_LIBRARY or OBJECT_LIBRARY or OBJECT_INTERFACE
        endif()

        if(NOT VERSIONINFO_COMPANY)
            set(VERSIONINFO_COMPANY "")
            message(FATAL_ERROR "COMPANY must be specified. Call function with the COMPANY attribute !")
        else()
            set(VERSIONINFO_COMPANY ${VERSIONINFO_COMPANY})
        endif()

        if(NOT VERSIONINFO_DEVELOPER)
            set(VERSIONINFO_DEVELOPER "")
            message(WARNING "DEVELOPER was not specified.")
        else()
            set(VERSIONINFO_DEVELOPER ${VERSIONINFO_DEVELOPER})
        endif()

        # Windows versioninfo
        if(WIN32)
            if(NOT VERSIONINFO_DESCRIPTION)
                set(VERSIONINFO_DESCRIPTION "")
            else()
                set(VERSIONINFO_DESCRIPTION ${VERSIONINFO_DESCRIPTION})
            endif()

            if(NOT VERSIONINFO_COPYRIGHT)
                set(VERSIONINFO_COPYRIGHT "Copyright © ${VERSIONINFO_COMPANY} ${RC_BUILD_YEAR}.")
            else()
                set(VERSIONINFO_COPYRIGHT ${VERSIONINFO_COPYRIGHT})
            endif()

            if(NOT VERSIONINFO_LEGALTRADEMARKS1)
                set(VERSIONINFO_LEGALTRADEMARKS1 "All rights reserved.")
            else()
                set(VERSIONINFO_LEGALTRADEMARKS1 ${VERSIONINFO_LEGALTRADEMARKS1})
            endif()

            if(NOT VERSIONINFO_LEGALTRADEMARKS2)
                set(VERSIONINFO_LEGALTRADEMARKS2 "Developed by ${VERSIONINFO_DEVELOPER}.")
            else()
                set(VERSIONINFO_LEGALTRADEMARKS2 ${VERSIONINFO_LEGALTRADEMARKS2})
            endif()

            if(NOT VERSIONINFO_LANGUAGE)
                set(VERSIONINFO_LANGUAGE "U.S. English")
            else()
                set(VERSIONINFO_LANGUAGE ${VERSIONINFO_LANGUAGE})
            endif()

            if(NOT VERSIONINFO_COMMENT)
                set(VERSIONINFO_COMMENT "")
            else()
                set(VERSIONINFO_COMMENT ${VERSIONINFO_COMMENT})
            endif()

            if(NOT VERSIONINFO_ADDITIONAL_INFO)
                set(VERSIONINFO_ADDITIONAL_INFO "")
            else()
                set(VERSIONINFO_ADDITIONAL_INFO ${VERSIONINFO_ADDITIONAL_INFO})
            endif()
                    
            if(NOT VERSIONINFO_ICON OR NOT EXISTS ${VERSIONINFO_ICON})
                set(GENERATE_VERSIONINFO_ICON_CODE "")
            else()
                # Embed the image if the path is valid
                set(GENERATE_VERSIONINFO_ICON_CODE "IDI_ICON1 ICON \"${VERSIONINFO_ICON}\"  // Actual path to your icon file.\n")
                # message(${VERSIONINFO_ICON})
            endif()

            set(VERSIONINFO_FILENAME "${VERSIONINFO_TARGET}.rc")
            if(NOT VERSIONINFO_DESTINATION)
                set(VERSIONINFO_DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
            else()
                set(VERSIONINFO_DESTINATION ${VERSIONINFO_DESTINATION})
            endif()
            
            # Format the file versions
            string(REPLACE "." "," VERSIONINFO_FILEVERSION "${VERSIONINFO_PRODUCT_VERSION}")

            # Get VERSIONINFO charset and langid               
            get_versioninfo_langid_charset(
                LANGUAGE ${VERSIONINFO_LANGUAGE}
                CHARSET VERSIONINFO_CHARSET 
                LANGID VERSIONINFO_LANGID
            )

            # Generate
            set(RC_VERSIONINFO_FILE_SOURCE
            "// Made by ${VERSIONINFO_DEVELOPER} on ${VERSIONINFO_TIMESTAMP} using ${CMAKE_CXX_COMPILER_ID}. \n"
            "#if defined(__MINGW64__) || defined(__MINGW32__)\n"
	        "#  if defined(__has_include) && __has_include(<winres.h>)\n"
	        "#      include <winres.h>\n"
	        "#  else\n"
	        "#      include <afxres.h>\n"
	        "#      include <winresrc.h>\n"
	        "#  endif\n"
            "#else\n"
	        "#  include <winres.h>\n"
            "#endif\n"
            "\n"
            ${GENERATE_VERSIONINFO_ICON_CODE}
            "\n"
            "VS_VERSION_INFO VERSIONINFO\n"
            "FILEFLAGSMASK 0x17L\n"
            "#ifdef _DEBUG\n"
            "   FILEFLAGS 0x1L\n"
            "#else\n"
            "   FILEFLAGS 0x0L\n"
            "#endif\n"
            "FILEOS 0x4L\n"
            "FILETYPE ${VERSIONINFO_FILETYPE}\n"
            "FILESUBTYPE 0x0L\n"
            "FILEVERSION ${VERSIONINFO_FILEVERSION}\n"
            "PRODUCTVERSION ${VERSIONINFO_FILEVERSION}\n"
            "BEGIN\n"
            "   BLOCK \"StringFileInfo\"\n"
            "   BEGIN\n"
            "       BLOCK \"${VERSIONINFO_LANGID}\"  // Language code ${VERSIONINFO_LANGUAGE}.\n"
            "       BEGIN\n"
            "           VALUE \"ProductName\", \"${VERSIONINFO_PRODUCT_NAME}\"\n"
            "           VALUE \"CompanyName\", \"${VERSIONINFO_COMPANY}\"\n"
            "           VALUE \"FileDescription\", \"${VERSIONINFO_DESCRIPTION}\"\n"
            "           VALUE \"FileVersion\", \"${VERSIONINFO_PRODUCT_VERSION}\"\n"
            "           VALUE \"ProductVersion\", \"${VERSIONINFO_PRODUCT_VERSION}\"\n"
            "           VALUE \"OriginalFilename\", \"${VERSIONINFO_TARGET}\"\n"
            "           VALUE \"LegalCopyright\", \"${VERSIONINFO_COPYRIGHT}\"\n"
            "           VALUE \"LegalTrademarks1\", \"${VERSIONINFO_LEGALTRADEMARKS1}\"\n"
            "           VALUE \"LegalTrademarks2\", \"${VERSIONINFO_LEGALTRADEMARKS2}\"\n"
            "           VALUE \"PrivateBuild\", \"Developed using ${CMAKE_CXX_COMPILER_ID} on ${VERSIONINFO_TIMESTAMP}.\"\n"
            "           VALUE \"Comments\", \"${VERSIONINFO_COMMENT}\"\n"
            "           VALUE \"AdditionalInfo\", \"${VERSIONINFO_ADDITIONAL_INFO}\"\n"
            "       END\n"
            "   END\n"
            "   BLOCK \"VarFileInfo\"\n"
            "   BEGIN\n"
            "       /* The following line should only be modified for localized versions.      */\n"
            "       /* It consists of any number of WORD,WORD pairs, with each pair            */\n"
            "       /* describing a language,codepage combination supported by the file.       */\n"
            "       /*                                                                         */\n"
            "       /* For example, a file might have values \"0x409,1252\" indicating that it   */\n"
            "       /* supports English language (0x409) in the Windows ANSI codepage (1252).  */\n\n"
            "       VALUE \"Translation\", ${VERSIONINFO_CHARSET} // Language code and character set for ${VERSIONINFO_LANGUAGE}.\n"
            "   END\n"
            "END\n")

            # message(STATUS "${RC_VERSIONINFO_FILE_SOURCE}")

            file(WRITE ${VERSIONINFO_DESTINATION}/${VERSIONINFO_FILENAME} ${RC_VERSIONINFO_FILE_SOURCE})

            set(VERSIONINFO_FILENAME "${VERSIONINFO_TARGET}.rc")

            if(NOT VERSIONINFO_DESTINATION)
                set(VERSIONINFO_DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
            else()
                set(VERSIONINFO_DESTINATION ${VERSIONINFO_DESTINATION})
            endif()

            # Tell the compiler that this file is generated.
            set_source_files_properties(${VERSIONINFO_DESTINATION}/${VERSIONINFO_FILENAME} PROPERTIES GENERATED TRUE)

            target_sources(${VERSIONINFO_TARGET} PRIVATE ${VERSIONINFO_DESTINATION}/${VERSIONINFO_FILENAME})

            set_target_properties(${VERSIONINFO_TARGET}
               PROPERTIES
                   DEBUG_POSTFIX d
            )
        endif()

        # Linux version
        if(UNIX AND NOT APPLE)
             set_target_properties(${VERSIONINFO_TARGET} 
                PROPERTIES
                    VERSION ${TARGET_VERSION}
                    SOVERSION ${TARGET_VERSION_MAJOR}
            )
        endif()

        # MACOS Info.plist
        if(APPLE)
            set_target_properties(${VERSIONINFO_TARGET} 
                PROPERTIES
                    FRAMEWORK TRUE
                    FRAMEWORK_VERSION ${TARGET_LANGUEGE}
                    MACOSX_FRAMEWORK_IDENTIFIER com.cmake.${VERSIONINFO_TARGET}
                    MACOSX_FRAMEWORK_INFO_PLIST Info.plist 
                    VERSION ${TARGET_VERSION}
                    SOVERSION ${TARGET_VERSION_MAJOR}
                    XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY ${VERSIONINFO_DEVELOPER}
            )
        endif()
    endforeach()
endfunction()


# English U.S is set by default.
function(get_versioninfo_langid_charset)

    set(options)
    set(oneValueArgs LANGUAGE)
    set(multiValueArgs CHARSET LANGID)
    
    cmake_parse_arguments(VSINFO "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # LangName:LangCode:LangCharset
    set(MS_VERSIONINFO_LANG_MAP
        "Arabic:040104E8:0x0401,1256"
        "Polish:041504E4:0x0415,1252"
        "Bulgarian:040204E4:0x0402,1252"
        "Portuguese (Brazil):041604E4:0x0416,1252"
        "Catalan:040304E4:0x0403,1252"
        "Rhaeto-Romanic:041704E4:0x0417,1252"
        "Traditional Chinese:040403B6:0x0404,950"
        "Romanian:041804E2:0x0418,1250"
        "Czech:040504E2:0x0405,1250"
        "Russian:041904E3:0x0419,1251"
        "Danish:040604E4:0x0406,1252"
        "Croato-Serbian (Latin):041A:0x041A"
        "German:040704E4:0x0407,1252"
        "Slovak:041B04E2:0x041B,1250"
        "Greek:040804E3:0x0408,1251"
        "Albanian:041C04E4:0x041C,1252"
        "U.S. English:040904E4:0x409,1252"
        "Swedish:041D04E4:0x041D,1252"
        "Castilian Spanish:040A04E4:0x040A,1252"
        "Thai:041E:0x041E"
        "Finnish:040B04E4:0x040B,1252"
        "Turkish:041F04E6:0x041F,1254"
        "French:040C04E4:0x040C,1252"
        "Urdu:0420:0x0420"
        "Hebrew:040D04E7:0x040D,1255"
        "Bahasa:042104E4:0x0421,1252"
        "Hungarian:040E04E2:0x040E,1250"
        "Simplified Chinese:080403B6:0x0804,950"
        "Icelandic:040F04E4:0x040F,1252"
        "Swiss German:080704E4:0x0807,1252"
        "Italian:041004E4:0x0410,1252"
        "U.K. English:080904E4:0x0809,1252"
        "Japanese:041103A4:0x0411,932"
        "Spanish:080A04E4:0x080A,1252"
        "Korean:041203B5:0x0412,949"
        "Belgian French:080C04E4:0x080C,1252"
        "Dutch:041304E4:0x0413,1252"
        "Canadian French:0C0C04E4:0x0C0C,1252"
        "Norwegian:041404E4:0x0414,1252"
        "Swiss French:0C0C04E4:0x0C0C,1252"
        "Swiss Italian:0810:0x0810"
        "Portuguese (Portugal):081604E4:0x0816,1252"
        "Belgian Dutch:081304E4:0x0813,1252"
        "Serbo-Croatian (Cyrillic):081A:0x081A"
        "Norwegian:0x0414:041404E4,1252"
    )

    set(PATTERN "([^:]+):([^:]+):(.+)")

    foreach(_LANG ${MS_VERSIONINFO_LANG_MAP})
        string(REGEX MATCH "${PATTERN}" MATCH_GROUPS "${_LANG}")

        if(MATCH_GROUPS AND "${CMAKE_MATCH_1}" STREQUAL "${VSINFO_LANGUAGE}")
            set(${VSINFO_LANGID} ${CMAKE_MATCH_2} PARENT_SCOPE)
            set(${VSINFO_CHARSET} ${CMAKE_MATCH_3} PARENT_SCOPE)
            break()
        endif()
    endforeach()

    if(NOT VSINFO_LANGUAGE)
        message(WARNING "Cannot find the language specified. Please see the Microsoft supported languages for VERSIONINFO.")
    endif()

endfunction()
