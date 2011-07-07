// Copyright (c) 2011, <insert copyright holder here>, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*
 ============================================================================
 Name        : $(sourceFile)
 Description : Illuminate multiple LEDs in sequence on an XC-1A board 
 ============================================================================
 */

#include <platform.h>
#define PERIOD 20000000

out port cled0 = PORT_CLOCKLED_0;
out port cled1 = PORT_CLOCKLED_1;
out port cled2 = PORT_CLOCKLED_2;
out port cled3 = PORT_CLOCKLED_3;
out port cledG = PORT_CLOCKLED_SELG;
out port cledR = PORT_CLOCKLED_SELR;

void tokenFlash (chanend left, chanend right, out port led, int delay, int isMaster) {
    timer tmr;
    unsigned t;

    if (isMaster) /* master inserts token into ring */
        right <: 1;

    while (1) {
        int token;
        left :> token; /* input token from left neighbor */
        led <: 1;
        tmr :> t;
        tmr when timerafter (t+ delay ) :> void;
        led <: 0;
        right <: token; /* output token to right neighbor */
    }
}

int main (void) {
    chan c0, c1, c2, c3;
    par {
        on stdcore [0]: { cledG <: 1;
                            tokenFlash (c0, c1, cled0, PERIOD, 1);
                        }
        on stdcore [1]: tokenFlash (c1, c2, cled1, PERIOD, 0);
	// other cores
    }
    return 0;
}