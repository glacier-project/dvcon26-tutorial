# 03 — Rosetta: SysML v2 → Lingua Franca

```bash
cd 03-rosetta
```

To run the steps one by one, pressing Enter before each, type `./run.sh`.

Every example has the same three steps. `sysmlc rosetta build` turns a SysML
v2 model into an LF program in `out/`, `lfc` compiles it, and you run it. The
SysML models are in this folder, under `showcase/` and `sm-examples/`. Edit one
and build again to see the change.

Each program prints its state changes with their logical time. To hide them,
add `--log-level warning` to `sysmlc rosetta build`. The output below is
abridged, and lines with the same time may come in another order. Exit code 0
means the model's own testbench passed.

## Examples 1 and 2: dispatch and safety constraints

The model: [`showcase/charging-station/charging_station.sysml`](showcase/charging-station/charging_station.sysml)

```bash
sysmlc rosetta build showcase/charging-station -o out
lfc out/chargingStationSystem.lf && ./bin/chargingStationSystem; echo "exit code: $?"
```

```
[ 0.00 s] entered ChargingStationTester.plugWait
[ 0.00 s] entered ChargingStation.idle
...
[ 0.90 s] entered ChargingStation.authorizing
...
[ 1.20 s] entered ChargingStation.authRetry
...
exit code: 0
```

`sysmlc` prints two `WARNING`s. They are expected, because the testbench never
sends `Reset` or `StopRequest`.

Open `out/chargingStationSystem.lf` and find `mode authorizing`. The SysML
`accept … via commPort` transitions became one reaction, tried in declaration
order. `accept after authTimeout` became a logical action. And
`assert constraint thermalEnvelope` became checks after every assignment to
`temperature`.

## Complex mappings: composite, parallel, join

The model: [`showcase/milling-workcell/milling_workcell.sysml`](showcase/milling-workcell/milling_workcell.sysml)

```bash
sysmlc rosetta build showcase/milling-workcell -e MillingWorkcell::millingWorkcellSystem -o out
lfc out/millingWorkcellSystem.lf && ./bin/millingWorkcellSystem; echo "exit code: $?"
```

```
...
[ 1.70 s] entered MillingWorkcell.machining
[ 1.70 s] entered MillingWorkcell.priming
[ 1.70 s] entered MillingWorkcell.spinUp
[ 1.70 s] entered MillingWorkcell.watching
...
[ 3.00 s] exited MillingWorkcell.watching
[ 3.00 s] exited MillingWorkcell.machining
...
exit code: 0
```

`machining` has three parallel regions: spindle, coolant and monitor. LF modes
do not nest directly, so Rosetta puts one modal reactor per region inside
`mode machining`. It also generates a **join** that leaves `machining` when all
regions are done, here at 3.00 s.

## Values at build time

The model: [`showcase/thermostat/thermostat.sysml`](showcase/thermostat/thermostat.sysml)

```bash
sysmlc rosetta build showcase/thermostat -e Thermostat::ThermostatBehavior --values values.yaml -o out
lfc src/Thermostat.lf && ./bin/Thermostat
```

```
[ 0.00 s] thermostat: heating
[ 0.00 s] thermostat: idle
[15.00 s] thermostat: heating
[18.00 s] thermostat: idle
```

[`values.yaml`](values.yaml) overrides the model's initial values. It sets a
setpoint of 22 °C and a start at 25.5 °C, so the thermostat goes idle at once.
A state machine on its own becomes a reactor without a `main`, so
[`src/Thermostat.lf`](src/Thermostat.lf) runs it for 20 s.

## Functions written outside the model: the Furuta pendulum

The model: [`showcase/furuta-pendulum/deterministic/furuta_pendulum.sysml`](showcase/furuta-pendulum/deterministic/furuta_pendulum.sysml)

```bash
sysmlc rosetta build showcase/furuta-pendulum/deterministic --python furuta_physics.py -o out
lfc out/furutaSystem.lf && ./bin/furutaSystem; echo "exit code: $?"
```

The model declares its physics and control laws as `calc def`s without a
body. [`furuta_physics.py`](furuta_physics.py) provides them, matched by name.
The run ends with exit code 0 when the controller has caught the pendulum.
To see it:

```bash
lfc src/FurutaViz.lf && ./bin/FurutaViz
```

```
[ 1.05 s] controller -> catching
[ 1.10 s] down ....................O.................... down  catching
...
[ 2.52 s] Balanced! (the testbench verdict) - watching 2 s more
...
wrote out/furuta.png and out/furuta.gif
```

`src/FurutaViz.lf` reuses the generated reactors and adds a visualizer. In the
text view, `|` is upright and `O` is the pendulum. Open `out/furuta.png` and
`out/furuta.gif`. They show the pendulum swing up, get caught and stay
upright.

## One model, several backends

The model: [`sm-examples/sm01-helloworld/sm01.sysml`](sm-examples/sm01-helloworld/sm01.sysml)

```bash
sysmlc backends
sysmlc rosetta build sm-examples/sm01-helloworld -e SM01::Machine --target python -o out/python
sysmlc rosetta build sm-examples/sm01-helloworld -e SM01::Machine --target c -o out/c
sysmlc rosetta build sm-examples/sm01-helloworld -e SM01::Machine --target uc -o out/uc
ls out/python out/c out/uc
```

Rosetta generates LF for Python, C and reactor-uc. reactor-uc is the LF
runtime for microcontrollers.
