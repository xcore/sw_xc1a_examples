// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>


//#include <print.h>

#include "firmware.h"
#include "uart_phy.h"

#define MAX_STR_LENGTH 5

// Identify ASCII number for UART carrage return.
#define UART_LINE_END_CHARACTER  (0x0d)

extern out port p_kled;

extern void sendLedVal(chanend c, unsigned o, unsigned r, unsigned g);
extern void doSoundGen_noLed(chanend c_snd);
extern void wait(timer, unsigned);
extern void ledDriver(chanend c_led, chanend cClock);


void uart_putstr(char string[])
{
  int i = 0;
  char tmp;

  while (string[i] != '\0')
  {
    tmp = string[i];
    if(tmp == NEW_LINE_CHAR)
    {
      uart_putch(0xd);		// Windows line endings
      uart_putch(0xa);
    }
    else
      uart_putch(tmp);
    i++;
  }
}

{int,int} uart_getstr(char string[], chanend c_keys)
{
  int Result = 0;
  unsigned char data;
  int killed;
  do
  {
    // receive a character from console.
    {data,killed} = uart_getch(c_keys);
    
    if(killed)
      return {0,1};

    // Echo it
    uart_putch(data);

    // check for end of line character.
    if (data == UART_LINE_END_CHARACTER) 
    {
      // append NULL termination.
      string[Result] = '\0';
    } 
    else 
    {
      string[Result] = data;
    }
      
    // error robust-ness
    if (Result < MAX_STR_LENGTH - 1)
    {
       Result += 1;
    }
  } while ((data != UART_LINE_END_CHARACTER));

  // Error trapping for max line length.
  if (Result == MAX_STR_LENGTH-1)
  {
    string[Result] = '\0';
  }

  return {Result-1, 0};
}


void doUart(chanend c_keys, chanend c_led)
{
  unsigned time, loop = 1;
  unsigned killed; 

  char string[MAX_STR_LENGTH];
  char header[] = "* XC-1A Version: "; 
  char version[] = {FIRMWARE_VER_MAJ_CHAR, 'v', FIRMWARE_VER_MIN_CHAR, '\0'} ;
  char menu[] = " *\n\nCommands:\n\nTurn LEDs on:\nO: Orange\nG: Green\nR: Red\n\n\n";
  //char enterval[] = "Enter Hex: 0x";
  
  uart_configure(UART_115200);

  while(loop)
  { 
    uart_putstr(header);
    uart_putstr(version); 
    uart_putstr(menu);
    
    {time,killed} = uart_getstr(string, c_keys);

    if(killed)
      break;
    switch(string[0])
    {
      case 'O':   // Orange
          sendLedVal(c_led, 0xfff, 0, 0);
        break;

      case 'G':   // Green
         sendLedVal(c_led, 0, 0, 0xfff);        
        break;

      case 'R':   // Red
        sendLedVal(c_led, 0x0, 0xfff, 0);
        break;

    }
  }

  c_led <: CMD_KILL;
}

void runUart(chanend c_keys, chanend cClock)
{
  chan c_led; 

  par
  {
    doUart(c_keys, c_led);
    ledDriver(c_led, cClock);
  }
}

