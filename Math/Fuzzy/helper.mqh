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
#include "InferenceMethod.mqh"
//+------------------------------------------------------------------+
//| Purpose: Analysis of the fuzzy rules                             |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| This class must be implemented by values in parsable rules       |
//+------------------------------------------------------------------+
class INamedValue : public CObject
  {
   //--- Methods: 
public :
   //+------------------------------------------------------------------+
   //| Check type                                                       |
   //+------------------------------------------------------------------+  
   virtual bool IsTypeOf(EnType type)
     {
      //--- return type
      return(type==TYPE_CLASS_INamedValue);
     }
   //+------------------------------------------------------------------+
   //| Get variable name                                                |
   //+------------------------------------------------------------------+   
   virtual string Name()
     {
      //--- return NULL
      return(NULL);
     }
   //+------------------------------------------------------------------+
   //| Set variable name                                                |
   //+------------------------------------------------------------------+     
   virtual void Name(const string name)
     {}
  };
//+------------------------------------------------------------------+
//| This class must be implemented by values in parsable rules       |
//+------------------------------------------------------------------+
class INamedVariable : public INamedValue
  {
   //--- Methods:  
public:
   //+------------------------------------------------------------------+
   //| Check type                                                       |
   //+------------------------------------------------------------------+  
   virtual bool IsTypeOf(EnType type)
     {
      //--- return type
      return(type==TYPE_CLASS_INamedVariable);
     }
   //+------------------------------------------------------------------+
   //| Get list of values that belongs to the variable                  |
   //+------------------------------------------------------------------+  
   virtual CList *Values()
     {
      //--- return NULL
      return(NULL);
     }
  };
//+------------------------------------------------------------------+
//| Named variable                                                   |
//+------------------------------------------------------------------+ 
class CNamedVariableImpl : public INamedVariable
  {
private:
   string            m_name;        // Name of the variable  
public:
   //--- Methods:
   //+------------------------------------------------------------------+
   //| Check type                                                       |
   //+------------------------------------------------------------------+  
   virtual bool IsTypeOf(EnType type)
     {
      //--- return
      return(type==TYPE_CLASS_NamedVariableImpl);
     }
   //+------------------------------------------------------------------+
   //| Set variable name                                                |
   //+------------------------------------------------------------------+  
   virtual void Name(const string name)
     {
      if(!CNameHelper::IsValidName(name))
        {
         Print("Invalid variable name.");
        }
      m_name=name;
     }
   //+------------------------------------------------------------------+
   //| Get variable name                                                |
   //+------------------------------------------------------------------+ 
   virtual string Name()
     {
      //--- return name
      return (m_name);
     }
   //+------------------------------------------------------------------+
   //| Get named values                                                 |
   //+------------------------------------------------------------------+ 
   virtual CList *Values()
     {
      //--- return NULL
      return(NULL);
     }
  };
//+------------------------------------------------------------------+
//| Named value of variable                                          |
//+------------------------------------------------------------------+ 
class CNamedValueImpl : public INamedValue
  {
private:
   string            m_name;        // Name of the value 
public:
   //--- Methods:
   //+------------------------------------------------------------------+
   //| Check type                                                       |
   //+------------------------------------------------------------------+  
   virtual bool IsTypeOf(EnType type)
     {
      //--- return type
      return(type==TYPE_CLASS_NamedValueImpl);
     }
   //+------------------------------------------------------------------+
   //| Set variable name                                                |
   //+------------------------------------------------------------------+
   virtual void Name(const string name)
     {
      if(!CNameHelper::IsValidName(name))
        {
         Print("Invalid term name.");
        }
      m_name=name;
     }
   //+------------------------------------------------------------------+
   //| Get variable name                                                |
   //+------------------------------------------------------------------+   
   virtual string Name()
     {
      //--- return name
      return (m_name);
     }
  };
//+------------------------------------------------------------------+
//| Keywords:                                                        |
//+------------------------------------------------------------------+
static string  KEYWORDS[]={ "if","then","is","and","or","not","(",")","slightly","somewhat","very","extremely" }; // Keywords in rules
//+------------------------------------------------------------------+
//| Class NameHelper checks the availability of names                |
//+------------------------------------------------------------------+
class CNameHelper
  {
public :
   //--- Methods:
   //+------------------------------------------------------------------+
   //| Check the name of variable/term                                  |
   //+------------------------------------------------------------------+
   static bool IsValidName(const string name)
     {
      //--- Empty names are not allowed
      if(StringLen(name)==0)
        {
         //--- return false
         return (false);
        }

      for(int i=0; i<StringLen(name); i++)
        {
         //--- Only letters, numbers or '_' are allowed
         char s=(char) StringGetCharacter(name,i);
         if(s!='_' && !(s>=48 && s<=57)    // Not numbers and symbol '_'
            && !( s >= 65 && s <= 90 )     // Not capital letters
            && !( s >= 97 && s <= 122 ))   // Not letters
           {
            //--- return false
            return (false);
           }
        }
      //--- Identifier cannot be a keword
      for(int i=0; i<ArraySize(KEYWORDS); i++)
        {
         if(name==KEYWORDS[i])
           {
            //--- return false
            return (false);
           }
        }
      //--- return true
      return (true);
     }
  };
//+------------------------------------------------------------------+
