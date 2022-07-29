/*
 * C to assembler menu hook
 *
 */

#include <stdio.h>
#include <stdint.h>
#include <ctype.h>

#include "stm32f3xx_hal.h"
#include "common.h"

void yj_watch(int timeout, int delay);

void _yj_A5(int action)
{
  if(action==CMD_SHORT_HELP || action==CMD_LONG_HELP) {  
    printf("Watch Game\n\n");

    return;
  }

  int fetch_status;

  uint32_t timeout;
  fetch_status = fetch_uint32_arg(&timeout);

  if(fetch_status) {
    // set default value as 500 (about 500/(40k/256) = 3.2s)
    timeout = 500;
  }

  uint32_t delay;
  fetch_status = fetch_uint32_arg(&delay);

  if(fetch_status) {
    // set default value as 500ms
    delay = 500;
  }

  yj_watch(timeout, delay);
}

ADD_CMD("_yjWatch", _yj_A5, "<timeout> <delay> for Assignment 5")