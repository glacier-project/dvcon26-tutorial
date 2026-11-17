/* Host build. The lamps are printed as one line on stdout. */
#include <stdio.h>
#include "lights.h"

int32_t setLights(int32_t mask)
{
    printf("LEDS r=%d g=%d y=%d\n", (mask & LIGHT_RED) != 0, (mask & LIGHT_GREEN) != 0, (mask & LIGHT_YELLOW) != 0);
    fflush(stdout);
    return mask;
}
