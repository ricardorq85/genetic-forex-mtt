//+------------------------------------------------------------------+
//|                                                  IParaOperar.mqh |
//|                                                      ricardorq85 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "ricardorq85"
#property link      "https://www.mql5.com"


class IParaOperar {

public:

   double            lote;
   double            precioCalculado;
   string            pair;
   bool              active;
   int               index;
   string            id;
};