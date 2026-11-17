#!/usr/bin/env bash
# Runs the steps of this README one by one. Press Enter to run each step.
cd "$(dirname "$0")" || exit 1

step() {
    printf "\n\033[1m== %s\033[0m\n" "$1"
    shift
    printf "\$ %s\n" "$@"
    if [ -t 0 ]; then read -rp "[Enter] "; fi
    for cmd in "$@"; do eval "$cmd" || exit 1; done
}

step "On this machine" \
    'sysmlc rosetta build model --target uc --c lights/lights_posix.c --c_h lights/lights.h -o out' \
    'cmake -S out -B out/build && cmake --build out/build' \
    'out/bin/trafficLightSystem; echo "exit code: $?"'
