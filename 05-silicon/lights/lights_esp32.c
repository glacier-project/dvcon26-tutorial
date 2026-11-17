/* ESP32-C6 build. The board's RGB LED on GPIO 8 shows the light.
 * The LED code follows Led.ulf in lf-esp-idf-uc-template. */
#include "led_strip.h"
#include "lights.h"

static led_strip_handle_t led;

int32_t setLights(int32_t mask)
{
    if (!led) {    /* set up the LED on the first call */
        led_strip_config_t strip = { .strip_gpio_num = 8, .max_leds = 1 };
        led_strip_rmt_config_t rmt = { 0 };
        led_strip_new_rmt_device(&strip, &rmt, &led);
    }
    if (mask & LIGHT_RED)    led_strip_set_pixel(led, 0, 40, 0, 0);
    if (mask & LIGHT_GREEN)  led_strip_set_pixel(led, 0, 0, 40, 0);
    if (mask & LIGHT_YELLOW) led_strip_set_pixel(led, 0, 40, 15, 0);
    led_strip_refresh(led);
    return mask;
}
