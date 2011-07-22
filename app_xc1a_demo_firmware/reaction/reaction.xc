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

extern int note_delay[];

extern void ledDriver(chanend c_led, chanend cClock);

void sendLedVal(chanend c, unsigned o, unsigned r, unsigned g);

void doSoundGen_noLed(chanend c_snd)
{
  int note = -1, time, spkVal = 0, cmd, loop = 1;
  timer t;

  while(loop)
  {
    partout(p_spk, 1, spkVal);
    t :> time;
    select
    {
      case (note!=-1) => t when timerafter(time + note_delay[note]*100) :> int _:
        spkVal = !spkVal;
        break;

      case c_snd :> cmd:
        if(cmd == CMD_KILL)
          loop = 0;
        else if(cmd == CMD_NOTE)
          c_snd :> note;
          if(note == -1)
            spkVal = 0;
        break;
    }
  }
}

// REMOVED DUE TO SIZE RESTRICTIONS
/*void playStartGame(chanend c_snd)
{
timer t;

  c_snd <: CMD_NOTE;
  c_snd <: 3;
  wait(t, 10000000);

  for (int i = 0; i < 2; i++)
  {
    c_snd <: CMD_NOTE;
    c_snd <: 4;
    wait(t, 10000000);

    c_snd <: CMD_NOTE;
    c_snd <: 5;
    wait(t, 10000000);
  }

  c_snd <: CMD_NOTE;
  c_snd <: -1;

}*/

void playLose(chanend c_snd)
{
  timer t;

  c_snd <: CMD_NOTE;
  c_snd <: 6;
  wait(t, 10000000);

  c_snd <: CMD_NOTE;
  c_snd <: 5;
  wait(t, 10000000);

  c_snd <: CMD_NOTE;
  c_snd <: 4;
  wait(t, 10000000);

  c_snd <: CMD_NOTE;
  c_snd <: -1;

}

void playWin(chanend c_snd)
{
  timer t;

  c_snd <: CMD_NOTE;
  c_snd <: 4;
  wait(t, 10000000);

  c_snd <: CMD_NOTE;
  c_snd <: 5;
  wait(t, 10000000);

  c_snd <: CMD_NOTE;
  c_snd <: 6;
  wait(t, 10000000);

  c_snd <: CMD_NOTE;
  c_snd <: -1;

}

#define SPIN_DELAY 70000000

void doGameLogic(chanend c_key, chanend c_snd, chanend c_led)
{
  timer t, t2;
  unsigned time, time2, cledVal = 1, loop = 1, cmd;
  int killed = 0, gameloop =1;

  int level = 0;
  int spinDelay = SPIN_DELAY;
  int trigLed = 0;
  int tickCount;
  int win;
  int spinCount = 0;

  cledVal = 0xfff;

  // Flash clock leds until user press button
  // REMOVED DUE TO SPACE RESTRICTIONS
  /*while(loop)
  {
    t :> time;
    select
    {
      case t when timerafter(time + 10000000) :> int _:
        sendLedVal(c_led, 0, cledVal, 0);
        cledVal = ~cledVal;
        break;

      case c_key :> cmd:
        switch(cmd)
        {
          case CMD_KILL:
            loop = 0;    	// Kill loop
            killed = 1;		// Set killed flag
            break;

          case CMD_KEYVAL:
             c_key :> cmd;	// Get keyval

             if((cmd & 0x8)== 0x8)
               //p1 = 1;
             //if((cmd & 0x4) == 0x4)
               //p2 = 1;

             //if(p1 && p2)	// Both players ready, term loop
               loop = 0;
            break;
        }
        break;
    }
  }*/

  //playStartGame(c_snd);
  playWin(c_snd);
  if(!killed)
  {
    loop = 1;
    cledVal = 1;
    killed = 0;
  }

  while(loop)
  {
    p_kled <: 0xf << level;
    gameloop = 1;
    trigLed = 0;
    tickCount = 0;
    spinCount = 0;
    win = 0;

    t2 :> time2;	// Used for tigger delay
    t :> time;

    while(gameloop)
    {
      sendLedVal(c_led, 0, cledVal, trigLed);

      t:> time;
      select
      {
        case t when timerafter(time + spinDelay) :> int _: // Shift red leds
        {
          spinCount++;
          cledVal <<= 1;

          if(trigLed == 0 && spinCount > (((time%10)+7)))
          {
            if(cledVal > 0x20)
               trigLed  = cledVal >> 6;
            else
               trigLed = cledVal << 6;
          }

          if(cledVal == 0x1000)		// Wrap leds
            cledVal = 1;

          if(trigLed != 0)		// Count ticks since trig led lit
            tickCount++;

          if(tickCount > 12)		 // user didn't press in time
            gameloop = 0;

          break;
       }
       case c_key :> cmd:
       {
          switch(cmd)
          {
            case CMD_KILL:
              gameloop = 0;     	// Kill current game loop
              loop = 0;			// Kill main loop
              killed = 1;
              break;

            case CMD_KEYVAL:
               c_key :> cmd;	        // Get keyval
               if((cmd&8) == 8)		// Check for correct button ('D')
               {
                 gameloop = 0;
                 if(trigLed == cledVal) // Check if user won
                   win = 1;
               }
               break;
          }
          break;
        }
      }
    }// end of gameloop
    if(!killed)
    {
      if(win)
      {
        //playWin(c_snd);
        level++;
        spinDelay >>= 1;

        if(level == 5)
        {
          // Game completed!
          par
          {
            {
              for(int i = 0; i < 3; i++)
                playWin(c_snd);
            }

            {
              timer t;
              unsigned time, ledVal = 0;
              for (int i = 0; i < 20; i++)
              {
                 p_kled <: ledVal;
                 sendLedVal(c_led, 0,0,ledVal);
                 //c_led <: CMD_CLED;
                 //c_led <: 0;
                 //c_led <: 0;
                 //c_led <: ledVal;
                 ledVal = ~ledVal;
                 wait(t, 10000000);
              }
            }
          }

          level = 0;			// Start game again
          spinDelay = SPIN_DELAY;

        }
        else
        {
          par
          {

            playWin(c_snd);


            {
              timer tx;
              //unsigned time;

              for (int i = 0; i < 10; i++)
              {
                sendLedVal(c_led, 0, cledVal, cledVal);
                //c_led <: CMD_CLED;
                //c_led <: 0;
                //c_led <: cledVal;;
                //c_led <: cledVal;
                wait(tx, 10000000);

                sendLedVal(c_led, 0,0,0);
                //c_led <: CMD_CLED;
                //c_led <: 0;
                //c_led <: 0;
                //c_led <: 0;
                wait(tx, 10000000);

              }
            }
          }
        }
      }
      else
      {
        par
        {
          playLose(c_snd);

          {
            timer t;
            unsigned time;
            for (int i = 0; i < 10; i++)
            {
              sendLedVal(c_led, 0, cledVal, trigLed);
              //c_led <: CMD_CLED;
              //c_led <: 0;
              //c_led <: cledVal;
              //c_led <: trigLed;
              wait(t, 10000000);

              sendLedVal(c_led, 0, 0, 0);
              //c_led <: CMD_CLED;
              //c_led <: 0;
              //c_led <: 0;
              //c_led <: 0;
              wait(t, 10000000);
            }
          }
        }
        //level = 0;			// Start game again
        //spinDelay = SPIN_DELAY;

      }
    }
  }

  c_snd <: CMD_KILL;	// Kill sound gen thread
  c_led <: CMD_KILL;    // Kill clock led thread

  return ;
}


void runReaction(chanend c_key, chanend cClock)
{
  chan c_snd, c_led;
  par
  {
    //doSounds(c_key_snd, c_snd);
    doSoundGen_noLed(c_snd);
    //doButtons(c_key, c_key_snd);
    doGameLogic(c_key, c_snd, c_led);
    ledDriver(c_led, cClock);
  }
  //printstr("ending reaction\n");
  return;
}
