# ESP-IDF firmware for the traffic light that Rosetta generates.
# Based on the CMakeLists.txt of https://github.com/lf-lang/lf-esp-idf-uc-template,
# plus the micromode setup that modal reactors need.
# Rosetta writes the program to src/ and Main.ulf runs it on ESP-IDF.
# The commands are in PRESENTERS.md.
cmake_minimum_required(VERSION 3.20.0)

include($ENV{IDF_PATH}/tools/cmake/idf.cmake)
project(dvcon-traffic-light-esp32)
set(PLATFORM "ESP_IDF" CACHE STRING "Platform to target")

if(NOT DEFINED ESP_IDF_BOARD)
  set(ESP_IDF_BOARD "esp32c6")
endif()
if(NOT DEFINED LF_MAIN)
  set(LF_MAIN "Main")
endif()
if(NOT DEFINED LOG_LEVEL)
  set(LOG_LEVEL "LF_LOG_LEVEL_WARN")   # read by ulfc.cmake
endif()

set(IDF_COMPONENTS "freertos" "esptool_py" "driver" "led_strip")
# led_strip drives the board's RGB LED. It comes from idf-extra-components.
if(NOT DEFINED IDF_EXTRA_COMPONENTS_PATH)
  set(IDF_EXTRA_COMPONENTS_PATH "${CMAKE_CURRENT_LIST_DIR}/idf-extra-components")
endif()
idf_build_component(${IDF_EXTRA_COMPONENTS_PATH}/led_strip)
idf_build_process(
  ${ESP_IDF_BOARD}
  COMPONENTS ${IDF_COMPONENTS}
  SDKCONFIG ${CMAKE_BINARY_DIR}/sdkconfig
  SDKCONFIG_DEFAULTS ${CMAKE_CURRENT_LIST_DIR}/sdkconfig.defaults
  BUILD_DIR ${CMAKE_BINARY_DIR})

add_executable(${LF_MAIN})

include($ENV{REACTOR_UC_PATH}/cmake/ulfc.cmake)
lf_setup()
lf_run_lfc(OUTPUT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/ FILES ${LF_MAIN}.ulf)
lf_build_generated_code(${LF_MAIN} ${CMAKE_CURRENT_SOURCE_DIR}/src-gen/${LF_MAIN})

# Modal reactors need micromode, as in the generated native CMakeLists.txt.
include(${CMAKE_CURRENT_SOURCE_DIR}/src-gen/${LF_MAIN}/Include.cmake)
add_subdirectory(${MICROMODE_PATH} micromode)
target_link_libraries(${LF_MAIN} PRIVATE micromode::micromode)
target_compile_definitions(reactor-uc PUBLIC
  LF_RUNTIME_EXTENSIONS=1
  LF_EXTENSION_CONFIG_HEADER="${CMAKE_CURRENT_SOURCE_DIR}/src-gen/${LF_MAIN}/lf_extensions.h")

# setLights() for this board, the C side of calc def Board::setLights.
target_sources(${LF_MAIN} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src/lights_esp32.c)
target_include_directories(${LF_MAIN} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src)

# ESP-IDF headers trigger -Wunused-parameter, so turn it off.
target_compile_options(${LF_MAIN} PRIVATE -Wno-unused-parameter)
target_compile_options(reactor-uc PRIVATE -Wno-unused-parameter)
target_compile_options(micromode PRIVATE -Wno-unused-parameter)

target_link_libraries(${LF_MAIN} PRIVATE reactor-uc idf::led_strip idf::driver)
idf_build_executable(${LF_MAIN})
