
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
#include "InferenceMethod.mqh"
//+------------------------------------------------------------------+
//| Purpose: Creating fuzzy rules                                    |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| And/Or operator type                                             |
//+------------------------------------------------------------------+ 
enum OperatorType
  {
   And,                               // And operator
   Or                                 // Or operator
  };
//+------------------------------------------------------------------+
//| Hedge modifiers                                                  |
//+------------------------------------------------------------------+ 
enum HedgeType
  {
   None,                              // None
   Slightly,                          // Cube root
   Somewhat,                          // Square root
   Very,                              // Square
   Extremely                          // Cube
  };
//+------------------------------------------------------------------+
//| Class of conditions used in the 'if' expression                  |
//+------------------------------------------------------------------+
class ICondition : public CObject
  {
public:
   //--- Method:
   //+------------------------------------------------------------------+
   //| Check type                                                       |
   //+------------------------------------------------------------------+  
   virtual bool IsTypeOf(EnCondition type)
     {
      //--- return type
      return(type==TYPE_CLASS_ICondition);
     }
  };
//+------------------------------------------------------------------+
//| Single condition                                                 |
//+------------------------------------------------------------------+
class SingleCondition : public ICondition //TODO: SingleCondition must be not public
  {
private:
   INamedVariable   *m_var;        // Type of variable
   INamedValue      *m_term;       // Type of value
   bool              m_not;        // Is MF inverted 
public:
   //--- Constructors:
   //+------------------------------------------------------------------+
   //| Constructor without parameters                                   |
   //+------------------------------------------------------------------+
                     SingleCondition(void)
     {
      m_var = NULL;
      m_not = false;
      m_term=NULL;
     };
   //+------------------------------------------------------------------+
   //| First constructor with parameters                                |
   //+------------------------------------------------------------------+
                     SingleCondition(INamedVariable *var,INamedValue *term)
     {
      m_var=var;
      m_term=term;
     }
   //+------------------------------------------------------------------+
   //| Second constructor with parameters                               |
   //+------------------------------------------------------------------+
                     SingleCondition(INamedVariable *var,INamedValue *term,bool not)
     {
      m_var=var;
      m_term=term;
      m_not=not;
     }
   //--- Destructor:  
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+ 
                    ~SingleCondition()
     {
      if(CheckPointer(m_var)==POINTER_DYNAMIC)
        {
         delete m_var;
        }
      if(CheckPointer(m_term)==POINTER_DYNAMIC)
        {
         delete m_term;
        }
     }
   //--- Methods: 
   //+------------------------------------------------------------------+
   //| Get a linguistic variable to which the condition is related      |
   //+------------------------------------------------------------------+  
   INamedVariable *Var()
     {
      //--- return variable
      return (m_var);
     }
   //+------------------------------------------------------------------+
   //| Set a linguistic variable to which the condition is related      |
   //+------------------------------------------------------------------+     
   void Var(INamedVariable *value) //*&value
     {
      m_var=value;
     }
   //+------------------------------------------------------------------+
   //| Get answer to the question "Is MF inverted"                      |
   //+------------------------------------------------------------------+ 
   bool Not()
     {
      //--- return bool
      return (m_not);
     }
   //+------------------------------------------------------------------+
   //| Invert MF                                                        |
   //+------------------------------------------------------------------+ 
   void Not(bool not)
     {
      m_not=not;
     }
   //+------------------------------------------------------------------+
   //| Get a term in expression 'variable is term'                      |
   //+------------------------------------------------------------------+
   //---'Term' is bad property name here
   INamedValue *Term()
     {
      //--- return term
      return (m_term);
     }
   //+------------------------------------------------------------------+
   //| Set a term in expression 'variable is term'                      |
   //+------------------------------------------------------------------+
   void Term(INamedValue *value) //*&value
     {
      m_term=value;
     }
   //+------------------------------------------------------------------+
   //| Check type                                                       |
   //+------------------------------------------------------------------+  
   virtual bool IsTypeOf(EnCondition type)
     {
      //--- return type
      return(type==TYPE_CLASS_SingleCondition);
     }
  };
//+------------------------------------------------------------------+
//| Condition of fuzzy rule for the both Mamdani and Sugeno systems  |
//+------------------------------------------------------------------+
class FuzzyCondition : public SingleCondition
  {
private:
   HedgeType         m_hedge;         // hedge type
public:
   //--- Constructors:
   //+------------------------------------------------------------------+
   //| First constructor with parameters                                |
   //+------------------------------------------------------------------+
                     FuzzyCondition(CFuzzyVariable *var,CFuzzyTerm *term,bool not)
     {
      SingleCondition::Var(var);
      SingleCondition::Term(term);
      SingleCondition::Not(not);
      m_hedge=None;
     }
   //+------------------------------------------------------------------+
   //| Second constructor with parameters                               |
   //+------------------------------------------------------------------+     

                     FuzzyCondition(CFuzzyVariable *var,CFuzzyTerm *term,bool not,HedgeType hedge)
     {
      SingleCondition::Var(var);
      SingleCondition::Term(term);
      SingleCondition::Not(not);
      m_hedge=hedge;
     }
   //+------------------------------------------------------------------+
   //| Thrid constructor with parameters                                |
   //+------------------------------------------------------------------+       
                     FuzzyCondition(CFuzzyVariable *var,CFuzzyTerm *term)

     {
      SingleCondition::Var(var);
      SingleCondition::Term(term);
      SingleCondition::Not(false);
     }
   //--- Methods: 
   //+------------------------------------------------------------------+
   //| Get hedge type                                                   |
   //+------------------------------------------------------------------+  
   HedgeType Hedge()
     {
      //--- return hedge type
      return (m_hedge);
     }
   //+------------------------------------------------------------------+
   //| Set hedge type                                                   |
   //+------------------------------------------------------------------+  
   void Hedge(HedgeType value)
     {
      m_hedge=value;
     }
   //+------------------------------------------------------------------+
   //| Check type                                                       |
   //+------------------------------------------------------------------+  
   virtual bool IsTypeOf(EnCondition type)
     {
      //--- return type
      return(type==TYPE_CLASS_FuzzyCondition);
     }
  };
//+------------------------------------------------------------------+
//| Several conditions linked by or/and operators                    |
//+------------------------------------------------------------------+
class Conditions : public ICondition
  {
private:
   bool              m_not;           // Default : false
   OperatorType      m_op;            // Type of operator. Default : And 
   CList            *m_Conditions;    // List of conditions
public:
   //--- Constructors:
   //+------------------------------------------------------------------+
   //| Constructor without parameters                                   |
   //+------------------------------------------------------------------+
                     Conditions(void)
     {
      m_not=false;
      m_op = And;
      m_Conditions=new CList;
     }
   //--- Destructor:  
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+ 
                    ~Conditions()
     {
      delete m_Conditions;
     }
   //--- Methods: 
   //+------------------------------------------------------------------+
   //| Get answer to the question "Is MF inverted"                      |
   //+------------------------------------------------------------------+ 
   bool Not()
     {
      //--- return bool
      return (m_not);
     }
   //+------------------------------------------------------------------+
   //| Invert MF                                                        |
   //+------------------------------------------------------------------+  
   void Not(bool value)
     {
      m_not=value;
     }
   //+------------------------------------------------------------------+
   //| Get operator that links expressions (and/or)                     |
   //+------------------------------------------------------------------+
   OperatorType Op()
     {
      //--- return type of operator
      return (m_op);
     }
   //+------------------------------------------------------------------+
   //| Set operator that links expressions (and/or)                     |
   //+------------------------------------------------------------------+     
   void Op(OperatorType value)
     {
      m_op=value;
     }
   //+------------------------------------------------------------------+
   //| Get a list of conditions (single or multiples)                    |
   //+------------------------------------------------------------------+
   CList *ConditionsList()
     {
      //--- return list of conditions
      return (m_Conditions);
     }
   //+------------------------------------------------------------------+
   //| Check type                                                       |
   //+------------------------------------------------------------------+  
   virtual bool IsTypeOf(EnCondition type)
     {
      //--- return type
      return(type==TYPE_CLASS_Conditions);
     }
  };
//+------------------------------------------------------------------+
//| Class used by rule parser                                        |
//+------------------------------------------------------------------+
class IParsableRule : public CObject
  {
public:
   //--- Methods: 
   //+------------------------------------------------------------------+
   //| Get condition (IF) part of the rule                              |
   //+------------------------------------------------------------------+   
   virtual Conditions *Condition()
     {
      //--- return NULL
      return (NULL);
     }
   //+------------------------------------------------------------------+
   //| Set condition (IF) part of the rule                              |
   //+------------------------------------------------------------------+      
   virtual void Condition(Conditions *value)
     {
     }
   //+------------------------------------------------------------------+
   //| Get conclusion (THEN) part of the rule                           |
   //+------------------------------------------------------------------+ 
   virtual SingleCondition *Conclusion()
     {
      //--- return NULL
      return (NULL);
     }
   //+------------------------------------------------------------------+
   //| Set conclusion (THEN) part of the rule                           |
   //+------------------------------------------------------------------+      
   virtual void Conclusion(SingleCondition *value)
     {
     }
   //+------------------------------------------------------------------+
   //| Check type                                                       |
   //+------------------------------------------------------------------+  
   virtual bool IsTypeOf(EnRule type)
     {
      //--- return type
      return(type==TYPE_CLASS_IParsableRule);
     }
  };
//+------------------------------------------------------------------+
//| Implements common functionality of fuzzy rules                   |
//+------------------------------------------------------------------+
class GenericFuzzyRule : public IParsableRule
  {
private:
   Conditions       *m_generic_condition; // Generic path of condition    
public:
   //--- Constructors:
   //+------------------------------------------------------------------+
   //| Constructor without parameters                                   |
   //+------------------------------------------------------------------+
                     GenericFuzzyRule(void){}
   //--- Destructor:  
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+ 
                    ~GenericFuzzyRule()
     {
      delete m_generic_condition;
     }
   //--- Methods: 
   //+------------------------------------------------------------------+
   //| Get condition (IF) part of the rule                              |
   //+------------------------------------------------------------------+ 
   Conditions *Condition()
     {
      //--- return generic path of condition
      return (m_generic_condition);
     }
   //+------------------------------------------------------------------+
   //| Set condition (IF) part of the rule                              |
   //+------------------------------------------------------------------+      
   void Condition(Conditions *value)
     {
      m_generic_condition=value;
     }
   //+------------------------------------------------------------------+
   //| Create a single condition(1)                                     |
   //+------------------------------------------------------------------+ 
   FuzzyCondition *CreateCondition(CFuzzyVariable *var,CFuzzyTerm *term)
     {
      //--- return fuzzy condition
      return new FuzzyCondition(var, term);
     }
   //+------------------------------------------------------------------+
   //| Create a single condition(2)                                     |
   //+------------------------------------------------------------------+ 
   FuzzyCondition *CreateCondition(CFuzzyVariable *var,CFuzzyTerm *term,bool not)
     {
      //--- return fuzzy condition 
      return new FuzzyCondition(var, term, not);
     }
   //+------------------------------------------------------------------+
   //| Create a single condition(3)                                     |
   //+------------------------------------------------------------------+ 
   FuzzyCondition *CreateCondition(CFuzzyVariable *var,CFuzzyTerm *term,bool not,HedgeType hedge)
     {
      //--- return fuzzy condition
      return new FuzzyCondition(var, term, not, hedge);
     }
   //+------------------------------------------------------------------+
   //| Get conclusion (THEN) part of the rule                           |
   //+------------------------------------------------------------------+ 
   virtual SingleCondition *Conclusion()
     {
      //--- return NULL
      return (NULL);
     }
   //+------------------------------------------------------------------+
   //| Set conclusion (THEN) part of the rule                           |
   //+------------------------------------------------------------------+      
   virtual void Conclusion(SingleCondition *value)
     {
     }
   //+------------------------------------------------------------------+
   //| Check type                                                       |
   //+------------------------------------------------------------------+  
   virtual bool IsTypeOf(EnRule type)
     {
      //--- return type
      return(type==TYPE_CLASS_GenericFuzzyRule);
     }
  };
//+------------------------------------------------------------------+
//| Fuzzy rule for Mamdani fuzzy system.                             |
//| NOTE: a rule cannot be created directly, only via                |
//| MamdaniFuzzySystem::EmptyRule or MamdaniFuzzySystem::ParseRule   |
//+------------------------------------------------------------------+
class CMamdaniFuzzyRule : public GenericFuzzyRule
  {
private:
   SingleCondition *m_mamdani_conclusion;   // Mamdani conclusion
   double            m_weight;               // Weight of Mamdani rule
public:
   //--- Constructors:
   //+---------------------------------------------------------------+
   //| Constructor without parameters                                |
   //+---------------------------------------------------------------+
                     CMamdaniFuzzyRule(void)
     {
      m_weight=1.0;
     }
   //--- Destructor:  
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+ 
                    ~CMamdaniFuzzyRule()
     {
      delete m_mamdani_conclusion;
     }
   //--- Methods: 
   //+------------------------------------------------------------------+
   //| Get conclusion (THEN) part of the rule                           |
   //+------------------------------------------------------------------+ 
   SingleCondition *Conclusion()
     {
      //--- return Mamdani conclusion
      return (m_mamdani_conclusion);
     }
   //+------------------------------------------------------------------+
   //| Set conclusion (THEN) part of the rule                           |
   //+------------------------------------------------------------------+  
   void Conclusion(SingleCondition *value)
     {
      m_mamdani_conclusion=value;
     }
   //+------------------------------------------------------------------+
   //| Get weight of the rule                                           |
   //+------------------------------------------------------------------+ 
   double Weight()
     {
      //--- return weight of rule
      return (m_weight);
     }
   //+------------------------------------------------------------------+
   //| Set weight of the rule                                           |
   //+------------------------------------------------------------------+
   void Weight(const double value)
     {
      m_weight=value;
     }
   //+------------------------------------------------------------------+
   //| Check type                                                       |
   //+------------------------------------------------------------------+  
   virtual bool IsTypeOf(EnRule type)
     {
      //--- return type
      return(type==TYPE_CLASS_MamdaniFuzzyRule);
     }
  };
//+------------------------------------------------------------------+
//| Fuzzy rule for Sugeno fuzzy system                               |
//| NOTE: a rule cannot be created directly, only via                |
//| SugenoFuzzySystem::EmptyRule or SugenoFuzzySystem::ParseRule     |
//+------------------------------------------------------------------+
class CSugenoFuzzyRule : public GenericFuzzyRule
  {
private:
   SingleCondition *m_sugeno_conclusion; // Sugeno conclusion
public:
   //--- Constructors:
   //+------------------------------------------------------------------+
   //| Constructor without parameters                                   |
   //+-------------------------- ---------------------------------------+
                     CSugenoFuzzyRule(void){}
   //--- Destructor:  
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+ 
                    ~CSugenoFuzzyRule()
     {
      delete m_sugeno_conclusion;
     }
   //--- Methods: 
   //+------------------------------------------------------------------+
   //| Get conclusion (THEN) part of the rule                           |
   //+------------------------------------------------------------------+
   SingleCondition *Conclusion()
     {
      //--- return] Sugeno conclusion
      return (m_sugeno_conclusion);
     }
   //+------------------------------------------------------------------+
   //| Set conclusion (THEN) part of the rule                           |
   //+------------------------------------------------------------------+     
   void Conclusion(SingleCondition *value)
     {
      m_sugeno_conclusion=value;
     }
   //+------------------------------------------------------------------+
   //| Check type                                                       |
   //+------------------------------------------------------------------+  
   virtual bool IsTypeOf(EnRule type)
     {
      //--- return type
      return(type==TYPE_CLASS_SugenoFuzzyRule);
     }
  };
//+------------------------------------------------------------------+


/*
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
#include "InferenceMethod.mqh"
//+------------------------------------------------------------------+
//| Purpose: Creating fuzzy rules                                    |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| And/Or operator type                                             |
//+------------------------------------------------------------------+ 
enum OperatorType
  {
   And,                               // And operator
   Or                                 // Or operator
  };
//+------------------------------------------------------------------+
//| Hedge modifiers                                                  |
//+------------------------------------------------------------------+ 
enum HedgeType
  {
   None,                              // None
   Slightly,                          // Cube root
   Somewhat,                          // Square root
   Very,                              // Square
   Extremely                          // Cube
  };
//+------------------------------------------------------------------+
//| Class of conditions used in the 'if' expression                  |
//+------------------------------------------------------------------+
class ICondition : public CObject
  {
public:
   //--- Method:
   //+------------------------------------------------------------------+
   //| Check type                                                       |
   //+------------------------------------------------------------------+  
   virtual bool IsTypeOf(EnCondition type)
     {
      //--- return type
      return(type==TYPE_CLASS_ICondition);
     }
  };
//+------------------------------------------------------------------+
//| Single condition                                                 |
//+------------------------------------------------------------------+
class SingleCondition : public ICondition //TODO: SingleCondition must be not public
  {
private:
   INamedVariable   *m_var;        // Type of variable
   INamedValue      *m_term;       // Type of value
   bool              m_not;        // Is MF inverted 
public:
   //--- Constructors:
   //+------------------------------------------------------------------+
   //| Constructor without parameters                                   |
   //+------------------------------------------------------------------+
                     SingleCondition(void)
     {
      m_var = NULL;
      m_not = false;
      m_term=NULL;
     };
   //+------------------------------------------------------------------+
   //| First constructor with parameters                                |
   //+------------------------------------------------------------------+
                     SingleCondition(INamedVariable *var,INamedValue *term)
     {
      m_var=var;
      m_term=term;
     }
   //+------------------------------------------------------------------+
   //| Second constructor with parameters                               |
   //+------------------------------------------------------------------+
                     SingleCondition(INamedVariable *var,INamedValue *term,bool not)
     {
      m_var=var;
      m_term=term;
      m_not=not;
     }
   //--- Destructor:  
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+ 
                    ~SingleCondition()
     {
      if(CheckPointer(m_var)==POINTER_DYNAMIC)
        {
         delete m_var;
        }
      if(CheckPointer(m_term)==POINTER_DYNAMIC)
        {
         delete m_term;
        }
     }
   //--- Methods: 
   //+------------------------------------------------------------------+
   //| Get a linguistic variable to which the condition is related      |
   //+------------------------------------------------------------------+  
   INamedVariable *Var()
     {
      //--- return variable
      return (m_var);
     }
   //+------------------------------------------------------------------+
   //| Set a linguistic variable to which the condition is related      |
   //+------------------------------------------------------------------+     
   void Var(INamedVariable *&value)
     {
      m_var=value;
     }
   //+------------------------------------------------------------------+
   //| Get answer to the question "Is MF inverted"                      |
   //+------------------------------------------------------------------+ 
   bool Not()
     {
      //--- return bool
      return (m_not);
     }
   //+------------------------------------------------------------------+
   //| Invert MF                                                        |
   //+------------------------------------------------------------------+ 
   void Not(bool not)
     {
      m_not=not;
     }
   //+------------------------------------------------------------------+
   //| Get a term in expression 'variable is term'                      |
   //+------------------------------------------------------------------+
   //---'Term' is bad property name here
   INamedValue *Term()
     {
      //--- return term
      return (m_term);
     }
   //+------------------------------------------------------------------+
   //| Set a term in expression 'variable is term'                      |
   //+------------------------------------------------------------------+
   void Term(INamedValue *&value)
     {
      m_term=value;
     }
   //+------------------------------------------------------------------+
   //| Check type                                                       |
   //+------------------------------------------------------------------+  
   virtual bool IsTypeOf(EnCondition type)
     {
      //--- return type
      return(type==TYPE_CLASS_SingleCondition);
     }
  };
//+------------------------------------------------------------------+
//| Condition of fuzzy rule for the both Mamdani and Sugeno systems  |
//+------------------------------------------------------------------+
class FuzzyCondition : public SingleCondition
  {
private:
   HedgeType         m_hedge;         // hedge type
public:
   //--- Constructors:
   //+------------------------------------------------------------------+
   //| First constructor with parameters                                |
   //+------------------------------------------------------------------+
                     FuzzyCondition(CFuzzyVariable *var,CFuzzyTerm *term,bool not)
     {
      SingleCondition::Var(var);
      SingleCondition::Term(term);
      SingleCondition::Not(not);
      m_hedge=None;
     }
   //+------------------------------------------------------------------+
   //| Second constructor with parameters                               |
   //+------------------------------------------------------------------+     

                     FuzzyCondition(CFuzzyVariable *var,CFuzzyTerm *term,bool not,HedgeType hedge)
     {
      SingleCondition::Var(var);
      SingleCondition::Term(term);
      SingleCondition::Not(not);
      m_hedge=hedge;
     }
   //+------------------------------------------------------------------+
   //| Thrid constructor with parameters                                |
   //+------------------------------------------------------------------+       
                     FuzzyCondition(CFuzzyVariable *var,CFuzzyTerm *term)

     {
      SingleCondition::Var(var);
      SingleCondition::Term(term);
      SingleCondition::Not(false);
     }
   //--- Methods: 
   //+------------------------------------------------------------------+
   //| Get hedge type                                                   |
   //+------------------------------------------------------------------+  
   HedgeType Hedge()
     {
      //--- return hedge type
      return (m_hedge);
     }
   //+------------------------------------------------------------------+
   //| Set hedge type                                                   |
   //+------------------------------------------------------------------+  
   void Hedge(HedgeType value)
     {
      m_hedge=value;
     }
   //+------------------------------------------------------------------+
   //| Check type                                                       |
   //+------------------------------------------------------------------+  
   virtual bool IsTypeOf(EnCondition type)
     {
      //--- return type
      return(type==TYPE_CLASS_FuzzyCondition);
     }
  };
//+------------------------------------------------------------------+
//| Several conditions linked by or/and operators                    |
//+------------------------------------------------------------------+
class Conditions : public ICondition
  {
private:
   bool              m_not;           // Default : false
   OperatorType      m_op;            // Type of operator. Default : And 
   CList            *m_Conditions;    // List of conditions
public:
   //--- Constructors:
   //+------------------------------------------------------------------+
   //| Constructor without parameters                                   |
   //+------------------------------------------------------------------+
                     Conditions(void)
     {
      m_not=false;
      m_op = And;
      m_Conditions=new CList;
     }
   //--- Destructor:  
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+ 
                    ~Conditions()
     {
      delete m_Conditions;
     }
   //--- Methods: 
   //+------------------------------------------------------------------+
   //| Get answer to the question "Is MF inverted"                      |
   //+------------------------------------------------------------------+ 
   bool Not()
     {
      //--- return bool
      return (m_not);
     }
   //+------------------------------------------------------------------+
   //| Invert MF                                                        |
   //+------------------------------------------------------------------+  
   void Not(bool value)
     {
      m_not=value;
     }
   //+------------------------------------------------------------------+
   //| Get operator that links expressions (and/or)                     |
   //+------------------------------------------------------------------+
   OperatorType Op()
     {
      //--- return type of operator
      return (m_op);
     }
   //+------------------------------------------------------------------+
   //| Set operator that links expressions (and/or)                     |
   //+------------------------------------------------------------------+     
   void Op(OperatorType value)
     {
      m_op=value;
     }
   //+------------------------------------------------------------------+
   //| Get a list of conditions (single or multiples)                    |
   //+------------------------------------------------------------------+
   CList *ConditionsList()
     {
      //--- return list of conditions
      return (m_Conditions);
     }
   //+------------------------------------------------------------------+
   //| Check type                                                       |
   //+------------------------------------------------------------------+  
   virtual bool IsTypeOf(EnCondition type)
     {
      //--- return type
      return(type==TYPE_CLASS_Conditions);
     }
  };
//+------------------------------------------------------------------+
//| Class used by rule parser                                        |
//+------------------------------------------------------------------+
class IParsableRule : public CObject
  {
public:
   //--- Methods: 
   //+------------------------------------------------------------------+
   //| Get condition (IF) part of the rule                              |
   //+------------------------------------------------------------------+   
   virtual Conditions *Condition()
     {
      //--- return NULL
      return (NULL);
     }
   //+------------------------------------------------------------------+
   //| Set condition (IF) part of the rule                              |
   //+------------------------------------------------------------------+      
   virtual void Condition(Conditions *value)
     {
     }
   //+------------------------------------------------------------------+
   //| Get conclusion (THEN) part of the rule                           |
   //+------------------------------------------------------------------+ 
   virtual SingleCondition *Conclusion()
     {
      //--- return NULL
      return (NULL);
     }
   //+------------------------------------------------------------------+
   //| Set conclusion (THEN) part of the rule                           |
   //+------------------------------------------------------------------+      
   virtual void Conclusion(SingleCondition *value)
     {
     }
   //+------------------------------------------------------------------+
   //| Check type                                                       |
   //+------------------------------------------------------------------+  
   virtual bool IsTypeOf(EnRule type)
     {
      //--- return type
      return(type==TYPE_CLASS_IParsableRule);
     }
  };
//+------------------------------------------------------------------+
//| Implements common functionality of fuzzy rules                   |
//+------------------------------------------------------------------+
class GenericFuzzyRule : public IParsableRule
  {
private:
   Conditions       *m_generic_condition; // Generic path of condition    
public:
   //--- Constructors:
   //+------------------------------------------------------------------+
   //| Constructor without parameters                                   |
   //+------------------------------------------------------------------+
                     GenericFuzzyRule(void){}
   //--- Destructor:  
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+ 
                    ~GenericFuzzyRule()
     {
      delete m_generic_condition;
     }
   //--- Methods: 
   //+------------------------------------------------------------------+
   //| Get condition (IF) part of the rule                              |
   //+------------------------------------------------------------------+ 
   Conditions *Condition()
     {
      //--- return generic path of condition
      return (m_generic_condition);
     }
   //+------------------------------------------------------------------+
   //| Set condition (IF) part of the rule                              |
   //+------------------------------------------------------------------+      
   void Condition(Conditions *value)
     {
      m_generic_condition=value;
     }
   //+------------------------------------------------------------------+
   //| Create a single condition(1)                                     |
   //+------------------------------------------------------------------+ 
   FuzzyCondition *CreateCondition(CFuzzyVariable *var,CFuzzyTerm *term)
     {
      //--- return fuzzy condition
      return new FuzzyCondition(var, term);
     }
   //+------------------------------------------------------------------+
   //| Create a single condition(2)                                     |
   //+------------------------------------------------------------------+ 
   FuzzyCondition *CreateCondition(CFuzzyVariable *var,CFuzzyTerm *term,bool not)
     {
      //--- return fuzzy condition 
      return new FuzzyCondition(var, term, not);
     }
   //+------------------------------------------------------------------+
   //| Create a single condition(3)                                     |
   //+------------------------------------------------------------------+ 
   FuzzyCondition *CreateCondition(CFuzzyVariable *var,CFuzzyTerm *term,bool not,HedgeType hedge)
     {
      //--- return fuzzy condition
      return new FuzzyCondition(var, term, not, hedge);
     }
   //+------------------------------------------------------------------+
   //| Get conclusion (THEN) part of the rule                           |
   //+------------------------------------------------------------------+ 
   virtual SingleCondition *Conclusion()
     {
      //--- return NULL
      return (NULL);
     }
   //+------------------------------------------------------------------+
   //| Set conclusion (THEN) part of the rule                           |
   //+------------------------------------------------------------------+      
   virtual void Conclusion(SingleCondition *value)
     {
     }
   //+------------------------------------------------------------------+
   //| Check type                                                       |
   //+------------------------------------------------------------------+  
   virtual bool IsTypeOf(EnRule type)
     {
      //--- return type
      return(type==TYPE_CLASS_GenericFuzzyRule);
     }
  };
//+------------------------------------------------------------------+
//| Fuzzy rule for Mamdani fuzzy system.                             |
//| NOTE: a rule cannot be created directly, only via                |
//| MamdaniFuzzySystem::EmptyRule or MamdaniFuzzySystem::ParseRule   |
//+------------------------------------------------------------------+
class CMamdaniFuzzyRule : public GenericFuzzyRule
  {
private:
   SingleCondition *m_mamdani_conclusion;   // Mamdani conclusion
   double            m_weight;               // Weight of Mamdani rule
public:
   //--- Constructors:
   //+---------------------------------------------------------------+
   //| Constructor without parameters                                |
   //+---------------------------------------------------------------+
                     CMamdaniFuzzyRule(void)
     {
      m_weight=1.0;
     }
   //--- Destructor:  
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+ 
                    ~CMamdaniFuzzyRule()
     {
      delete m_mamdani_conclusion;
     }
   //--- Methods: 
   //+------------------------------------------------------------------+
   //| Get conclusion (THEN) part of the rule                           |
   //+------------------------------------------------------------------+ 
   SingleCondition *Conclusion()
     {
      //--- return Mamdani conclusion
      return (m_mamdani_conclusion);
     }
   //+------------------------------------------------------------------+
   //| Set conclusion (THEN) part of the rule                           |
   //+------------------------------------------------------------------+  
   void Conclusion(SingleCondition *value)
     {
      m_mamdani_conclusion=value;
     }
   //+------------------------------------------------------------------+
   //| Get weight of the rule                                           |
   //+------------------------------------------------------------------+ 
   double Weight()
     {
      //--- return weight of rule
      return (m_weight);
     }
   //+------------------------------------------------------------------+
   //| Set weight of the rule                                           |
   //+------------------------------------------------------------------+
   void Weight(const double value)
     {
      m_weight=value;
     }
   //+------------------------------------------------------------------+
   //| Check type                                                       |
   //+------------------------------------------------------------------+  
   virtual bool IsTypeOf(EnRule type)
     {
      //--- return type
      return(type==TYPE_CLASS_MamdaniFuzzyRule);
     }
  };
//+------------------------------------------------------------------+
//| Fuzzy rule for Sugeno fuzzy system                               |
//| NOTE: a rule cannot be created directly, only via                |
//| SugenoFuzzySystem::EmptyRule or SugenoFuzzySystem::ParseRule     |
//+------------------------------------------------------------------+
class CSugenoFuzzyRule : public GenericFuzzyRule
  {
private:
   SingleCondition *m_sugeno_conclusion; // Sugeno conclusion
public:
   //--- Constructors:
   //+------------------------------------------------------------------+
   //| Constructor without parameters                                   |
   //+-------------------------- ---------------------------------------+
                     CSugenoFuzzyRule(void){}
   //--- Destructor:  
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+ 
                    ~CSugenoFuzzyRule()
     {
      delete m_sugeno_conclusion;
     }
   //--- Methods: 
   //+------------------------------------------------------------------+
   //| Get conclusion (THEN) part of the rule                           |
   //+------------------------------------------------------------------+
   SingleCondition *Conclusion()
     {
      //--- return] Sugeno conclusion
      return (m_sugeno_conclusion);
     }
   //+------------------------------------------------------------------+
   //| Set conclusion (THEN) part of the rule                           |
   //+------------------------------------------------------------------+     
   void Conclusion(SingleCondition *value)
     {
      m_sugeno_conclusion=value;
     }
   //+------------------------------------------------------------------+
   //| Check type                                                       |
   //+------------------------------------------------------------------+  
   virtual bool IsTypeOf(EnRule type)
     {
      //--- return type
      return(type==TYPE_CLASS_SugenoFuzzyRule);
     }
  };
//+------------------------------------------------------------------+
*/
