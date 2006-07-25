
CONTENT:

C  Ansari Test Statistic

C ##############################################################################

c Routine AS 93 returns frequencies. The following short routine calculates
c the distribution function from these frequencies (overwriting them).
c The calling arguments are as for AS 93. The distribution function is
c returned in array A1. The first element in A1 is F(ASTART).  N.B. ASTART
c is a real variable.
c
      subroutine wprob(test, other, astart, a1, l1, a2, a3, ifault)
      
      integer test, other, l1, ifault
      
      real*8 astart, a1(l1), a2(l1), a3(l1)
c
c     Local variables
c
      real*8 zero, sum
      data zero /0.0/
c
      call asgscale(test, other, astart, a1, l1, a2, a3, ifault)
      if (ifault .ne. 0) return
c
c     Scale column of F
c
      nrows = 1 + (test * other)/2
      sum = zero
      do 10 i = 1, nrows
         sum = sum + a1(i)
         a1(i) = sum
   10 continue
      do 20 i = 1, nrows
   20 a1(i) = a1(i) / sum
c
      return
      end

      
c-------------------------------------------------------------------------------


      SUBROUTINE asgscale(TEST,OTHER,ASTART,A1,L1,A2,A3,IFAULT)
C
C         ALGORITHM AS 93 APPL. STATIST. (1976) VOL.25, NO.1
C
C         FROM THE SIZES OF TWO SAMPLES THE DISTRIBUTION OF THE
C         ANSARI-BRADLEY TEST FOR SCALE IS GENERATED IN ARRAY A1.
C
      real*8 ASTART, A1(L1), A2(L1), A3(L1)
        
        
      REAL*8 AI, ONE, FPOINT
      INTEGER TEST, OTHER
      LOGICAL SYMM
      DATA ONE /1.0D0/
C
C         TYPE CONVERSION (EFFECT DEPENDS ON TYPE STATEMENT ABOVE).
C
      FPOINT(I) = I
C
C         CHECK PROBLEM SIZE AND DEFINE BASE VALUE OF THE DISTRIBUTION.
C
      M = MIN0(TEST, OTHER)
      IFAULT = 2
      IF (M. LT. 0) RETURN
      ASTART = FPOINT((TEST + 1) / 2) * FPOINT(1 + TEST / 2)
      N = MAX0(TEST, OTHER)
C
C         CHECK SIZE OF RESULT ARRAY.
C
      IFAULT = 1
      LRES = 1 + (M * N) / 2
      IF (L1 .LT. LRES) RETURN
      SYMM = MOD(M + N, 2) .EQ. 0
C
C         TREAT SMALL SAMPLES SEPARATELY.
C
        MM1 = M - 1
        IF (M .GT. 2) GOTO 5
C
C         START-UP PROCEDURES ONLY NEEDED.
C
        IF (MM1) 1, 2, 3
C
C         ONE SAMPLE ONLY.
C
1       A1(1) = ONE
        GOTO 15
C
C         SMALLER SAMPLE SIZE = 1.
C
2        CALL START1(N, A1, L1, LN1)
        GOTO 4
C
C         SMALLER SAMPLE SIZE = 2.
C
3       CALL START2(N, A1, L1, LN1)
C
C       RETURN IF A1 IS NOT IN REVERSE ORDER.
C
4       IF (SYMM .OR. (OTHER .GT. TEST)) GOTO 15
        GOTO 13
C
C         FULL GENERATOR NEEDED
C         SET UP INITIAL CONDITIONS (DEPENDS ON MOD(N, 2)).
C
5       NM1 = N - 1
        NM2 = N - 2
        MNOW = 3
        NC = 3
        IF (MOD(N, 2) .EQ. 1) GOTO 6
C         SET UP FOR EVEN N.
C
        N2B1 = 3
        N2B2 = 2
        CALL START2(N, A1, L1, LN1)
        CALL START2(NM2, A3, L1, LN3)
        CALL START1(NM1, A2, L1, LN2)
        GOTO 8
C
C         SET UP FOR ODD N.
C
6       N2B1 = 2
        N2B2 = 3
        CALL START1(N, A1, L1, LN1)
        CALL START2(NM1, A2, L1, LN2)
C
C         INCREASE ORDER OF DISTRIBUTION IN A1 BY 2
C         (USING A2 AND IMPLYING A3).
C
7       CALL FRQADD(A1, LN1, L1OUT, L1, A2, LN2, N2B1)
        LN1 = LN1 + N
        CALL IMPLY(A1, L1OUT, LN1, A3, LN3, L1, NC)
        NC = NC + 1
        IF (MNOW .EQ. M) GOTO 9
        MNOW = MNOW + 1
C
C         INCREASE ORDER OF DISTRIBUTION IN A2 BY 2 (USING A3).
C
8       CALL FRQADD(A2, LN2, L2OUT, L1, A3, LN3, N2B2)
        LN2 = LN2 + NM1
        CALL IMPLY(A2, L2OUT, LN2, A3, J, L1, NC)
        NC = NC + 1
        IF (MNOW .EQ. M) GOTO 9
        MNOW = MNOW + 1
        GOTO 7
C
C         IF SYMMETRICAL, RESULTS IN A1 ARE COMPLETE.
C
9       IF (SYMM) GOTO 15
C
C         FOR A SKEW RESULT ADD A2 (OFFSET) INTO A1.
C
        KS = (M + 3) / 2
        J = 1
        DO 12 I = KS, LRES
        IF (I .GT. LN1) GOTO 10
        A1(I) = A1(I) + A2(J)
        GOTO 11
10      A1(I) = A2(J)
11      J = J + 1
12      CONTINUE
C
C         DISTRIBUTION IN A1 POSSIBLY IN REVERSE ORDER.
C
        IF (OTHER .LT. TEST) GOTO 15
C
C         REVERSE THE RESULTS IN A1.
C
13      J = LRES
        NDO = LRES / 2
        DO 14 I = 1, NDO
        AI = A1(I)
        A1(I) = A1(J)
        A1(J) = AI
        J = J - 1
14      CONTINUE
C
C         FINAL RESULTS NOW IN A1.
C
15      IFAULT = 0

      
        RETURN
        END

       
c ------------------------------------------------------------------------------


        SUBROUTINE START1(N, F, L, LOUT)
C
C         ALGORITHM AS 93.1 APPL. STATIST. (1976) VOL.25, NO.1
C
C         GENERATES A 1,N ANSARI-BRADLEY DISTRIBUTION IN F.
C
        REAL*8 F(L) 
        REAL*8 ONE, TWO
        DATA ONE, TWO /1.0D0, 2.0D0/
        LOUT = 1 + N / 2
        DO 1 I = 1, LOUT
1       F(I) = TWO
        IF (MOD(N, 2) .EQ. 0) F(LOUT) = ONE
        RETURN
        END

        
c ------------------------------------------------------------------------------


        SUBROUTINE START2(N, F, L, LOUT)
C
C         ALGORITHM AS 93.2 APPL. STATIST. (1976) VOL.25, NO.1
C
C         GENERATES A 2,N ANSARI-BRADLEY DISTRIBUTION IN F.
C
        REAL*8 F(L)
        REAL*8 ONE, TWO, THREE, FOUR
        DATA ONE, TWO, THREE, FOUR /1.0D0, 2.0D0, 3.0D0, 4.0D0/
C
C         DERIVE F FOR 2, NU, WHERE NU IS HIGHEST EVEN INTEGER
C         LESS THAN OR EQUAL TO N.
C         DEFINE NU AND ARRAY LIMITS.
C
        NU = N - MOD(N, 2)
        J = NU + 1
        LOUT = J
        LT1 = LOUT + 1
        NDO = LT1 / 2
        A = ONE
        B = THREE
C
C         GENERATE THE SYMMETRICAL 2,NU DISTRIBUTION.
C
        DO 1 I = 1, NDO
        F(I) = A
        F(J) = A
        J = J - 1
        A = A + B
        B = FOUR - B
1       CONTINUE
        IF (NU .EQ. N) RETURN
C
C         ADD AN OFFSET 1,N DISTRIBUTION INTO F TO GIVE 2,N RESULT.
C
        NU = NDO + 1
        DO 2 I = NU, LOUT
2       F(I) = F(I) + TWO
        F(LT1) = TWO
        LOUT = LT1
        RETURN
        END
C

c ------------------------------------------------------------------------------


        SUBROUTINE FRQADD(F1, L1IN, L1OUT, L1, F2, L2, NSTART)
C
C         ALGORITHM AS 93.3 APPL. STATIST. (1976) VOL.25, NO.1
C
C         ARRAY F1 HAS TWICE THE CONTENTS OF ARRAY F2 ADDED INTO IT
C         STARTING WITH ELEMENTS NSTART AND 1 IN F1 AND F2 RESPECTIVELY.
C
        REAL*8 F1(L1), F2(L2)
        REAL*8 MUL2
        DATA MUL2 /2.0D0/
        I2 = 1
        DO 1 I1 = NSTART, L1IN
        F1(I1) = F1(I1) + MUL2 * F2(I2)
        I2 = I2 + 1
1       CONTINUE
        NXT = L1IN + 1
        L1OUT = L2 + NSTART - 1
        DO 2 I1 = NXT, L1OUT
        F1(I1) = MUL2 * F2(I2)
        I2 = I2 + 1
2       CONTINUE
        NSTART = NSTART + 1
        RETURN
        END

        
c ------------------------------------------------------------------------------


        SUBROUTINE IMPLY(F1, L1IN, L1OUT, F2, L2, L2MAX, NOFF)
C
C         ALGORITHM AS 93.4 APPL. STATIST. (1976) VOL.25, NO.1
C
C         GIVEN L1IN ELEMENTS OF AN ARRAY F1, A SYMMETRICAL
C         ARRAY F2 IS DERIVED AND ADDED ONTO F1, LEAVING THE
C         FIRST NOFF ELEMENTS OF F1 UNCHANGED AND GIVING A
C         SYMMETRICAL RESULT OF L1OUT ELEMENTS IN F1.
C
        REAL*8 F1(L1OUT), F2(L2MAX)
        REAL*8 SUM, DIFF
C
C         SET-UP SUBSCRIPTS AND LOOP COUNTER.
C
        I2 = 1 - NOFF
        J1 = L1OUT
        J2 = L1OUT - NOFF
        L2 = J2
        J2MIN = (J2 + 1) / 2
        NDO = (L1OUT + 1) / 2
C
C         DERIVE AND IMPLY NEW VALUES FROM OUTSIDE INWARDS.
C
        DO 6 I1 = 1, NDO
C
C         GET NEW F1 VALUE FROM SUM OF L/H ELEMENTS OF
C         F1 + F2 (IF F2 IS IN RANGE).
C
        IF (I2 .GT. 0) GOTO 1
        SUM = F1(I1)
        GOTO 2
1       SUM = F1(I1) + F2(I2)
C
C         REVISE LEFT ELEMENT OF F1.
C
        F1(I1) = SUM
C
C         IF F2 NOT COMPLETE IMPLY AND ASSIGN F2 VALUES
C         AND REVISE SUBSCRIPTS.
C
2       I2 = I2 + 1
        IF (J2 .LT. J2MIN) GOTO 5
        IF (J1 .LE. L1IN) GOTO 3
        DIFF = SUM
        GOTO 4
3       DIFF = SUM - F1(J1)
4       F2(I1) = DIFF
        F2(J2) = DIFF
        J2 = J2 - 1
C
C         ASSIGN R/H ELEMENT OF F1 AND REVISE SUBSCRIPT.
C
5       F1(J1) = SUM
        J1 = J1 - 1
6       CONTINUE
        RETURN
        END


C ##############################################################################

