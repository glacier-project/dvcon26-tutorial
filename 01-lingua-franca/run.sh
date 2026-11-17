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

step "What is a Reactor?" 'lfc src/Blink.lf && ./bin/Blink'
step "A Complete LF Program" 'lfc src/Machines.lf && ./bin/Machines'
step "Logical vs. Physical Time" 'lfc src/Tags.lf && ./bin/Tags'
step "Deterministic Concurrency" 'lfc src/Priority.lf && for i in 1 2 3 4 5; do ./bin/Priority; done'
step "Modal Reactors" 'lfc src/Crossing.lf && ./bin/Crossing'
step "Reset vs. History" 'lfc src/ResetVsHistory.lf && ./bin/ResetVsHistory'
step "Timers, logical actions, deadlines" 'lfc src/Timing.lf && ./bin/Timing'
