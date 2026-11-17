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

step "Ex 0 — Smoke test" \
    'sysmlc rosetta build model -o out' \
    'lfc out/trafficLightSystem.lf' \
    './bin/trafficLightSystem; echo "exit code: $?"'
step "Ex 1 — Retime the lights (solutions/ex1)" \
    'sysmlc rosetta build solutions/ex1 -o out' \
    'lfc out/trafficLightSystem.lf' \
    './bin/trafficLightSystem; echo "exit code: $?"' \
    'grep "timer t_show" out/trafficLightSystem.lf'
step "Ex 2 — Add a state (solutions/ex2)" \
    'sysmlc rosetta build solutions/ex2 -o out' \
    'lfc out/trafficLightSystem.lf' \
    './bin/trafficLightSystem; echo "exit code: $?"' \
    'grep -A1 "mode redAmber" out/trafficLightSystem.lf'
step "Ex 3 — The constraint catches a bug (solutions/ex3-broken)" \
    'sysmlc rosetta build solutions/ex3-broken -o out' \
    'lfc out/trafficLightSystem.lf' \
    './bin/trafficLightSystem; echo "exit code: $?"'
step "Ex 3 — The fixed model passes (solutions/ex3)" \
    'sysmlc rosetta build solutions/ex3 -o out' \
    'lfc out/trafficLightSystem.lf' \
    './bin/trafficLightSystem; echo "exit code: $?"' \
    'grep -c requestedClearsOnRed out/trafficLightSystem.lf'
