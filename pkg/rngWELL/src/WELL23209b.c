/* ***************************************************************************** */
/* Copyright:      Francois Panneton and Pierre L'Ecuyer, University of Montreal */
/*                 Makoto Matsumoto, Hiroshima University                        */
/* Notice:         This code can be used freely for personal, academic,          */
/*                 or non-commercial purposes. For commercial purposes,          */
/*                 please contact P. L'Ecuyer at: lecuyer@iro.UMontreal.ca       */
/* ***************************************************************************** */
/*
 * WELL23209 is __entirely__ based on the code of WELL44497 by P. L'Ecuyer.
 * we just change constants, parameters to get WELL23209, add some
 * code to interface with R and add some comments on #define's.
 */


/* functions work like this :
 * state_i      function
 *
 *  0           case1
 *  1           case2
 *  2           case6
 *  ...         ...
 *  R-M3-1      case6
 *  R-M3        case5
 *  ...         ...
 *  R-M1-1      case5
 *  R-M1        case4
 *  ...         ...
 *  R-M2-1      case4
 *  R-M2        case3
 *  ...         ...
 *  R-1         case3
 */


#define W 32
#define R 726
#define P 23
#define MASKU (0xffffffffU>>(W-P))
#define MASKL (~MASKU)

#define M1 610
#define M2 175
#define M3 662

#include "WELLmatrices.h"

//details of the algorithm figure 1 of Panneton et al. (2006)
// state_i is       i mod R
//v_i,0
#define V0            STATE[state_i]
//v_i,m1, first when i > r-m1
#define VM1Over       STATE[state_i+M1-R]
#define VM1           STATE[state_i+M1]
//v_i,m2, first when i > r-m2
#define VM2Over       STATE[state_i+M2-R]
#define VM2           STATE[state_i+M2]
//v_i,m3, first when i > r-m3
#define VM3Over       STATE[state_i+M3-R]
#define VM3           STATE[state_i+M3]
//v_i,r-1, second when i < R
#define Vrm1          STATE[state_i-1]
#define Vrm1Under     STATE[state_i+R-1]
//v_i,r-2, second when i < R
#define Vrm2          STATE[state_i-2]
#define Vrm2Under     STATE[state_i+R-2]
//v_i+1,0, second when i < R
#define newV0         STATE[state_i-1]
#define newV0Under    STATE[state_i-1+R]
//v_i+1,1
#define newV1         STATE[state_i]
//v_i+1,r-1
#define newVRm1       STATE[state_i-2]
#define newVRm1Under  STATE[state_i-2+R]

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

double (*WELLRNG23209b)(void);

void InitWELLRNG23209b(unsigned int *init )
{
  int j;
  state_i=0;
  WELLRNG23209b = case_1;
  for(j=0;j<R;j++)
    STATE[j]=init[j];
}

void GetWELLRNG23209b (unsigned int *state)
{
  int j, k;
  j = 0;
  for (k = state_i; k < R; k++)
    state[j++] = STATE[k];
  for (k = 0; k < state_i; k++)
    state[j++] = STATE[k];
}

// state_i == 0
double case_1(void)
{
  z0 = (Vrm1Under & MASKL) | (Vrm2Under & MASKU);
  z1 = MAT2(0xa8c296d1,V0) ^ MAT1(VM1);
  z2 = MAT5(15,0x5d6b45cc,0xfffeffff,0x00000002,VM2) ^ MAT0NEG(-24,VM3);
  newV1  = z1 ^ z2;
  newV0Under = MAT0NEG(-26,z0) ^ MAT1(z1) ^ MAT7(z2) ^ MAT0POS(16,newV1);
  state_i = R-1;
  WELLRNG23209b = case_3;

  return ((double) STATE[state_i] * FACT);
}

// state_i == 1
static double case_2(void)
{
  z0 = (Vrm1 & MASKL) | (Vrm2Under & MASKU);
  z1 = MAT2(0xa8c296d1,V0) ^ MAT1(VM1);
  z2 = MAT5(15,0x5d6b45cc,0xfffeffff,0x00000002,VM2) ^ MAT0NEG(-24,VM3);
  newV1  = z1 ^ z2;
  newV0 = MAT0NEG(-26,z0) ^ MAT1(z1) ^ MAT7(z2) ^ MAT0POS(16,newV1);
  state_i=0;
  WELLRNG23209b = case_1;

  return ((double) STATE[state_i] * FACT);
}

// R-1 >= state_i >= R-M2
static double case_3(void)
{
  z0 = (Vrm1 & MASKL) | (Vrm2 & MASKU);
  z1 = MAT2(0xa8c296d1,V0) ^ MAT1(VM1Over);
  z2 = MAT5(15,0x5d6b45cc,0xfffeffff,0x00000002,VM2Over) ^ MAT0NEG(-24,VM3Over);
  newV1  = z1 ^ z2;
  newV0 = MAT0NEG(-26,z0) ^ MAT1(z1) ^ MAT7(z2) ^ MAT0POS(16,newV1);
  state_i--;
  if(state_i+M2<R)
    WELLRNG23209b = case_4;

  return ((double) STATE[state_i] * FACT);
}

// R-M2-1 >= state_i >= R-M1
static double case_4(void)
{
  z0 = (Vrm1 & MASKL) | (Vrm2 & MASKU);
  z1 = MAT2(0xa8c296d1,V0) ^ MAT1(VM1Over);
  z2 = MAT5(15,0x5d6b45cc,0xfffeffff,0x00000002,VM2) ^ MAT0NEG(-24,VM3Over);
  newV1  = z1 ^ z2;
  newV0 = MAT0NEG(-26,z0) ^ MAT1(z1) ^ MAT7(z2) ^ MAT0POS(16,newV1);
  state_i--;
  if (state_i+M1< R)
    WELLRNG23209b = case_5;

  return ((double) STATE[state_i] * FACT);
}

// R-M1-1 >= state_i >= R-M3
static double case_5(void)
{
  z0 = (Vrm1 & MASKL) | (Vrm2 & MASKU);
  z1 = MAT2(0xa8c296d1,V0) ^ MAT1(VM1);
  z2 = MAT5(15,0x5d6b45cc,0xfffeffff,0x00000002,VM2) ^ MAT0NEG(-24,VM3Over);
  newV1  = z1 ^ z2;
  newV0 = MAT0NEG(-26,z0) ^ MAT1(z1) ^ MAT7(z2) ^ MAT0POS(16,newV1);
  state_i--;
  if(state_i+M3 < R)
    WELLRNG23209b = case_6;

  return ((double) STATE[state_i] * FACT);
}

// R-M3-1 >= state_i >= 2
static double case_6(void)
{
  z0 = (Vrm1 & MASKL) | (Vrm2 & MASKU);
  z1 = MAT2(0xa8c296d1,V0) ^ MAT1(VM1);
  z2 = MAT5(15,0x5d6b45cc,0xfffeffff,0x00000002,VM2) ^ MAT0NEG(-24,VM3);
  newV1  = z1 ^ z2;
  newV0 = MAT0NEG(-26,z0) ^ MAT1(z1) ^ MAT7(z2) ^ MAT0POS(16,newV1);
  state_i--;
  if(state_i == 1 )
    WELLRNG23209b = case_2;

  return ((double) STATE[state_i] * FACT);
}

