//+------------------------------------------------------------------+
//|                                                 PrintManager.mqh |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property copyright "RROJASQ"
#property version   "1.00"

#include <Genetic\Estrategy.mqh>
#include <Genetic\Difference.mqh>

class PrintManager {
   public:
      bool print;
      
      PrintManager(bool inPrint);
      ~PrintManager();
      void printOpenEvaluation(Difference *difference,Estrategy *currentEstrategia, ENUM_ORDER_TYPE tipoOperacion);
      void printCloseEvaluation(Difference *difference,Estrategy *currentEstrategia, ENUM_ORDER_TYPE tipoOperacion);
      void customPrint(string str);
            
      
};

PrintManager::PrintManager(bool inPrint) {
   print = inPrint;
}

PrintManager::~PrintManager() {
}

void PrintManager::customPrint(string str) { 
   if(print) {
      Print(str);
   }
}

void PrintManager::printOpenEvaluation(Difference *difference,Estrategy *currentEstrategia, ENUM_ORDER_TYPE tipoOperacion)
  {
   customPrint("printOpenEvaluation" + tipoOperacion);
   if(!(currentEstrategia.open==false))
     {
      customPrint("(currentEstrategia.open==false) FAILED");
     }
   if(!(currentEstrategia.orderType==tipoOperacion)) {
      customPrint("(currentEstrategia.orderType==)"+tipoOperacion+" FAILED");
     }
   if(!(difference.maDiff>=currentEstrategia.indicadorMa.openLower))
     {
      customPrint("(difference.maDiff >= currentEstrategia.indicadorMa.openLower) FAILED: difference.maDiff="+DoubleToString(difference.maDiff)+",currentEstrategia.indicadorMa.openLower="+DoubleToString(currentEstrategia.indicadorMa.openLower));
     }
   if(!(difference.maDiff<=currentEstrategia.indicadorMa.openHigher))
     {
      customPrint("(difference.maDiff <= currentEstrategia.indicadorMa.openHigher) FAILED: difference.maDiff="+DoubleToString(difference.maDiff)+",currentEstrategia.indicadorMa.openHigher="+DoubleToString(currentEstrategia.indicadorMa.openHigher));
     }
   if(!(difference.macdDiff>=currentEstrategia.indicadorMacd.openLower))
     {
      customPrint("(difference.macdDiff >= currentEstrategia.indicadorMacd.openLower) FAILED");
     }
   if(!(difference.macdDiff<=currentEstrategia.indicadorMacd.openHigher))
     {
      customPrint("(difference.macdDiff <= currentEstrategia.indicadorMacd.openHigher) FAILED");
     }
   if(!(difference.maCompareDiff>=currentEstrategia.indicadorMaCompare.openLower))
     {
      customPrint("(difference.maCompareDiff >= currentEstrategia.indicadorMaCompare.openLower) FAILED");
     }
   if(!(difference.maCompareDiff<=currentEstrategia.indicadorMaCompare.openHigher))
     {
      customPrint("(difference.maCompareDiff <= currentEstrategia.indicadorMaCompare.openHigher) FAILED");
     }
   if(!(difference.sarDiff>=currentEstrategia.indicadorSar.openLower))
     {
      customPrint("(difference.sarDiff >= currentEstrategia.indicadorSar.openLower) FAILED: difference.sarDiff="+DoubleToString(difference.sarDiff)+",currentEstrategia.indicadorSar.openLower="+DoubleToString(currentEstrategia.indicadorSar.openLower));
     }
   if(!(difference.sarDiff<=currentEstrategia.indicadorSar.openHigher))
     {
      customPrint("(difference.sarDiff <= currentEstrategia.indicadorSar.openHigher) FAILED: difference.sarDiff="+DoubleToString(difference.sarDiff)+",currentEstrategia.indicadorSar.openHigher="+DoubleToString(currentEstrategia.indicadorSar.openHigher));
     }
   if(!(difference.adxDiff>=currentEstrategia.indicadorAdx.openLower))
     {
      customPrint("(difference.adxDiff >= currentEstrategia.indicadorAdx.openLower) FAILED: difference.adxDiff="+DoubleToString(difference.adxDiff)+",currentEstrategia.indicadorAdx.openLower="+DoubleToString(currentEstrategia.indicadorAdx.openLower));
     }
   if(!(difference.adxDiff<=currentEstrategia.indicadorAdx.openHigher))
     {
      customPrint("(difference.adxDiff <= currentEstrategia.indicadorAdx.openHigher) FAILED: difference.adxDiff="+DoubleToString(difference.adxDiff)+",currentEstrategia.indicadorAdx.openHigher="+DoubleToString(currentEstrategia.indicadorAdx.openHigher));
     }
   if(!(difference.rsiDiff>=currentEstrategia.indicadorRsi.openLower))
     {
      customPrint("(difference.rsiDiff >= currentEstrategia.indicadorRsi.openLower) FAILED: difference.rsiDiff="+DoubleToString(difference.rsiDiff)+",currentEstrategia.indicadorRsi.openLower="+DoubleToString(currentEstrategia.indicadorRsi.openLower));
     }
   if(!(difference.rsiDiff<=currentEstrategia.indicadorRsi.openHigher))
     {
      customPrint("(difference.rsiDiff <= currentEstrategia.indicadorRsi.openHigher) FAILED: difference.rsiDiff="+DoubleToString(difference.rsiDiff)+",currentEstrategia.indicadorRsi.openHigher="+DoubleToString(currentEstrategia.indicadorRsi.openHigher));
     }
   if(!(difference.bollingerDiff>=currentEstrategia.indicadorBollinger.openLower))
     {
      customPrint("(difference.bollingerDiff >= currentEstrategia.indicadorBollinger.openLower) FAILED: difference.bollingerDiff="+DoubleToString(difference.bollingerDiff)+",currentEstrategia.indicadorBollinger.openLower="+DoubleToString(currentEstrategia.indicadorBollinger.openLower));
     }
   if(!(difference.bollingerDiff<=currentEstrategia.indicadorBollinger.openHigher))
     {
      customPrint("(difference.bollingerDiff <= currentEstrategia.indicadorBollinger.openHigher) FAILED: difference.bollingerDiff="+DoubleToString(difference.bollingerDiff)+",currentEstrategia.indicadorBollinger.openHigher="+DoubleToString(currentEstrategia.indicadorBollinger.openHigher));
     }
   if(!(difference.momentumDiff>=currentEstrategia.indicadorMomentum.openLower))
     {
      customPrint("(difference.momentumDiff >= currentEstrategia.indicadorMomentum.openLower) FAILED");
     }
   if(!(difference.momentumDiff<=currentEstrategia.indicadorMomentum.openHigher))
     {
      customPrint("(difference.momentumDiff <= currentEstrategia.indicadorMomentum.openHigher) FAILED");
     }
   if(!(difference.ichiTrendDiff>=currentEstrategia.indicadorIchiTrend.openLower))
     {
      customPrint("(difference.ichiTrendDiff >= currentEstrategia.indicadorIchiTrend.openLower) FAILED: difference.ichiTrendDiff="+DoubleToString(difference.ichiTrendDiff)+",currentEstrategia.indicadorIchiTrend.openLower="+DoubleToString(currentEstrategia.indicadorIchiTrend.openLower));
     }
   if(!(difference.ichiTrendDiff<=currentEstrategia.indicadorIchiTrend.openHigher))
     {
      customPrint("(difference.ichiTrendDiff <= currentEstrategia.indicadorIchiTrend.openHigher) FAILED: difference.ichiTrendDiff="+DoubleToString(difference.ichiTrendDiff)+",currentEstrategia.indicadorIchiTrend.openHigher="+DoubleToString(currentEstrategia.indicadorIchiTrend.openHigher));
     }
   if(!(difference.ichiSignalDiff>=currentEstrategia.indicadorIchiSignal.openLower))
     {
      customPrint("(difference.ichiSignalDiff >= currentEstrategia.openIchiSignalLower) FAILED: difference.ichiSignalDiff="+DoubleToString(difference.ichiSignalDiff)+",currentEstrategia.openIchiSignalLower="+DoubleToString(currentEstrategia.indicadorIchiSignal.openLower));
     }
   if(!(difference.ichiSignalDiff<=currentEstrategia.indicadorIchiSignal.openHigher))
     {
      customPrint("(difference.ichiSignalDiff <= currentEstrategia.openIchiSignalHigher) FAILED: difference.ichiSignalDiff="+DoubleToString(difference.ichiSignalDiff)+",currentEstrategia.openIchiSignalHigher="+DoubleToString(currentEstrategia.indicadorIchiSignal.openHigher));
     }
   if(!(difference.ma1200Diff>=currentEstrategia.indicadorMa1200.openLower))
     {
      customPrint("(difference.ma1200Diff >= currentEstrategia.indicadorMa1200.openLower) FAILED: difference.ma1200Diff="+DoubleToString(difference.ma1200Diff)+",currentEstrategia.indicadorMa1200.openLower="+DoubleToString(currentEstrategia.indicadorMa1200.openLower));
     }
   if(!(difference.ma1200Diff<=currentEstrategia.indicadorMa1200.openHigher))
     {
      customPrint("(difference.ma1200Diff <= currentEstrategia.indicadorMa1200.openHigher) FAILED: difference.ma1200Diff="+DoubleToString(difference.ma1200Diff)+",currentEstrategia.indicadorMa1200.openHigher="+DoubleToString(currentEstrategia.indicadorMa1200.openHigher));
     }     
   if(!(difference.macd20xDiff>=currentEstrategia.indicadorMacd20x.openLower))
     {
      customPrint("(difference.macd20xDiff >= currentEstrategia.indicadorMacd20x.openLower) FAILED");
     }
   if(!(difference.macd20xDiff<=currentEstrategia.indicadorMacd20x.openHigher))
     {
      customPrint("(difference.macd20xDiff <= currentEstrategia.indicadorMacd20x.openHigher) FAILED");
     }
   if(!(difference.maCompare1200Diff>=currentEstrategia.indicadorMaCompare1200.openLower))
     {
      customPrint("(difference.maCompare1200Diff >= currentEstrategia.indicadorMaCompare1200.openLower) FAILED");
     }
   if(!(difference.maCompare1200Diff<=currentEstrategia.indicadorMaCompare1200.openHigher))
     {
      customPrint("(difference.maCompare1200Diff <= currentEstrategia.indicadorMaCompare1200.openHigher) FAILED");
     }
   if(!(difference.sar1200Diff>=currentEstrategia.indicadorSar1200.openLower))
     {
      customPrint("(difference.sar1200Diff >= currentEstrategia.indicadorSar1200.openLower) FAILED: difference.sar1200Diff="+DoubleToString(difference.sar1200Diff)+",currentEstrategia.indicadorSar1200.openLower="+DoubleToString(currentEstrategia.indicadorSar1200.openLower));
     }
   if(!(difference.sar1200Diff<=currentEstrategia.indicadorSar1200.openHigher))
     {
      customPrint("(difference.sar1200Diff <= currentEstrategia.indicadorSar1200.openHigher) FAILED: difference.sar1200Diff="+DoubleToString(difference.sar1200Diff)+",currentEstrategia.indicadorSar1200.openHigher="+DoubleToString(currentEstrategia.indicadorSar1200.openHigher));
     }
   if(!(difference.adx168Diff>=currentEstrategia.indicadorAdx168.openLower))
     {
      customPrint("(difference.adx168Diff >= currentEstrategia.indicadorAdx168.openLower) FAILED: difference.adx168Diff="+DoubleToString(difference.adx168Diff)+",currentEstrategia.indicadorAdx168.openLower="+DoubleToString(currentEstrategia.indicadorAdx168.openLower));
     }
   if(!(difference.adx168Diff<=currentEstrategia.indicadorAdx168.openHigher))
     {
      customPrint("(difference.adx168Diff <= currentEstrategia.indicadorAdx168.openHigher) FAILED: difference.adx168Diff="+DoubleToString(difference.adx168Diff)+",currentEstrategia.indicadorAdx168.openHigher="+DoubleToString(currentEstrategia.indicadorAdx168.openHigher));
     }
   if(!(difference.rsi84Diff>=currentEstrategia.indicadorRsi84.openLower))
     {
      customPrint("(difference.rsi84Diff >= currentEstrategia.indicadorRsi84.openLower) FAILED: difference.rsi84Diff="+DoubleToString(difference.rsi84Diff)+",currentEstrategia.indicadorRsi84.openLower="+DoubleToString(currentEstrategia.indicadorRsi84.openLower));
     }
   if(!(difference.rsi84Diff<=currentEstrategia.indicadorRsi84.openHigher))
     {
      customPrint("(difference.rsi84Diff <= currentEstrategia.indicadorRsi84.openHigher) FAILED: difference.rsi84Diff="+DoubleToString(difference.rsi84Diff)+",currentEstrategia.indicadorRsi84.openHigher="+DoubleToString(currentEstrategia.indicadorRsi84.openHigher));
     }
   if(!(difference.bollinger240Diff>=currentEstrategia.indicadorBollinger240.openLower))
     {
      customPrint("(difference.bollinger240Diff >= currentEstrategia.indicadorBollinger240.openLower) FAILED: difference.bollinger240Diff="+DoubleToString(difference.bollinger240Diff)+",currentEstrategia.indicadorBollinger240.openLower="+DoubleToString(currentEstrategia.indicadorBollinger240.openLower));
     }
   if(!(difference.bollinger240Diff<=currentEstrategia.indicadorBollinger240.openHigher))
     {
      customPrint("(difference.bollinger240Diff <= currentEstrategia.indicadorBollinger240.openHigher) FAILED: difference.bollinger240Diff="+DoubleToString(difference.bollinger240Diff)+",currentEstrategia.indicadorBollinger240.openHigher="+DoubleToString(currentEstrategia.indicadorBollinger240.openHigher));
     }
   if(!(difference.momentum1200Diff>=currentEstrategia.indicadorMomentum1200.openLower))
     {
      customPrint("(difference.momentum1200Diff >= currentEstrategia.indicadorMomentum1200.openLower) FAILED");
     }
   if(!(difference.momentum1200Diff<=currentEstrategia.indicadorMomentum1200.openHigher))
     {
      customPrint("(difference.momentum1200Diff <= currentEstrategia.indicadorMomentum1200.openHigher) FAILED");
     }
   if(!(difference.ichiTrend6Diff>=currentEstrategia.indicadorIchiTrend6.openLower))
     {
      customPrint("(difference.ichiTrend6Diff >= currentEstrategia.indicadorIchiTrend6.openLower) FAILED: difference.ichiTrend6Diff="+DoubleToString(difference.ichiTrend6Diff)+",currentEstrategia.indicadorIchiTrend6.openLower="+DoubleToString(currentEstrategia.indicadorIchiTrend6.openLower));
     }
   if(!(difference.ichiTrend6Diff<=currentEstrategia.indicadorIchiTrend6.openHigher))
     {
      customPrint("(difference.ichiTrend6Diff <= currentEstrategia.indicadorIchiTrend6.openHigher) FAILED: difference.ichiTrend6Diff="+DoubleToString(difference.ichiTrend6Diff)+",currentEstrategia.indicadorIchiTrend6.openHigher="+DoubleToString(currentEstrategia.indicadorIchiTrend6.openHigher));
     }
   if(!(difference.ichiSignal6Diff>=currentEstrategia.indicadorIchiSignal6.openLower))
     {
      customPrint("(difference.ichiSignal6Diff >= currentEstrategia.openIchiSignalLower) FAILED: difference.ichiSignal6Diff="+DoubleToString(difference.ichiSignal6Diff)+",currentEstrategia.openIchiSignalLower="+DoubleToString(currentEstrategia.indicadorIchiSignal6.openLower));
     }
   if(!(difference.ichiSignal6Diff<=currentEstrategia.indicadorIchiSignal6.openHigher))
     {
      customPrint("(difference.ichiSignal6Diff <= currentEstrategia.openIchiSignalHigher) FAILED: difference.ichiSignal6Diff="+DoubleToString(difference.ichiSignal6Diff)+",currentEstrategia.openIchiSignalHigher="+DoubleToString(currentEstrategia.indicadorIchiSignal6.openHigher));
     }     
     
   customPrint("printOpenEvaluation END " + tipoOperacion);
  }

void PrintManager::printCloseEvaluation(Difference *difference,Estrategy *currentEstrategia, ENUM_ORDER_TYPE tipoOperacion)
  {
  customPrint("printCloseEvaluation" + tipoOperacion);
   if(!(currentEstrategia.open==true))
     {
      customPrint("(currentEstrategia.open==true) FAILED");
     }            
   if(!(currentEstrategia.orderType==tipoOperacion)) {
      customPrint("(currentEstrategia.orderType==)"+tipoOperacion+" FAILED");
     }

   if(!(difference.maDiff>=currentEstrategia.indicadorMa.closeLower))
     {
      customPrint("(difference.maDiff >= currentEstrategia.indicadorMa.closeLower) FAILED: difference.maDiff="+DoubleToString(difference.maDiff)+",currentEstrategia.indicadorMa.closeLower="+DoubleToString(currentEstrategia.indicadorMa.closeLower));
     }
   if(!(difference.maDiff<=currentEstrategia.indicadorMa.closeHigher))
     {
      customPrint("(difference.maDiff <= currentEstrategia.indicadorMa.closeHigher) FAILED: difference.maDiff="+DoubleToString(difference.maDiff)+",currentEstrategia.indicadorMa.closeHigher="+DoubleToString(currentEstrategia.indicadorMa.closeHigher));
     }
   if(!(difference.macdDiff>=currentEstrategia.indicadorMacd.closeLower))
     {
      customPrint("(difference.macdDiff >= currentEstrategia.indicadorMacd.closeLower) FAILED");
     }
   if(!(difference.macdDiff<=currentEstrategia.indicadorMacd.closeHigher))
     {
      customPrint("(difference.macdDiff <= currentEstrategia.indicadorMacd.closeHigher) FAILED");
     }
   if(!(difference.maCompareDiff>=currentEstrategia.indicadorMaCompare.closeLower))
     {
      customPrint("(difference.maCompareDiff >= currentEstrategia.indicadorMaCompare.closeLower) FAILED");
     }
   if(!(difference.maCompareDiff<=currentEstrategia.indicadorMaCompare.closeHigher))
     {
      customPrint("(difference.maCompareDiff <= currentEstrategia.indicadorMaCompare.closeHigher) FAILED");
     }
   if(!(difference.sarDiff>=currentEstrategia.indicadorSar.closeLower))
     {
      customPrint("(difference.sarDiff >= currentEstrategia.indicadorSar.closeLower) FAILED: difference.sarDiff="+DoubleToString(difference.sarDiff)+",currentEstrategia.indicadorSar.closeLower="+DoubleToString(currentEstrategia.indicadorSar.closeLower));
     }
   if(!(difference.sarDiff<=currentEstrategia.indicadorSar.closeHigher))
     {
      customPrint("(difference.sarDiff <= currentEstrategia.indicadorSar.closeHigher) FAILED: difference.sarDiff="+DoubleToString(difference.sarDiff)+",currentEstrategia.indicadorSar.closeHigher="+DoubleToString(currentEstrategia.indicadorSar.closeHigher));
     }
   if(!(difference.adxDiff>=currentEstrategia.indicadorAdx.closeLower))
     {
      customPrint("(difference.adxDiff >= currentEstrategia.indicadorAdx.closeLower) FAILED: difference.adxDiff="+DoubleToString(difference.adxDiff)+",currentEstrategia.indicadorAdx.closeLower="+DoubleToString(currentEstrategia.indicadorAdx.closeLower));
     }
   if(!(difference.adxDiff<=currentEstrategia.indicadorAdx.closeHigher))
     {
      customPrint("(difference.adxDiff <= currentEstrategia.indicadorAdx.closeHigher) FAILED: difference.adxDiff="+DoubleToString(difference.adxDiff)+",currentEstrategia.indicadorAdx.closeHigher="+DoubleToString(currentEstrategia.indicadorAdx.closeHigher));
     }
   if(!(difference.rsiDiff>=currentEstrategia.indicadorRsi.closeLower))
     {
      customPrint("(difference.rsiDiff >= currentEstrategia.indicadorRsi.closeLower) FAILED: difference.rsiDiff="+DoubleToString(difference.rsiDiff)+",currentEstrategia.indicadorRsi.closeLower="+DoubleToString(currentEstrategia.indicadorRsi.closeLower));
     }
   if(!(difference.rsiDiff<=currentEstrategia.indicadorRsi.closeHigher))
     {
      customPrint("(difference.rsiDiff <= currentEstrategia.indicadorRsi.closeHigher) FAILED: difference.rsiDiff="+DoubleToString(difference.rsiDiff)+",currentEstrategia.indicadorRsi.closeHigher="+DoubleToString(currentEstrategia.indicadorRsi.closeHigher));
     }
   if(!(difference.bollingerDiff>=currentEstrategia.indicadorBollinger.closeLower))
     {
      customPrint("(difference.bollingerDiff >= currentEstrategia.indicadorBollinger.closeLower) FAILED: difference.bollingerDiff="+DoubleToString(difference.bollingerDiff)+",currentEstrategia.indicadorBollinger.closeLower="+DoubleToString(currentEstrategia.indicadorBollinger.closeLower));
     }
   if(!(difference.bollingerDiff<=currentEstrategia.indicadorBollinger.closeHigher))
     {
      customPrint("(difference.bollingerDiff <= currentEstrategia.indicadorBollinger.closeHigher) FAILED: difference.bollingerDiff="+DoubleToString(difference.bollingerDiff)+",currentEstrategia.indicadorBollinger.closeHigher="+DoubleToString(currentEstrategia.indicadorBollinger.closeHigher));
     }
   if(!(difference.momentumDiff>=currentEstrategia.indicadorMomentum.closeLower))
     {
      customPrint("(difference.momentumDiff >= currentEstrategia.indicadorMomentum.closeLower) FAILED");
     }
   if(!(difference.momentumDiff<=currentEstrategia.indicadorMomentum.closeHigher))
     {
      customPrint("(difference.momentumDiff <= currentEstrategia.indicadorMomentum.closeHigher) FAILED");
     }
   if(!(difference.ichiTrendDiff>=currentEstrategia.indicadorIchiTrend.closeLower))
     {
      customPrint("(difference.ichiTrendDiff >= currentEstrategia.indicadorIchiTrend.closeLower) FAILED: difference.ichiTrendDiff="+DoubleToString(difference.ichiTrendDiff)+",currentEstrategia.indicadorIchiTrend.closeLower="+DoubleToString(currentEstrategia.indicadorIchiTrend.closeLower));
     }
   if(!(difference.ichiTrendDiff<=currentEstrategia.indicadorIchiTrend.closeHigher))
     {
      customPrint("(difference.ichiTrendDiff <= currentEstrategia.indicadorIchiTrend.closeHigher) FAILED: difference.ichiTrendDiff="+DoubleToString(difference.ichiTrendDiff)+",currentEstrategia.indicadorIchiTrend.closeHigher="+DoubleToString(currentEstrategia.indicadorIchiTrend.closeHigher));
     }
   if(!(difference.ichiSignalDiff>=currentEstrategia.indicadorIchiSignal.closeLower))
     {
      customPrint("(difference.ichiSignalDiff >= currentEstrategia.closeIchiSignalLower) FAILED: difference.ichiSignalDiff="+DoubleToString(difference.ichiSignalDiff)+",currentEstrategia.closeIchiSignalLower="+DoubleToString(currentEstrategia.indicadorIchiSignal.closeLower));
     }
   if(!(difference.ichiSignalDiff<=currentEstrategia.indicadorIchiSignal.closeHigher))
     {
      customPrint("(difference.ichiSignalDiff <= currentEstrategia.closeIchiSignalHigher) FAILED: difference.ichiSignalDiff="+DoubleToString(difference.ichiSignalDiff)+",currentEstrategia.closeIchiSignalHigher="+DoubleToString(currentEstrategia.indicadorIchiSignal.closeHigher));
     }
   if(!(difference.ma1200Diff>=currentEstrategia.indicadorMa1200.closeLower))
     {
      customPrint("(difference.ma1200Diff >= currentEstrategia.indicadorMa1200.closeLower) FAILED: difference.ma1200Diff="+DoubleToString(difference.ma1200Diff)+",currentEstrategia.indicadorMa1200.closeLower="+DoubleToString(currentEstrategia.indicadorMa1200.closeLower));
     }
   if(!(difference.ma1200Diff<=currentEstrategia.indicadorMa1200.closeHigher))
     {
      customPrint("(difference.ma1200Diff <= currentEstrategia.indicadorMa1200.closeHigher) FAILED: difference.ma1200Diff="+DoubleToString(difference.ma1200Diff)+",currentEstrategia.indicadorMa1200.closeHigher="+DoubleToString(currentEstrategia.indicadorMa1200.closeHigher));
     }     
   if(!(difference.macd20xDiff>=currentEstrategia.indicadorMacd20x.closeLower))
     {
      customPrint("(difference.macd20xDiff >= currentEstrategia.indicadorMacd20x.closeLower) FAILED");
     }
   if(!(difference.macd20xDiff<=currentEstrategia.indicadorMacd20x.closeHigher))
     {
      customPrint("(difference.macd20xDiff <= currentEstrategia.indicadorMacd20x.closeHigher) FAILED");
     }
   if(!(difference.maCompare1200Diff>=currentEstrategia.indicadorMaCompare1200.closeLower))
     {
      customPrint("(difference.maCompare1200Diff >= currentEstrategia.indicadorMaCompare1200.closeLower) FAILED");
     }
   if(!(difference.maCompare1200Diff<=currentEstrategia.indicadorMaCompare1200.closeHigher))
     {
      customPrint("(difference.maCompare1200Diff <= currentEstrategia.indicadorMaCompare1200.closeHigher) FAILED");
     }
   if(!(difference.sar1200Diff>=currentEstrategia.indicadorSar1200.closeLower))
     {
      customPrint("(difference.sar1200Diff >= currentEstrategia.indicadorSar1200.closeLower) FAILED: difference.sar1200Diff="+DoubleToString(difference.sar1200Diff)+",currentEstrategia.indicadorSar1200.closeLower="+DoubleToString(currentEstrategia.indicadorSar1200.closeLower));
     }
   if(!(difference.sar1200Diff<=currentEstrategia.indicadorSar1200.closeHigher))
     {
      customPrint("(difference.sar1200Diff <= currentEstrategia.indicadorSar1200.closeHigher) FAILED: difference.sar1200Diff="+DoubleToString(difference.sar1200Diff)+",currentEstrategia.indicadorSar1200.closeHigher="+DoubleToString(currentEstrategia.indicadorSar1200.closeHigher));
     }
   if(!(difference.adx168Diff>=currentEstrategia.indicadorAdx168.closeLower))
     {
      customPrint("(difference.adx168Diff >= currentEstrategia.indicadorAdx168.closeLower) FAILED: difference.adx168Diff="+DoubleToString(difference.adx168Diff)+",currentEstrategia.indicadorAdx168.closeLower="+DoubleToString(currentEstrategia.indicadorAdx168.closeLower));
     }
   if(!(difference.adx168Diff<=currentEstrategia.indicadorAdx168.closeHigher))
     {
      customPrint("(difference.adx168Diff <= currentEstrategia.indicadorAdx168.closeHigher) FAILED: difference.adx168Diff="+DoubleToString(difference.adx168Diff)+",currentEstrategia.indicadorAdx168.closeHigher="+DoubleToString(currentEstrategia.indicadorAdx168.closeHigher));
     }
   if(!(difference.rsi84Diff>=currentEstrategia.indicadorRsi84.closeLower))
     {
      customPrint("(difference.rsi84Diff >= currentEstrategia.indicadorRsi84.closeLower) FAILED: difference.rsi84Diff="+DoubleToString(difference.rsi84Diff)+",currentEstrategia.indicadorRsi84.closeLower="+DoubleToString(currentEstrategia.indicadorRsi84.closeLower));
     }
   if(!(difference.rsi84Diff<=currentEstrategia.indicadorRsi84.closeHigher))
     {
      customPrint("(difference.rsi84Diff <= currentEstrategia.indicadorRsi84.closeHigher) FAILED: difference.rsi84Diff="+DoubleToString(difference.rsi84Diff)+",currentEstrategia.indicadorRsi84.closeHigher="+DoubleToString(currentEstrategia.indicadorRsi84.closeHigher));
     }
   if(!(difference.bollinger240Diff>=currentEstrategia.indicadorBollinger240.closeLower))
     {
      customPrint("(difference.bollinger240Diff >= currentEstrategia.indicadorBollinger240.closeLower) FAILED: difference.bollinger240Diff="+DoubleToString(difference.bollinger240Diff)+",currentEstrategia.indicadorBollinger240.closeLower="+DoubleToString(currentEstrategia.indicadorBollinger240.closeLower));
     }
   if(!(difference.bollinger240Diff<=currentEstrategia.indicadorBollinger240.closeHigher))
     {
      customPrint("(difference.bollinger240Diff <= currentEstrategia.indicadorBollinger240.closeHigher) FAILED: difference.bollinger240Diff="+DoubleToString(difference.bollinger240Diff)+",currentEstrategia.indicadorBollinger240.closeHigher="+DoubleToString(currentEstrategia.indicadorBollinger240.closeHigher));
     }
   if(!(difference.momentum1200Diff>=currentEstrategia.indicadorMomentum1200.closeLower))
     {
      customPrint("(difference.momentum1200Diff >= currentEstrategia.indicadorMomentum1200.closeLower) FAILED");
     }
   if(!(difference.momentum1200Diff<=currentEstrategia.indicadorMomentum1200.closeHigher))
     {
      customPrint("(difference.momentum1200Diff <= currentEstrategia.indicadorMomentum1200.closeHigher) FAILED");
     }
   if(!(difference.ichiTrend6Diff>=currentEstrategia.indicadorIchiTrend6.closeLower))
     {
      customPrint("(difference.ichiTrend6Diff >= currentEstrategia.indicadorIchiTrend6.closeLower) FAILED: difference.ichiTrend6Diff="+DoubleToString(difference.ichiTrend6Diff)+",currentEstrategia.indicadorIchiTrend6.closeLower="+DoubleToString(currentEstrategia.indicadorIchiTrend6.closeLower));
     }
   if(!(difference.ichiTrend6Diff<=currentEstrategia.indicadorIchiTrend6.closeHigher))
     {
      customPrint("(difference.ichiTrend6Diff <= currentEstrategia.indicadorIchiTrend6.closeHigher) FAILED: difference.ichiTrend6Diff="+DoubleToString(difference.ichiTrend6Diff)+",currentEstrategia.indicadorIchiTrend6.closeHigher="+DoubleToString(currentEstrategia.indicadorIchiTrend6.closeHigher));
     }
   if(!(difference.ichiSignal6Diff>=currentEstrategia.indicadorIchiSignal6.closeLower))
     {
      customPrint("(difference.ichiSignal6Diff >= currentEstrategia.closeIchiSignalLower) FAILED: difference.ichiSignal6Diff="+DoubleToString(difference.ichiSignal6Diff)+",currentEstrategia.closeIchiSignalLower="+DoubleToString(currentEstrategia.indicadorIchiSignal6.closeLower));
     }
   if(!(difference.ichiSignal6Diff<=currentEstrategia.indicadorIchiSignal6.closeHigher))
     {
      customPrint("(difference.ichiSignal6Diff <= currentEstrategia.closeIchiSignalHigher) FAILED: difference.ichiSignal6Diff="+DoubleToString(difference.ichiSignal6Diff)+",currentEstrategia.closeIchiSignalHigher="+DoubleToString(currentEstrategia.indicadorIchiSignal6.closeHigher));
     }     
     
   customPrint("printCloseEvaluation END " + tipoOperacion);
  }
