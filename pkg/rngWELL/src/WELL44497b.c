/* ***************************************************************************** */
/* Copyright:      Francois Panneton and Pierre L'Ecuyer, University of Montreal */
/*                 Makoto Matsumoto, Hiroshima University                        */
/* Notice:         This code can be used freely for personal, academic,          */
/*                 or non-commercial purposes. For commercial purposes,          */
/*                 please contact P. L'Ecuyer at: lecuyer@iro.UMontreal.ca       */
/* ***************************************************************************** */

// This file is a copy of the file
//   http://www.iro.umontreal.ca/~panneton/well/WELL44497a.c
// modified as if #define TEMPERING is in effect and with further minor formatting
// modifications and extended with the function GetWELLRNG44497b()
// for interface to R package randtoolbox/rngWELL by Ch. Dutang and P. Savicky.

/* the assignment of cases is as follows
 * state_i      function
 *
 *  0           case1
 *  1           case2
 *  2           case6
 *  ...         ...
 *  R-M2-1      case6
 *  R-M2        case5
 *  ...         ...
 *  R-M3-1      case5
 *  R-M3        case4
 *  ...         ...
 *  R-M1-1      case4
 *  R-M1        case3
 *  ...         ...
 *  R-1         case3
 */

#define W 32
#define R 1391
#define P 15
#define MASKU (0xffffffffU>>(W-P))
#define MASKL (~MASKU)

#define M1 23
#define M2 481
#define M3 229

#define TEMPERB 0x93dd1400U
#define TEMPERC 0xfa118000U

#include "WELLmatrices.h"
#include "WELLindexing.h"

#define FACT 2.32830643653869628906e-10

static unsigned int STATE[R];
static unsigned int z0,z1,z2,y;
static int state_i=0;

static double case_1(void);
static double case_2(void);
static double case_3(void);
static double case_4(void);
static double case_5(void);
static double case_6(void);

double (*WELLRNG44497b)(void);

void InitWELLRNG44497b(unsigned int *init ){
  int j;
  state_i=0;
  WELLRNG44497b = case_1;
  for(j=0;j<R;j++)
    STATE[j]=init[j];
}

void GetWELLRNG44497b (unsigned int *state){
  int j, k;
  j = 0;
  for (k = state_i; k < R; k++)
    state[j++] = STATE[k];
  for (k = 0; k < state_i; k++)
    state[j++] = STATE[k];
}

// state_i == 0
double case_1(void){
  z0 = (Vrm1Under & MASKL) | (Vrm2Under & MASKU);
  z1 = MAT0NEG(-24,V0) ^ MAT0POS(30,VM1);
  z2 = MAT0NEG(-10,VM2) ^ MAT3NEG(-26,VM3);
  newV1  = z1 ^ z2;
  newV0Under = MAT1(z0) ^ MAT0POS(20,z1) ^  MAT5(9,0xb729fcecU,0xfbffffffU,0x00020000U,z2) ^ MAT1(newV1);
  state_i = R-1;
  WELLRNG44497b = case_3;

  y = STATE[state_i] ^ ((STATE[state_i] << 7) & TEMPERB);
  y =              y ^ ((             y << 15) & TEMPERC);
  return ((double) y * FACT);
}

// state_i == 1
static double case_2(void){
  z0 = (Vrm1 & MASKL) | (Vrm2Under & MASKU);
  z1 = MAT0NEG(-24,V0) ^ MAT0POS(30,VM1);
  z2 = MAT0NEG(-10,VM2) ^ MAT3NEG(-26,VM3);
  newV1 = z1 ^ z2;
  newV0 =  MAT1(z0) ^ MAT0POS(20,z1) ^ MAT5(9,0xb729fcecU,0xfbffffffU,0x00020000U,z2) ^ MAT1(newV1);
  state_i=0;
  WELLRNG44497b = case_1;

  y = STATE[state_i] ^ ((STATE[state_i] << 7) & TEMPERB);
  y =              y ^ ((             y << 15) & TEMPERC);
  return ((double) y * FACT);
}

// R-1 >= state_i >= R-M1
static double case_3(void){
  z0    = (Vrm1 & MASKL) | (Vrm2 & MASKU);
  z1    = MAT0NEG(-24,V0) ^ MAT0POS(30,VM1Over);
  z2    = MAT0NEG(-10,VM2Over) ^ MAT3NEG(-26,VM3Over);
  newV1 = z1 ^ z2;
  newV0 = MAT1(z0) ^ MAT0POS(20,z1) ^ MAT5(9,0xb729fcecU,0xfbffffffU,0x00020000U,z2) ^ MAT1(newV1);
  state_i--;
  if(state_i+M1<R)
    WELLRNG44497b = case_4;

  y = STATE[state_i] ^ ((STATE[state_i] << 7) & TEMPERB);
  y =              y ^ ((             y << 15) & TEMPERC);
  return ((double) y * FACT);
}

// R-M1-1 >= state_i >= R-M3
static double case_4(void){
  z0    = (Vrm1 & MASKL) | (Vrm2 & MASKU);
  z1    = MAT0NEG(-24,V0) ^ MAT0POS(30,VM1);
  z2    = MAT0NEG(-10,VM2Over) ^ MAT3NEG(-26,VM3Over);
  newV1 = z1 ^ z2;
  newV0 = MAT1(z0) ^ MAT0POS(20,z1) ^ MAT5(9,0xb729fcecU,0xfbffffffU,0x00020000U,z2) ^ MAT1(newV1);
  state_i--;
  if (state_i+M3 < R)
    WELLRNG44497b = case_5;

  y = STATE[state_i] ^ ((STATE[state_i] << 7) & TEMPERB);
  y =              y ^ ((             y << 15) & TEMPERC);
  return ((double) y * FACT);
}

// R-M3-1 >= state_i >= R-M2
static double case_5(void){
  z0    = (Vrm1 & MASKL) | (Vrm2 & MASKU);
  z1    = MAT0NEG(-24,V0) ^ MAT0POS(30,VM1);
  z2    = MAT0NEG(-10,VM2Over) ^ MAT3NEG(-26,VM3);
  newV1 = z1 ^ z2;
  newV0 = MAT1(z0) ^ MAT0POS(20,z1) ^ MAT5(9,0xb729fcecU,0xfbffffffU,0x00020000U,z2) ^ MAT1(newV1);
  state_i--;
  if(state_i+M2 < R)
    WELLRNG44497b = case_6;

  y = STATE[state_i] ^ ((STATE[state_i] << 7) & TEMPERB);
  y =              y ^ ((             y << 15) & TEMPERC);
  return ((double) y * FACT);
}

// R-M2-1 >= state_i >= 2
static double case_6(void){
  z0    = (Vrm1 & MASKL) | (Vrm2 & MASKU);
  z1    = MAT0NEG(-24,V0) ^ MAT0POS(30,VM1);
  z2    = MAT0NEG(-10,VM2) ^ MAT3NEG(-26,VM3);
  newV1 = z1 ^ z2;
  newV0 = MAT1(z0) ^ MAT0POS(20,z1) ^ MAT5(9,0xb729fcecU,0xfbffffffU,0x00020000U,z2) ^ MAT1(newV1);
  state_i--;
  if(state_i == 1 )
    WELLRNG44497b = case_2;

  y = STATE[state_i] ^ ((STATE[state_i] << 7) & TEMPERB);
  y =              y ^ ((             y << 15) & TEMPERC);
  return ((double) y * FACT);
}

