// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <xs1.h>
#include "uart_phy.h"
#include "firmware.h"

#define SW_REF_CLK_MHZ 100

extern out port p_kled;
extern out port UART_TX_PORT; // 1bit port Tx
extern in  port UART_RX_PORT; // 1bit port Rx

// UART initialisation state.
static unsigned bit_time = 0;

/** Initialise UART... bit_time
 *  Its fixed to, Data : 8bits, Parity : None, Stop : 1bit, Flow contorl : none.
 */
void uart_configure(UART_BAUD_RATE_t baud_rate)
{  
   bit_time  = SW_REF_CLK_MHZ * 1000000 / (unsigned) baud_rate;
   UART_TX_PORT <: 1;      
}

/** UART receive a character
  **/
{unsigned char, int} uart_getch(chanend c_keys)
{
   unsigned data = 0, time;
   int i;
   unsigned char buffer;
   
   // detect the start bit and time it.
   /*select
   {
     case UART_RX_PORT when pinseq( 1) :> int _:
       break;
      case c_keys :> data:
        if(data == CMD_KILL)
        {
          return{buffer, 1};
        }
        else if(data == CMD_KEYVAL)
        {
          c_keys :> data; // Ignore
        }

      break;
   }*/
   p_kled <: 0x00;
   select
   {
      case UART_RX_PORT when pinseq( 0) :> int _ @ time:
        break;
      case c_keys :> data:
        if(data == CMD_KILL)
        {
          return{buffer, 1};
        }
        else if(data == CMD_KEYVAL)
        {
          c_keys :> data; // Ignore
        }
        break;

   }
  
   time += bit_time + (bit_time >> 1);
   
   // sample each bit in the middle.
   for (i = 0; i < 8; i += 1)
   {
      UART_RX_PORT @ time :> >> data;
      time += bit_time;
   }

   // reshuffle the data.
   buffer = (unsigned char) (data >> 24);
   p_kled <: 0xf0;
   return {buffer,0};
}

/** UART transmit a character.
 *  This is blocking call for now.
 */
void uart_putch(unsigned char buffer)
{
   unsigned time, data;
   
   data = buffer;
   
   // get current time from port with force out.
   UART_TX_PORT <: 1 @ time;
   // Start bit.
   UART_TX_PORT <: 0;
   // Data bits.
   for (int i = 0; i < 8; i += 1)
   {
      time += bit_time;
      UART_TX_PORT @ time <: >> data;         
   }
   // Stop bit
   time += bit_time;
   UART_TX_PORT @ time <: 1;
   time += bit_time;
   UART_TX_PORT @ time <: 1; 
}

