// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>


#include <xs1.h>
#include "firmware.h"
#include <print.h>

extern void outClockLeds(int r, int g, int x, chanend cClock);
extern out port p_kled;
extern in port p_key;
extern buffered out port:32 p_spk; 

extern void wait(timer, unsigned);

extern void doSoundGen_noLed(chanend c_snd);

extern void ledDriver(chanend c_led, chanend cClock);

void sendLedVal(chanend c, unsigned o, unsigned r, unsigned g);

#define NOTE_COUNT 8
int note_delay[NOTE_COUNT]= {955, 851, 758, 716, 638, 568, 506, 478};

/*void doSoundGen(chanend c_snd)
{
  int note = -1, time, spkVal = 0, cmd, loop = 1, ledVal = 0;
  timer t;
  p_cled_r <: 1;
  p_cled_g <: 0;

  while(loop)
  {
    p_spk:1 <: spkVal;
    spkVal = !spkVal;
    t :> time;
    select
    {
      case (note!=-1) => t when timerafter(time + note_delay[note]*100) :> int _:
        break;

      case c_snd :> cmd:
        switch(cmd)
        {
          case CMD_KILL:
            loop = 0;
            break;
          case CMD_NOTE:
            c_snd :> note;
            ledVal = 1 << note;
            p_cled_0 <: ledVal;
            p_cled_1 <: ledVal >> 4;
            p_cled_2 <: ledVal >> 8;
            break;
        }
        break;
    }
  }
}*/


void doSounds(chanend c_key_snd, chanend c_snd, chanend c_led)
{
  int loop = 1, time, cmd;
  unsigned keyVal;
  timer t;

  // Do scale when startup
  for(int i = 0; i < NOTE_COUNT; i++)
  {  
     c_snd <: CMD_NOTE;
     c_snd <: i; 
     sendLedVal(c_led, 0, (1<<i), 0xfff ^ (1<<i));
     t :> time;
     select
     {
       case t when timerafter(time + 20000000) :> int _:
         break;
 
       case c_key_snd :> cmd:
         switch(cmd)
         { 
           case CMD_KILL:
             i = NOTE_COUNT;	// Kill the loop;
             loop = 0;
             break;
           case CMD_KEYVAL:	// Ignore keyvals
             c_key_snd :> cmd;
             break;
         }
         break;
           
     }
  }
  sendLedVal(c_led, 0, 0, 0xfff);
  c_snd <: CMD_NOTE;
  c_snd <: -1;

  
  while(loop)
  { 
    c_key_snd :> cmd;
   
    switch(cmd)
    {
      case CMD_KEYVAL:
        c_key_snd :> keyVal;         
        c_snd <: CMD_NOTE;
  
        if((keyVal&0xf) == 0)
        {  c_snd <: -1;
          sendLedVal(c_led, 0, 0, 0xfff);
 	}
        else
        { c_snd <: (keyVal&0xf)>>1; 
          sendLedVal(c_led, 0, (1 << ((keyVal&0xf)>>1)), 0xfff ^ (1 << ((keyVal&0xf)>>1)));
        }
         break;
       case CMD_KILL:
         loop = 0;
         break;
    }
  }
  c_snd <: CMD_KILL;
  c_led <: CMD_KILL;
}

void doButtons(chanend c, chanend c_key_snd)
{
  unsigned tmp, loop = 1;
 
  while(loop)
  {
    c :> tmp;
    switch(tmp)
    {
      case CMD_KILL:
        loop = 0;              // Kill loop
        c_key_snd <: CMD_KILL;
        break;

       case CMD_KEYVAL:
         c :> tmp; 
         c_key_snd <: CMD_KEYVAL;
         c_key_snd <: tmp;
         break;
    }
  }
}

void runAudio(chanend c_key, chanend cClock)
{ 
  chan c_key_snd, c_snd, c_led;
  par
  {
    doSounds(c_key_snd, c_snd, c_led);
    doSoundGen_noLed(c_snd);
    doButtons(c_key, c_key_snd);
    //doClockLeds(c_key_leds);
    ledDriver(c_led, cClock);
  } 
}
