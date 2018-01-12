&copy; 2017 Institute of Geodesy of the Techincal University of Graz

All rights reserved. This code or any portion thereof may not be reproduced or used in any manner whatsoever without the express written permission of the copyright owner.

```C++
/***********************************************/
/**
* @file fileSinex.cpp
*
* @brief SINEX file representation.
*
* @author Sebastian Strasser
* @date 2017-05-15
*
*/
/***********************************************/

#include "base/import.h"
#include "config/config.h"
#include "config/logging.h"
#include "inputOutput/file.h"
#include "programme/conversion/conversion.h"
#include "fileSinex.h"

/***********************************************/

Sinex::BlockType Sinex::blockType(const std::string &label)
{
  try
  {
    if(     label               == "FILE/REFERENCE")                  return BlockType::FILE_REFERENCE;
    else if(label               == "FILE/COMMENT")                    return BlockType::FILE_COMMENT;
    else if(label               == "INPUT/HISTORY")                   return BlockType::INPUT_HISTORY;
    else if(label               == "INPUT/FILES")                     return BlockType::INPUT_FILES;
    else if(label               == "INPUT/ACKNOWLEDGEMENTS" ||
            label               == "INPUT/ACKNOWLEDGMENTS")           return BlockType::INPUT_ACKNOWLEDGEMENTS;
    else if(label               == "NUTATION/DATA")                   return BlockType::NUTATION_DATA;
    else if(label               == "PRECESSION/DATA")                 return BlockType::PRECESSION_DATA;
    else if(label               == "SOURCE/ID")                       return BlockType::SOURCE_ID;
    else if(label               == "SITE/ID")                         return BlockType::SITE_ID;
    else if(label               == "SITE/DATA")                       return BlockType::SITE_DATA;
    else if(label               == "SITE/RECEIVER")                   return BlockType::SITE_RECEIVER;
    else if(label               == "SITE/ANTENNA")                    return BlockType::SITE_ANTENNA;
    else if(label               == "SITE/GPS_PHASE_CENTER")           return BlockType::SITE_GPS_PHASE_CENTER;
    else if(label               == "SITE/GAL_PHASE_CENTER")           return BlockType::SITE_GAL_PHASE_CENTER;
    else if(label               == "SITE/ECCENTRICITY")               return BlockType::SITE_ECCENTRICITY;
    else if(label               == "SATELLITE/ID")                    return BlockType::SATELLITE_ID;
    else if(label               == "SATELLITE/PHASE_CENTER")          return BlockType::SATELLITE_PHASE_CENTER;
    else if(label               == "BIAS/EPOCHS")                     return BlockType::BIAS_EPOCHS;
    else if(label               == "SOLUTION/EPOCHS")                 return BlockType::SOLUTION_EPOCHS;
    else if(label               == "SOLUTION/STATISTICS")             return BlockType::SOLUTION_STATISTICS;
    else if(label               == "SOLUTION/ESTIMATE")               return BlockType::SOLUTION_ESTIMATE;
    else if(label               == "SOLUTION/APRIORI")                return BlockType::SOLUTION_APRIORI;
    else if(label.substr(0, 24) == "SOLUTION/MATRIX_ESTIMATE")        return BlockType::SOLUTION_MATRIX_ESTIMATE;
    else if(label.substr(0, 23) == "SOLUTION/MATRIX_APRIORI")         return BlockType::SOLUTION_MATRIX_APRIORI;
    else if(label               == "SOLUTION/NORMAL_EQUATION_VECTOR") return BlockType::SOLUTION_NORMAL_EQUATION_VECTOR;
    else if(label.substr(0, 31) == "SOLUTION/NORMAL_EQUATION_MATRIX") return BlockType::SOLUTION_NORMAL_EQUATION_MATRIX;
    else
      throw(Exception("Unknown block type: " + label));
  }
  catch(std::exception &e)
  {
    rethrow(e);
  }
}

/***********************************************/

void Sinex::readConfigHeader(Config &config)
{
  try
  {
    Time        timeStart, timeEnd;
    std::string agencyCode, observationCode, constraintCode, solutionContent;
    std::string description, output, contact, software, hardware, input;
    std::vector<std::string> comment;

    readConfigSequence(config, "sinexHeader", Config::MUSTSET);
    readConfig(config, "agencyCode",              agencyCode,       Config::OPTIONAL, "TUG",    "identify the agency providing the data");
    readConfig(config, "timeStart",               timeStart,        Config::OPTIONAL, "",       "start time of the data");
    readConfig(config, "timeEnd",                 timeEnd,          Config::OPTIONAL, "",       "end time of the data ");
    readConfig(config, "observationCode",         observationCode,  Config::OPTIONAL, "C",      "technique used to generate the SINEX solution");
    readConfig(config, "constraintCode",          constraintCode,   Config::OPTIONAL, "2",      "0: tight constraint, 1: siginficant constraint, 2: unconstrained");
    readConfig(config, "solutionContent",         solutionContent,  Config::OPTIONAL, "",       "solution types contained in the SINEX solution (S O E T C A)");
    readConfig(config, "description",             description,      Config::OPTIONAL, "",       "organizitions gathering/alerting the file contents");
    readConfig(config, "contact",                 contact,          Config::OPTIONAL, "",       "Address of the relevant contact. e-mail");
    readConfig(config, "output",                  output,           Config::OPTIONAL, "",       "Description of the file contents");
    readConfig(config, "input",                   input,            Config::OPTIONAL, "",       "Brief description of the input used to generate this solution");
    readConfig(config, "software",                software,         Config::OPTIONAL, "GROOPS", "Software used to generate the file");
    readConfig(config, "hardware",                hardware,         Config::OPTIONAL, "",       "Computer hardware on which above software was run");
    readConfig(config, "comment",                 comment,          Config::OPTIONAL, "",       "comments in the comment block");
    endSequence(config);
    if(isCreateSchema(config)) return;

    // header line
    time_t now         = time(0);
    tm     gmtm        = *gmtime(&now);
    Time   timeCurrent = date2time(gmtm.tm_year+1900, gmtm.tm_mon+1, gmtm.tm_mday, gmtm.tm_hour, gmtm.tm_min, gmtm.tm_sec);
    std::stringstream ss;
    ss << "%=SNX 2.02 " << std::setw(3) << agencyCode.substr(0,3) << " " << time2str(timeCurrent) << " " << std::setw(3) << agencyCode.substr(0,3);
    ss << " " << time2str(timeStart) << " " << time2str(timeEnd) << " " << std::setw(1) << observationCode.substr(0,1) << " 00000";
    ss << " " << std::setw(1) << constraintCode.substr(0,1) << " " << std::setw(12) << constraintCode.substr(0,12);
    _header = ss.str();

    // reference block
    SinexTextPtr sinexTextReference = addBlock<SinexText>("FILE/REFERENCE");

    auto refLine = [] (const std::string &name, const std::string &info) -> std::string
    {
      std::stringstream ss;
      ss << std::left << std::setw(18) << name << " " << info.substr(0,60);
      return ss.str();
    };

    if(!description.empty()) sinexTextReference->readLine(refLine("DESCRIPTION", description));
    if(!output.empty())      sinexTextReference->readLine(refLine("OUTPUT",      output));
    if(!contact.empty())     sinexTextReference->readLine(refLine("CONTACT",     contact));
    if(!software.empty())    sinexTextReference->readLine(refLine("SOFTWARE",    software));
    if(!hardware.empty())    sinexTextReference->readLine(refLine("HARDWARE",    hardware));
    if(!input.empty())       sinexTextReference->readLine(refLine("INPUT",       input));

    // comment block
    SinexTextPtr sinexTextComment = addBlock<SinexText>("FILE/COMMENT");
    for(const auto& line : comment)
      sinexTextComment->readLine(line);
  }
  catch(std::exception &e)
  {
    rethrow(e);
  }
}

/***********************************************/
std::string Sinex::header() const
{
  try
  {
    UInt countParameter = 0;
    if(hasBlock("SOLUTION/APRIORI"))
      countParameter = getBlock<SinexSolutionVector>("SOLUTION/APRIORI")->size();
    std::string header = _header;
    header.replace(60, 5, countParameter%"%05i"_str);
    return header;
  }
  catch(std::exception &e)
  {
    rethrow(e);
  }
}

/***********************************************/

void Sinex::readFile(const FileName &fileName)
{
  try
  {
    if(fileName.empty())
      throw(Exception("File name is empty."));

    InFile file(fileName);

    std::string line, blockLabel;
    BlockType blockType = UNKNOWN;
    std::getline(file, _header);

    while(std::getline(file, line))
    {
      // skip comments
      if(line.empty() || (line.at(0) == '*'))
        continue;

      // %ENDSNX
      if(line.at(0) == '%')
        break;

      // start data block
      if(line.at(0) == '+')
      {
        if(!blockLabel.empty())
          throw(Exception("New SINEX block starts unexpectedly: '" + line + "' in block '" + blockLabel + "'"));
        blockLabel = Conversion::trim(line.substr(1));
        blockType  = Sinex::blockType(blockLabel);
        addBlock<SinexBlock>(blockLabel);
        continue;
      }

      // end data block
      if(line.at(0) == '-')
      {
        if(blockLabel != Conversion::trim(line.substr(1)))
          throw(Exception("SINEX block ends unexpectedly: '" + line + "' in block '" + blockLabel + "'"));
        blockLabel.clear();
        continue;
      }

      // unknown line
      if(line.at(0) != ' ')
      {
        logWarning << "Unknown line identifier: '" << line << "'" << Log::endl;
        continue;
      }

      // data lines
      if(_blocks.find(blockType) == _blocks.end())
        continue;
      _blocks.at(blockType)->readLine(line);
    }
  }
  catch(std::exception &e)
  {
    rethrow(e);
  }
}

/***********************************************/

void Sinex::writeFile(const FileName &fileName) const
{
  try
  {
    if(fileName.empty())
      throw(Exception("File name is empty."));

    OutFile file(fileName);
    file << header() << std::endl;
    file << "*" << std::string(79, '-') << std::endl;
    for(const auto& block : _blocks)
    {
      if(block.second->writeBlock(file))
        file << "*" << std::string(79, '-') << std::endl;
    }
    file << "%ENDSNX";
  }
  catch(std::exception &e)
  {
    rethrow(e);
  }
}

/***********************************************/

std::string Sinex::time2str(const Time &time)
{
  try
  {
    if(time == Time() || time == date2time(2500,1,1,0,0,0.))
      return "00:000:00000";

    UInt   year, month, day, hour, minute;
    Double second;
    time.date(year, month, day, hour, minute, second);

    std::stringstream ss;
    ss << std::setw(2) << std::setfill('0') << ((year >= 2000) ? (year-2000) : (year-1900)) << ":";
    ss << std::setw(3) << std::setfill('0') << time.dayOfYear() << ":";
    ss << std::setw(5) << std::setfill('0') << static_cast<UInt>(std::round(time.mjdMod()*86400));
    return ss.str();
  }
  catch(std::exception &e)
  {
    rethrow(e);
  }
}

/***********************************************/

Time Sinex::str2time(const std::string &line, size_t pos, size_t /*len*/)
{
  try
  {
    UInt year = static_cast<UInt>(Conversion::readInt(line, pos+0, 2));
    UInt day  = static_cast<UInt>(Conversion::readInt(line, pos+3, 3));
    UInt sec  = static_cast<UInt>(Conversion::readInt(line, pos+7, 5));
    Time time;
    if(year != 0 || day != 0 || sec != 0)
    {
      year += (year <= 50) ? 2000 : 1900;
      time = date2time(year,1,1,0,0,0.) + mjd2time(day-1) + seconds2time(sec);
    }
    if(year == 0 && day == 0 && sec == 0)
      time = date2time(2500,1,1,0,0,0.);
    return time;
  }
  catch(std::exception &e)
  {
    rethrow(e);
  }
}

/***********************************************/

std::string Sinex::SinexText::header() const
{
  try
  {
    if(blockType() == FILE_REFERENCE)
      return "*INFO_TYPE_________ INFO________________________________________________________";
    if(blockType() == INPUT_ACKNOWLEDGEMENTS)
      return "*AGY ______________________________FULL_DESCRIPTION_____________________________";
    if(blockType() == INPUT_HISTORY)
      return "*_VERSION_ CRE __CREATION__ OWN _DATA_START_ __DATA_END__ T PARAM S ____TYPE____";
    if(blockType() == INPUT_FILES)
      return "*OWN __CREATION__ ___________FILENAME__________ ___________DESCRIPTION__________";
    if(blockType() == SITE_ID)
      return "*CODE PT __DOMES__ T _STATION DESCRIPTION__ _LONGITUDE_ _LATITUDE__ HEIGHT_";
    if(blockType() == SITE_RECEIVER)
      return "*CODE PT SOLN T _DATA START_ __DATA_END__ ___RECEIVER_TYPE____ _S/N_ _FIRMWARE__";
    if(blockType() == SITE_ANTENNA)
      return "*CODE PT SOLN T _DATA START_ __DATA_END__ ____ANTENNA_TYPE____ _S/N_";
    if(blockType() == SITE_GPS_PHASE_CENTER)
      return "*________TYPE________ _S/N_ _L1_U_ _L1_N_ _L1_E_ _L2_U_ _L2_N_ _L2_E_ __MODEL___";
    if(blockType() == SITE_ECCENTRICITY)
      return "*CODE PT SOLN T _DATA START_ __DATA_END__ REF __DX_U__ __DX_N__ __DX_E__";
    if(blockType() == SOLUTION_EPOCHS)
      return "*CODE PT SOLN T _DATA_START_ __DATA_END__ _MEAN_EPOCH_";
    if(blockType() == SATELLITE_ID)
      return "*SITE PR COSPAR_ID T _DATA_START_ __DATA_END__ ______ANTENNA_______";
    if(blockType() == SATELLITE_PHASE_CENTER)
      return "*SITE L SATA_Z SATA_X SATA_Y L SATA_Z SATA_X SATA_Y __MODEL___ T M";
    return "";
  }
  catch(std::exception &e)
  {
    rethrow(e);
  }
}


/***********************************************/

Bool Sinex::SinexText::writeBlock(std::ostream &file) const
{
  try
  {
    if(!file.good())
      throw(Exception("Cannot write SINEX block: '" + label() + "'"));

    if(!_lines.size())
      return FALSE;

    file << "+" << label() << std::endl;
    if(!header().empty())
      file << header() << std::endl;
    for(const auto& line : _lines)
      file << (line.at(0) != ' ' ? " " : "") << line.substr(0,(line.at(0) != ' ' ? 79 : 80)) << std::endl;
    file << "-" << label() << std::endl;

    return TRUE;
  }
  catch(std::exception &e)
  {
    rethrow(e);
  }
}

/***********************************************/

std::string Sinex::SinexSolutionVector::header() const
{
  try
  {
    if(blockType() == SOLUTION_APRIORI)
      return "*INDEX _TYPE_ CODE PT SOLN _REF_EPOCH__ UNIT S ____APRIORI_VALUE____ __STD_DEV__";
    if(blockType() == SOLUTION_ESTIMATE)
      return "*INDEX _TYPE_ CODE PT SOLN _REF_EPOCH__ UNIT S ___ESTIMATED_VALUE___ __STD_DEV__";
    if(blockType() == SOLUTION_NORMAL_EQUATION_VECTOR)
      return "*INDEX _TYPE_ CODE PT SOLN _REF_EPOCH__ UNIT S ___RIGHT_HAND_SIDE___";
    return "*";
  }
  catch(std::exception &e)
  {
    rethrow(e);
  }
}

/***********************************************/

void Sinex::SinexSolutionVector::readLine(const std::string &line)
{
  try
  {
    Parameter parameter;
    parameter.parameterIndex = static_cast<UInt>(Conversion::readInt(line, 1, 5));
    parameter.parameterType  = Conversion::trim(line.substr(7, 6));
    parameter.siteCode       = Conversion::trim(line.substr(14, 4));
    parameter.pointCode      = Conversion::trim(line.substr(19, 2));
    parameter.solutionId     = Conversion::trim(line.substr(22, 4));
    parameter.time           = str2time(line, 27, 12);
    parameter.unit           = Conversion::trim(line.substr(40, 4));
    parameter.constraintCode = Conversion::trim(line.substr(45, 1));
    parameter.value          = Conversion::readDouble(line, 47, 21);
    if(blockType() != SOLUTION_NORMAL_EQUATION_VECTOR && line.length() > 68)
      parameter.sigma        = Conversion::readDouble(line, 69, 11);
    _parameters.resize(parameter.parameterIndex);
    _parameters.back() = parameter;
  }
  catch(std::exception &e)
  {
    rethrow(e);
  }
}

/***********************************************/

Bool Sinex::SinexSolutionVector::writeBlock(std::ostream &file) const
{
  try
  {
    if(!file.good())
      throw(Exception("Cannot write SINEX block: '" + label() + "'"));

    if(!_parameters.size())
      return FALSE;

    file << "+" << label() << std::endl;
    file << header() << std::endl;
    for(const auto& param : _parameters)
    {
      file << " " << std::right << std::setw(5)  << param.parameterIndex;
      file << " " << std::left  << std::setw(6)  << param.parameterType;
      file << " " << std::left  << std::setw(4)  << (param.siteCode.empty()   ? "----" : param.siteCode);
      file << " " << std::right << std::setw(2)  << (param.pointCode.empty()  ? "--"   : param.pointCode);
      file << " " << std::right << std::setw(4)  << (param.solutionId.empty() ? "----" : param.solutionId);
      file << " " << std::right << std::setw(12) << time2str(param.time);
      file << " " << std::left  << std::setw(4)  << param.unit;
      file << " " << std::right << std::setw(1)  << param.constraintCode;
      file << " " << std::right << std::setw(21) << std::setprecision(14) << std::scientific << param.value;
      if(blockType() != SOLUTION_NORMAL_EQUATION_VECTOR)
        file << " " << std::right << std::setw(11) << std::setprecision(5)  << std::scientific << param.sigma;
      file << std::endl;
    }
    file << "-" << label() << std::endl;

    return TRUE;
  }
  catch(std::exception &e)
  {
    rethrow(e);
  }
}

/***********************************************/

Vector Sinex::SinexSolutionVector::vector() const
{
  try
  {
    Vector vector(size());
    for(UInt i = 0; i < size(); i++)
      vector(i) = _parameters.at(i).value;
    return vector;
  }
  catch(std::exception &e)
  {
    rethrow(e);
  }
}

/***********************************************/

std::vector<ParameterName> Sinex::SinexSolutionVector::parameterNames() const
{
  try
  {
    std::vector<ParameterName> parameterNames(size());
    for(UInt i = 0; i < size(); i++)
    {
      // spherical harmonics coefficients
      if(_parameters.at(i).parameterType == "CN" || _parameters.at(i).parameterType == "SN")
      {
        std::string type = "sphericalHarmonics." + std::string(_parameters.at(i).parameterType == "CN" ? "c_" : "s_")
                         + Conversion::trim(_parameters.at(i).siteCode) + "_" // degree
                         + Conversion::trim(_parameters.at(i).solutionId);     // order
        parameterNames.at(i) = ParameterName("", type);
      }
      // other parameters
      else
      {
        std::string object = (!_parameters.at(i).siteCode.empty() && _parameters.at(i).siteCode != "----") ? Conversion::trim(_parameters.at(i).siteCode) : "";
        if(_parameters.at(i).parameterType.substr(0,3) != "SAT")
          std::transform(object.begin(), object.end(), object.begin(), ::tolower);

        std::string type;
        if(     _parameters.at(i).parameterType == "STAX")   type = "position.x";
        else if(_parameters.at(i).parameterType == "STAY")   type = "position.y";
        else if(_parameters.at(i).parameterType == "STAZ")   type = "position.z";
        else if(_parameters.at(i).parameterType == "VELX")   type = "velocity.x";
        else if(_parameters.at(i).parameterType == "VELY")   type = "velocity.y";
        else if(_parameters.at(i).parameterType == "VELZ")   type = "velocity.z";
        else if(_parameters.at(i).parameterType == "XGC")    type = "geocenter.x";
        else if(_parameters.at(i).parameterType == "YGC")    type = "geocenter.y";
        else if(_parameters.at(i).parameterType == "ZGC")    type = "geocenter.z";
        else if(_parameters.at(i).parameterType == "LOD")    type = "LOD";
        else if(_parameters.at(i).parameterType == "UT")     type = "UT1";
        else if(_parameters.at(i).parameterType == "XPO")    type = "polarMotion.xp";
        else if(_parameters.at(i).parameterType == "YPO")    type = "polarMotion.yp";
        else if(_parameters.at(i).parameterType == "XPOR")   type = "polarMotionRate.xp";
        else if(_parameters.at(i).parameterType == "YPOR")   type = "polarMotionRate.yp";
        else if(_parameters.at(i).parameterType == "NUT_X")  type = "nutation.X";
        else if(_parameters.at(i).parameterType == "NUT_Y")  type = "nutation.Y";
        else if(_parameters.at(i).parameterType == "NUTR_X") type = "nutationRate.X";
        else if(_parameters.at(i).parameterType == "NUTR_Y") type = "nutationRate.Y";
        else if(_parameters.at(i).parameterType == "SAT__X") type = "position.x";
        else if(_parameters.at(i).parameterType == "SAT__Y") type = "position.y";
        else if(_parameters.at(i).parameterType == "SAT__Z") type = "position.z";
        else if(_parameters.at(i).parameterType == "SAT_VX") type = "velocity.x";
        else if(_parameters.at(i).parameterType == "SAT_VY") type = "velocity.y";
        else if(_parameters.at(i).parameterType == "SAT_VZ") type = "velocity.z";
        else if(_parameters.at(i).parameterType == "SATA_X") type = "antennaCenterVariations.xOffset";
        else if(_parameters.at(i).parameterType == "SATA_Y") type = "antennaCenterVariations.yOffset";
        else if(_parameters.at(i).parameterType == "SATA_Z") type = "antennaCenterVariations.zOffset";
        else                                                 type = _parameters.at(i).parameterType; // not all types implemented yet, see SINEX documentation
        parameterNames.at(i) = ParameterName(object, type);
      }
    }
    return parameterNames;
  }
  catch(std::exception &e)
  {
    rethrow(e);
  }
}

/***********************************************/

Sinex::SinexSolutionMatrix::SinexSolutionMatrix(const std::string &label, const UInt size) : SinexBlock(label.substr(0, label.find_first_of(' ')))
{
  try
  {
    if(size == 0)
      throw(Exception("Matrix size must be greater than zero: " + label));

    const std::string baseLabel  = label.substr(0, label.find_first_of(' '));
    const std::string triangular = label.length() > baseLabel.length() ? label.substr(baseLabel.length()+1, 1) : "";
    if(triangular == "L")
      _matrix = Matrix(size, Matrix::SYMMETRIC, Matrix::LOWER);
    else if(triangular == "U")
      _matrix = Matrix(size, Matrix::SYMMETRIC, Matrix::UPPER);
    else
      throw(Exception("Undefined SINEX matrix type for: " + label));

    if(baseLabel != "SOLUTION/NORMAL_EQUATION_MATRIX")
    {
      const std::string type = label.substr(baseLabel.length()+3);
      if(type == "CORR")
        _type = CORRELATION;
      else if(type == "COVA")
        _type = COVARIANCE;
      else if(type == "INFO")
        _type = INFORMATION;
      else
        throw(Exception("Undefined SINEX matrix type for: " + label));
    }
  }
  catch(std::exception &e)
  {
    rethrow(e);
  }
}

/***********************************************/

std::string Sinex::SinexSolutionMatrix::label() const
{
  try
  {
    std::string label = SinexBlock::label();

    if(_matrix.getType() == Matrix::SYMMETRIC && _matrix.isUpper())
      label += " U";
    else if(_matrix.getType() == Matrix::SYMMETRIC && !_matrix.isUpper())
      label += " L";
    else
      throw(Exception("undefined SINEX matrix type for: " + label));

    if(label.substr(0, label.length()-2) != "SOLUTION/NORMAL_EQUATION_MATRIX")
    {
      if(type() == CORRELATION)
        label += " CORR";
      else if(type() == COVARIANCE)
        label += " COVA";
      else if(type() == INFORMATION)
        label += " INFO";
      else
        throw(Exception("undefined SINEX matrix type for: " + label));
    }

    return label;
  }
  catch(std::exception &e)
  {
    rethrow(e);
  }
}

/***********************************************/

void Sinex::SinexSolutionMatrix::readLine(const std::string &line)
{
  try
  {
    UInt i = static_cast<UInt>(Conversion::readInt(line, 1, 5)) - 1;
    UInt j = static_cast<UInt>(Conversion::readInt(line, 7, 5)) - 1;
    for(UInt k = 0; k < 3; k++)
      if(line.length() >= 13+k*22+21)
        _matrix(i,j+k) += Conversion::readDouble(line, 13+k*22, 21);
  }
  catch(std::exception &e)
  {
    rethrow(e);
  }
}

/***********************************************/

Bool Sinex::SinexSolutionMatrix::writeBlock(std::ostream &file) const
{
  try
  {
    if(!file.good())
      throw(Exception("Cannot write SINEX block: '" + label() + "'"));

    if(!_matrix.size())
      return FALSE;

    file << "+" << label() << std::endl;
    file << header() << std::endl;
    const UInt size    = _matrix.rows();
    const Bool isUpper = _matrix.isUpper();
    for(UInt i = 0; i < size; i++)
      for(UInt j = (isUpper ? i : 0); j < (isUpper ? size : i+1); j++)
        if(_matrix(i,j) != 0)
        {
          file << " " << std::setw(5) << i+1 << " " << std::setw(5) << j+1;
          for(UInt k = 0; k < 3; k++)
          {
            if(j < (isUpper ? size : i+1) && _matrix(i,j) != 0)
              file << " " << std::right << std::setw(21) << std::setprecision(14) << _matrix(i, (k<2) ? j++ : j);
            else
              break;
          }
          file << std::endl;
        }
    file << "-" << label() << std::endl;

    return TRUE;
  }
  catch(std::exception &e)
  {
    rethrow(e);
  }
}

/***********************************************/

void Sinex::SinexSolutionStatistics::readLine(const std::string &line)
{
  try
  {
    _values[Conversion::trim(line.substr(1, 30))] = Conversion::readDouble(line, 32, 22);
  }
  catch(std::exception &e)
  {
    rethrow(e);
  }
}

/***********************************************/

Bool Sinex::SinexSolutionStatistics::writeBlock(std::ostream &file) const
{
  try
  {
    if(!file.good())
      throw(Exception("Cannot write SINEX block: '" + label() + "'"));

    if(!_values.size())
      return FALSE;

    file << "+" << label() << std::endl;
    file << header() << std::endl;
    for(const auto& value : _values)
      file << " " << std::left << std::setw(30) << value.first << " " << std::right << std::fixed << std::setw(22)
           << std::setprecision((value.second == std::round(value.second)) ? 0 : 15) << value.second << std::endl;
    file << "-" << label() << std::endl;

    return TRUE;
  }
  catch(std::exception &e)
  {
    rethrow(e);
  }
}

/***********************************************/

Double Sinex::SinexSolutionStatistics::value(const std::string &name) const
{
  try
  {
    auto iter = _values.find(name);
    if(iter == _values.end())
      throw(Exception("SINEX solution statistics not found: " + name));

    return _values.at(name);
  }
  catch(std::exception &e)
  {
    rethrow(e);
  }
}

/***********************************************/
```