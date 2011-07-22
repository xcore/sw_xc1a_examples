// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*
 ============================================================================
 Name        : $(sourceFile)
 Description : Flash an LED on the XC-1A board 
 ============================================================================
 */

#include <platform.h>
#define FLASH_PERIOD 20000000

out port bled = PORT_BUTTONLED;

int main (void) {
    timer tmr;
    unsigned isOn = 1;
    unsigned t;
    tmr :> t;
    while (1) {
        bled <: isOn;
        t += FLASH_PERIOD;
        tmr when timerafter (t) :> void;
        isOn = !isOn;
    }
    return 0;
}
