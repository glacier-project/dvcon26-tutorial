# 05 — From model to silicon

```bash
cd 05-silicon
```

To run the steps one by one, pressing Enter before each, type `./run.sh`.

The traffic light in [`model/traffic_light.sysml`](model/traffic_light.sysml),
with its testbench, compiled with Rosetta's **reactor-uc** target. reactor-uc
is Lingua Franca for microcontrollers, in C instead of Python. Each lamp state
calls a board function and keeps the result in the attribute `leds`:

```sysml
package Board {
    calc def setLights { in mask : Integer; return : Integer; }
}
state showRed {
    entry action {
        assign requested := false;
        assign color := LightColor::red;
        assign leds := Board::setLights(1);    // red = 1, green = 2, yellow = 4
    }
}
```

The model does not say how the lamps are driven. One C file per board does.
[`lights/lights_posix.c`](lights/lights_posix.c) prints them, and
[`lights/lights_esp32.c`](lights/lights_esp32.c) shows them on the board's RGB LED.

## On this machine

```bash
sysmlc rosetta build model --target uc --c lights/lights_posix.c --c_h lights/lights.h -o out
cmake -S out -B out/build && cmake --build out/build
out/bin/trafficLightSystem; echo "exit code: $?"
```

```
LEDS r=1 g=0 y=0
LEDS r=0 g=1 y=0
LEDS r=0 g=0 y=1
LEDS r=1 g=0 y=0
exit code: 0
```

`--target uc` writes a `.ulf` program and a `CMakeLists.txt`. `cmake` runs
reactor-uc's compiler and builds a native program. The testbench runs too, and
`exit code: 0` means it passed.

## On an ESP32-C6 board

Flashing needs USB, so this runs on a laptop, not in the Codespace. The
board's RGB LED shows the light, so there is no wiring.

Once, get ESP-IDF v5.5.1 and `led_strip` from the reactor-uc ESP-IDF template,
and set `REACTOR_UC_PATH` to a reactor-uc checkout on branch `micromode`:

```bash
git clone --recursive https://github.com/lf-lang/lf-esp-idf-uc-template ~/esp-template
~/esp-template/esp-idf/install.sh esp32c6
```

Then, with the board on USB:

```bash
cd esp32
sysmlc rosetta build ../model -e TrafficLight::TrafficLightBehavior --target uc --c ../lights/lights_esp32.c --c_h ../lights/lights.h -o src
. ~/esp-template/esp-idf/export.sh
cmake -Bbuild -GNinja -DLF_MAIN=Main -DIDF_EXTRA_COMPONENTS_PATH=$HOME/esp-template/idf-extra-components -DCMAKE_TOOLCHAIN_FILE=$IDF_PATH/tools/cmake/toolchain-esp32c6.cmake
cmake --build build
ninja -C build flash
```

`esp32/run.sh` runs these steps one by one, with the one-time setup if
`~/esp-template` is missing. Rosetta writes the light into `esp32/src/`, and
[`esp32/Main.ulf`](esp32/Main.ulf) runs it on ESP-IDF. Only the light runs,
without the testbench, so it keeps cycling. That is also why `sysmlc` warns
that `WalkOn` has no peer.

There are two programs to flash. Pick one with `-DLF_MAIN`:

- [`esp32/Main.ulf`](esp32/Main.ulf): the light alone.
- [`esp32/MainButton.ulf`](esp32/MainButton.ulf): the light, with the board's
  BOOT button as the pedestrian button. Press it while the light is green and
  the light turns yellow at once. It is the same SysML model that the
  testbench presses in simulation.

`./run.sh` in `esp32/` flashes `Main`, and `./run.sh MainButton` flashes the
other one.
