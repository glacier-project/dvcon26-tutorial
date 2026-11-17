#!/usr/bin/env bash
# Runs every folder's run.sh and checks the output its README shows.
# Usage: bash tests/run_all.sh
cd "$(dirname "$0")/.." || exit 1
failed=0

# run <folder>: runs <folder>/run.sh and keeps its output
run() {
    echo "== $1"
    out="$(bash "$1/run.sh" 2>&1 </dev/null)" || { echo "FAIL  $1/run.sh stopped"; tail -15 <<<"$out"; failed=1; }
}

# expect <regex> [<count>]: the output has the line, or has it <count> times
expect() {
    local n
    n="$(grep -cE -- "$1" <<<"$out")"
    if [ "$n" -ge 1 ] && { [ -z "$2" ] || [ "$n" = "$2" ]; }; then
        echo "ok    $1"
    else
        echo "FAIL  $1 (found $n times)"
        failed=1
    fi
}

run 01-lingua-franca
expect '\[ 0.50 s\] led = False'
expect 'acked at 2000000000 ns'
expect 'tag=\(2000000000, 1\)'
expect 'final x = 6142' 5
expect '\[ 7.00 s\] light -> showRed'
expect '\[ 4.50 s\] history: tick'
expect 'deadline missed'

run 02-frost
expect 'moveAndCheck -> True'
expect 'checks=3 failures=1'
expect '\[ 0.46 s\] bounce #1'
expect 'in sync: yes'

run 03-rosetta
expect 'entered ChargingStation.authRetry'
expect 'exited MillingWorkcell.machining'
expect '\[15.00 s\] thermostat: heating'
expect 'Balanced!'
expect 'wrote out/furuta.png'
expect 'MachineMain.ulf'
expect 'exit code: 0' 3

run 04-hands-on
expect '\[10.00 s\] exited TrafficLightTester.watchRed'
expect 'timer t_showGreen\(4 sec\)'
expect 'entered TrafficLight.redAmber'
expect 'SysML constraint violated: .*requestedClearsOnRed'
expect 'exit code: 0' 4
expect 'exit code: 1' 1

run 05-silicon
expect 'LEDS r=0 g=0 y=1'
expect 'exit code: 0' 1

exit "$failed"
