# SINEX format

- [Format description (EGSIEM)](http://jgte.github.io/gswarm/SINEX/EGSIEM_NEQ_SNX.pdf)
- [Complete description (IERS)](https://www.iers.org/IERS/EN/Organization/AnalysisCoordinator/SinexFormat/sinex.html)
- [SINEX-related utilites at Mathworks](https://www.mathworks.com/matlabcentral/fileexchange?term=sinex)

## Requirements for the contents

- Only gravity field parameters (no initial state vectors, drag coefficients, etc);
- No degree 1 coefficients;
- Normal equations must be normalized by the a priori sigma squared (which each institute must estimate themselves).

## Example (IfG)

- Plain text (GROOPS format)
  - [Normal Matrix](http://jgte.github.io/gswarm/SINEX/example_IfG/txt/normals_swarm1_2013-11.txt) (2.4Mb)
  - [RHS vector](http://jgte.github.io/gswarm/SINEX/example_IfG/txt/normals_swarm1_2013-11.rightHandSide.txt) (12Kb)
- [SINEX](http://jgte.github.io/gswarm/SINEX/example_IfG/sinex/normals_swarm1_2013-11.snx.txt) (2.5Mb) **Important:** the extension ".txt" has been appended to this file so that it shows on browser
- [tarball with all files](http://jgte.github.io/gswarm/SINEX/example_IfG/examples.tar.gz) (2Mb)
- Code:
  - [fileSinex.h](http://jgte.github.io/gswarm/SINEX/example_IfG/fileSinex.h)
  - [fileSinex.cpp](http://jgte.github.io/gswarm/SINEX/example_IfG/fileSinex.cpp)
  - [normalsSphericalHarmonics2Sinex.cpp](http://jgte.github.io/gswarm/SINEX/example_IfG/normalsSphericalHarmonics2Sinex.cpp)

## Example (AIUB)

- Code:
  - [write_SNX.f90](http://jgte.github.io/gswarm/SINEX/example_AIUB/write_SNX.f90)
- Example header:
  - only the `COMMENT` block is mandatory for the EGSIEM-SINEX files, since the information of GM (`earth_gravity_constant`), R (`radius`), maximum degree (`max_degree`) and tide system (`tide_system`) is needed to correctly read and process the files.

```
+FILE/REFERENCE
*INFO_TYPE_________ INFO________________________________________________________
 DESCRIPTION        GRACE monthly gravity field
 CONTACT            ulrich.meyer@aiub.unibe.ch
 SOFTWARE           Bernese GNSS Software Version EGSIEM
 INPUT              monthly NEQs: MErr
-FILE/REFERENCE

+FILE/COMMENT
 modelname              EGSIEM_AIUB_RL01
 earth_gravity_constant 3.9860044150e+14
 radius                 6.3781363000e+06
 max_degree             90
 norm                   fully_normalized
 tide_system            tide_free
-FILE/COMMENT

+INPUT/ACKNOWLEDGMENTS
*AGY DESCRIPTION________________________________________________________________
 EGS EGSIEM-contribution from Astronomical Institute of the University of Berne
-INPUT/ACKNOWLEDGMENTS
```

## Example (ASU)

- .mat text (MATLAB)
  - [Normal Matrix](http://jgte.github.io/gswarm/SINEX/example_ASU/komb_SW_NK03_NormMtx_nmax20/nm_mat/komb_multi_01_SW_2014_0801_NormMtx_nmax020_norm_mtx.mat) (1.4Mb)
  - [RHS vector](http://jgte.github.io/gswarm/SINEX/example_ASU/komb_SW_NK03_NormMtx_nmax20/sc_mat/komb_multi_01_SW_2014_0801_NormMtx_nmax020_sp.mat) (8Kb)
- [SINEX](http://jgte.github.io/gswarm/SINEX/example_ASU/komb_SW_NK03_NormMtx_nmax20/sinex/GSWARM_NE_SABC_ASU_2014-08_01_IFG.snx.txt) (2.5Mb) **Important:** the extension ".txt" has been appended to this file so that it shows on browser
- [zip archive with all files](http://jgte.github.io/gswarm/SINEX/example_ASU/example_export_to_sinex_matlab.zip) (2.4Mb)
- Code:
  - [sinex_asu_01c.m.](http://jgte.github.io/gswarm/SINEX/example_ASU/sinex_asu_01c.m.txt) ** Important:** requires additional routines found in the "private" directory in the zip archive and the extension ".txt" has been appended to this file so that it shows on browser
- Readme:

```
Sample code to export the normal equation matrix related to gravity field solutions
in the SINEX for the DISC consortium according to guidelines provided by https://jgte.github.io/gswarm/SINEX/.

After running sinex_asu_01c.m, one should obtain the file 'GSWARM_NE_SABC_ASU_2014-08_01_IFG.snx'.

The code is free to use, in its entirety or in parts.

Ales Bezdek, bezdek@asu.cas.cz, 15. 3. 2018
```

