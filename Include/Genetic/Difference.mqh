//+------------------------------------------------------------------+
//|                                                   Difference.mqh |
//|                                               ricardorq85        |
//+------------------------------------------------------------------+
#property copyright "ricardorq85"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Difference
  {
private:

public:
   double            maDiff;
   double            macdDiff;
   double            maCompareDiff;
   double            sarDiff;
   double            adxDiff;
   double            rsiDiff;
   double            bollingerDiff;
   double            momentumDiff;
   double            ichiTrendDiff;
   double            ichiSignalDiff;
   double            ma1200Diff;
   double            macd20xDiff;
   double            maCompare1200Diff;
   double            sar1200Diff;
   double            adx168Diff;
   double            rsi84Diff;
   double            bollinger240Diff;
   double            momentum1200Diff;
   double            ichiTrend6Diff;
   double            ichiSignal6Diff;

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
