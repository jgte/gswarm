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
  - [write_SNX.txt](http://jgte.github.io/gswarm/SINEX/example_AIUB/write_SNX.txt)