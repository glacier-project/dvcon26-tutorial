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

step "The Machine Data Model and control-flow graphs" 'lfc src/ConveyorCfg.lf && ./bin/ConveyorCfg'
step "A machine and a client" 'lfc src/QualityCheck.lf && ./bin/QualityCheck'
step "An FMU in Frost" 'lfc src/BouncingBall.lf && ./bin/BouncingBall'
step "Co-simulation: two FMUs, one clock" 'lfc src/CoSimulation.lf && ./bin/CoSimulation'
