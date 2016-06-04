//+------------------------------------------------------------------+
//|                                             GestionMonetaria.mqh |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"

#include <Genetic\Estrategy.mqh>

class ClosingManager
  {
private:
	void closeBuyByIndicator(Estrategy *currentEstrategia, bool inactive);
	void closeSellByIndicator(Estrategy *currentEstrategia, bool inactive);
public:

   ClosingManager();
  ~ClosingManager();
  
  void closeByIndicator(Estrategy *currentEstrategia, Difference *difference, ENUM_ORDER_TYPE orderType);
  
  };
  
ClosingManager::ClosingManager()
  {
  }

ClosingManager::~ClosingManager()
  {
  }

void ClosingManager::closeByIndicator(Estrategy *currentEstrategia, Difference *difference, ENUM_ORDER_TYPE orderType)
  {
	if (orderType==ORDER_TYPE_BUY) {
//		closeBuyByIndicator
	} else if (orderType==ORDER_TYPE_SELL) {
		closeSellByIndicator();
	}	
  }


void ClosingManager::closeSellByIndicator(Estrategy *currentEstrategia, Difference *difference) {
      if((currentEstrategia.open==true)
         && (currentEstrategia.orderType==ORDER_TYPE_SELL)
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

void ClosingManager::closeBuyByIndicator(Estrategy *currentEstrategia, Difference *difference) {

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
