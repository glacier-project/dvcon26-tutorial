package TrafficLight {
    private import ScalarValues::*;
    private import SI::*;
    private import ISQ::DurationValue;

    enum def LightColor :> String {
        enum red = "red";
        enum green = "green";
        enum yellow = "yellow";
    }

    // The edge of the board. An external function drives the lights.
    // Each platform has its own C file for it, lights_posix.c or lights_esp32.c.
    // A calc def can only be called inside an expression, so it returns the mask.
    package Board {
        calc def setLights { in mask : Integer; return : Integer; }
    }

    // Signals exchanged over commPort
    item def PedestrianRequest;   // a pedestrian presses the button
    item def WalkOn;              // the light announces the walk phase

    state def TrafficLightBehavior {
        attribute color : LightColor := LightColor::red;
        attribute requested : Boolean := false;
        attribute leds : Integer := 0;

        // a button press must never survive into red
        assert constraint requestedClearsOnRed {
            color != LightColor::red or requested == false
        }

        port commPort;

        entry;
            then showRed;

        state showRed {
            entry action {
                assign requested := false;     // first clear any button press,
                assign color := LightColor::red;   // then turn red
                assign leds := Board::setLights(1);    // red = 1, green = 2, yellow = 4
            }
        }
        state showGreen {
            entry action {
                assign color := LightColor::green;
                assign leds := Board::setLights(2);
            }
        }
        // Visited right after a button press, to send WalkOn.
        state walkRequest;
        state showYellow {
            entry action {
                assign color := LightColor::yellow;
                assign leds := Board::setLights(4);
            }
        }

        transition first showRed accept after 4 [s] then showGreen;
        transition first showGreen
            accept PedestrianRequest via commPort
            do assign requested := true
            then walkRequest;
        // No trigger, so it fires as soon as walkRequest is entered.
        transition first walkRequest
            do send new WalkOn() via commPort
            then showYellow;
        transition first showGreen accept after 6 [s] then showYellow;
        transition first showYellow accept after 2 [s] then showRed;
    }

    // The testbench presses the button at 5 s and expects WalkOn within 15 s.
    // Then it watches 5 s more, while the light turns red again, and stops.
    // Without WalkOn it sets verdict to 1.
    // testPassed then fails and the run exits with 1.
    state def TrafficLightTest {
        attribute verdict : Integer := 0;
        assert constraint testPassed { verdict == 0 }

        port commPort;

        entry; then waitGreen;
        state waitGreen;
        state watchRed;
        state walkWait {
            entry send new PedestrianRequest() via commPort;
        }
        state fail {
            entry assign verdict := 1;
        }

        transition first waitGreen accept after 5.0 [s] then walkWait;
        transition first walkWait accept WalkOn via commPort then watchRed;
        transition first watchRed accept after 5.0 [s] then done;
        transition first walkWait accept after 15.0 [s] then fail;
        transition first fail then done;
    }

    part def TrafficLight       { port commPort; exhibit state : TrafficLightBehavior; }
    part def TrafficLightTester { port commPort; exhibit state : TrafficLightTest; }

    part trafficLightSystem {
        part plant : TrafficLight;
        part tb    : TrafficLightTester;
        interface plant.commPort to tb.commPort;
    }
}
