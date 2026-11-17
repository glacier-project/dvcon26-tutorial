# The same models with quake

quake is another sysmlc backend. It runs a SysML v2 state machine directly in
Python, with [sismic](https://github.com/AlexandreDecan/sismic), without
Lingua Franca. It prints every step the model takes, with its time.

This is optional and not part of the tutorial. It works for the models of
parts 03 and 04. Part 05 needs C functions, so it only runs with Rosetta.

## Install

quake is not already installed in the Codespace. Install it with:

```bash
pip install "sysmlc-quake @ git+https://github.com/glacier-project/sysmlc-quake@e02a7644c5edae1f1be5422b3d680b82bae0d247"
```

## Run

Type these in the top folder of this repo.

```bash
sysmlc quake run 03-rosetta/sm-examples/sm01-helloworld -e SM01::Machine
sysmlc quake run 03-rosetta/showcase/charging-station
sysmlc quake run 03-rosetta/showcase/milling-workcell
sysmlc quake run 03-rosetta/showcase/thermostat --until 30
sysmlc quake run 03-rosetta/showcase/furuta-pendulum --python 03-rosetta/furuta_physics.py --until 10 --max-steps 100000
sysmlc quake run 04-hands-on/model --until 30
```

- `-e` picks one state definition when the model has several.
- `--until 30` stops at 30 s. The thermostat and the traffic light never stop
  by themselves.
- `--python` gives quake the Python functions behind the model's `calc def`s.
  `--max-steps` raises the limit of 1000 steps, because the pendulum takes
  many small steps.

The traffic light of part 04 (abridged):

```
Ran TrafficLight::trafficLightSystem:
trace:
  plant: Step@0(None, [], >['TrafficLightBehavior', 'showRed'], <[])
  plant: Step@4.0(InternalEvent('_tick_showRed_t1', ...), [Transition('showRed', 'showGreen', ...)], ...)
  plant: Step@5.0(Event('PedestrianRequest'), [Transition('showGreen', 'walkRequest', ...)], ...)
  tb: Step@5.0(Event('WalkOn'), [Transition('walkWait', 'watchRed', event='WalkOn')], ...)
  plant: Step@7.0(InternalEvent('_tick_showYellow_t1', ...), [Transition('showYellow', 'showRed', ...)], ...)
  ...
clock=30.0 status=reached time bound
```

`plant` is the light and `tb` is its testbench. These are the same times as in
the Lingua Franca run.

The constraint of Ex 3 works too. The broken model stops at once:

```bash
sysmlc quake run 04-hands-on/solutions/ex3-broken
```

```
error: InvariantError
Object: CompoundState('TrafficLightBehavior')
Assertion: (color != "red" or requested == False) # sysmlc.constraint_id=0
```

## See the statechart

`build` writes the statechart as YAML and as a PlantUML diagram, instead of
running it:

```bash
sysmlc quake build 04-hands-on/model -o out
```

In `out/trafficLightSystem/`, `plant.yaml` and `plant.puml` are the light, and
`tb.yaml` and `tb.puml` are the testbench.
