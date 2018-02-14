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
#include "GenericFuzzySystem.mqh"
#include "InferenceMethod.mqh"
#include "RuleParser.mqh"
#include "FuzzyRule.mqh"
#include "SugenoVariable.mqh"
//+------------------------------------------------------------------+
//| Purpose: Creating Sugeno fuzzy system                            |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Sugeno fuzzy inference system                                    |
//+------------------------------------------------------------------+
class CSugenoFuzzySystem : public GenericFuzzySystem
  {
private:
   CList            *m_output;              // List of Sugeno variable
   CList            *m_rules;               // List of Sugeno fuzzy rule
public:
   //--- Constructor:
   //+------------------------------------------------------------------+
   //| Constructor without parameters                                   |
   //+------------------------------------------------------------------+
                     CSugenoFuzzySystem()
     {
      m_output=new CList;
      m_rules=new CList;
     }
   //--- Destructor:  
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+     
     ~CSugenoFuzzySystem()
     {
      delete m_output;
      delete m_rules;
     }     
   //--- Methods:
   //+------------------------------------------------------------------+
   //| Get output of the system                                         |
   //+------------------------------------------------------------------+
   CList *Output()
     {
      //--- return list of Sugeno variable
      return (m_output);
     }
   //+------------------------------------------------------------------+
   //| Get list of rules of the system                                  |
   //+------------------------------------------------------------------+
   CList *Rules()
     {
      //--- return list of Sugeno fuzzy rule 
      return (m_rules);
     }
   //+------------------------------------------------------------------+
   //| Get the output variable of the system by name                    |
   //+------------------------------------------------------------------+
   CSugenoVariable *OutputByName(const string name)
     {
      for(int i=0; i<m_output.Total(); i++)
        {
         CSugenoVariable *var=m_output.GetNodeAtIndex(i);
         if(var.Name()==name)
           {
            //--- return Sugeno variable
            return (var);
           }
        }
      Print("Variable with that name is not found");
      //--- return NULL 
      return (NULL);
     }
   //+------------------------------------------------------------------------+
   //| Use this method to create a linear function for the Sugeno fuzzy system|
   //+------------------------------------------------------------------------+
   CLinearSugenoFunction *CreateSugenoFunction(const string name,CList *&coeffs,const double constValue)
     {
      //--- return linear Sugeno function  
      return new CLinearSugenoFunction(name, GenericFuzzySystem::Input(), coeffs, constValue);
     }
   //+------------------------------------------------------------------------+
   //| Use this method to create a linear function for the Sugeno fuzzy system|
   //+------------------------------------------------------------------------+
   CLinearSugenoFunction *CreateSugenoFunction(const string name,const double &coeffs[])
     {
      //--- return linear Sugeno function 
      return new CLinearSugenoFunction(name, Input(), coeffs);
     }
   //+------------------------------------------------------------------+
   //| Use this method to create an empty rule for the system           |
   //+------------------------------------------------------------------+
   CSugenoFuzzyRule *EmptyRule()
     {
      //--- return Sugeno fuzzy rule
      return new CSugenoFuzzyRule();
     }
   //+------------------------------------------------------------------+
   //| Use this method to create rule by its textual representation     |
   //+------------------------------------------------------------------+
   CSugenoFuzzyRule *ParseRule(const string rule)
     {
      //--- return Sugeno fuzzy rule
      return RuleParser::Parse(rule, EmptyRule(), Input(), Output());
     }
   //+------------------------------------------------------------------+
   //| Evaluate conditions                                              |
   //+------------------------------------------------------------------+
   CList *EvaluateConditions(CList *fuzzifiedInput)
     {
      CList *result=new CList;
      for(int i=0; i<Rules().Total(); i++)
        {
         CDictionary_Obj_Double *p_rd=new CDictionary_Obj_Double;
         CSugenoFuzzyRule *rule=Rules().GetNodeAtIndex(i);
         p_rd.SetAll(rule,EvaluateCondition(rule.Condition(),fuzzifiedInput));
         result.Add(p_rd);
        }
      //--- return result
      return (result);
     }
   //+------------------------------------------------------------------+
   //| Calculate functions results                                      |
   //+------------------------------------------------------------------+
   CList *EvaluateFunctions(CList *inputValues)
     {
      CList *result=new CList;
      for(int i=0; i<Output().Total(); i++)
        {
         CSugenoVariable *var=Output().GetNodeAtIndex(i);
         CList *varResult=new CList;
         for(int j=0; j<var.Functions().Total(); j++)
           {
            CDictionary_Obj_Double *p_fd=new CDictionary_Obj_Double;
            CLinearSugenoFunction *func=var.Functions().GetNodeAtIndex(j);
            p_fd.SetAll(func,func.Evaluate(inputValues));
            varResult.Add(p_fd);
           }
         CDictionary_Obj_Obj *p_vl=new CDictionary_Obj_Obj;  
         p_vl.SetAll(var,varResult);
         result.Add(p_vl);
        }
      //--- return result
      return (result);
     }
   //+------------------------------------------------------------------+
   //| Combine results of functions and rule evaluation                 |
   //+------------------------------------------------------------------+
   CList *CombineResult(CList *ruleWeights,CList *functionResults)
     {
      CList *results=new CList;
      CList *numerators=new CList;
      CDictionary_Obj_Double *p_vd1;
      CList *denominators=new CList;
      CDictionary_Obj_Double *p_vd2;
      //--- Calculate numerator and denominator separately for each output
      for(int i=0; i<Output().Total(); i++)
        {
         p_vd1=new CDictionary_Obj_Double;
         p_vd1.SetAll(Output().GetNodeAtIndex(i),0.0);
         numerators.Add(p_vd1);
         p_vd2=new CDictionary_Obj_Double;
         p_vd2.SetAll(Output().GetNodeAtIndex(i),0.0);
         denominators.Add(p_vd2);
        }
      for(int i=0; i<ruleWeights.Total(); i++)
        {
         double z=NULL;
         double w=NULL;
         CDictionary_Obj_Double *p_rd=ruleWeights.GetNodeAtIndex(i);
         CSugenoFuzzyRule *rule=p_rd.Key();
         CSugenoVariable *var=rule.Conclusion().Var();
         for(int j=0; j<functionResults.Total(); j++)
           {
            CDictionary_Obj_Obj *p_vl=functionResults.GetNodeAtIndex(j);
            if(p_vl.Key()==var)
              {
               CList *list=p_vl.Value();
               for(int k=0; k<list.Total(); k++)
                 {
                  CDictionary_Obj_Double *p_fd=list.GetNodeAtIndex(k);
                  if(p_fd.Key()==rule.Conclusion().Term())
                    {
                     z=p_fd.Value();
                     break;
                    }
                 }
               break;
              }
           }
         for(int j=0; j<ruleWeights.Total();j++)
           {
            p_rd=ruleWeights.GetNodeAtIndex(j);
            if(p_rd.Key()==rule)
              {
               w=p_rd.Value();
               break;
              }
           }
         for(int j=0; j<numerators.Total();j++)
           {
            p_vd1=numerators.GetNodeAtIndex(j);
            double num=p_vd1.Value();
            if(p_vd1.Key()==rule.Conclusion().Var())
              {
               num=num+(z*w);
               p_vd1.Value(num);
               break;
              }
           }
         for(int j=0; j<denominators.Total();j++)
           {
            p_vd2=denominators.GetNodeAtIndex(j);
            double den=p_vd2.Value();
            if(p_vd2.Key()==rule.Conclusion().Var())
              {
               den=den+w;
               p_vd2.Value(den);
               break;
              }
           }
        }
      //--- Calculate the fractions
      for(int i=0; i<Output().Total(); i++)
        {
         CSugenoVariable *var=Output().GetNodeAtIndex(i);
         CDictionary_Obj_Double *p_vd_res=new CDictionary_Obj_Double;
         CDictionary_Obj_Double *p_vd_num;
         CDictionary_Obj_Double *p_vd_den;
         for(int j=0; j<numerators.Total(); j++)
           {
            p_vd_num=numerators.GetNodeAtIndex(j);
            if(p_vd_num.Key()==var)
              {
               break;
              }
           }
         for(int j=0; j<denominators.Total(); j++)
           {
            p_vd_den=denominators.GetNodeAtIndex(j);
            if(p_vd_den.Key()==var)
              {
               break;
              }
           }
         if(p_vd_den.Value()==0.0)
           {
            p_vd_res.Value(0.0);
            results.Add(p_vd_res);
           }
         else
           {
            p_vd_res.Value(p_vd_num.Value()/p_vd_den.Value());
            results.Add(p_vd_res);
           }
        }
      //--- return result
      delete numerators;
      delete denominators;
      return (results);
     }
   //+------------------------------------------------------------------+
   //| Calculate output of fuzzy system                                 |
   //+------------------------------------------------------------------+
   CList *Calculate(CList *&inputValues)
     {
      //--- There should be one rule as minimum
      if(m_rules.Total()==0)
        {
         Print("There should be one rule as minimum.");
         //--- return NULL
         return (NULL);
        }
      //--- Fuzzification step
      CList *fuzzifiedInput=Fuzzify(inputValues);
      //--- Evaluate the conditions
      CList *ruleWeights=EvaluateConditions(fuzzifiedInput);
      //--- Functions evaluation
      CList *functionsResult=EvaluateFunctions(inputValues);
      //--- Combine output
      CList *result=CombineResult(ruleWeights,functionsResult);
      delete functionsResult;
      delete ruleWeights;
      delete fuzzifiedInput;
      //--- return result
      return (result);
     }
  };
//+------------------------------------------------------------------+
