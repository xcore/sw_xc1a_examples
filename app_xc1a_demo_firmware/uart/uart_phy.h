/**
 * Module:  app_xc1a_firmware
 * Version: 1v3
 * Build:   0d899968f20a382e3779bfcd0446c7abe32cf649
 * File:    uart_phy.h
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
 *
 * Copyright XMOS Ltd 2008
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
