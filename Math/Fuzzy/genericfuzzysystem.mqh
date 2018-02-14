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
#include <Arrays\ArrayObj.mqh>
#include "FuzzyRule.mqh"
#include "InferenceMethod.mqh"
#include "Dictionary.mqh"
//+------------------------------------------------------------------+
//| Purpose: Creating generic fuzzy system                           |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Common functionality of Mamdani and Sugeno fuzzy systems         |
//+------------------------------------------------------------------+
class GenericFuzzySystem
  {
private:
   CList            *m_input;          // List of input fuzzy variables
   AndMethod         m_and_method;     // And method from InferenceMethod
   OrMethod          m_or_method;      // Or method from InferenceMethod
protected:
   //--- Constructors:
   //+------------------------------------------------------------------+
   //| Constructor without parameters                                   |
   //+------------------------------------------------------------------+
                     GenericFuzzySystem(void)
     {
      m_input=new CList;
     };
   //--- Destructor:
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+     
                    ~GenericFuzzySystem()
     {
      if(CheckPointer(m_input)==POINTER_DYNAMIC)
        {
         delete m_input;
        }
     }
   //--- Methods:
   //+------------------------------------------------------------------+
   //| Get input linguistic variables                                   |
   //+------------------------------------------------------------------+  
public:
   CList *Input()
     {
      //--- return list of input fuzzy variables 
      return (m_input);
     }
   //+------------------------------------------------------------------+
   //| Set type of "And method"                                         |
   //+------------------------------------------------------------------+ 
   void AndMethod(AndMethod value)
     {
      m_and_method=value;
     }
   //+------------------------------------------------------------------+
   //| Get type of "And method"                                         |
   //+------------------------------------------------------------------+ 
   AndMethod AndMethod()
     {
      //--- return "and" method
      return (m_and_method);
     }
   //+------------------------------------------------------------------+
   //| Set type of "Or method"                                          |
   //+------------------------------------------------------------------+ 
   void OrMethod(OrMethod value)
     {
      m_or_method=value;
     }
   //+------------------------------------------------------------------+
   //| Get type of "Or method"                                          |
   //+------------------------------------------------------------------+ 
   OrMethod OrMethod()
     {
      //--- return "or" method 
      return (m_or_method);
     }
   //+------------------------------------------------------------------+
   //| Get input linguistic variable by its name                        |
   //+------------------------------------------------------------------+ 
   CFuzzyVariable *InputByName(const string name)
     {
      CList *result=GenericFuzzySystem::Input();
      for(int i=0; i<result.Total(); i++)
        {
         CFuzzyVariable *var=result.GetNodeAtIndex(i);
         if(var.Name()==name)
           {
            //--- return fuzzy variable 
            return (var);
           }
        }
      Print("The variable with that name is not found");
      //--- return NULL
      return (NULL);
     }
   //+------------------------------------------------------------------+
   //| Fuzzify input                                                    |
   //+------------------------------------------------------------------+ 
   CList *Fuzzify(CList *inputValues)
     {
      //--- Validate input
      string msg;
      if(!ValidateInputValues(inputValues,msg))
        {
         Print(msg);
         //--- return NULL
         return (NULL);
        }
      //--- Fill results list
      CList *result=new CList;
      for(int i=0; i<Input().Total(); i++)
        {
         CFuzzyVariable *var=Input().GetNodeAtIndex(i);
         double value=NULL;
         for(int k=0; k<inputValues.Total(); k++)
           {
            CDictionary_Obj_Double *p_vd=inputValues.GetNodeAtIndex(i);
            CFuzzyVariable *v=p_vd.Key();
            if(p_vd.Key()==var)
              {
               value=p_vd.Value();
               break;
              }
           }
         CList *resultForVar=new CList;
         for(int j=0; j<var.Terms().Total(); j++)
           {
            CDictionary_Obj_Double *p_vd=new CDictionary_Obj_Double;
            CFuzzyTerm *term=var.Terms().GetNodeAtIndex(j);
            p_vd.SetAll(term,term.MembershipFunction().GetValue(value));
            resultForVar.Add(p_vd);
           }
         CDictionary_Obj_Obj *p_vl=new CDictionary_Obj_Obj;
         p_vl.SetAll(var,resultForVar);
         result.Add(p_vl);
        }
      //--- return result
      return (result);
     }
   //+------------------------------------------------------------------+
   //| Evaluate fuzzy condition (or conditions)                         |
   //+------------------------------------------------------------------+ 
protected:
   double EvaluateCondition(ICondition *condition,CList *fuzzifiedInput)
     {
      double result=0.0;
      ICondition *IC;
      if(condition.IsTypeOf(TYPE_CLASS_Conditions))
        {
         Conditions *conds=condition;
         if(conds.ConditionsList().Total()==0)
           {
            Print("Inner exception.");
           }
         else if(conds.ConditionsList().Total()==1)
           {
            IC=conds.ConditionsList().GetNodeAtIndex(0);
            result=EvaluateCondition(IC,fuzzifiedInput);
           }
         else
           {
            IC=conds.ConditionsList().GetNodeAtIndex(0);
            result=EvaluateCondition(IC,fuzzifiedInput);
            for(int i=1; i<conds.ConditionsList().Total(); i++)
              {
               IC=conds.ConditionsList().GetNodeAtIndex(i);
               double cond2=EvaluateCondition(IC,fuzzifiedInput);;
               result=EvaluateConditionPair(result,cond2,conds.Op());
              }
           }
         if(conds.Not())
           {
            result=1.0-result;
           }
         //--- return result 
         return (result);
        }
      else if(condition.IsTypeOf(TYPE_CLASS_FuzzyCondition))
        {
         FuzzyCondition *cond=condition;
         CDictionary_Obj_Obj *p_vl;
         CDictionary_Obj_Double *p_td;
         for(int i=0; i<fuzzifiedInput.Total(); i++)
           {
            p_vl=fuzzifiedInput.GetNodeAtIndex(i);
            if(p_vl.Key()==cond.Var())
              {
               CList *list=p_vl.Value();
               for(int j=0; j<list.Total(); j++)
                 {
                  p_td=list.GetNodeAtIndex(j);
                  if(p_td.Key()==cond.Term())
                    {
                     break;
                    }
                 }
               break;
              }
           }
         result=p_td.Value();
         switch(cond.Hedge())
           {
            case Slightly:
               //--- Cube root
               result=pow(result,1.0/3.0);
               break;
            case Somewhat:
               result=sqrt(result);
               break;
            case Very:
               result=result*result;
               break;
            case Extremely:
               result=result*result*result;
               break;
            default:
               break;
           }
         if(cond.Not())
           {
            result=1.0-result;
           }
         //--- return result 
         return (result);
        }
      else
        {
         Print("Internal exception.");
         //--- return NULL
         return (NULL);
        }
     }
   //+------------------------------------------------------------------+
   //| Evaluate fuzzy condition (or conditions)                         |
   //+------------------------------------------------------------------+ 
   double EvaluateConditionPair(const double cond1,const double cond2,OperatorType op)
     {
      if(op==And)
        {
         if(GenericFuzzySystem::AndMethod()==MinAnd)
           {
            //--- return evaluate condition
            return fmin(cond1, cond2);
           }
         else if(GenericFuzzySystem::AndMethod()==ProductionAnd)
           {
            //--- return evaluate condition 
            return (cond1 * cond2);
           }
         else
           {
            Print("Internal error.");
            //--- return NULL 
            return(NULL);
           }
        }
      else if(op==Or)
        {
         if(GenericFuzzySystem::OrMethod()==MaxOr)
           {
            //--- return evaluate condition 
            return fmax(cond1, cond2);
           }
         else if(GenericFuzzySystem::OrMethod()==ProbabilisticOr)
           {
            //--- return evaluate condition 
            return (cond1 + cond2 - cond1 * cond2);
           }
         else
           {
            Print("Internal error.");
            //--- return NULL
            return (NULL);
           }
        }
      else
        {
         Print("Internal error.");
         //--- return NULL
         return (NULL);
        }
     }
   //+------------------------------------------------------------------+
   //|  Validate input values                                           |
   //+------------------------------------------------------------------+
private:
   bool ValidateInputValues(CList *inputValues,string &msg)
     {
      msg=NULL;
      if(inputValues.Total()!=Input().Total())
        {
         msg="Input values count is incorrect.";
         //--- return false
         return (false);
        }
      bool contain;
      for(int i=0; i<Input().Total(); i++)
        {
         CFuzzyVariable *var=Input().GetNodeAtIndex(i);
         contain=false;
         for(int j=0; j<inputValues.Total();j++)
           {
            CDictionary_Obj_Double *p_vd=inputValues.GetNodeAtIndex(j);
            if(p_vd.Key()==var)
              {
               contain=true;
               double val=p_vd.Value();
               if(val<var.Min() || val>var.Max())
                 {
                  msg=StringFormat("Value for the %s variable is out of range.",var.Name());
                  //--- return false
                  return (false);
                 }
              }
           }
         if(contain==false)
           {
            msg=StringFormat("Value for the %s variable does not present.",var.Name());
            //--- return false
            return (false);
           }
        }
      //--- return true 
      return (true);
     }
  };
//+------------------------------------------------------------------+
