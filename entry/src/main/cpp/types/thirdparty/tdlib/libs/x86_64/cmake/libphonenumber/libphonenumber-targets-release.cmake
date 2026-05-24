#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "libphonenumber::phonenumber" for configuration "Release"
set_property(TARGET libphonenumber::phonenumber APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(libphonenumber::phonenumber PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "C;CXX"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libphonenumber.a"
  )

list(APPEND _cmake_import_check_targets libphonenumber::phonenumber )
list(APPEND _cmake_import_check_files_for_libphonenumber::phonenumber "${_IMPORT_PREFIX}/lib/libphonenumber.a" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
