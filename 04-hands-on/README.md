# 04 — Hands-on

```bash
cd 04-hands-on
```

To run every exercise on its solution, pressing Enter before each step, type
`./run.sh`.

You edit one model: [`model/traffic_light.sysml`](model/traffic_light.sysml).
It has two parts:

- `TrafficLightBehavior`, the traffic light: red, green, yellow, and a button
  for pedestrians.
- `TrafficLightTest`, its testbench. It presses the button at 5 s and expects
  the walk signal within 15 s. Then it waits 5 s more, while the light turns
  red again, and stops.

After every edit, the same three commands:

```bash
sysmlc rosetta build model -o out
lfc out/trafficLightSystem.lf
./bin/trafficLightSystem; echo "exit code: $?"
```

The run takes 10 s, because the light runs in real time. The solutions are in
`solutions/`. Each one is the original model plus that one exercise. To build
one, use `sysmlc rosetta build solutions/ex1 -o out`.
To undo all your edits, run `git checkout model`.

## Ex 0 — Smoke test

Run the three commands on the model as it is:

```
[ 0.00 s] entered TrafficLight.showRed
[ 0.00 s] entered TrafficLightTester.waitGreen
[ 4.00 s] entered TrafficLight.showGreen
[ 5.00 s] entered TrafficLightTester.walkWait
[ 5.00 s] entered TrafficLight.walkRequest
[ 5.00 s] entered TrafficLight.showYellow
[ 7.00 s] entered TrafficLight.showRed
[10.00 s] exited TrafficLightTester.watchRed
exit code: 0
```

The output is abridged, and lines with the same time may come in another
order. `exit code: 0` means the testbench's `assert constraint testPassed`
held. The verification is part of the SysML model. Open
`out/trafficLightSystem.lf` and find the four `mode`s of `TrafficLight`.

## Ex 1 — Retime the lights

Change the three `accept after` times:

```sysml
transition first showRed    accept after 2 [s] then showGreen;    // was 4
transition first showGreen  accept after 4 [s] then showYellow;   // was 6
transition first showYellow accept after 1 [s] then showRed;      // was 2
```

Run, then look at the generated timers:

```bash
grep "timer t_show" out/trafficLightSystem.lf
```

```
    timer t_showRed(2 sec)
    timer t_showGreen(4 sec)
    timer t_showYellow(1 sec)
```

Green now starts at 2 s, and the run still ends with `exit code: 0`.

**Bonus:** try 3 s for green. Red (2 s) plus green (3 s) ends at exactly 5 s,
when the testbench presses the button. The light turns yellow first and the
press is ignored. At 20 s the testbench fails with `exit code: 1`, the same way
on every run. The model's own test caught a timing collision. Then set green
back to 4 s.

## Ex 2 — Add a state

Directly above `state showGreen {`, add:

```sysml
// NEW: red + amber before green (UK/EU-style)
state redAmber;
```

Then replace the transition `showRed ... then showGreen` with these two. Red
lasts 3 s and red-amber 1 s, so green still starts at 4 s:

```sysml
transition first showRed accept after 3 [s] then redAmber;
transition first redAmber accept after 1 [s] then showGreen;
```

Run:

```
...
[ 3.00 s] entered TrafficLight.redAmber
[ 4.00 s] exited TrafficLight.redAmber
[ 4.00 s] entered TrafficLight.showGreen
...
exit code: 0
```

One new SysML state gives one new LF mode. To see it, run
`grep -A1 "mode redAmber" out/trafficLightSystem.lf`.

## Ex 3 — A safety constraint

`requested` records a button press. Add a constraint that says it is always
cleared when the light is red. Inside `state def TrafficLightBehavior`, below
the attributes, add:

```sysml
// NEW: a button press must never survive into red
assert constraint requestedClearsOnRed {
    color != LightColor::red or requested == false
}
```

Run the three commands. You get `exit code: 0`. Rosetta checks the constraint
at startup and after every assignment to `color` or `requested`.
`grep -c requestedClearsOnRed out/trafficLightSystem.lf` counts how often it
appears in the generated code.

Now break the model:

1. Change the attribute declaration to `attribute requested : Boolean := true;`.
   The run stops at once:

   ```
   AssertionError: SysML constraint violated: {"reactor":"TrafficLight",...,"name":"requestedClearsOnRed",...}
   exit code: 1
   ```

   The traceback above it is expected. Set it back to `false`.

2. Now the real bug. In `state showRed`, delete `assign requested := false;`.
   The button press at 5 s sets `requested`. When the light turns red again,
   at 7 s (or 6 s with your Ex 1 times), the constraint fails. The testbench
   never checked this, but the invariant did.

Look at the order in `showRed`: `requested := false` comes before
`color := red`. The constraint is checked after every assignment, so the
other order would fail in between.
