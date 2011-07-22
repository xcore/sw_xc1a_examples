// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*
 ============================================================================
 Name        : $(sourceFile)
 Description : Illuminate an LED on the XC-1A board 
 ============================================================================
 */

#include <platform.h>

out port bled = PORT_BUTTONLED;

int main() {
  bled <: 0b0001;
  while(1)
    ;
  return 0;
}

