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
#include "FuzzyVariable.mqh"
#include "Dictionary.mqh"
//+------------------------------------------------------------------+
//| Purpose: creating Sugeno variable.                               |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| The base class for Linear Sugeno Function                        |
//+------------------------------------------------------------------+
class ISugenoFunction : public CNamedValueImpl
  {
public:
   //--- Methods:
   //+------------------------------------------------------------------+
   //| Check type                                                       |
   //+------------------------------------------------------------------+  
   virtual bool IsTypeOf(EnType type)
     {
      //--- return type
      return(type==TYPE_CLASS_ISugenoFunction);
     }
  };
//+------------------------------------------------------------------+
//| Lenear function for Sugeno Fuzzy System                          |
//+------------------------------------------------------------------+  
class CLinearSugenoFunction : public ISugenoFunction
  {
private:
   CList            *m_input;         // List of input variables
   CList            *m_coeffs;        // The dictionary which stores variables and their coefficients
   double            m_const_value;   // The constant term of the linear equation
public:
   //--- Constructors:
   //+------------------------------------------------------------------+
   //| First constructor with parameters                                |
   //+------------------------------------------------------------------+
                     CLinearSugenoFunction(const string name,CList *&in)
     {
      m_coeffs=new CList;
      CNamedValueImpl::Name(name);
      m_input=in;
     }
   //+------------------------------------------------------------------+
   //| Second constructor with parameters                               |
   //+------------------------------------------------------------------+
                     CLinearSugenoFunction(const string name,CList *in,CList *coeffs,const double constValue)
     {
      CNamedValueImpl::Name(name);
      m_input=in;
      //--- Check that all coeffecients are related to the variable from input     
      for(int i=0; i<coeffs.Total(); i++)
        {
         CDictionary_Obj_Double *p_vd=coeffs.GetNodeAtIndex(i);
         if((m_input.IndexOf(p_vd.Key())==-1) && (in.Total()==coeffs.Total()))
           {
            Print("Input of the fuzzy system does not contain all variable.");
           }
        }
      m_coeffs=coeffs;
      m_const_value=constValue;
     }
   //+------------------------------------------------------------------+
   //| Third constructor with parameters                                |
   //+------------------------------------------------------------------+
                     CLinearSugenoFunction(const string name,CList *in,const double  &coeffs[])
     {
      m_coeffs=new CList;
      m_input=in;
      CNamedValueImpl::Name(name);
      //--- Check input values
      if(ArraySize(coeffs)!=in.Total() && ArraySize(coeffs)!=(in.Total()+1))
        {
         Print("Wrong lenght of coefficients array");
        }
      //--- Fill list of coefficients 
      for(int i=0; i<in.Total(); i++)
        {
         CDictionary_Obj_Double *p_vd=new CDictionary_Obj_Double;
         CFuzzyVariable *var=in.GetNodeAtIndex(i);
         p_vd.SetAll(var,coeffs[i]);
         m_coeffs.Add(p_vd);
        }
      if(ArraySize(coeffs)==(in.Total()+1))
        {
         m_const_value=coeffs[ArraySize(coeffs)-1];
        }
     }
   //--- Destructor:  
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+ 
                    ~CLinearSugenoFunction()
     {
      if(CheckPointer(m_input)==POINTER_DYNAMIC)
        {
         delete m_input;
        }
      if(CheckPointer(m_coeffs)==POINTER_DYNAMIC)
        {
         delete m_coeffs;
        }
     }
   //--- Methods:
   //+------------------------------------------------------------------+
   //| Check type                                                       |
   //+------------------------------------------------------------------+  
   virtual bool IsTypeOf(EnType type)
     {
      //--- return type
      return(type==TYPE_CLASS_LinearSugenoFunction);
     }
   //+------------------------------------------------------------------+
   //| Set constant coefficient                                         |
   //+------------------------------------------------------------------+
   void ConstValue(const double value)
     {
      m_const_value=value;
     }
   //+------------------------------------------------------------------+
   //| Get constant coefficient                                         |
   //+------------------------------------------------------------------+
   double ConstValue()
     {
      //--- return const value
      return (m_const_value);
     }
   //+------------------------------------------------------------------+
   //| Get coefficient by fuzzy variable                                |
   //+------------------------------------------------------------------+
   double GetCoefficient(CFuzzyVariable *var)
     {
      if(var==NULL)
        {
         //--- return const coefficient
         return (m_const_value);
        }
      else
        {
         for(int i=0; i<m_coeffs.Total(); i++)
           {
            CDictionary_Obj_Double *p_vd=m_coeffs.GetNodeAtIndex(i);
            if(p_vd.Key()==var)
              {
               //--- return coefficient
               return (p_vd.Value());
              }
           }
        }
      //--- return NULL 
      return (NULL);
     }
   //+------------------------------------------------------------------+
   //| Set coefficient by fuzzy variable                                |
   //+------------------------------------------------------------------+
   void SetCoefficient(CFuzzyVariable *var,const double coeff)
     {
      if(var==NULL)
        {
         m_const_value=coeff;
        }
      else
        {
         for(int i=0; i<m_coeffs.Total(); i++)
           {
            CDictionary_Obj_Double *p_vd=m_coeffs.GetNodeAtIndex(i);
            if(p_vd.Key()==var)
              {
               p_vd.Value(coeff);
              }
            m_coeffs.Delete(i);
            m_coeffs.Insert(p_vd,i);
           }
        }
     }
   //+------------------------------------------------------------------+
   //| Calculate result of linear function                              |
   //+------------------------------------------------------------------+
   double Evaluate(CList *inputValues)
     {
      //--- NOTE: input values should be validated here
      double result=0.0;
      for(int i=0; i<m_coeffs.Total(); i++)
        {
         CDictionary_Obj_Double *p_vd1=m_coeffs.GetNodeAtIndex(i);
         CDictionary_Obj_Double *p_vd2=inputValues.GetNodeAtIndex(i);
         result+=(p_vd1.Value())*(p_vd2.Value());
        }
      result+=m_const_value;
      //--- return result
      return (result);
     }
  };
//+------------------------------------------------------------------+
//| Used as an output variable in Sugeno fuzzy inference system      |
//+------------------------------------------------------------------+
class CSugenoVariable : public CNamedVariableImpl
  {
private:
   CList            *m_functions;     // List of Sugeno functions
public:
   //--- Constructors:
   //+------------------------------------------------------------------+
   //| Constructor with parameters                                      |
   //+------------------------------------------------------------------+
                     CSugenoVariable(const string name)
     {
      m_functions=new CList;
      CNamedVariableImpl::Name(name);
     }
   //--- Destructor:  
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+ 
                    ~CSugenoVariable()
     {
      delete m_functions;
     }
   //--- Methods:
   //+------------------------------------------------------------------+
   //| Check type                                                       |
   //+------------------------------------------------------------------+  
   virtual bool IsTypeOf(EnType type)
     {
      //--- return type
      return(type==TYPE_CLASS_SugenoVariable);
     }
   //+------------------------------------------------------------------+
   //| Get list of functions that belongs to the variable               |
   //+------------------------------------------------------------------+
   CList *Functions()
     {
      //--- return list of Sugeno functions
      return (m_functions);
     }
   //+--------------------------------------------------------------------------------------+
   //| Get list of functions that belongs to the variable (implementation of INamedVariable)|
   //+--------------------------------------------------------------------------------------+
   CList *Values()
     {
      //--- return list of values
      return (m_functions);
     }
   //+--------------------------------------------------------------------------------------+
   //| Find function by its name                                                            |
   //+--------------------------------------------------------------------------------------+
   ISugenoFunction *GetFuncByName(const string name)
     {
      CList *values=CSugenoVariable::Values();
      values.Total();
      for(int i=0; i<values.Total(); i++)
        {
         CNamedValueImpl *func=values.GetNodeAtIndex(i);
         if(func.Name()==name)
           {
            ISugenoFunction *result=m_functions.GetNodeAtIndex(i);
            //--- return result
            return (result);
           }
        }
      Print("The function of the same name is not found");
      //--- return NULL
      return (NULL);
     }
  };
//+------------------------------------------------------------------+
