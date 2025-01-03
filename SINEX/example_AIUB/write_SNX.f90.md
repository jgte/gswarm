&copy; 2017 Astronomical Institute of the University of Bern

All rights reserved. This code or any portion thereof may not be reproduced or used in any manner whatsoever without the express written permission of the copyright owner.

{% highlight fortran %}

SUBROUTINE sinstore(neq,regMat,aNor_free,bNor_free)

! Open the output file
! --------------------
  CALL opnfil(lfnres, opt%sinexrs, 'UNKNOWN', 'FORMATTED', ' ', ' ', ios)

! Header line
! -----------

  WRITE(lfnres,'(A1,  A1,  A3,  1X,F4.2,  1X,A3,  1X,A12,  1X,A3,          &
         &       1X,A12,  1X,A12,  1X,A1,  1X,I5.5,  1X,A1,  6(1X,A1))' )  &
               '%', '=', 'SNX', version, agencyFile, sysTime, agencyData,  &
               startTime, endTime, technique, neq%misc%npar, flgCon,       &
               parString(1:6)

! Reference Block
! ---------------

!!!!!! There some external text-file is read and written to the SNX-file.
!!!!!! I will provide this file separately.

! Solution/Statistics Block
! -------------------------

  WRITE(lfnres,'("*",79("-"))')
  WRITE(lfnres,'(A,/,A,/,3(1X,A30,1X,A,/),           &
                 &        (1X,A30,1X,F22.5))')       &
    '+SOLUTION/STATISTICS',                                      &
    '*_STATISTICAL PARAMETER________ __VALUE(S)____________',    &
        'NUMBER OF OBSERVATIONS        ', hlpstr(1),             &
        'NUMBER OF UNKNOWNS            ', hlpstr(2),             &
        'NUMBER OF DEGREES OF FREEDOM  ', hlpstr(3),             &
        'PHASE MEASUREMENTS SIGMA      ', opt%sigma0
  WRITE(lfnres,'("-SOLUTION/STATISTICS")')


! Solution/Normal_Equation_Vector
! -------------------------------

  WRITE(lfnres,'("*",79("-"))')
  WRITE(lfnres,'(A)') '+SOLUTION/NORMAL_EQUATION_VECTOR'
  WRITE(lfnres,'(A)') &
       '*INDEX TYPE__ CODE PT SOLN _REF_EPOCH__ UNIT S __RIGHT_HAND_SIDE____'
  DO iparSrt = 1, neq%misc%npar
    ! Degree and order for gravity field coefficients
    WRITE(siteCode,'(i4)') neq%par(ipar)%locq(5)
    WRITE(solID,'(i4)') neq%par(ipar)%locq(6)

    WRITE(lfnres, '(1X,I5, 1X,A6, 1X,A4, 1X,A2, 1X,A4, 1X,A12, 1X,A4, 1X,A1, &
          &         1X,E21.15, 1X,E11.6)')                                   &
          iparSrt, parType, siteCode, pointCode, solID, refTime, unit,       &
          flgConPar(ipar), value
  END DO
  WRITE(lfnres,'(A)') '-SOLUTION/NORMAL_EQUATION_VECTOR'

! Solution/Estimate Block
! -----------------------

  WRITE(lfnres,'("*",79("-"))')
  WRITE(lfnres,'(A)') '+SOLUTION/ESTIMATE'
  WRITE(lfnres,'(A)') &
       '*INDEX TYPE__ CODE PT SOLN _REF_EPOCH__ UNIT S __ESTIMATED '//&
       'VALUE____ _STD_DEV___'
  DO iparSrt = 1, neq%misc%npar
    ! Degree and order for gravity field coefficients
    WRITE(siteCode,'(i4)') neq%par(ipar)%locq(5)
    WRITE(solID,'(i4)') neq%par(ipar)%locq(6)

    WRITE(lfnres, '(1X,I5, 1X,A6, 1X,A4, 1X,A2, 1X,A4, 1X,A12, 1X,A4, 1X,A1, &
          &         1X,E21.15, 1X,E11.6)')                                   &
          iparSrt, parType, siteCode, pointCode, solID, refTime, unit,       &
          flgConPar(ipar), estimate,                                         &
          SQRT(ABS( wfact * neq%aNor(ikf(ipar,ipar))))
  END DO
  WRITE(lfnres,'(A)') '-SOLUTION/ESTIMATE'

! Solution/Apriori Block
! ----------------------

  WRITE(lfnres,'("*",79("-"))')
  WRITE(lfnres,'(A)') '+SOLUTION/APRIORI'
  WRITE(lfnres,'(A)') &
       '*INDEX TYPE__ CODE PT SOLN _REF_EPOCH__ UNIT S __APRIORI VALUE______ '//&
       '_STD_DEV___'

  DO iparSrt = 1, neq%misc%npar
    ! Degree and order for gravity field coefficients
    WRITE(siteCode,'(i4)') neq%par(ipar)%locq(5)
    WRITE(solID,'(i4)') neq%par(ipar)%locq(6)

    WRITE(lfnres, '(1X,I5, 1X,A6, 1X,A4, 1X,A2, 1X,A4, 1X,A12, 1X,A4, 1X,A1, &
          &         1X,E21.15, 1X,E11.6)')                                   &
          iparSrt, parType, siteCode, pointCode, solID, refTime, unit,       &
          flgConPar(ipar), apriori, sigApr
  END DO
  WRITE(lfnres,'(A)') '-SOLUTION/APRIORI'

! Solution/Normal_Equation_Matrix
! -------------------------------

  WRITE(lfnres,'("*",79("-"))')
  WRITE(lfnres,'(A)') '+SOLUTION/NORMAL_EQUATION_MATRIX L'
  WRITE(lfnres,'(A)') &
       '*PARA1 PARA2 ____PARA2+0__________ ____PARA2+1__________ '//&
       '____PARA2+2__________'

  nWrite = 0
  line   = ''
  DO iparSrt1 = 1, neq%misc%npar
    ip1 = sortPar(iparSrt1)
    DO iparSrt2 = 1, iparSrt1
      ip2 = sortPar(iparSrt2)
      IF ( nWrite == 0 ) THEN
        WRITE(line(1:34), '(2(1X,I5), 1X,E21.14)') &
             iparSrt1, iparSrt2, aNor_free(ikf(ip1,ip2))
      ELSE IF ( nWrite == 1 ) THEN
        WRITE(line(35:56), '(1X,E21.14)') aNor_free(ikf(ip1,ip2))
      ELSE
        WRITE(line(57:78), '(1X,E21.14)') aNor_free(ikf(ip1,ip2))
      END IF
      nWrite = nWrite + 1
      IF (nWrite == 3 .OR. iparSrt1 == iparSrt2) THEN
        WRITE(lfnres,'(A)') line(1:LEN_TRIM(line))
        nWrite = 0
        line =  ''
      END IF
    END DO
  END DO
  WRITE(lfnres,'(A)') '-SOLUTION/NORMAL_EQUATION_MATRIX L'

! End of File
! -----------
  WRITE(lfnres,'(A)') '%ENDSNX'
  CLOSE(lfnres)
END SUBROUTINE sinstore


{% endhighlight %}