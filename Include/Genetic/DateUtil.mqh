//+------------------------------------------------------------------+
//|                                                     DateUtil.mqh |
//|                                                      ricardorq85 |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "ricardorq85"
#property link      ""
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CDateUtil
  {
private:

public:
                     CDateUtil();
                    ~CDateUtil();
                    long obtenerDiferenciaEnHoras(datetime d1,datetime d2);
                    long obtenerDiferenciaEnMinutos(datetime d1,datetime d2);
                    bool esViernes(datetime d1);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDateUtil::CDateUtil()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDateUtil::~CDateUtil()
  {
  }
//+------------------------------------------------------------------+
long CDateUtil::obtenerDiferenciaEnHoras(datetime d1,datetime d2) 
  {
   MqlDateTime str1,str2;
   TimeToStruct(d1,str1);
   TimeToStruct(d2,str2);

// Se debe arreglar para fechas de diferentes años
   //long dif=(str2.hour-str1.hour)+(str2.day-str1.day)*24+(str2.mon-str1.mon)*30*24+(str2.year-str1.year)*360*24;
   
   //Fixed
   long longD1 = ((str1.year-1970)*12*30*24*60) + (str1.day_of_year*24*60) + (str1.hour) + (str1.min/60);
   long longD2 = ((str2.year-1970)*12*30*24*60) + (str2.day_of_year*24*60) + (str2.hour) + (str2.min/60);

   return (longD2 - longD1);
  }

long CDateUtil::obtenerDiferenciaEnMinutos(datetime d1,datetime d2) 
  {
   MqlDateTime str1,str2;
   TimeToStruct(d1,str1);
   TimeToStruct(d2,str2);
   
   long longD1 = ((str1.year-1970)*12*30*24*60) + (str1.day_of_year*24*60) + (str1.hour*60) + (str1.min);
   long longD2 = ((str2.year-1970)*12*30*24*60) + (str2.day_of_year*24*60) + (str2.hour*60) + (str2.min);

   return (longD2 - longD1);
  }
  
 bool CDateUtil::esViernes(datetime d1) {
   MqlDateTime str1;
   TimeToStruct(d1,str1);
   
   return (str1.day_of_week==FRIDAY);
 }
