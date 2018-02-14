//+------------------------------------------------------------------+
//|                                                     fuzzynet.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//| Implementation of FuzzyNet library in MetaQuotes Language 4(MQL4)|
//|                                                                  |
//| The features of the FuzzyNet library include:                    |
//| - Create Mamdani fuzzy model                                     |
//| - Create Sugeno fuzzy model                                      |
//| - Normal membership function                                     |
//| - Triangular membership function                                 |
//| - Trapezoidal membership function                                |
//| - Constant membership function                                   |
//| - Defuzzification method of center of gravity (COG)              |
//| - Defuzzification method of bisector of area (BOA)               |
//| - Defuzzification method of mean of maxima (MeOM)                |
//|                                                                  |
//| If you find any functional differences between FuzzyNet for MQL4 |
//| and the original FuzzyNet project , please contact developers of |
//| MQL4 on the Forum at www.mql4.com.                               |
//|                                                                  |
//| You can report bugs found in the computational algorithms of the |
//| FuzzyNet library by notifying the FuzzyNet project coordinators  |
//+------------------------------------------------------------------+
//|                         SOURCE LICENSE                           |
//|                                                                  |
//| This program is free software; you can redistribute it and/or    |
//| modify it under the terms of the GNU General Public License as   |
//| published by the Free Software Foundation (www.fsf.org); either  |
//| version 2 of the License, or (at your option) any later version. |
//|                                                                  |
//| This program is distributed in the hope that it will be useful,  |
//| but WITHOUT ANY WARRANTY; without even the implied warranty of   |
//| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the     |
//| GNU General Public License for more details.                     |
//|                                                                  |
//| A copy of the GNU General Public License is available at         |
//| http://www.fsf.org/licensing/licenses                            |
//+------------------------------------------------------------------+
#property strict
#include <Arrays\List.mqh>
#include "MembershipFunction.mqh"
#include "Helper.mqh"
//+------------------------------------------------------------------+
//| Purpose: creating fuzzy term.                                    |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Fuzzy or linguistic term.                                        |
//+------------------------------------------------------------------+
class CFuzzyTerm : public CNamedValueImpl
  {
private:
   IMembershipFunction *m_mf;         // The membership function of the term
public:
   //--- Constructor:
   //+------------------------------------------------------------------+
   //| Constructor with parameters                                      |
   //+------------------------------------------------------------------+
                     CFuzzyTerm(const string name,IMembershipFunction *mf)
     {
      CNamedValueImpl::Name(name);
      m_mf=mf;
     }
   //--- Destructor:
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+     
                    ~CFuzzyTerm()
     {
      if(CheckPointer(m_mf)==POINTER_DYNAMIC)
        {
         delete m_mf;
        }
     }
   //--- Methods:
   //+------------------------------------------------------------------+
   //| Check type                                                       |
   //+------------------------------------------------------------------+  
   virtual bool IsTypeOf(EnType type)
     {
      //--- return type
      return(type==TYPE_CLASS_FuzzyTerm);
     }
   //+------------------------------------------------------------------+
   //| Get membership function initially associated with the term       |
   //+------------------------------------------------------------------+
   IMembershipFunction *MembershipFunction()
     {
      //--- return membership function
      return (m_mf);
     }
  };
//+------------------------------------------------------------------+
