# 01 — Lingua Franca

```bash
cd 01-lingua-franca
```

To run the steps one by one, pressing Enter before each, type `./run.sh`.

The programs are in `src/`. `lfc` compiles each one into `bin/`, then you run
it. All programs but the last use `fast: true`. Logical time then runs as fast
as the computer can, so 20 s of logical time pass in a moment.

## What is a Reactor?

```bash
lfc src/Blink.lf && ./bin/Blink
```

```
[ 0.00 s] led = True
[ 0.50 s] led = False
[ 1.00 s] led = True
...
```

`Blinker` has a parameter (`period`), a timer, a state variable and an output.
**Try:** in `src/Blink.lf`, write `new Blinker(period = 200 ms)` and run again.

## A Complete LF Program

```bash
lfc src/Machines.lf && ./bin/Machines
```

```
acked at 2000000000 ns
```

`a.ack -> b.cmd after 2 sec` delivers the acknowledgment exactly 2 s later in
logical time. This holds on every run, however fast the program runs.

## Logical vs. Physical Time

```bash
lfc src/Tags.lf && ./bin/Tags
```

```
tag=(0, 0) startup
tag=(2000000000, 0) timer t fires
tag=(2000000000, 1) zero-delay action #1
tag=(2000000000, 2) zero-delay action #2
```

Every event has a tag (time, microstep). An action with zero delay keeps the
time and advances the microstep.

## Deterministic Concurrency

```bash
lfc src/Priority.lf && for i in 1 2 3 4 5; do ./bin/Priority; done
```

```
final x = 6142
final x = 6142
...
```

The sink's two reactions are triggered at the same tag, and both change `x`
(`+ 1`, then `* 2`). Reactions of one reactor never run at the same time. They
run in **declaration order**, so `x` is the same on every run.
**Try:** swap the two reactions in `Sink`. `x` changes, but it is again the
same on every run.

## Modal Reactors: Modes, Reset vs. History

```bash
lfc src/Crossing.lf && ./bin/Crossing
```

```
[ 0.00 s] light -> showRed
[ 4.00 s] light -> showGreen
[ 5.00 s] pedestrian presses the button
[ 5.00 s] light -> walkRequest
[ 5.00 s] WALK
[ 5.00 s] light -> showYellow
[ 7.00 s] light -> showRed
...
```

A traffic light with four modes. Red, green and yellow each have a timer.

```bash
lfc src/ResetVsHistory.lf && ./bin/ResetVsHistory
```

```
...
[ 2.50 s] -- pause --
[ 4.00 s] -- resume --
[ 4.00 s]   reset: tick      <- reset: the timer starts over
[ 4.50 s] history: tick      <- history: the remaining 0.5 s is resumed
...
```

Two tickers are paused at 2.5 s and resumed at 4 s. One re-enters its mode
with reset, the other with history. The tickers are independent, so lines with
the same time may come in either order. LF fixes *when* things happen, not the
order of unrelated prints.

## Timers, logical actions, deadlines

```bash
lfc src/Timing.lf && ./bin/Timing
```

```
[ 0.00 s] timer t fires
[ 0.05 s] logical action fires (50 ms after t); working 30 ms...
[ 0.05 s] direct: deadline missed (started > 10 ms late in wall-clock time)
[ 0.15 s] after 100 ms: on time (value sent at 0.05 s)
...
```

The program has a timer, a logical action 50 ms later, a connection with
`after 100 ms`, and a `deadline(10 ms)`. A deadline checks wall-clock time.
The reaction before it works for 30 ms, so the direct consumer starts too late.
This program does not use fast mode, and its output is the only one that
depends on the computer.

Tip: open any `.lf` file and click the diagram icon at the top right to see its
reactors drawn.
