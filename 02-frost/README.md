# 02 — Frost

```bash
cd 02-frost
```

To run the steps one by one, pressing Enter before each, type `./run.sh`.

The four programs are in `src/`. Each machine's interface is a **Machine Data
Model** in `resources/data_model/`. `resources/frost_config.yml` says which data
model each Frost reactor loads. Frost reads this file from the folder you run in.

## The Machine Data Model and control-flow graphs

```bash
lfc src/ConveyorCfg.lf && ./bin/ConveyorCfg
```

```
[ 1.00 s] client: moveAndCheck(destination=3.0)
[ 1.00 s] conveyor: sendPalletTo(3.0)
[ 7.00 s] conveyor: arrived at 3.0 m
[ 7.10 s] client: moveAndCheck -> True (took 6.1 s)
```

- [`resources/data_model/conveyor.yml`](resources/data_model/conveyor.yml) is
  the conveyor's interface. It has the variables `arrived` and `position`, the
  async method `sendPalletTo`, and `moveAndCheck`. `moveAndCheck` is a
  **composite method** with the control-flow graph
  `Call sendPalletTo → Wait arrived == true → Read arrived`.
- In `src/ConveyorCfg.lf`, the conveyor implements only `sendPalletTo` and its
  motor. `moveAndCheck` has no code. Frost runs its graph over the data model.

The first second is the components registering with the `FrostLink`. The last
0.1 s is the conveyor's `update_interval`. The conveyor sends data-model changes
every 100 ms, and one of them wakes the `Wait`.

**Connector binding:**
[`conveyor_opcua.yml`](resources/data_model/conveyor_opcua.yml) is the same
model bound to a real conveyor over OPC UA. Only the lines marked `NEW` change.
`moveAndCheck` stays the same, so one graph drives both the twin and the plant.
There is no conveyor in the room, so this one is not run.

## A machine and a client

```bash
lfc src/QualityCheck.lf && ./bin/QualityCheck
```

```
[ 1.00 s] client -> check_quality('good')
[ 1.00 s] client <- True
[ 1.00 s] client -> check_quality('bad')
[ 1.00 s] client <- False
[ 1.00 s] client -> check_quality('good')
[ 1.00 s] client <- True
checks=3 failures=1
```

`ControlQuality` is a `FrostReactor` with the data model
[`control_quality.yml`](resources/data_model/control_quality.yml). It binds
`check_quality` to a Python method. The client calls it through the
`FrostLink` hub, which routes messages between components.

## An FMU in Frost

```bash
lfc src/BouncingBall.lf && ./bin/BouncingBall
```

```
[ 0.46 s] bounce #1  (FMU time 0.46 s)
[ 1.09 s] bounce #2  (FMU time 1.09 s)
[ 1.54 s] bounce #3  (FMU time 1.54 s)
[ 1.85 s] bounce #4  (FMU time 1.85 s)
```

`resources/bouncingBall.fmu` is a co-simulation FMU (FMI 2.0), and `FrostFmu`
loads it. Every 10 ms of logical time, the cell asks for one step and writes
the ball's height and speed into its data model. FMU time and logical time stay
equal, so the bounces happen at the same times on every run.

## Co-simulation: two FMUs, one clock

```bash
lfc src/CoSimulation.lf && ./bin/CoSimulation
```

```
[ 0.00 s] common step = 0 ms, model times = {}
[ 0.01 s] common step = 10 ms, model times = {'ball_fine': 0.0, 'ball_coarse': 0.0}
[ 0.02 s] common step = 10 ms, model times = {'ball_fine': 0.01, 'ball_coarse': 0.01}
...
101 co-simulation steps; in sync: yes
```

Two instances of the same FMU. Their wrappers propose steps of 10 ms and
25 ms. The `Orchestrator` takes the smallest proposal, advances logical time by
it and sends that step to both, so the two FMUs move in lockstep. They exchange
no data. This example shows only the shared clock.
**Try:** in `src/CoSimulation.lf`, set `preferred_ms = 5` on `coarse`.
