&copy; 2017 Institute of Geodesy of the Technical University of Graz

All rights reserved. This code or any portion thereof may not be reproduced or used in any manner whatsoever without the express written permission of the copyright owner.

```C++
/***********************************************/
/**
* @file normalsSphericalHarmonics2Sinex.cpp
*
* @brief Write potential coefficients and normal equations to SINEX format.
*
* @author Saniya Behzadpour, Sebastian Strasser
* @date 2015-03-17
*
*/
/***********************************************/

// Latex documentation
#define DOCSTRING docstring
static const char *docstring = R"(
Write potential coefficients and normal equations to SINEX format.
)";

/***********************************************/

#include "programme/program.h"
#include "inputOutput/fileSinex.h"
#include "files/fileMatrix.h"
#include "files/fileNormalEquation.h"

/***** CLASS ***********************************/

/** @brief Write potential coefficients and normal equations to SINEX format. */
class NormalsSphericalHarmonics2Sinex
{
  static void addVector(Sinex::SinexSolutionVectorPtr vector, const Time &time, const std::vector<ParameterName> &parameterName, const Vector x, const Vector sigma = Vector());

public:
  void run(Config &config);
};
PROGRAM_CONVERSION(NormalsSphericalHarmonics2Sinex, "Write potential coefficients and normal equations to SINEX format.")

/***********************************************/

void NormalsSphericalHarmonics2Sinex::run(Config &config)
{
  try
  {
    if(!Parallel::isMaster()) return;

    FileName    fileNameSinex;
    FileName    fileNameNormals;
    FileName    fileNameSolution, fileNameSigmax, fileNameApriori;
    Time        time;
    Sinex       sinex;

    readConfig(config, "outputfileSinex",         fileNameSinex,    Config::MUSTSET,  "", "solutions in SINEX format");
    readConfig(config, "inputfileNormals",        fileNameNormals,  Config::MUSTSET,  "", "normal equation matrix");
    readConfig(config, "inputfileSolution",       fileNameSolution, Config::OPTIONAL, "", "parameter vector");
    readConfig(config, "inputfileSigmax",         fileNameSigmax,   Config::OPTIONAL, "", "standard deviations of the parameters (sqrt of the diagonal of the inverse normal equation)");
    readConfig(config, "inputfileApriori",        fileNameApriori,  Config::MUSTSET,  "", "apriori parameter vector");
    readConfig(config, "time",                    time,             Config::MUSTSET,  "", "reference time for parameters");
    sinex.readConfigHeader(config);
    if(isCreateSchema(config)) return;

    // ==================================================

    // read data from files
    // --------------------
    Matrix x;
    if(!fileNameSolution.empty())
    {
      logStatus<<"reading solution from <"<<fileNameSolution<<">"<<Log::endl;
      readFileMatrix(fileNameSolution, x);
    }

    Matrix sigmax;
    if(!fileNameSigmax.empty())
    {
      logStatus<<"reading standard deviations from <"<<fileNameSigmax<<">"<<Log::endl;
      readFileMatrix(fileNameSigmax, sigmax);
    }

    Matrix x0;
    if(!fileNameApriori.empty())
    {
      logStatus<<"reading apriori solution from <"<<fileNameApriori<<">"<<Log::endl;
      readFileMatrix(fileNameApriori, x0);
    }

    std::vector<ParameterName> parameterName;
    Matrix N, n;
    Vector lPl;
    UInt   countObservation;
    logStatus<<"reading normal equation matrix from <"<<fileNameNormals<<">"<<Log::endl;
    normalEquationRead(fileNameNormals, parameterName, N, n, lPl, countObservation);
    UInt countParameter = N.rows();

    // ==================================================

    // add data to SINEX
    // -----------------
    // SOLUTION/STATISTICS
    Sinex::SinexSolutionStatisticsPtr solutionStatistics = sinex.addBlock<Sinex::SinexSolutionStatistics>("SOLUTION/STATISTICS");
    solutionStatistics->addValue("NUMBER OF OBSERVATIONS", countObservation);
    solutionStatistics->addValue("NUMBER OF UNKNOWNS", countParameter);
    solutionStatistics->addValue("NUMBER OF DEGREES OF FREEDOM", countObservation-countParameter);
    solutionStatistics->addValue("WEIGHTED SQUARE SUM OF O-C", lPl(0));

    // SOLUTION/ESTIMATE
    if(x.size())
    {
      Sinex::SinexSolutionVectorPtr solutionEstimate = sinex.addBlock<Sinex::SinexSolutionVector>("SOLUTION/ESTIMATE");
      addVector(solutionEstimate, time, parameterName, x, sigmax.size() ? sigmax : Vector());
    }

    // SOLUTION/APRIORI
    if(x0.size())
    {
      Sinex::SinexSolutionVectorPtr solutionApriori = sinex.addBlock<Sinex::SinexSolutionVector>("SOLUTION/APRIORI");
      addVector(solutionApriori, time, parameterName, x0);
    }

    // SOLUTION/NORMAL_EQUATION_VECTOR
    Sinex::SinexSolutionVectorPtr solutionNormalEquationVector = sinex.addBlock<Sinex::SinexSolutionVector>("SOLUTION/NORMAL_EQUATION_VECTOR");
    addVector(solutionNormalEquationVector, time, parameterName, n);

    // SOLUTION/NORMAL_EQUATION_MATRIX
    Sinex::SinexSolutionMatrixPtr solutionNormalEquationMatrix = sinex.addBlock<Sinex::SinexSolutionMatrix>("SOLUTION/NORMAL_EQUATION_MATRIX " + std::string(N.isUpper() ? "U" : "L"));
    solutionNormalEquationMatrix->setMatrix(N);

    // ==================================================

    // write SINEX file
    // ----------------
    logStatus<<"write SINEX file <"<<fileNameSinex<<">"<<Log::endl;
    sinex.writeFile(fileNameSinex);
  }
  catch(std::exception &e)
  {
    rethrow(e);
  }
}

/***********************************************/

void NormalsSphericalHarmonics2Sinex::addVector(Sinex::SinexSolutionVectorPtr vector, const Time &time, const std::vector<ParameterName> &parameterName, const Vector x, const Vector sigma)
{
  try
  {
    for(UInt i = 0; i < x.size(); i++)
    {
      const UInt idxDegree = parameterName.at(i).type.find_first_of('_')+1;
      const UInt idxOrder  = parameterName.at(i).type.find_last_of('_')+1;
      if(parameterName.at(i).type.substr(0,18) != "sphericalHarmonics")
        throw(Exception("non spherical harmonics parameter: " + parameterName.at(i).str()));

      Sinex::Parameter parameter;
      if(parameterName.at(i).type[idxDegree-2]=='c')
        parameter.parameterType = "CN";
      else if(parameterName.at(i).type[idxDegree-2]=='s')
        parameter.parameterType = "SN";
      else
        throw(Exception("unknown parameter type: " + parameterName.at(i).str()));
      parameter.parameterIndex = i+1;
      parameter.siteCode       = std::atoi(parameterName.at(i).type.substr(idxDegree,idxOrder-idxDegree-1).c_str())%"% 4i"_str; // degree
      parameter.solutionId     = std::atoi(parameterName.at(i).type.substr(idxOrder).c_str())%"% 4i"_str;                       // order
      parameter.pointCode      = "--";
      parameter.unit           = "----";
      parameter.constraintCode = "2"; // unconstrained
      parameter.time           = time;
      parameter.value          = x(i);
      if(sigma.size())
        parameter.sigma        = sigma(i);

      vector->addParameter(parameter);
    }
  }
  catch(std::exception &e)
  {
    rethrow(e);
  }
}

/***********************************************/
```