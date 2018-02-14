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
//#property strict
#include <Arrays\List.mqh>
#include "FuzzyTerm.mqh"
//+------------------------------------------------------------------+
//| Purpose: creating fuzzy variable                                 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Fuzzy or linguistic variable.                                    |
//+------------------------------------------------------------------+
class CFuzzyVariable : public CNamedVariableImpl
  {
private:
   double            m_min;         // Minimum value of the variable
   double            m_max;         // Maximum value of the variable
   CList            *m_terms;       // List of terms in a variable
public :
   //--- Constructor:
   //+------------------------------------------------------------------+
   //| Constructor with parameters                                      |
   //+------------------------------------------------------------------+   
                     CFuzzyVariable(const string name,const double min,const double max)
     {
      CNamedVariableImpl::Name(name);
      m_terms=new CList();
      if(min>max)
        {
         Print("Incorrect parameters! Maximum value must be greater than minimum one.");
        }
      else
        {
         m_min = min;
         m_max = max;
        }
     }
   //--- Destructor:
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+     
     ~CFuzzyVariable()
     {
      delete m_terms;
     }     
   //--- Methods:
   //+------------------------------------------------------------------+
   //| Check type                                                       |
   //+------------------------------------------------------------------+  
   virtual bool IsTypeOf(EnType type)
     {
      //--- return type
      return(type==TYPE_CLASS_FuzzyVariable);
     }
   //+------------------------------------------------------------------+
   //| Add fuzzy term to list terms in a variable                       |
   //+------------------------------------------------------------------+     
   void AddTerm(CFuzzyTerm *&term)
     {
      m_terms.Add(term);
     }
   //+------------------------------------------------------------------+
   //| Get list terms in a variable                                     |
   //+------------------------------------------------------------------+
   CList *Terms()
     {
      //--- return list of terms in a variable
      return (m_terms);
     }
   //+------------------------------------------------------------------+
   //| Set list terms in a variable                                     |
   //+------------------------------------------------------------------+
   void Terms(CList *&terms)
     {
      m_terms=terms;
     }
   //+------------------------------------------------------------------+
   //| Get list terms in a variable                                     |
   //+------------------------------------------------------------------+
   CList *Values()
     {
      //--- return result
      return (m_terms);
     }
   //+------------------------------------------------------------------+
   //| Get membership function (term) by name                           |
   //+------------------------------------------------------------------+
   CFuzzyTerm *GetTermByName(const string name)
     {
      for(int i=0; i<m_terms.Total(); i++)
        {
         CFuzzyTerm *term = m_terms.GetNodeAtIndex(i);
         if(term.Name()==name)
           {
            //--- return fuzzy term
            return (term);
           }
        }
      Print("Term with the same name can not be found!");
      //--- return NULL
      return (NULL);
     }
   //+------------------------------------------------------------------+
   //| Set max                                                          |
   //+------------------------------------------------------------------+
   void Max(const double max)
     {
      m_max=max;
     }
   //+------------------------------------------------------------------+
   //| Get max                                                          |
   //+------------------------------------------------------------------+  
   double Max()
     {
      //--- return maximum value of the variable
      return (m_max);
     }
   //+------------------------------------------------------------------+
   //| Set min                                                          |
   //+------------------------------------------------------------------+
   void Min(const double min)
     {
      m_min=min;
     }
   //+------------------------------------------------------------------+
   //| Get min                                                          |
   //+------------------------------------------------------------------+       
   double Min()
     {
      //--- return minimum value of the variable
      return (m_min);
     }
  };
//+------------------------------------------------------------------+
