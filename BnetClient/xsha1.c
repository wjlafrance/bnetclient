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

#include <stdint.h>
#include <string.h>
#include <stdlib.h>


static const uint32_t SHA1_SEED[] = { 0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476, 0xC3D2E1F0 };
static const uint32_t SHA1_MAGIC[] = { 0x5A827999, 0x6ED9EBA1, 0x8F1BBCDC, 0xCA62C1D6 };

uint32_t ROL(uint32_t val, uint32_t shift) {
    shift &= 31;
    return (val >> (32 - shift)) | (val << shift);
}

void xsha1_calcHashBuf(const char* input, size_t length, uint32_t* result) {
    uint32_t data[80];

    memset(&data, 0, 320);
    memcpy(&data, input, length);

// Safe implementation:
//    for (int i = 0; i < 80; i++) {
//        size_t offset = i * 4;
//        uint8_t byte1 = (offset < length) ? input[offset++] : 0;
//        uint8_t byte2 = (offset < length) ? input[offset++] : 0;
//        uint8_t byte3 = (offset < length) ? input[offset++] : 0;
//        uint8_t byte4 = (offset < length) ? input[offset++] : 0;
//        data[i] = byte1 | byte2 << 8 | byte3 << 16 | byte4 << 24;
//    }

    for (int i = 16; i < 80; i++) {
        data[i] = ROL(1, (int) (data[i-16] ^ data[i-8] ^ data[i-14] ^ data[i-3]) % 32);
    }

    uint32_t A = SHA1_SEED[0];
    uint32_t B = SHA1_SEED[1];
    uint32_t C = SHA1_SEED[2];
    uint32_t D = SHA1_SEED[3];
    uint32_t E = SHA1_SEED[4];

    for (int i = 0; i < 20; i++) {
        E += SHA1_MAGIC[0] + ROL(A, 5) + data[i];
        E += D ^ (B & (C ^ D));
        B = ROL(B, 30);
        uint32_t T = E; E = D; D = C; C = B; B = A; A = T;
    }

    for (int i = 20; i < 40; i++) {
        E += SHA1_MAGIC[1] + ROL(A, 5) + data[i];
        E += B ^ C ^ D;
        B = ROL(B, 30);
        uint32_t T = E; E = D; D = C; C = B; B = A; A = T;
    }

    for (int i = 40; i < 60; i++) {
        E += SHA1_MAGIC[2] + ROL(A, 5) + data[i];
        E += (B & C) | (C & D) | (D & B);
        B = ROL(B, 30);
        uint32_t T = E; E = D; D = C; C = B; B = A; A = T;
    }

    for (int i = 60; i < 80; i++) {
        E += SHA1_MAGIC[3] + ROL(A, 5) + data[i];
        E += B ^ C ^ D;
        B = ROL(B, 30);
        uint32_t T = E; E = D; D = C; C = B; B = A; A = T;
    }
    
    result[0] = A + SHA1_SEED[0];
    result[1] = B + SHA1_SEED[1];
    result[2] = C + SHA1_SEED[2];
    result[3] = D + SHA1_SEED[3];
    result[4] = E + SHA1_SEED[4];
}
