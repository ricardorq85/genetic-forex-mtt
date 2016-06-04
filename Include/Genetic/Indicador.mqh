//+------------------------------------------------------------------+
//|                                                    Indicador.mqh |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Indicador
  {
private:

public:
   double            openLower;
   double            openHigher;
   bool              hasOpen;
   
   double            closeLower;
   double            closeHigher;
   bool              hasClose;

                     Indicador();
                    ~Indicador();
   bool              open(double value);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Indicador::Indicador()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Indicador::~Indicador()
  {
  }
//+------------------------------------------------------------------+

bool Indicador::open(double value) {
   bool val = false;

   val = ((!hasOpen)
                  || ((value>=openLower)
                  && (value<=openHigher)));
   return val;
}