// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>



#include <xs1.h>
//#include <safestring.h>
#include "audio_synth.h"
//#include <print.h>

typedef struct
{
  //int numSections;
  int startTime[10];
  int timePerSample[10];
  int ampStart[10];
  int ampDir[10];
  int ampDelta[10];
} FM_data;

#define SINE_WAVELENGTH 460
int Sinewave[SINE_WAVELENGTH];
/*{
 0, 402, 804, 1206, 1608, 2009, 2410, 2811, 3212, 3612, 4011, 4410, 4808, 5205, 5602, 5998, 6393, 6786, 7179, 7571, 7962, 8351, 8739, 9126, 9512, 9896, 10278, 10659, 11039, 11417, 11793, 12167, 12539, 12910, 13279, 13645, 14010, 14372, 14732, 15090, 15446, 15800, 16151, 16499, 16846, 17189, 17530, 17869, 18204, 18537, 18868, 19195, 19519, 19841, 20159, 20475, 20787, 21096, 21403, 21705, 22005, 22301, 22594, 22884, 23170, 23452, 23731, 24007, 24279, 24547, 24811, 25072, 25329, 25582, 25832, 26077, 26319, 26556, 26790, 27019, 27245, 27466, 27683, 27896, 28105, 28310, 28510, 28706, 28898, 29085, 29268, 29447, 29621, 29791, 29956, 30117, 30273, 30424, 30571, 30714, 30852, 30985, 31113, 31237, 31356, 31470, 31580, 31685, 31785, 31880, 31971, 32057, 32137, 32213, 32285, 32351, 32412, 32469, 32521, 32567, 32609, 32646, 32678, 32705, 32728, 32745, 32757, 32765,
 32767, 32765, 32757, 32745, 32728, 32705, 32678, 32646, 32609, 32567, 32521, 32469, 32412, 32351, 32285, 32213, 32137, 32057, 31971, 31880, 31785, 31685, 31580, 31470, 31356, 31237, 31113, 30985, 30852, 30714, 30571, 30424, 30273, 30117, 29956, 29791, 29621, 29447, 29268, 29085, 28898, 28706, 28510, 28310, 28105, 27896, 27683, 27466, 27245, 27019, 26790, 26556, 26319, 26077, 25832, 25582, 25329, 25072, 24811, 24547, 24279, 24007, 23731, 23452, 23170, 22884, 22594, 22301, 22005, 21705, 21403, 21096, 20787, 20475, 20159, 19841, 19519, 19195, 18868, 18537, 18204, 17869, 17530, 17189, 16846, 16499, 16151, 15800, 15446, 15090, 14732, 14372, 14010, 13645, 13279, 12910, 12539, 12167, 11793, 11417, 11039, 10659, 10278, 9896, 9512, 9126, 8739, 8351, 7962, 7571, 7179, 6786, 6393, 5998, 5602, 5205, 4808, 4410, 4011, 3612, 3212, 2811, 2410, 2009, 1608, 1206, 804, 402,
 0, -402, -804, -1206, -1608, -2009, -2410, -2811, -3212, -3612, -4011, -4410, -4808, -5205, -5602, -5998, -6393, -6786, -7179, -7571, -7962, -8351, -8739, -9126, -9512, -9896, -10278, -10659, -11039, -11417, -11793, -12167, -12539, -12910, -13279, -13645, -14010, -14372, -14732, -15090, -15446, -15800, -16151, -16499, -16846, -17189, -17530, -17869, -18204, -18537, -18868, -19195, -19519, -19841, -20159, -20475, -20787, -21096, -21403, -21705, -22005, -22301, -22594, -22884, -23170, -23452, -23731, -24007, -24279, -24547, -24811, -25072, -25329, -25582, -25832, -26077, -26319, -26556, -26790, -27019, -27245, -27466, -27683, -27896, -28105, -28310, -28510, -28706, -28898, -29085, -29268, -29447, -29621, -29791, -29956, -30117, -30273, -30424, -30571, -30714, -30852, -30985, -31113, -31237, -31356, -31470, -31580, -31685, -31785, -31880, -31971, -32057, -32137, -32213, -32285, -32351, -32412, -32469, -32521, -32567, -32609, -32646, -32678, -32705, -32728, -32745, -32757, -32765,
 -32767, -32765, -32757, -32745, -32728, -32705, -32678, -32646, -32609, -32567, -32521, -32469, -32412, -32351, -32285, -32213, -32137, -32057, -31971, -31880, -31785, -31685, -31580, -31470, -31356, -31237, -31113, -30985, -30852, -30714, -30571, -30424, -30273, -30117, -29956, -29791, -29621, -29447, -29268, -29085, -28898, -28706, -28510, -28310, -28105, -27896, -27683, -27466, -27245, -27019, -26790, -26556, -26319, -26077, -25832, -25582, -25329, -25072, -24811, -24547, -24279, -24007, -23731, -23452, -23170, -22884, -22594, -22301, -22005, -21705, -21403, -21096, -20787, -20475, -20159, -19841, -19519, -19195, -18868, -18537, -18204, -17869, -17530, -17189, -16846, -16499, -16151, -15800, -15446, -15090, -14732, -14372, -14010, -13645, -13279, -12910, -12539, -12167, -11793, -11417, -11039, -10659, -10278, -9896, -9512, -9126, -8739, -8351, -7962, -7571, -7179, -6786, -6393, -5998, -5602, -5205, -4808, -4410, -4011, -3612, -3212, -2811, -2410, -2009, -1608, -1206, -804, -402,};*/



// flat sound
//#define MUSIC_LENGTH 10
#define MUSIC_LENGTH 13
#define TEMPO 2000

#define ONE_SECOND 1000000000

#define SAMPLE_PERIOD ONE_SECOND/44000

#define CMD_DOSOUND 2
#define CMD_KILL 1


void player(chanend c_app, chanend synth)
{
  int currentSound = 0, cmd, loopTerm = 1;
  int waitLoopTerm = 1;
  
  FM_data fm_data[2];
     
  // tick
  //fm_data[0].numSections = 2;
  fm_data[0].startTime[0] = 0;
  fm_data[0].timePerSample[0] = (ONE_SECOND / 6500) / SINE_WAVELENGTH;
  fm_data[0].ampStart[0] = TEMPO;
  fm_data[0].ampDir[0] = 0;
  fm_data[0].ampDelta[0] = 30;

  fm_data[0].startTime[1] = 200;
  fm_data[0].timePerSample[1] = (ONE_SECOND / 6500) / SINE_WAVELENGTH;;
  fm_data[0].ampStart[1] = TEMPO>>1;
  fm_data[0].ampDir[1] = 0;
  fm_data[0].ampDelta[1] = 20;  
  
  // Tock
  //fm_data[1].numSections = 2;
  fm_data[1].startTime[0] = 0;
  fm_data[1].timePerSample[0] = (ONE_SECOND / 10000) / SINE_WAVELENGTH;;
  fm_data[1].ampStart[0] = TEMPO;
  fm_data[1].ampDir[0] = 0;
  fm_data[1].ampDelta[0] = 30;

  fm_data[1].startTime[1] = 200;
  fm_data[1].timePerSample[1] = (ONE_SECOND / 10000) / SINE_WAVELENGTH;;
  fm_data[1].ampStart[1] = TEMPO>>1;
  fm_data[1].ampDir[1] = 0;
  fm_data[1].ampDelta[1] = 20;  
  
  // Play the clock tick sound  
 

  while (loopTerm)
  { 
    c_app :> cmd;
    switch(cmd)
    {
      case AUDCMD_DOTICK: 
        synth <: CMD_DOSOUND;
        synth <: fm_data[currentSound];

        //synth :> cmd;
        while(waitLoopTerm)
        {
          select
          {
            case c_app :> cmd:	// Ignore new tick cmds until done
              if (cmd == AUDCMD_KILL)
              {
                loopTerm = 0;
                synth :> cmd;
                synth <: CMD_KILL; 
                waitLoopTerm = 0;
              }
              break;
 
            case synth :> cmd:
              waitLoopTerm = 0;
              break;
          }
        }
        waitLoopTerm = 1;
        currentSound = !currentSound;
        break;
      case AUDCMD_KILL:               // Die.. kill other threads
        loopTerm=0;
        synth <: CMD_KILL; 
        break;
    }    
  }   
}

// Generate a sine wave
void initSineTable()
{
  // IIR filter to generate sine 
  // from http://www.ee.ic.ac.uk/pcheung/teaching/ee3_Study_Project/Sinewave%20Generation(708).pdf
  int i;

  // 460
  const int A=0x7FFD; //0xFFFB; /* A=(1.999/2 * 32768) */
  int y[3]={0,0x192,0}; /* (y0,y1,y2), y1=(0.01227*32768) */
  
  for (i=0; i<2; i++) 
  {        
    Sinewave[i] = y[i] * 16 / 16 + 4096;    
  }  
  for (i=2; i<SINE_WAVELENGTH; i++) 
  {    
    //y[0] = ((A*y[1])>>15) - y[2];
    y[0] = (2 * ((A*y[1])>>15)) - y[2];
    //y[0] = (((A*y[1])>>15) + ((A*y[1])>>15)) - y[2];
    y[2] = y[1]; /* y2 < y1 */
    y[1] = y[0]; /* y1 < y0 */
    Sinewave[i] = y[0] *16/16 + 4096;  
  }    
}


void audio_synth(chanend player, chanend left)
{
  unsigned  i;
  unsigned int timePerSample;
  int currentTone;
  unsigned int fixedPointI;
  int amp;
  int ampDir;
  int ampDelta;
  unsigned int value;
  int currentSection;
  int currentSound;
  unsigned cmd, loopTerm = 1;
  
  FM_data fm_data;
     
  i=0;  
  fixedPointI = 0;
  currentTone = 0;
  
  currentSound = 0;
  
  while (loopTerm)
  {
    player :> cmd;
    switch(cmd)
    {
      case CMD_KILL:
        loopTerm = 0;
        outuint(left, CMD_KILL);
        outct(left, XS1_CT_END);
      break;

      case CMD_DOSOUND:

      player :> fm_data;
      
      amp=TEMPO;
      ampDir=0;
      ampDelta = 2;
    
      currentSection = 0;
  
      for(int j=0; j<TEMPO; j++)
      {    
        // frequency modulation.
        if (j == fm_data.startTime[currentSection])
        {
          ampDir = fm_data.ampDir[currentSection];
          amp = fm_data.ampStart[currentSection];
          ampDelta = fm_data.ampDelta[currentSection];
        
          timePerSample = fm_data.timePerSample[currentSection];
        
          currentSection++;
        }  
      
        if (ampDir == 0)  
        {  
          amp-=ampDelta;
          if (amp<=0)
          {  
            amp=0;
          }
        }
        else
        { 
          amp+=ampDelta;
          if (ampDir >= TEMPO)  
          {  
            amp=TEMPO;
          }
        }  
            
        if (currentTone != 1)
        {  
        
          // create the desired frequency
          fixedPointI += ((SAMPLE_PERIOD<<16)/timePerSample);
          if (fixedPointI >= (SINE_WAVELENGTH<<16))
          {
            fixedPointI -= (SINE_WAVELENGTH<<16);
          }
          
          i = (fixedPointI >> 16);


          // modulate the freq
          value = ((Sinewave[i]*(amp))/TEMPO);
          value = value * 1;
        }
        else
        {  // silent
          i=0;
          value = Sinewave[0];
        }    
     
        outuint(left, CMD_DOSOUND); 
        outuint(left, value);  // scale amplitude
           
      }
      player <: (unsigned) 1;
    break;
  }
 
  }
}

extern buffered out port:32 p_spk; 
 
void one_bit_dac(chanend left)
{ 
  int dacArray[33];
  int value;
  unsigned int dacValue, loopTerm = 1;
  int remainder = 0;
 
  // init dacArray
  dacArray[0] = 0;
  for(int i=1; i<=32; i+=1) 
  {
    unsigned int mask = 0;
    int sum = 0;
    int j;
    for(j=0; j<32; j+=1) 
    {
      mask = mask<<1;
      sum += i;
      if (sum >= 32) 
      {
        mask |= 1;
        sum -= 32;
      }
    }
    dacArray[i] = mask;
  }
  dacArray[32] = ~0;
   
#pragma unsafe arrays
  while (loopTerm)
  {        
    value = inuint(left);

    switch(value)
    {
      case CMD_KILL:
        loopTerm = 0;
        inct(left); 
        break;

      case CMD_DOSOUND:
        value = inuint(left); 
      for (int i=0; i<71; i++)
      {
          int k = (value+32768 + remainder);
          dacValue = k >> 11;
          remainder = k & 0x7ff;
          
          if (dacValue >= 32)
          {
              dacValue = 32;
          }  
          if (dacValue <= 0)
          {
              dacValue = 0;
          }  
          dacValue = dacArray[dacValue];
          
          p_spk <: dacValue;
      }
      break; 
    } 
  }
}


