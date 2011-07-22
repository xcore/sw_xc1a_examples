// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*
 ============================================================================
 Name        : $(sourceFile)
 Description : Illuminate multiple LEDs concurrently on the XC-1A board 
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

void flashLED (out port led, int period);

int main (void) {
    par {
        on stdcore [0]: { cledG <: 1;
                            flashLED (cled0 , PERIOD);
                        }
        on stdcore [1]: flashLED (cled1, PERIOD);
        on stdcore [2]: flashLED (cled2, PERIOD);
        on stdcore [3]: flashLED (cled3, PERIOD);
    }
    return 0;
}

void flashLED (out port led, int period){
}
