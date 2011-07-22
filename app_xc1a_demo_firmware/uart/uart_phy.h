// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*
 * Link layer implementation of simple RS232 UART.
 *
 * NOTE: UART is fixed to following configuration.
 *       Data     : 8bits.
 *       Parity   : None.
 *       StartBit : 1bit.
 *       StopBit  : 1bit.
 *       FlowCtl  : None.
 *
 * Following UART baud rates are supported.
 *
 *  UART_2400   = 2400,
 *  UART_4800   = 4800,
 *  UART_9600   = 9600,
 *  UART_14400  = 14400,
 *  UART_19200  = 19200,
 *  UART_38400  = 38400,
 *  UART_57600  = 57600,
 *  UART_115200 = 115200,
 *  UART_230400 = 230400,
 *  UART_460800 = 460800,
 *  UART_921600 = 921600
 */

#ifndef _UART_PHY_H_
#define _UART_PHY_H_ 1

// Avaliable UART baud rate.
typedef enum
{
   UART_2400   = 2400,
   UART_4800   = 4800,
   UART_9600   = 9600,
   UART_14400  = 14400,
   UART_19200  = 19200,
   UART_38400  = 38400,
   UART_57600  = 57600,
   UART_115200 = 115200,
   UART_230400 = 230400,
   UART_460800 = 460800,
   UART_921600 = 921600
} UART_BAUD_RATE_t;

#define NEW_LINE_CHAR ('\n')


/** This initialise the UART and do sanity checking
 *  Its fixed to, Data : 8bits, Parity : None, Stop : 1bit, Flow contorl : none.
 */
void uart_configure(UART_BAUD_RATE_t baud_rate);

/** UART receive a character.
 *  This is blocking call for now.
 */
{unsigned char, int} uart_getch(chanend c_keys);

/** UART transmit a character.
 *  This is blocking call for now.
 */
void uart_putch(unsigned char buffer);


#endif
