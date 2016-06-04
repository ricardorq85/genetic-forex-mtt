//+------------------------------------------------------------------+
//|                                             GestionMonetaria.mqh |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"

#include <Genetic\Estrategy.mqh>
#include <Genetic\Vigencia.mqh>
#include <Genetic\Difference.mqh>
#include <Trade\Trade.mqh>
#include <Genetic\GestionMonetaria.mqh>

class ClosingManager
  {
private:
	void closeBuyByIndicator(CTrade *trading, Estrategy *currentEstrategia, Difference *difference, datetime activeTime); 
	void closeSellByIndicator(CTrade *trading, Estrategy *currentEstrategia, Difference *difference, datetime activeTime);
	
	GestionMonetaria *gm;
	
public:

   ClosingManager();
  ~ClosingManager();
  
  void closeByIndicator(CTrade *trading, Estrategy *currentEstrategia, Difference *difference, 
         datetime activeTime, ENUM_ORDER_TYPE orderType);  
   void closeByCantidadVigencia(CTrade *trading, Estrategy *estrategiaOpenPosition, int cantidad, datetime activeTime);        
   void close(CTrade *trading, Estrategy *estrategiaOpenPosition);
  };
  
ClosingManager::ClosingManager()
  {
   gm = new GestionMonetaria();
  }

ClosingManager::~ClosingManager()
  {
   gm = new GestionMonetaria();
  } 
  
void ClosingManager::close(CTrade *trading, Estrategy *estrategiaOpenPosition) {
   trading.PositionClose(_Symbol);
   estrategiaOpenPosition.openDate=NULL;
   estrategiaOpenPosition.open = false;
}
  
void ClosingManager::closeByCantidadVigencia(CTrade *trading, Estrategy *estrategiaOpenPosition, int cantidad, datetime activeTime) {   
   if(PositionSelect(_Symbol)) {
      bool closed = false;
      if (estrategiaOpenPosition.orderType==ORDER_TYPE_SELL) {
         double loteActual = PositionGetDouble(POSITION_VOLUME);
         double loteCerrado = (estrategiaOpenPosition.Lote * cantidad) / gm.getLotDivide();
         if ((loteCerrado > 0) && (loteCerrado < loteActual)) {
            trading.Buy(loteActual-loteCerrado, _Symbol); 
         } else if ((loteCerrado == 0) || (loteCerrado == loteActual)) {
            trading.PositionClose(_Symbol);
            closed = true;
         }
      }
      if (closed) {
         estrategiaOpenPosition.openDate=NULL;
         estrategiaOpenPosition.open = false;
      }
   }   
}  

void ClosingManager::closeByIndicator(CTrade *trading, Estrategy *currentEstrategia, 
Difference *difference, datetime activeTime, ENUM_ORDER_TYPE tipoOperacion) {
   if((currentEstrategia.open==true)
      && (currentEstrategia.orderType==tipoOperacion)
		&& (currentEstrategia.closeIndicator==true)
		&& (currentEstrategia.openDate!=activeTime))
   {
      if(currentEstrategia.debeCerrarXIndicador(difference))
      {
      bool abcBol = (currentEstrategia.indicadorBollinger.close(difference.bollingerDiff));
         if(PositionSelect(_Symbol))
           {
            string comment=PositionGetString(POSITION_COMMENT);
            if(comment==currentEstrategia.Index+"-"+currentEstrategia.EstrategiaId)
              {
               close(trading, currentEstrategia);
              }
           }
      }                      
   }
}

/*
void ClosingManager::closeBuyByIndicator(CTrade *trading, Estrategy *currentEstrategia, Difference *difference, datetime activeTime) {

      if((currentEstrategia.open==true)
         && (currentEstrategia.orderType==ORDER_TYPE_BUY)
         && (currentEstrategia.closeIndicator==true)
         && (currentEstrategia.openDate!=activeTime)
         && (!currentEstrategia.indicadorMa.hasClose
            || ((difference.maDiff >= currentEstrategia.indicadorMa.closeLower)
            && (difference.maDiff <= currentEstrategia.indicadorMa.closeHigher)))
         && (!currentEstrategia.indicadorMacd.hasClose
            || ((difference.macdDiff >= currentEstrategia.indicadorMacd.closeLower)
            && (difference.macdDiff <= currentEstrategia.indicadorMacd.closeHigher)))
         && (!currentEstrategia.indicadorMaCompare.hasClose
            || ((difference.maCompareDiff >= currentEstrategia.indicadorMaCompare.closeLower)
            && (difference.maCompareDiff <= currentEstrategia.indicadorMaCompare.closeHigher)))
         && (!currentEstrategia.indicadorSar.hasClose
            || ((difference.sarDiff >= currentEstrategia.indicadorSar.closeLower)
            && (difference.sarDiff <= currentEstrategia.indicadorSar.closeHigher)))
         && (!currentEstrategia.indicadorAdx.hasClose
            || ((difference.adxDiff >= currentEstrategia.indicadorAdx.closeLower)
            && (difference.adxDiff <= currentEstrategia.indicadorAdx.closeHigher)))
         && (!currentEstrategia.indicadorRsi.hasClose
            || ((difference.rsiDiff >= currentEstrategia.indicadorRsi.closeLower)
            && (difference.rsiDiff <= currentEstrategia.indicadorRsi.closeHigher)))
         && (!currentEstrategia.indicadorBollinger.hasClose
            || ((difference.bollingerDiff >= currentEstrategia.indicadorBollinger.closeLower)
            && (difference.bollingerDiff <= currentEstrategia.indicadorBollinger.closeHigher)))
         && (!currentEstrategia.indicadorMomentum.hasClose
            || ((difference.momentumDiff >= currentEstrategia.indicadorMomentum.closeLower)
            && (difference.momentumDiff <= currentEstrategia.indicadorMomentum.closeHigher)))
         && (!currentEstrategia.indicadorIchiTrend.hasClose
            || ((difference.ichiTrendDiff >= currentEstrategia.indicadorIchiTrend.closeLower)
            && (difference.ichiTrendDiff <= currentEstrategia.indicadorIchiTrend.closeHigher)))
         && (!currentEstrategia.indicadorIchiSignal.hasClose
            || ((difference.ichiSignalDiff >= currentEstrategia.indicadorIchiSignal.closeLower)
            && (difference.ichiSignalDiff <= currentEstrategia.indicadorIchiSignal.closeHigher)))
         )
        {
         if(PositionSelect(_Symbol))
           {
            string comment=PositionGetString(POSITION_COMMENT);
            if(comment==currentEstrategia.Index+"-"+currentEstrategia.EstrategiaId)
              {
               trading.PositionClose(_Symbol);
               currentEstrategia.openDate=NULL;
		currentEstrategia.open = false;
              }
           }
        }

}
*/