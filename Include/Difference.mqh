//+------------------------------------------------------------------+
//|                                                   Difference.mqh |
//|                                                          RROJASQ |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "RROJASQ"
#property link      "http://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Difference
  {
private:

public:
   double maDiff;
   double macdDiff;
   double maCompareDiff;
   double sarDiff;
   double adxDiff;
   double rsiDiff;
   double bollingerDiff;
   double momentumDiff;
   double ichiTrendDiff;
   double ichiSignalDiff;

   Difference();
  ~Difference();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Difference::Difference()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Difference::~Difference()
  {
  }
//+------------------------------------------------------------------+
