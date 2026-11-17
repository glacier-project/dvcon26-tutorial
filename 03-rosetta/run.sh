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

step "Examples 1 and 2: dispatch and safety constraints" \
    'sysmlc rosetta build showcase/charging-station -o out' \
    'lfc out/chargingStationSystem.lf && ./bin/chargingStationSystem; echo "exit code: $?"'
step "Complex mappings: composite, parallel, join" \
    'sysmlc rosetta build showcase/milling-workcell -e MillingWorkcell::millingWorkcellSystem -o out' \
    'lfc out/millingWorkcellSystem.lf && ./bin/millingWorkcellSystem; echo "exit code: $?"'
step "Values at build time" \
    'sysmlc rosetta build showcase/thermostat -e Thermostat::ThermostatBehavior --values values.yaml -o out' \
    'lfc src/Thermostat.lf && ./bin/Thermostat'
step "Functions written outside the model: the Furuta pendulum" \
    'sysmlc rosetta build showcase/furuta-pendulum/deterministic --python furuta_physics.py -o out' \
    'lfc out/furutaSystem.lf && ./bin/furutaSystem; echo "exit code: $?"'
step "The Furuta pendulum, visualized" 'lfc src/FurutaViz.lf && ./bin/FurutaViz'
step "One model, several backends" \
    'sysmlc backends' \
    'sysmlc rosetta build sm-examples/sm01-helloworld -e SM01::Machine --target python -o out/python' \
    'sysmlc rosetta build sm-examples/sm01-helloworld -e SM01::Machine --target c -o out/c' \
    'sysmlc rosetta build sm-examples/sm01-helloworld -e SM01::Machine --target uc -o out/uc' \
    'ls out/python out/c out/uc'
