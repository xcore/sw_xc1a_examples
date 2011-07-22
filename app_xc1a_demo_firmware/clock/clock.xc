// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>


#include <xs1.h>
#include "firmware.h"
#include "audio_synth.h"
#include <print.h>

#define HALF_SECOND 		50000000

#define DELAY       		HALF_SECOND
#define DELAY_FAST  		50000
#define FLASH_ON 	    	5000
#define FLASH_OFF		    500

extern void outClockLeds(int r, int g, int x, chanend cClock);
extern out port p_kled;
extern in port p_key;

extern void player(chanend c, chanend synth);
extern void audio_synth( chanend player, chanend left);
extern void one_bit_dac(chanend left);
extern void wait(timer tmr, unsigned delay);
extern void initSineTable();

void patternGen(chanend c, chanend c_led, chanend c_audio)
{
  timer t;
  unsigned time;
  unsigned ledVal = 0xf0;
  int secs = 0x1;
  unsigned mins = 0x1 << 11;
  unsigned hours = 0x1 << 11;
  unsigned delay = DELAY;
  unsigned tmp, loopTerm = 1;
  unsigned secCount = 0;
  int reSync = 1;
  int soundOn = 1;
 
  // Update LEDS to initial
  c_led <: CMD_CLED;
  c_led <: secs;
  c_led <: hours;
  c_led <: mins;
  p_kled <: ledVal;

  t :> time;

  while(loopTerm)
  {
    if(reSync)
    {
     t:>time;
     reSync=0;
    }
    time+=delay; 
       
    select
    {
      case c :> tmp:                   // Input from keys. Could be kill or key values
      { 
        switch(tmp)
        {
          case CMD_KILL:
            loopTerm = 0;              // Kill loop
            c_led <: CMD_KILL;      // kill other threads
            c_audio <: AUDCMD_KILL;
            break;

          case CMD_KEYVAL:
             c :> tmp;                  // Input key value      
  
            if((tmp & 2) == 2)          // Key 1 pressed... Speedup while pressed
            {
              delay = DELAY_FAST;
              reSync = 1;
            }
            else                          
            {
              delay = DELAY;
              reSync = 1;
            }

            if((tmp & 4) == 4)		// Key 2 pressed... sound on
            {
              soundOn = 1;
            }

            if((tmp & 8) == 8)
            {
              soundOn = 0;	        // Key 3 pressed... sound off
            }  
            break;
        }
        break;
      }
      case t when timerafter(time) :> int _:
      {
        if(soundOn) 
        c_audio <: AUDCMD_DOTICK;
        time+=delay;

        secCount++;
  
        if(secCount == 5)
        {
          // Shift Vals
          // Clock wise
          secs <<= 1;
          if(secs > 0x800)
          {
            secs = 0x1;
            ledVal>>=1;
            if(ledVal == 0x7)
            { 
              ledVal = 0xf0;
              mins <<= 1;
              if(mins>0x800)
              {
                mins = 0x1;
                hours <<= 1;
                if(hours>0x800)
                  hours = 1;
              } 
            } 
          }

          secCount = 0;
        }

        // Update LEDS
        c_led <: CMD_CLED;
        c_led <: secs;
        c_led <: hours;
        c_led <: mins;
        p_kled <: ledVal;

        break;
      }
    }
  }
}

int yellowCounter = 0;

void outputLedVals(unsigned redVal, unsigned greenVal, unsigned yellowVal, chanend cClock)
{
  timer t;
  
  outClockLeds(1, 0, redVal, cClock);   
  wait(t, FLASH_ON);

  outClockLeds(0, 1, greenVal, cClock);   
  wait(t, FLASH_ON); 
 
  if(yellowCounter <5)
  {
    outClockLeds(0, 1, yellowVal, cClock);   
  }
  else 
  {
    outClockLeds(1, 0, yellowVal, cClock);   
    yellowCounter = 0;
  }

  yellowCounter++;
  wait(t, FLASH_ON);
  outClockLeds(0, 0, yellowVal, cClock); 
}

// Send led vals to led driver
void sendLedVal(chanend c, unsigned o, unsigned r, unsigned g)
{
  c <: CMD_CLED;
  c <: o;
  c <: r;
  c <: g;
}


void ledDriver(chanend c_led, chanend cClock)
{
  unsigned pattern_g = 0;
  unsigned pattern_r = 0;
  unsigned pattern_y = 0;
  unsigned time, cmd, loopTerm = 1;
  timer t;
  
  while(loopTerm)
  {
    t :> time;
    select
    {
      case c_led :> cmd:
      {
        switch(cmd)
        {
          case CMD_CLED:
            c_led :> pattern_y;
            c_led :> pattern_r;
            c_led :> pattern_g;
            break;
          case CMD_KILL:
            loopTerm = 0;
            break;
        }
        break;
      }
      case t when timerafter(time+500) :> int _:
        outputLedVals(pattern_r, pattern_g, pattern_y, cClock);
        break;
    }
  }
}
extern int Sinewave[];

void runClock(chanend c, chanend cClock)
{
  chan c_led, c_synth, c_left, c_audio;
    
  initSineTable();
 
  par
  {
    patternGen(c, c_led, c_audio);
    ledDriver(c_led, cClock);
    player(c_audio, c_synth);
    audio_synth(c_synth, c_left);
    one_bit_dac(c_left); 
  }
}
 



