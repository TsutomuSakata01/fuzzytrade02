//+------------------------------------------------------------------+
//|                                                     fuzzynet.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//| Implementation of FuzzyNet library in MetaQuotes Language 5(MQL5)|
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
//| If you find any functional differences between FuzzyNet for MQL5 |
//| and the original FuzzyNet project , please contact developers of |
//| MQL5 on the Forum at www.mql5.com.                               |
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
//+------------------------------------------------------------------+
//| Purpose: creating membership functions.                          |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Types of membership functions composition                        |
//+------------------------------------------------------------------+
enum MfCompositionType
  {
   MinMF,                               // Minumum of functions
   MaxMF,                               // Maximum of functions
   ProdMF,                              // Production of functions
   SumMF                                // Sum of functions
  };
//+------------------------------------------------------------------+
//| The base class of all classes of membership functions            |
//+------------------------------------------------------------------+
class IMembershipFunction : public CObject
  {
public:
   //--- Methods:
   //+------------------------------------------------------------------+
   //| Evaluate value of the membership function                        |
   //+------------------------------------------------------------------+ 
   //modified,2018.02.08
   virtual double    GetValue(const double x)=NULL; 
   /*
   virtual double    GetValue(const double x)
     {
      //--- return NULL
      return (NULL);
     }
     */
  };
//+------------------------------------------------------------------+
//| Gaussian combination membership function                         |
//+------------------------------------------------------------------+
class CNormalCombinationMembershipFunction : public IMembershipFunction
  {
private:
   double            m_b1;            // Parametr b1: coordinate of the minimum membership function
   double            m_sigma1;        // Parametr sigma1: concentration factor of the left path of function 
   double            m_b2;            // Parametr b2: coordinate of the maximum membership function
   double            m_sigma2;        // Parametr sigma2: concentration factor of the rigth path of function
public:
   //--- Constructors:
   //+------------------------------------------------------------------+
   //| Constructor without parameters                                   |
   //+------------------------------------------------------------------+
                     CNormalCombinationMembershipFunction(void);
   //+------------------------------------------------------------------+
   //| Constructor with parameters                                      |
   //+------------------------------------------------------------------+
                     CNormalCombinationMembershipFunction(const double b1,const double sigma1,const double b2,const double sigma2)
     {
      m_b1=b1;
      m_sigma1=sigma1;
      m_b2=b2;
      m_sigma2=sigma2;
     }
   //--- Methods:
   //+------------------------------------------------------------------+
   //| Set value b1                                                     |
   //+------------------------------------------------------------------+
   void B1(const double b1)
     {
      m_b1=b1;
     }
   //+------------------------------------------------------------------+
   //| Get value b1                                                     |
   //+------------------------------------------------------------------+
   double B1()
     {
      //--- return parametr b1
      return (m_b1);
     }
   //+------------------------------------------------------------------+
   //| Set value sigma1                                                 |
   //+------------------------------------------------------------------+
   void Sigma1(const double sigma1)
     {
      m_sigma1=sigma1;
     }
   //+------------------------------------------------------------------+
   //| Get value b1                                                     |
   //+------------------------------------------------------------------+
   double Sigma1()
     {
      //--- return parametr sigma1
      return (m_sigma1);
     }
   //+------------------------------------------------------------------+
   //| Set value b2                                                     |
   //+------------------------------------------------------------------+
   void B2(const double b2)
     {
      m_b2=b2;
     }
   //+------------------------------------------------------------------+
   //| Get value b2                                                     |
   //+------------------------------------------------------------------+
   double B2()
     {
      //--- return parametr b2
      return (m_b2);
     }
   //+------------------------------------------------------------------+
   //| Set value sigma2                                                 |
   //+------------------------------------------------------------------+
   void Sigma2(const double sigma2)
     {
      m_sigma2=sigma2;
     }
   //+------------------------------------------------------------------+
   //| Get value b1                                                     |
   //+------------------------------------------------------------------+
   double Sigma2()
     {
      //--- return parametr sigma2
      return (m_sigma2);
     }
   //--- Overloading:
   //+------------------------------------------------------------------+
   //| Get argument (x axis value)                                      |
   //+------------------------------------------------------------------+
   double GetValue(const double x)
     {
      if(m_b1<m_b2)
        {
         if(x<m_b1)
           {
            //--- return result
            return (exp((x - m_b1) * (x - m_b1) / ( -2.0 * m_sigma1 * m_sigma1)));
           }
         else if(x>m_b2)
           {
            //--- return result
            return (exp((x - m_b2) * (x - m_b2) / ( -2.0 * m_sigma2 * m_sigma2)));
           }
         else
           {
            //--- m_b1 <= x && x <= m_b2
            //--- return result 
            return (1);
           }

        }
      if(m_b1>m_b2)
        {
         if(x<m_b2)
           {
            //--- return result
            return (exp((x - m_b1) * (x - m_b1) / ( -2.0 * m_sigma1 * m_sigma1)));
           }
         else if(x>m_b1)
           {
            //--- return result
            return (exp((x - m_b2) * (x - m_b2) / ( -2.0 * m_sigma2 * m_sigma2)));
           }
         else
           {
            //--- m_b1 <= x && x <= m_b2
            //--- return result 
            return ( exp((x - m_b1) * (x - m_b1) / ( -2.0 * m_sigma1 * m_sigma1)) * exp((x - m_b2) * (x - m_b2) / ( -2.0 * m_sigma2 * m_sigma2)) );
           }
        }
      //--- m_b1 == m_b2
      //--- return result  
      return (m_b1);
     }
  };
//+------------------------------------------------------------------+
//| Generalized bell-shaped membership function                      |
//+------------------------------------------------------------------+
class CGeneralizedBellShapedMembershipFunction : public IMembershipFunction
  {
private:
   double            m_a;             // Parametr a: the concentration factor of the membership function
   double            m_b;             // Parametr b: coefficients slope of the membership function
   double            m_c;             // Parametr c:  the maximum coordinate of the membership function
public:
   //--- Constructors:
   //+------------------------------------------------------------------+
   //| Constructor without parameters                                   |
   //+------------------------------------------------------------------+
                     CGeneralizedBellShapedMembershipFunction(void);
   //+------------------------------------------------------------------+
   //| Constructor with parameters                                      |
   //+------------------------------------------------------------------+                     
                     CGeneralizedBellShapedMembershipFunction(const double a,const double b,const double c)
     {
      m_a=a;
      m_b=b;
      m_c=c;
     }
   //--- Methods:
   //+------------------------------------------------------------------+
   //| Set value a                                                      |
   //+------------------------------------------------------------------+
   void A(const double a)
     {
      m_a=a;
     }
   //+------------------------------------------------------------------+
   //| Get value a                                                      |
   //+------------------------------------------------------------------+
   double A()
     {
      //--- return parametr a
      return (m_a);
     }
   //+------------------------------------------------------------------+
   //| Set value b                                                      |
   //+------------------------------------------------------------------+
   void B(const double b)
     {
      m_b=b;
     }
   //+------------------------------------------------------------------+
   //| Get value b                                                      |
   //+------------------------------------------------------------------+
   double B()
     {
      //--- return parametr b
      return (m_b);
     }
   //+------------------------------------------------------------------+
   //| Set value c                                                      |
   //+------------------------------------------------------------------+
   void C(const double c)
     {
      m_c=c;
     }
   //+------------------------------------------------------------------+
   //| Get value c                                                      |
   //+------------------------------------------------------------------+
   double C()
     {
      //--- return parametr c
      return (m_c);
     }
   //--- Overloading:
   //+------------------------------------------------------------------+
   //| Get argument (x axis value)                                      |
   //+------------------------------------------------------------------+
   double GetValue(const double x)
     {
      //--- return result
      return (1 / (1 + pow( fabs((x - m_a) / m_c) , 2 * m_b )));
     }
  };
//+------------------------------------------------------------------+
//| S-shaped membership function                                     |
//+------------------------------------------------------------------+
class CS_ShapedMembershipFunction : public IMembershipFunction
  {
private:
   double            m_a;             // Parametr a: beginning of the interval increases        
   double            m_b;             // Parametr b: end of the interval increases  
public:
   //--- Constructors:
   //+------------------------------------------------------------------+
   //| Constructor without parameters                                   |
   //+------------------------------------------------------------------+
                     CS_ShapedMembershipFunction(void);
                     CS_ShapedMembershipFunction(const double a,const double b)
   //+------------------------------------------------------------------+
   //| Constructor with parameters                                      |
   //+------------------------------------------------------------------+
     {
      m_a=a;
      m_b=b;
     }
   //--- Methods:   //+------------------------------------------------------------------+
   //| Set value a                                                      |
   //+------------------------------------------------------------------+
   void A(const double a)
     {
      m_a=a;
     }
   //+------------------------------------------------------------------+
   //| Get value a                                                      |
   //+------------------------------------------------------------------+
   double A()
     {
      //--- return parametr a
      return (m_a);
     }
   //+------------------------------------------------------------------+
   //| Set value b                                                      |
   //+------------------------------------------------------------------+
   void B(const double b)
     {
      m_b=b;
     }
   //+------------------------------------------------------------------+
   //| Get value b                                                      |
   //+------------------------------------------------------------------+
   double B()
     {
      //--- return parametr b
      return (m_b);
     }
   //--- Overloading:
   //+------------------------------------------------------------------+
   //| Get argument (x axis value)                                      |
   //+------------------------------------------------------------------+ 
   double GetValue(const double x)
     {
      if(x<=m_a)
        {
         //--- return result
         return (0);
        }
      else if((m_a<=x) && (x<=(m_a+m_b)/2))
        {
         //--- return result---(modified 2018.02.08)
         return (2.0*((x-m_a)/(m_b-m_a))*((x-m_a)/(m_b-m_a)));
         //return (2*pow( (x-m_a) / (m_b-m_a) ,2));
         /*
         //--- return result
         return (2*pow( (x-m_a) / (m_b-m_a) ,2));
         */
        }
      else if(((m_a+m_b)/2<=x) && (x<=m_b))
        {
         //--- return result---(modified 2018.02.08)
         return (1.0 - 2.0*((x - m_b)/(m_b - m_a))*((x - m_b)/(m_b - m_a)));
         //return (1-(2*pow( (x-m_a) / (m_b-m_a) ,2)));
         /*
         //--- return result
         return (1-(2*pow( (x-m_a) / (m_b-m_a) ,2)));
         */
        }
      else 
        {//--- x >= m_b
         //--- return result
         return (1);
        }
     }
  };
//+------------------------------------------------------------------+
//| Z-shaped membership function                                     |
//+------------------------------------------------------------------+
class CZ_ShapedMembershipFunction : public IMembershipFunction
  {
private:
   double            m_a;             // Parametr a: beginning of the interval decreasing       
   double            m_b;             // Parametr b: end of the interval decreasing 
public:
   //--- Constructors:
   //+------------------------------------------------------------------+
   //| Constructor without parameters                                   |
   //+------------------------------------------------------------------+
                     CZ_ShapedMembershipFunction(void);
   //+------------------------------------------------------------------+
   //| Constructor with parameters                                      |
   //+------------------------------------------------------------------+
                     CZ_ShapedMembershipFunction(const double a,const double b)
     {
      m_a=a;
      m_b=b;
     }
   //--- Methods:
   //+------------------------------------------------------------------+
   //| Set value a                                                      |
   //+------------------------------------------------------------------+
   void A(const double a)
     {
      m_a=a;
     }
   //+------------------------------------------------------------------+
   //| Get value a                                                      |
   //+------------------------------------------------------------------+
   double A()
     {
      //--- return parametr a
      return (m_a);
     }
   //+------------------------------------------------------------------+
   //| Set value b                                                      |
   //+------------------------------------------------------------------+
   void B(const double b)
     {
      m_b=b;
     }
   //+------------------------------------------------------------------+
   //| Get value b                                                      |
   //+------------------------------------------------------------------+
   double B()
     {
      //--- return parametr b
      return (m_b);
     }
   //--- Overloading:
   //+------------------------------------------------------------------+
   //| Get argument (x axis value)                                      |
   //+------------------------------------------------------------------+
   double GetValue(const double x)
     {
      if(x<=m_a)
        {
         //--- return result
         return (1);
        }
      else if((m_a<=x) && (x<=(m_a+m_b)/2))
        {
         //--- return result
         return (1-(2*pow( (x-m_a) / (m_b-m_a) ,2)));
        }
      else if(((m_a+m_b)/2<=x) && (x<=m_b))
        {
         //--- return result
         return (2*pow( (x-m_a) / (m_b-m_a) ,2));
        }
      else
        {//--- x >= m_b
         //--- return result
         return (0);
        }
     }
  };
//+------------------------------------------------------------------+
//| Π-shaped membership function                                     |
//+------------------------------------------------------------------+
class CP_ShapedMembershipFunction : public IMembershipFunction
  {
private:
   double            m_a;             // Parametr a: carrier fuzzy set
   double            m_d;             // Parametr d: carrier fuzzy set
   double            m_b;             // Parametr b: the core of a fuzzy set
   double            m_c;             // Parametr c: the core of a fuzzy set
public:
   //--- Constructors:
   //+------------------------------------------------------------------+
   //| Constructor without parameters                                   |
   //+------------------------------------------------------------------+
                     CP_ShapedMembershipFunction(void);
   //+------------------------------------------------------------------+
   //| Constructor with parameters                                      |
   //+------------------------------------------------------------------+
                     CP_ShapedMembershipFunction(const double a,const double d,const double b,const double c)
     {
      m_a=a;
      m_d=d;
      m_b=b;
      m_c=c;
     }
   //--- Methods:
   //+------------------------------------------------------------------+
   //| Set value a                                                      |
   //+------------------------------------------------------------------+
   void A(const double a)
     {
      m_a=a;
     }
   //+------------------------------------------------------------------+
   //| Get value a                                                      |
   //+------------------------------------------------------------------+
   double A()
     {
      //--- return parametr a
      return (m_a);
     }
   //+------------------------------------------------------------------+
   //| Set value d                                                      |
   //+------------------------------------------------------------------+
   void D(const double d)
     {
      m_d=d;
     }
   //+------------------------------------------------------------------+
   //| Get value d                                                      |
   //+------------------------------------------------------------------+
   double D()
     {
      //--- return parametr d
      return (m_d);
     }
   //+------------------------------------------------------------------+
   //| Set value b                                                      |
   //+------------------------------------------------------------------+
   void B(const double b)
     {
      m_b=b;
     }
   //+------------------------------------------------------------------+
   //| Get value b                                                      |
   //+------------------------------------------------------------------+
   double B()
     {
      //--- return parametr b
      return (m_b);
     }
   //+------------------------------------------------------------------+
   //| Set value c                                                      |
   //+------------------------------------------------------------------+
   void C(const double c)
     {
      m_c=c;
     }
   //+------------------------------------------------------------------+
   //| Get value c                                                      |
   //+------------------------------------------------------------------+
   double C()
     {
      //--- return parametr c
      return (m_c);
     }
   //--- Overloading:
   //+------------------------------------------------------------------+
   //| Get argument (x axis value)                                      |
   //+------------------------------------------------------------------+     
   double GetValue(const double x)
     {
      CZ_ShapedMembershipFunction z_function(m_a,m_b);
      CS_ShapedMembershipFunction s_function(m_c,m_d);
      double result=z_function.GetValue(x) * s_function.GetValue(x);
      //--- return result
      return (result);
     }
  };
//+------------------------------------------------------------------+
//| Sigmoidal membership function                                    |
//+------------------------------------------------------------------+
class CSigmoidalMembershipFunction : public IMembershipFunction
  {
private:
   double            m_a;            // Parametr a1: the slope coefficient of membership functions
   double            m_c;            // Parametr c1: coordinate of the inflection of membership function
public:
   //--- Constructors:
   //+------------------------------------------------------------------+
   //| Constructor without parameters                                   |
   //+------------------------------------------------------------------+
                     CSigmoidalMembershipFunction(void);
   //+------------------------------------------------------------------+
   //| Constructor with parameters                                      |
   //+------------------------------------------------------------------+
                     CSigmoidalMembershipFunction(const double a,const double c)
     {
      m_a = a;
      m_c = c;
     }
   //--- Methods:
   //+------------------------------------------------------------------+
   //| Set value a                                                     |
   //+------------------------------------------------------------------+
   void A1(const double a)
     {
      m_a=a;
     }
   //+------------------------------------------------------------------+
   //| Get value a                                                     |
   //+------------------------------------------------------------------+
   double A()
     {
      //--- return parametr a
      return (m_a);
     }
   //+------------------------------------------------------------------+
   //| Set value c                                                     |
   //+------------------------------------------------------------------+
   void C(const double c)
     {
      m_c=c;
     }
   //+------------------------------------------------------------------+
   //| Get value c                                                     |
   //+------------------------------------------------------------------+
   double C()
     {
      //--- return parametr c
      return (m_c);
     }
   //--- Overloading:
   //+------------------------------------------------------------------+
   //| Get argument (x axis value)                                      |
   //+------------------------------------------------------------------+
   double GetValue(const double x)
     {
      //--- return result
      return (1/(1+exp(-m_a*(x-m_c))));
     }
  };
//+------------------------------------------------------------------+
//| Product of two sigmoidal membership functions                    |
//+------------------------------------------------------------------+
class CProductTwoSigmoidalMembershipFunctions : public IMembershipFunction
  {
private:
   double            m_a1;            // Parametr a1: the slope coefficient of the first functions
   double            m_c1;            // Parametr c1: coordinate of the inflection of the first function
   double            m_a2;            // Parametr a1: the slope coefficient of the second functions
   double            m_c2;            // Parametr c2: coordinate of the inflection of the second function
public:
   //--- Constructors:
   //+------------------------------------------------------------------+
   //| Constructor without parameters                                   |
   //+------------------------------------------------------------------+
                     CProductTwoSigmoidalMembershipFunctions(void);
   //+------------------------------------------------------------------+
   //| Constructor with parameters                                      |
   //+------------------------------------------------------------------+
                     CProductTwoSigmoidalMembershipFunctions(const double a1,const double c1,const double a2,const double c2)
     {
      m_a1 = a1;
      m_a2 = a2;
      m_c1 = c1;
      m_c2 = c2;
     }
   //--- Methods:
   //+------------------------------------------------------------------+
   //| Set value a1                                                     |
   //+------------------------------------------------------------------+
   void A1(const double a1)
     {
      m_a1=a1;
     }
   //+------------------------------------------------------------------+
   //| Get value a1                                                     |
   //+------------------------------------------------------------------+
   double A1()
     {
      //--- return parametr a1
      return (m_a1);
     }
   //+------------------------------------------------------------------+
   //| Set value c1                                                     |
   //+------------------------------------------------------------------+
   void C1(const double c1)
     {
      m_c1=c1;
     }
   //+------------------------------------------------------------------+
   //| Get value c1                                                     |
   //+------------------------------------------------------------------+
   double C1()
     {
      //--- return parametr c1
      return (m_c1);
     }
   //+------------------------------------------------------------------+
   //| Set value a2                                                     |
   //+------------------------------------------------------------------+
   void A2(const double a2)
     {
      m_a2=a2;
     }
   //+------------------------------------------------------------------+
   //| Get value a2                                                     |
   //+------------------------------------------------------------------+
   double A2()
     {
      //--- return parametr a2
      return (m_a2);
     }
   //+------------------------------------------------------------------+
   //| Set value c2                                                     |
   //+------------------------------------------------------------------+
   void C2(const double c2)
     {
      m_c2=c2;
     }
   //+------------------------------------------------------------------+
   //| Get value c2                                                     |
   //+------------------------------------------------------------------+
   double C2()
     {
      //--- return parametr c2
      return (m_c2);
     }
   //--- Overloading:
   //+------------------------------------------------------------------+
   //| Get argument (x axis value)                                      |
   //+------------------------------------------------------------------+
   double GetValue(const double x)
     {
      double first_equation=1/(1+exp(-m_a1*(x-m_c1)));
      double second_equation=1/(1+exp(-m_a2*(x-m_c2)));
      //--- return result
      return (first_equation * second_equation);
     }
  };
//+------------------------------------------------------------------+
//| Difference between two sigmoidal functions membership function   |
//+------------------------------------------------------------------+
class CDifferencTwoSigmoidalMembershipFunction : public IMembershipFunction
  {
private:
   double            m_a1;            // Parametr a1: the slope coefficient of the first functions
   double            m_c1;            // Parametr c1: coordinate of the inflection of the first function
   double            m_a2;            // Parametr a1: the slope coefficient of the second functions
   double            m_c2;            // Parametr c2: coordinate of the inflection of the second function
public:
   //--- Constructors:
   //+------------------------------------------------------------------+
   //| Constructor without parameters                                   |
   //+------------------------------------------------------------------+
                     CDifferencTwoSigmoidalMembershipFunction(void);
   //+------------------------------------------------------------------+
   //| Constructor with parameters                                      |
   //+------------------------------------------------------------------+
                     CDifferencTwoSigmoidalMembershipFunction(const double a1,const double c1,const double a2,const double c2)
     {
      m_a1 = a1;
      m_a2 = a2;
      m_c1 = c1;
      m_c2 = c2;
     }
   //--- Methods:
   //+------------------------------------------------------------------+
   //| Set value a1                                                     |
   //+------------------------------------------------------------------+
   void A1(const double a1)
     {
      m_a1=a1;
     }
   //+------------------------------------------------------------------+
   //| Get value a1                                                     |
   //+------------------------------------------------------------------+
   double A1()
     {
      //--- return parametr a1
      return (m_a1);
     }
   //+------------------------------------------------------------------+
   //| Set value c1                                                     |
   //+------------------------------------------------------------------+
   void C1(const double c1)
     {
      m_c1=c1;
     }
   //+------------------------------------------------------------------+
   //| Get value c1                                                     |
   //+------------------------------------------------------------------+
   double C1()
     {
      //--- return parametr c1
      return (m_c1);
     }
   //+------------------------------------------------------------------+
   //| Set value a2                                                     |
   //+------------------------------------------------------------------+
   void A2(const double a2)
     {
      m_a2=a2;
     }
   //+------------------------------------------------------------------+
   //| Get value a2                                                     |
   //+------------------------------------------------------------------+
   double A2()
     {
      //--- return parametr a2
      return (m_a2);
     }
   //+------------------------------------------------------------------+
   //| Set value c2                                                     |
   //+------------------------------------------------------------------+
   void C2(const double c2)
     {
      m_c2=c2;
     }
   //+------------------------------------------------------------------+
   //| Get value c2                                                     |
   //+------------------------------------------------------------------+
   double C2()
     {
      //--- return parametr c2
      return (m_c2);
     }
   //--- Overloading:
   //+------------------------------------------------------------------+
   //| Get argument (x axis value)                                      |
   //+------------------------------------------------------------------+
   double GetValue(const double x)
     {
      double first_equation=1/(1+exp(-m_a1*(x-m_c1)));
      double second_equation=1/(1+exp(-m_a2*(x-m_c2)));
      //--- return result
      return (first_equation - second_equation);
     }
  };
//+------------------------------------------------------------------+
//| Trapezoidal-shaped membership function                           |
//+------------------------------------------------------------------+ 
class CTrapezoidMembershipFunction : public IMembershipFunction
  {
private:
   double            m_x1;            // Parametr x1: the first point on the abscissa
   double            m_x2;            // Parametr x2: the second point on the abscissa
   double            m_x3;            // Parametr x3: the third point on the abscissa
   double            m_x4;            // Parametr x4: the fourth point on the abscissa
public:
   //--- Constructors:
   //+------------------------------------------------------------------+
   //| Constructor without parameters                                   |
   //+------------------------------------------------------------------+
                     CTrapezoidMembershipFunction(void);
   //+------------------------------------------------------------------+
   //| Constructor with parameters                                      |
   //+------------------------------------------------------------------+
                     CTrapezoidMembershipFunction(const double x1,const double x2,const double x3,const double x4)
     {
      if(!(x1<=x2 && x2<=x3 && x3<=x4))
        {
         Print("Incorrect parameters! It is necessary to re-initialize them.");
        }
      else
        {
         m_x1 = x1;
         m_x2 = x2;
         m_x3 = x3;
         m_x4 = x4;
        }
     }
   //--- Methods:
   //+------------------------------------------------------------------+
   //| Set value X1                                                     |
   //+------------------------------------------------------------------+ 
   void X1(const double x)
     {
      m_x1=x;
     }
   //+------------------------------------------------------------------+
   //| Get value X1                                                     |
   //+------------------------------------------------------------------+      
   double X1()
     {
      //--- return point X1
      return (m_x1);
     }
   //+------------------------------------------------------------------+
   //| Set value X2                                                     |
   //+------------------------------------------------------------------+ 
   void X2(const double x)
     {
      m_x2=x;
     }
   //+------------------------------------------------------------------+
   //| Get value X2                                                     |
   //+------------------------------------------------------------------+ 
   double X2()
     {
      //--- return point X2
      return (m_x2);
     }
   //+------------------------------------------------------------------+
   //| Set value X3                                                     |
   //+------------------------------------------------------------------+ 
   void X3(const double x)
     {
      m_x3=x;
     }
   //+------------------------------------------------------------------+
   //| Get value X3                                                     |
   //+------------------------------------------------------------------+
   double X3()
     {
      //--- return point X3
      return (m_x3);
     }
   //+------------------------------------------------------------------+
   //| Set value X4                                                     |
   //+------------------------------------------------------------------+ 
   void X4(const double x)
     {
      m_x4=x;
     }
   //+------------------------------------------------------------------+
   //| Get value X4                                                     |
   //+------------------------------------------------------------------+
   double X4()
     {
      //--- return point X4
      return (m_x4);
     }
   //--- Overloading:
   //+------------------------------------------------------------------+
   //| Get argument (x axis value)                                      |
   //+------------------------------------------------------------------+ 
   double GetValue(const double x)
     {
      double result=0;
      if(x==m_x1 && x==m_x2)
        {
         result=1.0;
        }
      else if(x==m_x3 && x==m_x4)
        {
         result=1.0;
        }
      else if(x<=m_x1 || x>=m_x4)
        {
         result=0;
        }
      else if((x>=m_x2) && (x<=m_x3))
        {
         result=1;
        }
      else if((x>m_x1) && (x<m_x2))
        {
         result=(x/(m_x2-m_x1)) -(m_x1/(m_x2-m_x1));
        }
      else
        {
         result=(-x/(m_x4-m_x3))+(m_x4/(m_x4-m_x3));
        }
      //--- return result
      return (result);
     }
  };
//+------------------------------------------------------------------+
//| Gaussian curve membership function                               |
//+------------------------------------------------------------------+  
class CNormalMembershipFunction : public IMembershipFunction
  {
private:
   double            m_b;             // Parametr b: coordinate of the maximum membership function
   double            m_sigma;         // Parametr sigma: concentration factor of the membership function
public:
   //--- Constructors:
   //+------------------------------------------------------------------+
   //| Constructor with parameters                                      |
   //+------------------------------------------------------------------+ 
                     CNormalMembershipFunction(const double b,const double sigma)
     {
      m_b=b;
      m_sigma=sigma;
     }
   //--- Methods:
   //+------------------------------------------------------------------+
   //| Set value b (center of MF)                                       |
   //+------------------------------------------------------------------+ 
   void B(const double b)
     {
      m_b=b;
     }
   //+------------------------------------------------------------------+
   //| Get value b (center of MF)                                       |
   //+------------------------------------------------------------------+ 
   double B()
     {
      //--- return maximum membership function
      return (m_b);
     }
   //+------------------------------------------------------------------+
   //| Set value sigma                                                  |
   //+------------------------------------------------------------------+
   void Sigma(const double sigma)
     {
      m_sigma=sigma;
     }
   //+------------------------------------------------------------------+
   //| Get value sigma                                                  |
   //+------------------------------------------------------------------+   
   double Sigma()
     {
      //--- return sigma
      return (m_sigma);
     }
   //--- Overloading:
   //+------------------------------------------------------------------+
   //| Get argument (x axis value)                                      |
   //+------------------------------------------------------------------+ 
   double GetValue(const double x)
     {
      //--- return result
      return (exp(-(x - m_b) * (x - m_b) / (2.0 * m_sigma * m_sigma)));
     }
  };
//+------------------------------------------------------------------+
//| Triangular-shaped membership function                            |
//+------------------------------------------------------------------+
class CTriangularMembershipFunction : public IMembershipFunction
  {
private:
   double            m_x1;            // Parametr x1: the first point on the abscissa
   double            m_x2;            // Parametr x2: the second point on the abscissa
   double            m_x3;            // Parametr x3: the third point on the abscissa
public:
   //--- Constructors:
   //+------------------------------------------------------------------+
   //| Constructor without parameters                                   |
   //+------------------------------------------------------------------+
                     CTriangularMembershipFunction(void);
   //+------------------------------------------------------------------+
   //| Constructor with parameters                                      |
   //+------------------------------------------------------------------+
                     CTriangularMembershipFunction(const double x1,const double x2,const double x3)
     {
      if(!(x1<=x2 && x2<=x3))
        {
         Print("Incorrect parameters! It is necessary to re-initialize them.");
        }
      m_x1=x1;
      m_x2=x2;
      m_x3=x3;
     }
   //--- Methods:
   //+------------------------------------------------------------------+
   //| Set value X1                                                     |
   //+------------------------------------------------------------------+ 
   void X1(const double x)
     {
      m_x1=x;
     }
   //+------------------------------------------------------------------+
   //| Get value X1                                                     |
   //+------------------------------------------------------------------+      
   double X1()
     {
      //--- return point X1
      return (m_x1);
     }
   //+------------------------------------------------------------------+
   //| Set value X2                                                     |
   //+------------------------------------------------------------------+ 
   void X2(const double x)
     {
      m_x2=x;
     }
   //+------------------------------------------------------------------+
   //| Get value X2                                                     |
   //+------------------------------------------------------------------+ 
   double X2()
     {
      //--- return point X2
      return (m_x2);
     }
   //+------------------------------------------------------------------+
   //| Set value X3                                                     |
   //+------------------------------------------------------------------+ 
   void X3(const double x)
     {
      m_x3=x;
     }
   //+------------------------------------------------------------------+
   //| Get value X3                                                     |
   //+------------------------------------------------------------------+
   double X3()
     {
      //--- return point X3
      return (m_x3);
     }
   //+------------------------------------------------------------------+
   //| Approximately converts triangular membership function to normal  |
   //+------------------------------------------------------------------+ 
   CNormalMembershipFunction *ToNormalMF()
     {
      double b=m_x2;
      double sigma25=(m_x3-m_x1)/2.0;
      double sigma=sigma25/2.5;
      //--- return normal membership function
      return new CNormalMembershipFunction(b, sigma);
     }
   //--- Overloading:
   //+------------------------------------------------------------------+
   //| Get argument (x axis value)                                      |
   //+------------------------------------------------------------------+ 
   double GetValue(const double x)
     {
      double result=0;
      if(x==m_x1 && x==m_x2)
        {
         result=1.0;
        }
      else if(x==m_x2 && x==m_x3)
        {
         result=1.0;
        }
      else if(x<=m_x1 || x>=m_x3)
        {
         result=0;
        }
      else if(x==m_x2)
        {
         result=1;
        }
      else if((x>m_x1) && (x<m_x2))
        {
         result=(x/(m_x2-m_x1)) -(m_x1/(m_x2-m_x1));
        }
      else
        {
         result=(-x/(m_x3-m_x2))+(m_x3/(m_x3-m_x2));
        }
      //--- return result
      return (result);
     }
  };
//+------------------------------------------------------------------+
//| Constant membership function                                     |
//+------------------------------------------------------------------+  
class CConstantMembershipFunction : public IMembershipFunction
  {
private:
   double            m_constValue;     // Value of the function at all points
public:
   //--- Constructor:
   //+------------------------------------------------------------------+
   //| Constructor with parameters                                      |
   //+------------------------------------------------------------------+
                     CConstantMembershipFunction(const double constValue)
     {
      if(constValue<0.0 || constValue>1.0)
        {
         Print("Incorrect parameter! It is necessary to re-initialize them.");
        }
      m_constValue=constValue;
     }
   //--- Overloading:
   //+------------------------------------------------------------------+
   //| Get argument (x axis value)                                      |
   //+------------------------------------------------------------------+
   double GetValue(const double x)
     {
      //--- return result
      return (m_constValue);
     }
  };
//+--------------------------------------------------------------------------------------+
//| Composition of several membership functions represened as single membership function |
//+--------------------------------------------------------------------------------------+ 
class CCompositeMembershipFunction : public IMembershipFunction
  {
private:
   CList            *m_mfs;           // List of membership functions
   MfCompositionType m_composType;    // Composite Type
public:
   //--- Constructors:
   //+------------------------------------------------------------------+
   //| First constructor with parameters                                |
   //+------------------------------------------------------------------+
                     CCompositeMembershipFunction(MfCompositionType composType)
     {
      m_mfs=new CList;
      m_composType=composType;
     }
   //+------------------------------------------------------------------+
   //| Second constructor with parameters                               |
   //+------------------------------------------------------------------+
                     CCompositeMembershipFunction(MfCompositionType composType,IMembershipFunction *mf1,IMembershipFunction *mf2)
     {
      m_mfs=new CList;
      m_mfs.Add(mf1);
      m_mfs.Add(mf2);
      m_composType=composType;
     }
   //+------------------------------------------------------------------+
   //| Third constructor with parameters                                |
   //+------------------------------------------------------------------+
                     CCompositeMembershipFunction(MfCompositionType composType,CList *mfs)
     {
      m_mfs=mfs;
      m_composType=composType;
     }
   //--- Destructor:
   //+------------------------------------------------------------------+
   //| Destructor                                                       |
   //+------------------------------------------------------------------+     
                    ~CCompositeMembershipFunction()
     {
      for(int i=0; i<m_mfs.Total(); i++)
        {
         if(CheckPointer(m_mfs.GetNodeAtIndex(i))==POINTER_DYNAMIC)
           {
            delete m_mfs.GetNodeAtIndex(i);
           }
        }
      m_mfs.FreeMode(false);
      delete m_mfs;
     }
   //--- Methods:
   //+------------------------------------------------------------------+
   //| Get list of membership functions                                 |
   //+------------------------------------------------------------------+
   CList *MembershipFunctions()
     {
      //--- return list of membership functions
      return  (m_mfs);
     }
   //+------------------------------------------------------------------+
   //| Get membership functions composition type                        |
   //+------------------------------------------------------------------+
   MfCompositionType CompositionType()
     {
      //--- return composition type
      return (m_composType);
     }
   //+------------------------------------------------------------------+
   //| Set membership functions composition type                        |
   //+------------------------------------------------------------------+ 
   void CompositionType(MfCompositionType value)
     {
      m_composType=value;
     }
   //+------------------------------------------------------------------+
   //| The composition of the membership functions                      |
   //+------------------------------------------------------------------+
   double Compose(const double val1,const double val2)
     {
      switch(m_composType)
        {
         case MaxMF:
            //--- return result of composition
            return fmax(val1, val2);
         case MinMF:
            //--- return result of composition
            return fmin(val1, val2);
         case ProdMF:
            //--- return result of composition
            return (val1 * val2);
         case SumMF:
            //--- return result of composition
            return (val1 + val2);
         default:
           {
            Print("Incorrect type of composition");
            //--- return NULL
            return (NULL);
           }
        }
     }
   //+------------------------------------------------------------------+
   //| Get argument (x axis value)                                      |
   //+------------------------------------------------------------------+
   double GetValue(double const x)
     {
      if(m_mfs.Total()==0)
        {
         //--- return result
         return 0.0;
        }
      else if(m_mfs.Total()==1)
        {
         IMembershipFunction *fun=m_mfs.GetNodeAtIndex(0);
         //--- return result
         return fun.GetValue(x);
        }
      else
        {
         IMembershipFunction *fun=m_mfs.GetNodeAtIndex(0);
         double result=fun.GetValue(x);
         for(int i=1; i<m_mfs.Total(); i++)
           {
            fun=m_mfs.GetNodeAtIndex(i);
            result=Compose(result,fun.GetValue(x));
           }
         //--- return result
         return (result);
        }
     }
  };
//+------------------------------------------------------------------+
