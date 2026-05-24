#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "Td::tdjson" for configuration "Release"
set_property(TARGET Td::tdjson APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(Td::tdjson PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libtdjson.so.1.8.60"
  IMPORTED_SONAME_RELEASE "libtdjson.so.1.8.60"
  )

list(APPEND _cmake_import_check_targets Td::tdjson )
list(APPEND _cmake_import_check_files_for_Td::tdjson "${_IMPORT_PREFIX}/lib/libtdjson.so.1.8.60" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
