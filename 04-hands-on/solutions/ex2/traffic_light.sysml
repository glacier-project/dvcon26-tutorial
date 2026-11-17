package TrafficLight {
    private import ScalarValues::*;
    private import SI::*;
    private import ISQ::DurationValue;

    enum def LightColor :> String {
        enum red = "red";
        enum green = "green";
        enum yellow = "yellow";
    }

    // Signals exchanged over commPort
    item def PedestrianRequest;   // a pedestrian presses the button
    item def WalkOn;              // the light announces the walk phase

    state def TrafficLightBehavior {
        attribute color : LightColor := LightColor::red;
        attribute requested : Boolean := false;

        port commPort;

        entry;
            then showRed;

        state showRed {
            entry action {
                assign requested := false;     // first clear any button press,
                assign color := LightColor::red;   // then turn red
            }
        }
        // NEW: red + amber before green (UK/EU-style)
        state redAmber;
        state showGreen {
            entry assign color := LightColor::green;
        }
        // Visited right after a button press, to send WalkOn.
        state walkRequest;
        state showYellow {
            entry assign color := LightColor::yellow;
        }

        transition first showRed accept after 3 [s] then redAmber;
        transition first redAmber accept after 1 [s] then showGreen;
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
