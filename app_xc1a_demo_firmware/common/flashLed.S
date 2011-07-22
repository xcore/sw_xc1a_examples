// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

     
#include <xs1.h>
 
.text
.align    4
.globl flashLed
.globl flashLed.nstackwords
.linkset flashLed.nstackwords, 6
flashLed:
        entsp     0x6 
          stw       r4, sp[0x1] 
          stw       r5, sp[0x2] 
          stw       r6, sp[0x3] 
          stw       r7, sp[0x4]
          stw       r8, sp[0x5] 
          mov       r8, r0             // r8: port
         
          mov       r4, r1             // r4: onpulse
          mov       r7, r2             // r7: offpulse            
          ldw       r6, sp[0x7]        // r6: onVal 
          
          getr      r5, XS1_RES_TYPE_TIMER
          bf        r3, return
loop:
          out       res[r8], r6 
          mov       r1, r4
          mov       r0, r5
          bl        wait 
          ldc       r11, 0x0
          out       res[r8], r11 
          mov       r1, r7
          mov       r0, r5
          bl        wait 
          sub       r3, r3, 0x1        // Shouldn;t really use r3
          bt        r3, loop 
return:
          freer     res[r5]
          ldw       r4, sp[0x1] 
          ldw       r5, sp[0x2] 
          ldw       r6, sp[0x3]
          ldw       r7, sp[0x4] 
          ldw       r8, sp[0x5] 
          retsp     0x6 

