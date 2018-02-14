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
#include <Object.mqh>
#include <Arrays\List.mqh>
#include "RuleParser.mqh"
//+------------------------------------------------------------------+
//| Gets the value associated with the specified key in the CList    |
//| Where key - string, value - CObject                              |
//+------------------------------------------------------------------+
bool TryGetValue(CList *list,string key,CObject *&value)
  {
   for(int i=0; i<list.Total(); i++)
     {
      CDictionary_String_Obj *pair=list.GetNodeAtIndex(i);
      if(pair.Key()==key)
        {
         value=pair.Value();
         return (true);
        }
     }
   return (false);
  }
//+------------------------------------------------------------------+
//| Removes a range of elements from a list of CList                 |
//+------------------------------------------------------------------+
void RemoveRange(CArrayObj &list,const int index,const int count)
  {
   for(int i=0; i<count; i++)
     {
      list.Delete(index);
     }
  }
//+------------------------------------------------------------------+
//| It creates a shallow copy of a range of elements                 |
//| from the original list of CList                                  |
//+------------------------------------------------------------------+   
CArrayObj *GetRange(CArrayObj *&list,const int index,const int count)
  {
   CArrayObj *new_list=new CArrayObj;
   for(int i=0; i<count; i++)
     {
      new_list.Add(list.At(i+index));
     }
   return (new_list);
  }
//+------------------------------------------------------------------+
//| Dictionary: Object - Object                                      |
//+------------------------------------------------------------------+
class CDictionary_Obj_Obj : public CObject
  {
private:
   CObject          *m_key;
   CObject          *m_value;
public:
   //--- Constructor:
   //+------------------------------------------------------------------+
   //| Constructor without parameters                                   |
   //+------------------------------------------------------------------+
                     CDictionary_Obj_Obj(void){}
   //--- Destructor:
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+     
                    ~CDictionary_Obj_Obj()
     {
      if(CheckPointer(m_key)==POINTER_DYNAMIC)
        {
         delete m_key;
        }
      if(CheckPointer(m_value)==POINTER_DYNAMIC)
        {
         delete m_value;
        }
     }
   //--- Methods:
   //+------------------------------------------------------------------+
   //| Set key and value                                                |
   //+------------------------------------------------------------------+    
   void SetAll(CObject *key,CObject *value)
     {
      m_key=key;
      m_value=value;
     }
   //+------------------------------------------------------------------+
   //| Set key                                                          |
   //+------------------------------------------------------------------+       
   void Key(CObject *&key)
     {
      m_key=key;
     }
   //+------------------------------------------------------------------+
   //| Set value                                                        |
   //+------------------------------------------------------------------+         
   void Value(CObject *value)
     {
      m_value=value;
     }
   //+------------------------------------------------------------------+
   //| Get key                                                          |
   //+------------------------------------------------------------------+         
   CObject *Key()
     {
      return (m_key);
     }
   //+------------------------------------------------------------------+
   //| Get value                                                        |
   //+------------------------------------------------------------------+         
   CObject *Value()
     {
      return (m_value);
     }
  };
//+------------------------------------------------------------------+
//| Dictionary Object - Double                                       |
//+------------------------------------------------------------------+
class CDictionary_Obj_Double : public CObject
  {
private:
   CObject          *m_key;
   double            m_value;
public:
   //--- Constructor:
   //+------------------------------------------------------------------+
   //| Constructor without parameters                                   |
   //+------------------------------------------------------------------+
                     CDictionary_Obj_Double(void){}
   //--- Destructor:
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+     
                    ~CDictionary_Obj_Double()
     {
      if(CheckPointer(m_key)==POINTER_DYNAMIC)
        {
         delete m_key;
        }
     }
   //--- Methods:
   //+------------------------------------------------------------------+
   //| Set key and value                                                |
   //+------------------------------------------------------------------+         
   void SetAll(CObject *key,const double value)
     {
      m_key=key;
      m_value=value;
     }
   //+------------------------------------------------------------------+
   //| Set key                                                          |
   //+------------------------------------------------------------------+         
   void Key(CObject *key)
     {
      m_key=key;
     }
   //+------------------------------------------------------------------+
   //| Set value                                                        |
   //+------------------------------------------------------------------+     
   void Value(const double value)
     {
      m_value=value;
     }
   //+------------------------------------------------------------------+
   //| Get key                                                          |
   //+------------------------------------------------------------------+        
   CObject *Key()
     {
      return (m_key);
     }
   //+------------------------------------------------------------------+
   //| Get value                                                        |
   //+------------------------------------------------------------------+        
   double Value()
     {
      return (m_value);
     }
  };
//+------------------------------------------------------------------+
//| Dictionary: String - Object                                      |
//+------------------------------------------------------------------+
class CDictionary_String_Obj : public CObject
  {
private:
   string            m_key;
   CObject          *m_value;
public:
   //--- Constructor:
   //+------------------------------------------------------------------+
   //| Constructor without parameters                                   |
   //+------------------------------------------------------------------+
                     CDictionary_String_Obj(void){}
   //--- Destructor:
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+     
                    ~CDictionary_String_Obj(void)
     {
      if(CheckPointer(m_value)==POINTER_DYNAMIC)
        {
         delete m_value;
        }
     }
   //--- Methods:
   //+------------------------------------------------------------------+
   //| Set key and value                                                |
   //+------------------------------------------------------------------+         
   void SetAll(const string key,CObject *value)
     {
      m_key=key;
      m_value=value;
     }
   //+------------------------------------------------------------------+
   //| Set key                                                          |
   //+------------------------------------------------------------------+        
   void Key(const string key)
     {
      m_key=key;
     }
   //+------------------------------------------------------------------+
   //| Set value                                                        |
   //+------------------------------------------------------------------+        
   void Value(CObject *value)
     {
      m_value=value;
     }
   //+------------------------------------------------------------------+
   //| Get key                                                          |
   //+------------------------------------------------------------------+         
   string Key()
     {
      return (m_key);
     }
   //+------------------------------------------------------------------+
   //| Get value                                                        |
   //+------------------------------------------------------------------+        
   CObject *Value()
     {
      return (m_value);
     }
  };
//+------------------------------------------------------------------+
