/*
 MBNCSUtil -- Managed Battle.net Authentication Library
 Copyright (C) 2005-2008 by Robert Paveza
 X-SHA-1 ported to C by wjlafrance, January 3rd 2013.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.) Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.
 2.) Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 3.) The name of the author may not be used to endorse or promote products derived
 from this software without specific prior written permission.
 
 See LICENSE.TXT that should have accompanied this software for full terms and
 conditions.
 */

#ifndef XSHA1_H
#define XSHA1_H

void xsha1_calcHashBuf(const char* input, size_t length, uint32_t* result);

#endif // XSHA1_Hs