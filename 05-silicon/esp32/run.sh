#!/usr/bin/env bash
# Runs the steps of this README one by one. Press Enter to run each step.
# ./run.sh flashes the light alone, ./run.sh MainButton adds the BOOT button.
cd "$(dirname "$0")" || exit 1
main=${1:-Main}

step() {
    printf "\n\033[1m== %s\033[0m\n" "$1"
    shift
    printf "\$ %s\n" "$@"
    if [ -t 0 ]; then read -rp "[Enter] "; fi
    for cmd in "$@"; do eval "$cmd" || exit 1; done
}

step "One-time setup: ESP-IDF v5.5.1 and led_strip (skipped if ~/esp-template exists)" \
    '[ -d ~/esp-template ] || { git clone --recursive https://github.com/lf-lang/lf-esp-idf-uc-template ~/esp-template && ~/esp-template/esp-idf/install.sh esp32c6; }'
step "Generate the light into src/" \
    'sysmlc rosetta build ../model -e TrafficLight::TrafficLightBehavior --target uc --c ../lights/lights_esp32.c --c_h ../lights/lights.h -o src'
step "Build $main.ulf for the ESP32-C6" \
    '. ~/esp-template/esp-idf/export.sh' \
    "cmake -Bbuild -GNinja -DLF_MAIN=$main -DIDF_EXTRA_COMPONENTS_PATH=\$HOME/esp-template/idf-extra-components -DCMAKE_TOOLCHAIN_FILE=\$IDF_PATH/tools/cmake/toolchain-esp32c6.cmake" \
    'cmake --build build'
step "Flash the board" 'ninja -C build flash'
