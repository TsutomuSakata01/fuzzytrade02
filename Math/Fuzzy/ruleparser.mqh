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
#include "Dictionary.mqh"
#include "FuzzyRule.mqh"
#include "Helper.mqh"
#include "InferenceMethod.mqh"
#include "SugenoVariable.mqh"
//+------------------------------------------------------------------+
//| Purpose: Analysis of the fuzzy rules                             |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Class responsible for parsing                                    |
//+------------------------------------------------------------------+
class RuleParser : public INamedVariable
  {
   //+------------------------------------------------------------------+
   //| Base class for all expression                                    |
   //+------------------------------------------------------------------+
   class IExpression : public CObject
     {
   public:
      //--- Methods:
      //+------------------------------------------------------------------+
      //| Get text                                                         |
      //+------------------------------------------------------------------+  
      virtual string Text()
        {
         //--- return NULL
         return(NULL);
        }
      //+------------------------------------------------------------------+
      //| Check type                                                       |
      //+------------------------------------------------------------------+  
      virtual bool IsTypeOf(EnLexem type)
        {
         //--- return type
         return (type==TYPE_CLASS_IExpression);
        }
     };
   //+------------------------------------------------------------------+
   //| Class for creating lexem                                         |
   //+------------------------------------------------------------------+
   class Lexem : public IExpression
     {
   public:
      //--- Methods:
      //+------------------------------------------------------------------+
      //| Get text                                                         |
      //+------------------------------------------------------------------+     
      virtual string Text()
        {
         //--- return NULL
         return(NULL);
        }
      //+------------------------------------------------------------------+
      //| Convert text to string                                           |
      //+------------------------------------------------------------------+  
      string ToString()
        {
         //--- return
         return IExpression::Text();
        }
      //+------------------------------------------------------------------+
      //| Check type                                                       |
      //+------------------------------------------------------------------+  
      virtual bool IsTypeOf(EnLexem type)
        {
         //--- return type
         return(type==TYPE_CLASS_Lexem);
        }
     };
   //+------------------------------------------------------------------+
   //| Class condition expression                                       |
   //+------------------------------------------------------------------+     
   class ConditionExpression : public IExpression
     {
   private:
      CArrayObj        *m_expressions;   // List of expression
      FuzzyCondition   *m_condition;     // Fuzzy condition
   public:
      //--- Constructor:
      //+------------------------------------------------------------------+
      //| Constructor with parameters                                      |
      //+------------------------------------------------------------------+
                        ConditionExpression(CArrayObj *expressions,FuzzyCondition *condition)
        {
         m_expressions=expressions;
         m_condition=condition;
        }
      //--- Methods:
      //+------------------------------------------------------------------+
      //| Get list of expression                                           |
      //+------------------------------------------------------------------+  
      CArrayObj *Expressions()
        {
         //--- return list of expressions
         return (m_expressions);
        }
      //+------------------------------------------------------------------+
      //| Set list of expression                                           |
      //+------------------------------------------------------------------+          
      void Expressions(CArrayObj *value)
        {
         m_expressions=value;
        }
      //+------------------------------------------------------------------+
      //| Get fuzzy condition                                              |
      //+------------------------------------------------------------------+          
      FuzzyCondition *Condition()
        {
         //--- return fuzzy condition
         return m_condition;
        }
      //+------------------------------------------------------------------+
      //| Set fuzzy condition                                              |
      //+------------------------------------------------------------------+        
      void Condition(FuzzyCondition *value)
        {
         m_condition=value;
        }
      //+------------------------------------------------------------------+
      //| Convert all expressions to text(string)                          |
      //+------------------------------------------------------------------+  
      string Text()
        {
         string sb;
         for(int i=0; i<m_expressions.Total(); i++)
           {
            IExpression *ex=m_expressions.At(i);
            string str=ex.Text();
            StringAdd(sb,str);
           }
         //--- return text of all expressions
         return ((string)sb);
        }
      //+------------------------------------------------------------------+
      //| Check type                                                       |
      //+------------------------------------------------------------------+  
      virtual bool IsTypeOf(EnLexem type)
        {
         //--- return type
         return(type==TYPE_CLASS_ConditionExpression);
        }
     };
   //+------------------------------------------------------------------+
   //| Class keyword lexem                                              |
   //+------------------------------------------------------------------+       
   class KeywordLexem : public Lexem
     {
   private:
      string            m_name;          // Name of keyword lexem
   public:
      //--- Constructor:
      //+------------------------------------------------------------------+
      //| Constructor with parameters                                      |
      //+------------------------------------------------------------------+   
                        KeywordLexem(const string name)
        {
         m_name=name;
        }
      //--- Methods:
      //+------------------------------------------------------------------+
      //| Get text                                                         |
      //+------------------------------------------------------------------+        
      string Text()
        {
         //--- return name
         return (m_name);
        }
      //+------------------------------------------------------------------+
      //| Check type                                                       |
      //+------------------------------------------------------------------+  
      virtual bool IsTypeOf(EnLexem type)
        {
         //--- return
         return(type==TYPE_CLASS_KeywordLexem);
        }
     };
   //+------------------------------------------------------------------+
   //| Class for handling variable lexem                                |
   //+------------------------------------------------------------------+      
   class VarLexem : public Lexem
     {
   private:
      INamedVariable   *m_var;           // Variable type
      bool              m_input;         // Confirmation of the variable
   public:
      //--- Constructor:
      //+------------------------------------------------------------------+
      //| Constructor with parameters                                      |
      //+------------------------------------------------------------------+   
                        VarLexem(INamedVariable *&var,bool in)
        {
         m_var=var;
         m_input=in;
        }
      //--- Destructor:
      //+------------------------------------------------------------------+
      //| Destructor                                                       |
      //+------------------------------------------------------------------+     
                       ~VarLexem(){}
      //--- Methods:
      //+------------------------------------------------------------------+
      //| Get variable                                                     |
      //+------------------------------------------------------------------+         
      INamedVariable *Var()
        {
         //--- return
         return (m_var);
        }
      //+------------------------------------------------------------------+
      //| Set variable                                                     |
      //+------------------------------------------------------------------+           
      void Var(INamedVariable *var)
        {
         m_var=var;
        }
      //+------------------------------------------------------------------+
      //| Get name                                                         |
      //+------------------------------------------------------------------+         
      string Text()
        {
         //--- return
         return m_var.Name();
        }
      //+------------------------------------------------------------------+
      //| Get input                                                        |
      //+------------------------------------------------------------------+           
      bool Input()
        {
         //--- return
         return (m_input);
        }
      //+------------------------------------------------------------------+
      //| Set input                                                        |
      //+------------------------------------------------------------------+          
      void Input(bool value)
        {
         m_input=value;
        }
      //+------------------------------------------------------------------+
      //| Check type                                                       |
      //+------------------------------------------------------------------+  
      virtual bool IsTypeOf(EnLexem type)
        {
         //--- return
         return(type==TYPE_CLASS_VarLexem);
        }
     };
   //+------------------------------------------------------------------+
   //| Class alternative lexem                                          |
   //+------------------------------------------------------------------+       
   class IAltLexem : public Lexem
     {
   public:
      //--- Methods:
      //+------------------------------------------------------------------+
      //| Get alternative lexem                                            |
      //+------------------------------------------------------------------+      
      virtual IAltLexem *Alternative(){ return(NULL);}
      //+------------------------------------------------------------------+
      //| Set alternative lexem                                            |
      //+------------------------------------------------------------------+
      virtual void Alternative(IAltLexem *value){}
      //+------------------------------------------------------------------+
      //| Check type                                                       |
      //+------------------------------------------------------------------+  
      virtual bool IsTypeOf(EnLexem type)
        {
         return(type==TYPE_CLASS_AltLexem);
        }
     };
   //+------------------------------------------------------------------+
   //| Class term lexem                                                 |
   //+------------------------------------------------------------------+
   class TermLexem : public IAltLexem
     {
   private:
      INamedValue      *m_term;          // Value type
      IAltLexem        *m_alternative;   // Alternative lexem
      bool              m_input;         //
   public:
      //--- Constructor:
      //+------------------------------------------------------------------+
      //| Constructor with parameters                                      |
      //+------------------------------------------------------------------+      
                        TermLexem(INamedValue *term,bool in)
        {
         m_term=term;
         m_input=in;
        }
      //--- Destructor:  
      //+------------------------------------------------------------------+
      //| Destructor                                                       |
      //+------------------------------------------------------------------+
                       ~TermLexem()
        {
         if(m_alternative!=NULL)
           {
            delete m_alternative;
           }
        }
      //--- Methods:
      //+------------------------------------------------------------------+
      //| Get term                                                         |
      //+------------------------------------------------------------------+        
      INamedValue *Term()
        {
         //--- return term
         return (m_term);
        }
      //+------------------------------------------------------------------+
      //| Set term                                                         |
      //+------------------------------------------------------------------+         
      void Term(INamedValue *value)
        {
         m_term=value;
        }
      //+------------------------------------------------------------------+
      //| Get name of term                                                 |
      //+------------------------------------------------------------------+ 
      string Text()
        {
         //--- return name
         return m_term.Name();
        }
      //+------------------------------------------------------------------+
      //| Get alternative lexem                                            |
      //+------------------------------------------------------------------+ 
      IAltLexem *Alternative()
        {
         //--- return alternative lexem
         return (m_alternative);
        }
      //+------------------------------------------------------------------+
      //| Set alternative lexem                                            |
      //+------------------------------------------------------------------+         
      void Alternative(IAltLexem *value)
        {
         m_alternative=value;
        }
      //+------------------------------------------------------------------+
      //| Check type                                                       |
      //+------------------------------------------------------------------+  
      virtual bool IsTypeOf(EnLexem type)
        {
         //--- return type
         return(type==TYPE_CLASS_TermLexem);
        }
     };
   //+------------------------------------------------------------------+
   //| Build lexems list                                                |
   //+------------------------------------------------------------------+
private:
   static CList *BuildLexemsList(CList *in,CList *out)
     {
      CList *lexems=new CList();
      for(int i=0;i<ArraySize(KEYWORDS); i++)
        {
         string keyword=KEYWORDS[i];
         KeywordLexem *keywordLexem=new KeywordLexem(keyword);
         CDictionary_String_Obj *p_so=new CDictionary_String_Obj;
         p_so.SetAll(keywordLexem.Text(),keywordLexem);
         lexems.Add(p_so);
        }
      for(int i=0; i<in.Total(); i++)
        {
         INamedVariable *var=in.GetNodeAtIndex(i);
         BuildLexemsList(var,true,lexems);
        }
      for(int i=0; i<out.Total(); i++)
        {
         INamedVariable *var=out.GetNodeAtIndex(i);
         BuildLexemsList(var,false,lexems);
        }
      //--- return lexems
      return (lexems);
     }
   //+------------------------------------------------------------------+
   //| Build lexems list                                                |
   //+------------------------------------------------------------------+
   static void BuildLexemsList(INamedVariable *var,bool in,CList *&lexems)
     {
      VarLexem *varLexem=new VarLexem(var,in);
      CDictionary_String_Obj *p_so_var=new CDictionary_String_Obj;
      p_so_var.SetAll(varLexem.Text(),varLexem);
      lexems.Add(p_so_var);
      for(int i=0; i<var.Values().Total(); i++)
        {
         INamedValue *term=var.Values().GetNodeAtIndex(i);
         TermLexem *termLexem=new TermLexem(term,in);
         Lexem *foundLexem;
         bool contain=false;
         for(int j=0; j<lexems.Total(); j++)
           {
            CDictionary_String_Obj *p_so=lexems.GetNodeAtIndex(j);
            foundLexem=p_so.Value();
            if(p_so.Key()==termLexem.Text())
              {
               contain=true;
               break;
              }
           }
         if(contain==false)
           {
            CDictionary_String_Obj *p_so_val=new CDictionary_String_Obj;
            p_so_val.SetAll(termLexem.Text(),termLexem);
            lexems.Add(p_so_val);
           }
         else
           {
            if(foundLexem.IsTypeOf(TYPE_CLASS_TermLexem))
              {
               //--- There can be more than one terms with the same name.
               //--- TODO: But only if they belong to defferent variables.
               TermLexem *foundTermLexem=foundLexem;
               while(foundTermLexem.Alternative()!=NULL)
                 {
                  foundTermLexem=foundTermLexem.Alternative();
                 }
               foundTermLexem.Alternative(termLexem);
              }
            else
              {
               //--- Only terms of different vatiables can have the same name
               Print("Found more than one lexems with the same name");
              }
           }
        }
     }
   //+------------------------------------------------------------------+
   //| Parse lexems                                                     |
   //+------------------------------------------------------------------+
   static CArrayObj *ParseLexems(const string rule,CList *&lexems)
     {
      CArrayObj *expressions=new CArrayObj;
      string words[];
      StringSplit(rule,' ',words);
      int index=0;
      for(int i=0; i<ArraySize(words); i++)
        {
         string word=words[i];
         //Lexem *lexem;
         CObject *lexem = NULL;
         if(TryGetValue(lexems,word,lexem))
           {
            expressions.Add(lexem);
           }
         else
           {
            Print(StringFormat("Unknown identifier : %s",word));
            //--- return  NULL
            return(NULL);
           }
        }
      //--- return expressions
      return (expressions);
     }
   //+------------------------------------------------------------------+
   //| Extract single condidtions                                       |
   //+------------------------------------------------------------------+
   static CArrayObj *ExtractSingleCondidtions(CArrayObj *&conditionExpression,CList *&in,CList *&lexems)
     {
      CArrayObj *copyExpressions=conditionExpression;
      CArrayObj *expressions=new CArrayObj;
      int index=0;
      while(copyExpressions.Total()-index>0)
        {
         IExpression *expr0=copyExpressions.At(index);
         if(expr0.IsTypeOf(TYPE_CLASS_VarLexem))
           {
            //--- Parse variable
            VarLexem *varLexem=copyExpressions.At(index);
            if(copyExpressions.Total()<3)
              {
               Print(StringFormat("Condition strated with '%s' is incorrect.",varLexem.Text()));
               //--- return NULL
               return(NULL);
              }
            if(varLexem.Input()==false)
              {
               Print("The variable in condition part must be an input variable.");
               //--- return NULL
               return(NULL);
              }
            //--- Parse 'is' lexem
            Lexem *exprIs=copyExpressions.At(index+1);
            CDictionary_String_Obj *p_so;
            for(int i=0;i<lexems.Total();i++)
              {
               p_so=lexems.GetNodeAtIndex(i);
               if(p_so.Key()=="is")
                 {
                  break;
                 }
              }
            if(exprIs!=p_so.Value())
              {
               Print(StringFormat("'is' keyword must go after '%s' identifier.",varLexem.Text()));
               //--- return NULL
               return(NULL);
              }
            //--- Parse 'not' lexem (if exists)
            int cur=2;
            bool not=false;
            for(int i=0;i<lexems.Total();i++)
              {
               p_so=lexems.GetNodeAtIndex(i);
               if(p_so.Key()=="not")
                 {
                  break;
                 }
              }
            if(copyExpressions.At(cur+index)==p_so.Value())
              {
               not=true;
               cur++;
               if(copyExpressions.Total()-index<=cur)
                 {
                  Print("Error at 'not' in condition part of the rule.");
                  //--- return NULL
                  return(NULL);
                 }
              }
            //--- "slightly"
            //--- "somewhat"
            //--- "very"
            //--- "extremely"
            //--- Parse hedge modifier (if exists)
            HedgeType hedge=None;
            for(int i=0;i<lexems.Total();i++)
              {
               p_so=lexems.GetNodeAtIndex(i);
               if(p_so.Key()=="slightly")
                 {
                  if(copyExpressions.At(cur+index)==p_so.Value())
                    {
                     hedge=Slightly;
                     break;
                    }
                 }
               else if(p_so.Key()=="somewhat")
                 {
                  if(copyExpressions.At(cur+index)==p_so.Value())
                    {
                     hedge=Somewhat;
                     break;
                    }
                 }
               else if(p_so.Key()=="very")
                 {
                  if(copyExpressions.At(cur+index)==p_so.Value())
                    {
                     hedge=Very;
                     break;
                    }
                 }
               else if(p_so.Key()=="extremely")
                 {
                  if(copyExpressions.At(cur+index)==p_so.Value())
                    {
                     hedge=Extremely;
                     break;
                    }
                 }
              }
            if(hedge!=None)
              {
               cur++;
               if(copyExpressions.Total()-index<=cur)
                 {
                  Print("Error in condition part of the rule.");
                  //--- return NULL
                  return(NULL);
                 }
              }
            //--- Parse term
            Lexem *exprTerm=copyExpressions.At(cur+index);
            if(!exprTerm.IsTypeOf(TYPE_CLASS_TermLexem))
              {
               Print(StringFormat("Wrong identifier '%s' in conditional part of the rule.",exprTerm.Text()));
               //--- return NULL
               return(NULL);
              }
            IAltLexem *altLexem=exprTerm;
            TermLexem *termLexem=NULL;
            do
              {
               if(!altLexem.IsTypeOf(TYPE_CLASS_TermLexem))
                 {
                  continue;
                 }
               termLexem=altLexem;
               if(varLexem.Var().Values().IndexOf(termLexem.Term())==-1)
                 {
                  termLexem=NULL;
                  continue;
                 }
              }
            while((altLexem=altLexem.Alternative())!=NULL && termLexem==NULL);
            if(termLexem==NULL)
              {
               Print(StringFormat("Wrong identifier '%s' in conditional part of the rule.",exprTerm.Text()));
               //--- return NULL
               return(NULL);
              }
            //--- Add new condition expression
            FuzzyCondition *condition=new FuzzyCondition(varLexem.Var(),termLexem.Term(),not,hedge);
            CArrayObj *cutExpression = GetRange(copyExpressions,index,cur+1);
            expressions.Add(new ConditionExpression(cutExpression,condition));
            cutExpression.FreeMode(false);
            delete cutExpression;
            index=index+cur+1;
           }
         else
           {
            CDictionary_String_Obj *p_so;
            IExpression *expr=copyExpressions.At(index);
            bool contain=false;
            for(int i=0; i<lexems.Total(); i++)
              {
               p_so=lexems.GetNodeAtIndex(i);
               if(p_so.Key()=="and" || p_so.Key()=="or" || p_so.Key()=="(" || p_so.Key()==")")
                 {
                  if(expr==p_so.Value())
                    {
                     contain=true;
                     break;
                    }
                 }
              }
            if(contain==true)
              {
               expressions.Add(copyExpressions.At(index));
               index=index+1;
              }
            else
              {
               Lexem *unknownLexem=expr;
               Print(StringFormat("Lexem '%s' found at the wrong place in condition part of the rule.",unknownLexem.Text()));
               //--- return NULL
               return (NULL);
              }
           }
        }
      //--- return expressions
      return (expressions);
     }
   //+------------------------------------------------------------------+
   //| Parse conditions                                                 |
   //+------------------------------------------------------------------+
   static Conditions *ParseConditions(CArrayObj *conditionExpression,CList *in,CList *lexems)
     {
      //--- Extract single conditions
      CArrayObj *expressions=ExtractSingleCondidtions(conditionExpression,in,lexems);
      if(expressions.Total()==0)
        {
         Print("No valid conditions found in conditions part of the rule.");
         //--- return NULL
         return (NULL);
        }
      ICondition *cond=ParseConditionsRecurse(expressions,lexems);
      delete expressions;
      if(cond.IsTypeOf(TYPE_CLASS_Conditions))
        {
         //--- return conditions
         return (cond);
        }
      else
        {
         delete cond;
         delete expressions;
         Conditions *conditions=new Conditions();
         //--- return conditions
         return (conditions);
        }
     }
   //+------------------------------------------------------------------+
   //| Find pair bracket                                                |
   //+------------------------------------------------------------------+
   static int FindPairBracket(CArrayObj *expressions,CList *&lexems)
     {
      //--- Assume that '(' stands at first place
      int bracketsOpened=1;
      int closeBracket=-1;
      CDictionary_String_Obj *p_so_open;
      CDictionary_String_Obj *p_so_close;
      for(int i=0; i<lexems.Total(); i++)
        {
         CDictionary_String_Obj *p_so=lexems.GetNodeAtIndex(i);
         if(p_so.Key()=="(")
           {
            p_so_open=p_so;
           }
         if(p_so.Key()==")")
           {
            p_so_close=p_so;
           }
        }
      for(int i=1; i<expressions.Total(); i++)
        {
         if(expressions.At(i)==p_so_open.Value())
           {
            bracketsOpened++;
           }
         else if(expressions.At(i)==p_so_close.Value())
           {
            bracketsOpened--;
            if(bracketsOpened==0)
              {
               closeBracket=i;
               break;
              }
           }
        }
      //--- return index of bracket
      return (closeBracket);
     }
   //+------------------------------------------------------------------+
   //| Parse conditions recurse                                         |
   //+------------------------------------------------------------------+
   static ICondition *ParseConditionsRecurse(CArrayObj *expressions,CList *&lexems)
     {
      if(expressions.Total()<1)
        {
         Print("Empty condition found.");
         //--- return NULL
         return(NULL);
        }
      CDictionary_String_Obj *p_so;
      for(int i=0; i<lexems.Total();i++)
        {
         p_so=lexems.GetNodeAtIndex(i);
         if(p_so.Key()=="(")
           {
            break;
           }
        }
      IExpression *expr=expressions.At(0);
      if(expressions.At(0)==p_so.Value() && FindPairBracket(expressions,lexems)==expressions.Total())
        {
         //--- Remove extra brackets
         //-- return  conditions
         CArrayObj *cutExpression=GetRange(expressions,1,expressions.Total()-2);
         ICondition *cond=ParseConditionsRecurse(cutExpression,lexems);
         cutExpression.FreeMode(false);
         delete cutExpression;
         return cond;
        }
      else if(expressions.Total()==1 && expr.IsTypeOf(TYPE_CLASS_ConditionExpression))
        {
         //-- return single conditions
         ConditionExpression *condExp=expressions.At(0);
         return condExp.Condition();
        }
      else
        {
         //--- Parse list of one level conditions connected by or/and
         CArrayObj *copyExpressions=expressions;
         ConditionExpression *condExp;
         Conditions *conds=new Conditions();
         int index=0;
         bool setOrAnd=false;
         while(copyExpressions.Total()-index>0)
           {
            ICondition *cond=NULL;
            for(int i=0; i<lexems.Total();i++)
              {
               p_so=lexems.GetNodeAtIndex(i);
               if(p_so.Key()=="(")
                 {
                  break;
                 }
              }
            if(copyExpressions.At(0)==p_so.Value())
              {
               //--- Find pair bracket
               int closeBracket=FindPairBracket(copyExpressions,lexems);
               if(closeBracket==-1)
                 {
                  Print("Parenthesis error.");
                  //--- return NULL
                  return (NULL);
                 }
               CArrayObj *cutExpression=GetRange(copyExpressions,index+1,closeBracket-1);
               cond=ParseConditionsRecurse(cutExpression,lexems);
               cutExpression.FreeMode(false);
               delete cutExpression;
               index=index+closeBracket+1;
              }
            else if(expr.IsTypeOf(TYPE_CLASS_ConditionExpression))
              {
               condExp=copyExpressions.At(index);
               cond=condExp.Condition();
               index=index+1;
              }
            else
              {
               condExp=copyExpressions.At(index);
               Print(StringFormat("Wrong expression in condition part at '%s'",condExp.Text()));
               //--- return NULL
               return (NULL);
              }
            //--- And condition to the list
            conds.ConditionsList().Add(cond);
            p_so=NULL;
            CDictionary_String_Obj *p_so_and;
            CDictionary_String_Obj *p_so_or;
            for(int i=0; i<lexems.Total(); i++)
              {
               p_so=lexems.GetNodeAtIndex(i);
               if(p_so.Key()=="and")
                 {
                  p_so_and=p_so;
                 }
               if(p_so.Key()=="or")
                 {
                  p_so_or=p_so;
                 }
              }
            if(copyExpressions.Total()-index>0)
              {
               if((copyExpressions.At(index)==p_so_and.Value() && p_so_and.Key()=="and") || (copyExpressions.At(index)==p_so_or.Value() && p_so_or.Key()=="or"))
                 {
                  if(copyExpressions.Total()-index<2)
                    {
                     condExp=copyExpressions.At(index);
                     Print(StringFormat("Error at %s in condition part.",condExp.Text()));
                     //--- return NULL
                     return (NULL);
                    }
                  //--- Set and/or for conditions list
                  OperatorType newOp=NULL;
                  if(copyExpressions.At(index)==p_so_and.Value() && p_so_and.Key()=="and")
                    {
                     newOp=And;
                    }
                  if(copyExpressions.At(index)==p_so_or.Value() && p_so_or.Key()=="or")
                    {
                     newOp=Or;
                    }
                  if(setOrAnd)
                    {
                     if(conds.Op()!=newOp)
                       {
                        Print("At the one nesting level cannot be mixed and/or operations.");
                        //--- return NULL
                        return (NULL);
                       }
                    }
                  else
                    {
                     conds.Op(newOp);
                     setOrAnd=true;
                    }
                  index=index+1;
                 }
               else
                 {
                  string str;
                  condExp=copyExpressions.At(index);
                  str=condExp.Text();
                  condExp=copyExpressions.At(index+1);
                  Print(StringFormat("%s cannot goes after %s",str,condExp.Text()));
                  //--- return NULL
                  return (NULL);
                 }
              }
           }
         //--- return conditions
         return (conds);
        }
     }
   //+------------------------------------------------------------------+
   //| Parse conclusion                                                 |
   //+------------------------------------------------------------------+
   static SingleCondition *ParseConclusion(CArrayObj *&conditionExpression,CList *&out,CList *&lexems)
     {
      CArrayObj *copyExpression=conditionExpression;
      //--- Remove extra brackets
      CDictionary_String_Obj *p_so;
      CDictionary_String_Obj *p_so_open;
      CDictionary_String_Obj *p_so_close;
      for(int i=0; i<lexems.Total(); i++)
        {
         p_so=lexems.GetNodeAtIndex(i);
         if(p_so.Key()=="(")
           {
            p_so_open=p_so;
           }
         if(p_so.Key()==")")
           {
            p_so_close=p_so;
           }
        }
      int index=0;
      int Total=copyExpression.Total();
      while(Total>=2 && (copyExpression.At(index)==p_so_open.Value() && copyExpression.At(index+conditionExpression.Total()-1)==p_so_close.Value()))
        {
         index=index+1;
         Total=Total-2;
        }
      if(Total!=3)
        {
         Print("Conclusion part of the rule should be in form: 'variable is term'");
         //--- return NULL
         return (NULL);
        }
      //--- Parse variable
      Lexem *exprVariable=copyExpression.At(index);
      if(!exprVariable.IsTypeOf(TYPE_CLASS_VarLexem))
        {
         Print(StringFormat("Wrong identifier '%s' in conclusion part of the rule.",exprVariable.Text()));
         //--- return NULL
         return (NULL);
        }
      VarLexem *varLexem=exprVariable;
      if(varLexem.Input()==true)
        {
         Print("The variable in conclusion part must be an output variable.");
         //--- return NULL
         return (NULL);
        }
      //--- Parse 'is' lexem
      Lexem *exprIs=copyExpression.At(index+1);
      for(int i=0; i<lexems.Total(); i++)
        {
         p_so=lexems.GetNodeAtIndex(i);
         if(p_so.Key()=="is")
           {
            break;
           }
        }
      if(exprIs!=p_so.Value())
        {
         Print(StringFormat("'is' keyword must go after %s identifier.",varLexem.Text()));
         //--- return NULL
         return (NULL);
        }
      //--- Parse term
      Lexem *exprTerm=copyExpression.At(index+2);
      if(!exprTerm.IsTypeOf(TYPE_CLASS_TermLexem))
        {
         Print(StringFormat("Wrong identifier '%s' in conclusion part of the rule.",exprTerm.Text()));
        }
      IAltLexem *altLexem=exprTerm;
      TermLexem *termLexem=NULL;
      do
        {
         if(!altLexem.IsTypeOf(TYPE_CLASS_TermLexem))
           {
            continue;
           }
         termLexem=altLexem;
         if(varLexem.Var().Values().IndexOf(termLexem.Term())==-1)
           {
            termLexem=NULL;
            continue;
           }
        }
      while((altLexem=altLexem.Alternative())!=NULL && termLexem==NULL);
      if(termLexem==NULL)
        {
         Print(StringFormat("Wrong identifier '%s' in conclusion part of the rule.",exprTerm.Text()));
         //--- return NULL
         return (NULL);
        }
      //--- Return fuzzy rule's conclusion
      INamedVariable *var=varLexem.Var();
      INamedValue *term=termLexem.Term();
      //--- return single condition
      return new SingleCondition(var, term, false);
     }
   //+------------------------------------------------------------------+
   //| Parse                                                            |
   //+------------------------------------------------------------------+
public:
   static IParsableRule *Parse(const string rule,IParsableRule *emptyRule,CList *in,CList *out)
     {
      if(StringLen(rule)==0)
        {
         Print("Rule cannot be empty.");
         //--- return NULL
         return (NULL);
        }
      //--- Surround brakes with spaces, remove double spaces
      string sb=NULL;
      char ch;
      for(int i=0; i<StringLen(rule); i++)
        {
         ch=(char)StringGetCharacter(rule,i);
         if((ch=='(') || (ch==')'))
           {
            if(StringLen(sb)>0 && StringGetCharacter(sb,StringLen(sb)-1)==' ')
              {
               //--- Do not duplicate spaces
              }
            else
              {
               sb+=CharToString(' ');
              }
            sb+=CharToString(ch);
            sb+=CharToString(' ');
           }
         else
           {
            if(ch==' ' && StringLen(sb)>0 && StringGetCharacter(sb,StringLen(sb)-1)==' ')
              {
               // Do not duplicate spaces
              }
            else
              {
               sb+=CharToString(ch);
              }
           }
        }
      //--- Remove spaces
      //+------------------------------------------------------------------+
      //| Use conditional compilation to determine                         |
      //| the type of program MQL4 or MQL5 because they have               |
      //| different realization of StringTrimRight() and StringTrimLeft()  |
      //+------------------------------------------------------------------+      
#ifdef __MQL5__
      StringTrimRight(sb);
      StringTrimLeft(sb);
#else 
#ifdef  __MQL4__
      sb=StringTrimRight(sb);
      sb=StringTrimLeft(sb);
#endif
#endif
      string prepRule=sb;
      //--- Build lexems dictionary
      CList *lexemsDict=BuildLexemsList(in,out);
      //--- At first we parse lexems
      CArrayObj *expressions=ParseLexems(prepRule,lexemsDict);
      if(expressions.Total()==0)
        {
         Print("No valid identifiers found.");
         //--- return NULL
         return (NULL);
        }
      //--- Find condition & conclusion parts part  
      CDictionary_String_Obj *p_so;
      for(int i=0; i<lexemsDict.Total(); i++)
        {
         p_so=lexemsDict.GetNodeAtIndex(i);
         if(p_so.Key()=="if")
           {
            break;
           }
        }
      if(expressions.At(0)!=p_so.Value())
        {
         Print("'if' should be the first identifier.");
         //--- return NULL
         return (NULL);
        }
      int thenIndex=-1;
      for(int i=1; i<expressions.Total(); i++)
        {
         for(int j=0; j<lexemsDict.Total(); j++)
           {
            p_so=lexemsDict.GetNodeAtIndex(j);
            if(p_so.Key()=="then"){break;}
           }
         if(expressions.At(i)==p_so.Value())
           {
            thenIndex=i;
            break;
           }
        }
      if(thenIndex==-1)
        {
         Print("'then' identifier not found.");
         //--- return NULL
         return (NULL);
        }
      int conditionLen=thenIndex-1;
      if(conditionLen<1)
        {
         Print("Condition part of the rule not found.");
         //--- return NULL
         return (NULL);
        }
      int conclusionLen=expressions.Total()-thenIndex-1;
      if(conclusionLen<1)
        {
         Print("Conclusion part of the rule not found.");
         //--- return NULL
         return (NULL);
        }
      CArrayObj *conditionExpressions=GetRange(expressions,1,conditionLen);
      CArrayObj *conclusionExpressions=GetRange(expressions,thenIndex+1,conclusionLen);
      Conditions *conditions=ParseConditions(conditionExpressions,in,lexemsDict);
      emptyRule.Condition(conditions);
      SingleCondition *conclusion=ParseConclusion(conclusionExpressions,out,lexemsDict);
      if(emptyRule.IsTypeOf(TYPE_CLASS_MamdaniFuzzyRule))
        {
         CMamdaniFuzzyRule *mamdani_rule=emptyRule;
         mamdani_rule.Conclusion(conclusion);
         emptyRule=mamdani_rule;
        }
      if(emptyRule.IsTypeOf(TYPE_CLASS_SugenoFuzzyRule))
        {
         CSugenoFuzzyRule *sugeno_rule=emptyRule;
         sugeno_rule.Conclusion(conclusion);
         emptyRule=sugeno_rule;
        }
      //--- return empty rule
      conditionExpressions.FreeMode(false);
      delete conditionExpressions;
      conclusionExpressions.FreeMode(false);
      delete conclusionExpressions;
      expressions.FreeMode(false);
      delete expressions;
      delete lexemsDict;
      return (emptyRule);
     }
  };
//+------------------------------------------------------------------+
