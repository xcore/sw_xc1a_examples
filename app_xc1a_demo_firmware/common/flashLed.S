/**
 * Module:  app_xc1a_firmware
 * Version: 1v3
 * Build:   0d899968f20a382e3779bfcd0446c7abe32cf649
 * File:    flashLed.S
 *
 * The copyrights, all other intellectual and industrial 
 * property rights are retained by XMOS and/or its licensors. 
 * Terms and conditions covering the use of this code can
 * be found in the Xmos End User License Agreement.
 *
 * Copyright XMOS Ltd 2010
 *
 * In the case where this code is a modification of existing code
 * under a separate license, the separate license terms are shown
 * below. The modifications to the code are still covered by the 
 * copyright notice above.
 *
 **/                                   
     
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

