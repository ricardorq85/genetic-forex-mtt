//+------------------------------------------------------------------+
//|                                               StopsEsperados.mqh |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property copyright "RROJASQ"
#property version   "1.00"

#include <Genetic\Estrategy.mqh>

class StopsEsperados {
   public:
      StopsEsperados();
      ~StopsEsperados();
      double sumaTP;
      double promedioTP;
      double sumaSL;
      double promedioSL;
      int countEsperados;
      bool modify;
      long symbolStopLevel;
      
      void StopsEsperados::calcularEsperados(Estrategy *estrategiaOpenPosition, Estrategy *currentEstrategia, ENUM_ORDER_TYPE tipoOperacion);
      void StopsEsperados::restore();
      bool StopsEsperados::estaListoParaModificar();
      bool StopsEsperados::tieneStopsPositivos();
      bool StopsEsperados::tieneStopsValidos(Estrategy *estrategiaOpenPosition);
      bool StopsEsperados::tieneTakeProfitValido(Estrategy *estrategiaOpenPosition);
      bool StopsEsperados::tieneStopLossValido(Estrategy *estrategiaOpenPosition);

   private:
      bool StopsEsperados::superaStopLevel(double value);
};

StopsEsperados::StopsEsperados() {
      sumaTP=0;
      promedioTP=0;
      sumaSL=0;
      promedioSL=0;
      countEsperados=0;
      modify=false;
      symbolStopLevel = SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
}

StopsEsperados::~StopsEsperados()
{

}

bool StopsEsperados::superaStopLevel(double value) {
   return (MathAbs(value)>symbolStopLevel);
}

bool StopsEsperados::tieneStopsPositivos() {
   return (promedioTP>0 && promedioSL>0);
}
bool StopsEsperados::tieneStopsValidos(Estrategy *estrategiaOpenPosition) {
   return superaStopLevel(promedioSL-estrategiaOpenPosition.LastStopLoss)||superaStopLevel(promedioTP-estrategiaOpenPosition.LastTakeProfit);
}


bool StopsEsperados::tieneStopLossValido(Estrategy *estrategiaOpenPosition) {
   bool s = superaStopLevel(promedioSL-estrategiaOpenPosition.LastStopLoss);
   return s;
}

bool StopsEsperados::tieneTakeProfitValido(Estrategy *estrategiaOpenPosition) {
   bool s = superaStopLevel(promedioTP-estrategiaOpenPosition.LastTakeProfit);
   return s;
}

bool StopsEsperados::estaListoParaModificar() {
   return (modify && countEsperados>1);
}

void StopsEsperados::restore() {
   sumaTP = 0;
   promedioTP = 0;      
   sumaSL = 0;
   promedioSL = 0;
   countEsperados = 0;  
}


void StopsEsperados::calcularEsperados(Estrategy *estrategiaOpenPosition, Estrategy *currentEstrategia, ENUM_ORDER_TYPE tipoOperacion) {
   double precioEsperadoTP;
   double pipsEsperadosTP;
   double precioEsperadoSL;
   double pipsEsperadosSL;   
   if (tipoOperacion==ORDER_TYPE_BUY) {
      precioEsperadoTP = estrategiaOpenPosition.openPrice + currentEstrategia.TakeProfit/_Point;
      pipsEsperadosTP = (precioEsperadoTP - estrategiaOpenPosition.openPrice)*_Point;

      precioEsperadoSL = estrategiaOpenPosition.openPrice - currentEstrategia.StopLoss/_Point;
      pipsEsperadosSL = (estrategiaOpenPosition.openPrice - precioEsperadoSL)*_Point; 
   } else {
      precioEsperadoTP = estrategiaOpenPosition.openPrice - currentEstrategia.TakeProfit/_Point;
      pipsEsperadosTP = (estrategiaOpenPosition.openPrice - precioEsperadoTP)*_Point;

      precioEsperadoSL = estrategiaOpenPosition.openPrice + currentEstrategia.StopLoss/_Point;
      pipsEsperadosSL = (precioEsperadoSL - estrategiaOpenPosition.openPrice)*_Point;
   }
   modify = true;
   countEsperados++;
   
   sumaTP += pipsEsperadosTP;
   promedioTP = (sumaTP/countEsperados);
   
   sumaSL += pipsEsperadosSL;
   promedioSL = (sumaSL/countEsperados);   
}
