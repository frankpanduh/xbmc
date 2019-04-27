# IOS/TVOS packaging
#if(CORE_PLATFORM_NAME_LC STREQUAL tvos)
  # TVOS packaging

  # asset catalog
#  set(ASSET_CATALOG "${CMAKE_SOURCE_DIR}/xbmc/platform/darwin/tvos/Assets.xcassets")
#  execute_process(COMMAND ${CMAKE_SOURCE_DIR}/tools/darwin/Support/GenerateMissingImages-tvos.py "${ASSET_CATALOG}")
#  target_sources(${APP_NAME_LC} PRIVATE "${ASSET_CATALOG}")
#  set_source_files_properties("${ASSET_CATALOG}" PROPERTIES MACOSX_PACKAGE_LOCATION "Resources") # adds to Copy Bundle Resources build phase
#  set_target_properties(${APP_NAME_LC} PROPERTIES XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_APPICON_NAME "Brand Assets"
#                                                  XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_LAUNCHIMAGE_NAME "LaunchImage")

#else()
  set(BUNDLE_RESOURCES ${CMAKE_SOURCE_DIR}/xbmc/platform/darwin/ios/LaunchImage-1100-Landscape-2436h@3x.png
                       ${CMAKE_SOURCE_DIR}/xbmc/platform/darwin/ios/LaunchImage-1100-Portrait-2436h@3x.png
                       ${CMAKE_SOURCE_DIR}/xbmc/platform/darwin/ios/LaunchImage-1200-Landscape-1792h@2x.png
                       ${CMAKE_SOURCE_DIR}/xbmc/platform/darwin/ios/LaunchImage-1200-Portrait-2224h@2x.png
                       ${CMAKE_SOURCE_DIR}/xbmc/platform/darwin/ios/LaunchImage-1200-Landscape-2224h@2x.png
                       ${CMAKE_SOURCE_DIR}/xbmc/platform/darwin/ios/LaunchImage-1200-Portrait-2388h@2x.png
                       ${CMAKE_SOURCE_DIR}/xbmc/platform/darwin/ios/LaunchImage-1200-Landscape-2388h@2x.png
                       ${CMAKE_SOURCE_DIR}/xbmc/platform/darwin/ios/LaunchImage-1200-Landscape-2688h@3x.png
                       ${CMAKE_SOURCE_DIR}/xbmc/platform/darwin/ios/LaunchImage-1200-Portrait-1792h@2x.png
                       ${CMAKE_SOURCE_DIR}/xbmc/platform/darwin/ios/LaunchImage-1200-Portrait-2688h@3x.png
                       ${CMAKE_SOURCE_DIR}/xbmc/platform/darwin/ios/LaunchImage-568h@2x.png
                       ${CMAKE_SOURCE_DIR}/xbmc/platform/darwin/ios/LaunchImage-700-568h@2x.png
                       ${CMAKE_SOURCE_DIR}/xbmc/platform/darwin/ios/LaunchImage-700-Landscape@2x~ipad.png
                       ${CMAKE_SOURCE_DIR}/xbmc/platform/darwin/ios/LaunchImage-700-Portrait@2x~ipad.png
                       ${CMAKE_SOURCE_DIR}/xbmc/platform/darwin/ios/LaunchImage-700@2x.png
                       ${CMAKE_SOURCE_DIR}/xbmc/platform/darwin/ios/LaunchImage-800-667h@2x.png
                       ${CMAKE_SOURCE_DIR}/xbmc/platform/darwin/ios/LaunchImage-800-Landscape-736h@3x.png
                       ${CMAKE_SOURCE_DIR}/xbmc/platform/darwin/ios/LaunchImage-800-Portrait-736h@3x.png
                       ${CMAKE_SOURCE_DIR}/xbmc/platform/darwin/ios/LaunchImage-Landscape@2x~ipad.png
                       ${CMAKE_SOURCE_DIR}/xbmc/platform/darwin/ios/LaunchImage-Portrait@2x~ipad.png
                       ${CMAKE_SOURCE_DIR}/xbmc/platform/darwin/ios/LaunchImage@2x.png
                       ${CMAKE_SOURCE_DIR}/tools/darwin/packaging/media/ios/rounded/AppIcon29x29.png
                       ${CMAKE_SOURCE_DIR}/tools/darwin/packaging/media/ios/rounded/AppIcon29x29@2x.png
                       ${CMAKE_SOURCE_DIR}/tools/darwin/packaging/media/ios/rounded/AppIcon40x40.png
                       ${CMAKE_SOURCE_DIR}/tools/darwin/packaging/media/ios/rounded/AppIcon40x40@2x.png
                       ${CMAKE_SOURCE_DIR}/tools/darwin/packaging/media/ios/rounded/AppIcon50x50.png
                       ${CMAKE_SOURCE_DIR}/tools/darwin/packaging/media/ios/rounded/AppIcon50x50@2x.png
                       ${CMAKE_SOURCE_DIR}/tools/darwin/packaging/media/ios/rounded/AppIcon57x57.png
                       ${CMAKE_SOURCE_DIR}/tools/darwin/packaging/media/ios/rounded/AppIcon57x57@2x.png
                       ${CMAKE_SOURCE_DIR}/tools/darwin/packaging/media/ios/rounded/AppIcon60x60.png
                       ${CMAKE_SOURCE_DIR}/tools/darwin/packaging/media/ios/rounded/AppIcon60x60@2x.png
                       ${CMAKE_SOURCE_DIR}/tools/darwin/packaging/media/ios/rounded/AppIcon72x72.png
                       ${CMAKE_SOURCE_DIR}/tools/darwin/packaging/media/ios/rounded/AppIcon72x72@2x.png
                       ${CMAKE_SOURCE_DIR}/tools/darwin/packaging/media/ios/rounded/AppIcon76x76.png
                       ${CMAKE_SOURCE_DIR}/tools/darwin/packaging/media/ios/rounded/AppIcon76x76@2x.png)

  target_sources(${APP_NAME_LC} PRIVATE ${BUNDLE_RESOURCES})
  foreach(file IN LISTS BUNDLE_RESOURCES)
    set_source_files_properties(${file} PROPERTIES MACOSX_PACKAGE_LOCATION .)
  endforeach()

  target_sources(${APP_NAME_LC} PRIVATE ${CMAKE_SOURCE_DIR}/xbmc/platform/darwin/ios-common/English.lproj/InfoPlist.strings)
  set_source_files_properties(${CMAKE_SOURCE_DIR}/xbmc/platform/darwin/ios-common/English.lproj/InfoPlist.strings PROPERTIES MACOSX_PACKAGE_LOCATION "./English.lproj")

#endif()


# Options for code signing propagated as env vars to Codesign.command via Xcode
set(CODE_SIGN_IDENTITY "" CACHE STRING "Code Sign Identity")
if(CODE_SIGN_IDENTITY)
  set_target_properties(${APP_NAME_LC} PROPERTIES XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED TRUE
                                                  XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY ${CODE_SIGN_IDENTITY})
endif()

add_custom_command(TARGET ${APP_NAME_LC} POST_BUILD
    # TODO: Remove in sync with CopyRootFiles-ios expecting the ".bin" file
    COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:${APP_NAME_LC}>
                                     $<TARGET_FILE_DIR:${APP_NAME_LC}>/${APP_NAME}.bin

    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/${CORE_BUILD_DIR}/DllPaths_generated.h
                                     ${CMAKE_BINARY_DIR}/xbmc/DllPaths_generated.h
    COMMAND "ACTION=build"
            "TARGET_BUILD_DIR=$<TARGET_FILE_DIR:${APP_NAME_LC}>/.."
            "TARGET_NAME=${APP_NAME}.app"
            "APP_NAME=${APP_NAME}"
            "PRODUCT_NAME=${APP_NAME}"
            "WRAPPER_EXTENSION=app"
            "SRCROOT=${CMAKE_BINARY_DIR}"
            ${CMAKE_SOURCE_DIR}/tools/darwin/Support/CopyRootFiles-ios.command
    COMMAND "XBMC_DEPENDS=${DEPENDS_PATH}"
            "TARGET_BUILD_DIR=$<TARGET_FILE_DIR:${APP_NAME_LC}>/.."
            "TARGET_NAME=${APP_NAME}.app"
            "APP_NAME=${APP_NAME}"
            "PRODUCT_NAME=${APP_NAME}"
            "FULL_PRODUCT_NAME=${APP_NAME}.app"
            "WRAPPER_EXTENSION=app"
            "SRCROOT=${CMAKE_BINARY_DIR}"
            ${CMAKE_SOURCE_DIR}/tools/darwin/Support/copyframeworks-ios.command
    COMMAND "XBMC_DEPENDS=${DEPENDS_PATH}"
            "NATIVEPREFIX=${NATIVEPREFIX}"
            "PLATFORM_NAME=${PLATFORM}"
            "CODESIGNING_FOLDER_PATH=$<TARGET_FILE_DIR:${APP_NAME_LC}>"
            "BUILT_PRODUCTS_DIR=$<TARGET_FILE_DIR:${APP_NAME_LC}>/.."
            "WRAPPER_NAME=${APP_NAME}.app"
            "APP_NAME=${APP_NAME}"
            "CURRENT_ARCH=${ARCH}"
            ${CMAKE_SOURCE_DIR}/tools/darwin/Support/Codesign.command
)

set(DEPENDS_ROOT_FOR_XCODE ${NATIVEPREFIX}/..)
configure_file(${CMAKE_SOURCE_DIR}/tools/darwin/packaging/ios/mkdeb.sh.in
               ${CMAKE_BINARY_DIR}/tools/darwin/packaging/ios/mkdeb.sh @ONLY)
configure_file(${CMAKE_SOURCE_DIR}/tools/darwin/packaging/ios/migrate_to_kodi.sh.in
               ${CMAKE_BINARY_DIR}/tools/darwin/packaging/ios/migrate_to_kodi.sh @ONLY)

add_custom_target(deb
    COMMAND sh ./mkdeb.sh ${CORE_BUILD_CONFIG}
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/tools/darwin/packaging/ios)
add_dependencies(deb ${APP_NAME_LC})
