/**
 * Module:  app_xc1a_firmware
 * Version: 1v3
 * Build:   0d899968f20a382e3779bfcd0446c7abe32cf649
 * File:    firmware.xc
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
// System headers
#include <xs1.h>
#include <platform.h>
#include <print.h>

#include "firmware.h"

// Demo headers
#include "clock.h"
#include "audio.h"
#include "reaction.h"
#include "uart.h"

extern void flashLed(out port p, unsigned onPulse, unsigned offPulse, unsigned noFlashes, unsigned onVal);
unsigned doKeys(chanend c, unsigned killMask, in port p_key);

void setRegVal(int psctl, int reg, int procc, int n);

/* Port declarations */
// Keys/Key-leds
out port p_kled =   PORT_BUTTONLED;	
in port p_key	=     PORT_BUTTON; 	

// 'Clock' leds
out port p_cled_g = PORT_CLOCKLED_SELG;
out port p_cled_r = PORT_CLOCKLED_SELR;
out port p_cled_0 = PORT_CLOCKLED_0;
out port p_cled_1 = PORT_CLOCKLED_1;
out port p_cled_2 = PORT_CLOCKLED_2;
out port p_cled_3 = PORT_CLOCKLED_3;

buffered out port:32 p_spk = PORT_SPEAKER;

out port UART_TX_PORT = PORT_UART_TX; // 1bit port Tx
in  port UART_RX_PORT = PORT_UART_RX; // 1bit port Rx

#define DEMO_FLASHS 5            // Number of times to flash key LED on demo selection
#define DEMO_KILL_MASK 1

// Call Demos from these functions
// NOTE: EACH DEMO SHOULD TAKE A CHANEND AS PARAM, AND DIE ON RECEIVE CMD_KILL
// Demos can also receive key values from this channel (CMD_KEYVAL) command, which is sent
// everytime there is a change in button state.
void runDemo(int demoNumber, in port p_key, chanend cClock)
{
  chan c;
  unsigned tmp;

  flashLed(p_kled, 10000000, 10000000, DEMO_FLASHS, (1<<demoNumber));
  par
  {
    tmp = doKeys(c, DEMO_KILL_MASK, p_key);
    {  
      if(demoNumber ==0)
        runClock(c, cClock);    
      else if(demoNumber == 1) 
        runAudio(c, cClock);
      else if(demoNumber == 2)
        runReaction(c, cClock);
      else if(demoNumber == 3)
        runUart(c, cClock);
    }
  }
}


//Simple delay using passed timer
void wait(timer tmr, unsigned delay)
{
  unsigned s;
  tmr :> s;
  tmr when timerafter(s+delay) :> unsigned t ;
}


#define TIMESTEP 800000    //time it takes to turn the led on or off
#define RESOLUTION 600     //the number of time slices per time step
#define INCREMENTS 50     //the amount of brightness step
#define GREENTIME_STEP 15

void outClockLeds(int r, int g, int x, chanend cClock)
{
  cClock <: ((x&0xFFF) << 2) | ((r&1) << 1) | (g&1);
  cClock :> int _;
}

void ledFade(int selVal, int greenTime, int cLedValr, chanend cClock)
{
  timer t;
  int i, j;
  unsigned const step = (TIMESTEP/RESOLUTION)/INCREMENTS;

  // LED fade on
  for(i=1;i<INCREMENTS ;i++)
  {
    for(int j = 0; j <= greenTime;j++)
    {  
      outClockLeds(selVal, !selVal, cLedValr, cClock); 
      wait(t, i*step);
      outClockLeds(selVal, !selVal, ~cLedValr, cClock); 
      wait(t, (INCREMENTS-i)*step); 
    }
       
    for(j = 0; j < RESOLUTION-greenTime;j++)
    {  
      outClockLeds(!selVal, selVal, ~cLedValr, cClock); 
      wait(t, i*step);
      outClockLeds(!selVal, selVal, cLedValr, cClock); 
      wait(t, (INCREMENTS-i)*step); 
    } 
  }
}


// Does something pretty on the 'clock' LEDs, untill killed by user press
void  doClockLedGlow(chanend c, chanend c1, chanend cClock)
{
  int loopTerm = 1;
  int cLedValr = 0xaaa;
  timer t;
  unsigned time, tmp, selVal = 1;
  unsigned greenTime = GREENTIME_STEP;

  while(loopTerm)
  {
    t :> time;
    select
    {
      case c :> tmp:
        if(tmp == CMD_KILL)
        {
          outClockLeds(0, 0, 0, cClock); 
          loopTerm = 0;
 
          c1 <: CMD_KILL;     // Kill keyled thread
        }
        break;
   
      case t when timerafter(time+1000) :> int tmpTime: 
        greenTime+=GREENTIME_STEP;
        if(greenTime>=(RESOLUTION-GREENTIME_STEP))
        {
          selVal = !selVal;
          greenTime = GREENTIME_STEP;
        }
        //LED fade On
        ledFade(selVal, greenTime, cLedValr, cClock);
        ledFade(selVal, greenTime, ~cLedValr, cClock); 
        break;
    }
  }
}

void fadeLed(out port p, unsigned x)
{
  int i, j;
  timer t;
 
  for(i=0;i<INCREMENTS ;i++)
  {
    for(j=0;j<RESOLUTION ;j++)
    {  
      p <: x;
      wait(t, i*((TIMESTEP /RESOLUTION) /INCREMENTS ));
      p <: 0;
      wait(t, (INCREMENTS-i)*((TIMESTEP /RESOLUTION)/INCREMENTS)); 
    } 
  }
           
  //LED fade out
  for(i=1;i<INCREMENTS-10; i++)
  {
        
    for(j=0;j<RESOLUTION ;j++)
    {
      p <: x;
      wait(t, (INCREMENTS-i)*((TIMESTEP /RESOLUTION) /INCREMENTS));
      p <: 0;  
      wait(t, i*((TIMESTEP /RESOLUTION)/INCREMENTS  ));
     }
  }   
}

void doKeyLeds(chanend c)
{
  unsigned kledVal = 8; 
  unsigned kledValDir = 1;
  unsigned time, loopTerm = 1;
  timer t;
  
  while(loopTerm)
  { 
    t:> time;
    select
    {
      case c :> time:
      {
        if(time == CMD_KILL)
          loopTerm = 0;
        break;
      }
      case t when timerafter(time + 30000000) :> int tmpTime: 
      {
        fadeLed(p_kled, kledVal<<4);
        if(kledValDir)
        {
          kledVal >>= 1;  
          if(kledVal == 0)
          {
            kledVal = 2;
            kledValDir = !kledValDir;
          }    
        }
        else
        {
          kledVal <<= 1;  
        
          if(kledVal > 8) 
          {   
            kledVal = 4;
            kledValDir = !kledValDir;
          }
        }
        break;
      }
    }
  }
}

/**
 * @brief Watches buttons, sends kill cmd when buttons change to match killMask.  
 * @brief also responds to other threads requesting key values
 * @param c Chanend to thread that wants key data
 * @param killVal Mask of button values that will issue kill. e.g. if 0x1, button 1 is kill,
 * if 0xf any will issue kill
 * @return button value
 **/
unsigned doKeys(chanend c, unsigned killMask, in port p_key)
{
  unsigned newKeyVal,loopTerm = 1, oldKeyVal = 0xf;
  timer t; 
  wait(t, 100000); 
  // Wait for user to stop pressing keys

  p_key when pinseq(0xf) :> int _; 
 
  while(loopTerm)
  { 
    p_key when pinsneq(oldKeyVal) :> newKeyVal;
    oldKeyVal = newKeyVal;
    newKeyVal = (~newKeyVal);
      
    if((newKeyVal & killMask))  	// If killMask matched then send kill to thread
    {
      c <: CMD_KILL;
      loopTerm = 0;
    }
    else				// If not kill key(s) send to thread
    {
      c <: CMD_KEYVAL;
      c <: newKeyVal;
    }
    wait(t, 10000); 
  }
  //wait(t, 10000000);

  // Return button val when thread dies
  //printstrln("key led thread die");
  return newKeyVal;       
}

void clockLEDs(chanend cClock, chanend cLED[3])
{
  int x;
  while (1)
  {
    cClock :> x;
    
    p_cled_g <: x;
    x >>= 1;
    
    p_cled_r <: x;
    x >>= 1;
    
    p_cled_0 <: (x & 0x7) << 4;
    x >>= 3;
    cLED[0] <: (x & 0x7) << 4;
    x >>= 3;
    cLED[1] <: (x & 0x7) << 4;
    x >>= 3;
    cLED[2] <: (x & 0x7) << 4;
    
    cClock <: 1;
  }
}

void ledManager(chanend cLED, out port p)
{
  int x;
  while (1)
  {
    cLED :> x;
    p <: x;
  }
}

void doDemoLoop(in port p_key, chanend cClock)
{
  chan c;
  chan c1;

  unsigned buttonVal;

  while(1)
  { 
    // Read button vals
    p_key when pinseq(0xf) :> int _;
    p_key :> buttonVal;
    //buttonVal >>= 4;

    // Wait for user press or update LEDs 
    par
    {
      doClockLedGlow(c, c1, cClock);                 // Do something pretty on 'clock' LEDs
      buttonVal = doKeys(c, 0xf, p_key) ;           // Watchs keys and does key leds (returns button no)
                                             // (Any key kills)
      doKeyLeds(c1);			       // Do something pretty on the 'key' LEDs
    }

    // Button Pressed, run relevant demo
    if((buttonVal & 1) == 1)
      runDemo(0, p_key, cClock);
    else if((buttonVal & 2) == 2)
      runDemo(1, p_key, cClock);
    else if((buttonVal & 4) == 4)
      runDemo(2, p_key, cClock);
    else if((buttonVal & 8) == 8)
      runDemo(3, p_key, cClock);
  }
}

void doVersionLeds(chanend cClock)
{
  unsigned verNumMin = 1 << FIRMWARE_VER_MIN;
  unsigned verNumMaj = 1 << FIRMWARE_VER_MAJ;
  timer t;
  
  outClockLeds(0, 1, verNumMin, cClock); 
  
  verNumMaj <<= 4;
  
  p_kled <: verNumMaj; 

  wait(t, 50000000);
  
  outClockLeds(0, 0, verNumMin, cClock); 
  p_kled <: 0; 
}


int main2(chanend cClock)
{
  // Display version number on LEDs (in function so compiler frees timer)
  doVersionLeds(cClock); 
  set_port_pull_up(p_key);

  // Run demo loop
  doDemoLoop(p_key, cClock);
 
  return 0;
}

int main(void)
{
 chan cClock;
 chan cLED[3];
   
 par
 {
   on stdcore[0]: main2(cClock);
   on stdcore[0]: clockLEDs(cClock, cLED);
   on stdcore[1]: ledManager(cLED[0], p_cled_1);
   on stdcore[2]: ledManager(cLED[1], p_cled_2);
   on stdcore[3]: ledManager(cLED[2], p_cled_3);
 }

 return 0;
}

