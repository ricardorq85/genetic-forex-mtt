//+------------------------------------------------------------------+
//|                                               GeneticTrading.mqh |
//|                                                      ricardorq85 |
//|                                            ricardorq85@gmail.com |
//+------------------------------------------------------------------+
#property copyright "ricardorq85"
#property link      "ricardorq85@gmail.com"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>

class GeneticTrading {
   private:
      CTrade     *trading;
      string   symbol;
      
   public:
      GeneticTrading();
      ~GeneticTrading();
      void getLowestAndHighestPrice(datetime fechaInicio, datetime fechaFin, double &lowest, double &highest);
};


GeneticTrading::GeneticTrading() {
   symbol = _Symbol;
}

GeneticTrading::~GeneticTrading() {}

void GeneticTrading::getLowestAndHighestPrice(datetime fechaInicio, datetime fechaFin, double &lowest, double &highest) {
   MqlRates  rates_array[];
   ArraySetAsSeries(rates_array,true);
   int cantidad = CopyRates(symbol, PERIOD_M1, fechaInicio, fechaFin, rates_array);   
   for(int i=cantidad-1; i>=0; i--) {
      MathMax(highest, rates_array[i].high);
      MathMax(lowest, rates_array[i].low);
   }
}
