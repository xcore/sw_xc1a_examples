/**
 * Module:  app_xc1a_firmware
 * Version: 1v3
 * Build:   0d899968f20a382e3779bfcd0446c7abe32cf649
 * File:    firmware.h
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

#ifndef _FIRMWARE_H_
#define _FIRMWARE_H_

#define CMD_KILL 	0
#define CMD_KEYVAL 	1
#define CMD_NOTE 	2
#define CMD_CLED 	3

#define FIRMWARE_VER_MAJ 1 
#define FIRMWARE_VER_MIN 2


// Add ascii offset
#define FIRMWARE_VER_MAJ_CHAR FIRMWARE_VER_MAJ + '0'
#define FIRMWARE_VER_MIN_CHAR FIRMWARE_VER_MIN + '0'



#endif
