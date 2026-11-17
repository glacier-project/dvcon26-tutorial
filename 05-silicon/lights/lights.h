#ifndef LIGHTS_H
#define LIGHTS_H

#include <stdint.h>

/* Drives the three lamps from a bit mask. Red is 1, green 2, yellow 4.
 * Returns the mask it applied. Each platform has its own implementation.
 * The signature matches what Rosetta generates for this SysML:
 *   calc def setLights { in mask : Integer; return : Integer; }
 */
enum { LIGHT_RED = 1, LIGHT_GREEN = 2, LIGHT_YELLOW = 4 };

int32_t setLights(int32_t mask);

#endif
