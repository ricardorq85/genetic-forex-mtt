//+------------------------------------------------------------------+
//|                                            ForexGenetic_File.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, RROJASQ"
#property link      ""
#property version   "1.00"

#include <Trade\Trade.mqh>
#include <Estrategy.mqh>
#include <Difference.mqh>

//--- input parameters
input string   fileName="estrategias.csv";
input string   compare="EURUSD";
input bool   print=false;
input bool   calculateLot=false;
input bool   onceAtTime=true;
input bool   reloadEstrategias=false;
input int   numDayFortalezaEstrategia=30;
input bool   doInactive=false;
input bool   oneByPeriod=false;
int maHandle;
int maCompareHandle;
int macdHandle;
int sarHandle;
int adxHandle;
int rsiHandle;
int bandsHandle;
int momentumHandle;
int ichiHandle;

MqlRates  rates_array[];
MqlRates  rates_array_compare[];
double maBuffer[];
double maCompareBuffer[];
double macdMainBuffer[];
double macdSignalBuffer[];
double sarBuffer[];
double adxMainBuffer[];
double adxPlusBuffer[];
double adxMinusBuffer[];
double rsiBuffer[];
double bandsLowerBuffer[];
double bandsUpperBuffer[];
double momentumBuffer[];
double ichiTenkanSenBuffer[];
double ichiKijunSenBuffer[];
double ichiSenkouSpanABuffer[];
double ichiSenkouSpanBBuffer[];
double ichiChinkouSpanBuffer[];

double initialBalance=0.0;
double maxBalance=0.0;
datetime lastTime=0;
datetime nextVigencia=NULL;
int shift=1;
double pipsFixer=0.0;
bool endEstrategias=false;
datetime fileLastReadTime=NULL;
int lastTotalPositions=0;
datetime activeTime=NULL;
int counter=1;
Estrategy   *estrategias[];
CTrade     *trading;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print("Inicio... ");
//---
//string common_data_path=TerminalInfoString(TERMINAL_COMMONDATA_PATH);
   loadEstrategias();
   loadHandles();
   pipsFixer=0/exponent(10,_Digits);
   trading=new CTrade();
   trading.SetExpertMagicNumber(1);     // magic
   initialBalance=AccountInfoDouble(ACCOUNT_BALANCE);
   maxBalance=initialBalance;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   if(trading!=NULL)
     {
      delete trading;
      trading=NULL;
     }
   Print("Fin... ");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(reloadEstrategias)
     {
      loadEstrategias();
     }
   process();
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
   return(0.0);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
  }
//+------------------------------------------------------------------+
//| BookEvent function                                               |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol)
  {
  }
//+------------------------------------------------------------------+
void loadHandles()
  {
   ArraySetAsSeries(rates_array,true);
   ArraySetAsSeries(rates_array_compare,true);

   maHandle=iMA(_Symbol,_Period,60,0,MODE_SMA,PRICE_WEIGHTED);
   SetIndexBuffer(0,maBuffer,INDICATOR_DATA);
   ArraySetAsSeries(maBuffer,true);

   maCompareHandle=iMA(compare,_Period,60,0,MODE_SMA,PRICE_WEIGHTED);
   SetIndexBuffer(0,maCompareBuffer,INDICATOR_DATA);
   ArraySetAsSeries(maCompareBuffer,true);

   macdHandle=iMACD(_Symbol,_Period,12,26,9,PRICE_WEIGHTED);
   SetIndexBuffer(0,macdMainBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,macdSignalBuffer,INDICATOR_DATA);
   ArraySetAsSeries(macdMainBuffer,true);
   ArraySetAsSeries(macdSignalBuffer,true);

   sarHandle=iSAR(_Symbol,_Period,0.02,0.2);
   SetIndexBuffer(0,sarBuffer,INDICATOR_DATA);
   ArraySetAsSeries(sarBuffer,true);

   adxHandle=iADX(_Symbol,_Period,14);
   SetIndexBuffer(0,adxMainBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,adxPlusBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,adxMinusBuffer,INDICATOR_DATA);
   ArraySetAsSeries(adxMainBuffer,true);
   ArraySetAsSeries(adxPlusBuffer,true);
   ArraySetAsSeries(adxMinusBuffer,true);

   rsiHandle=iRSI(_Symbol,_Period,28,PRICE_WEIGHTED);
   SetIndexBuffer(0,rsiBuffer,INDICATOR_DATA);
   ArraySetAsSeries(rsiBuffer,true);

   bandsHandle=iBands(_Symbol,_Period,20,2,2,PRICE_WEIGHTED);
   SetIndexBuffer(0,bandsUpperBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,bandsLowerBuffer,INDICATOR_DATA);
   ArraySetAsSeries(bandsUpperBuffer,true);
   ArraySetAsSeries(bandsLowerBuffer,true);

   momentumHandle=iMomentum(_Symbol,_Period,28,PRICE_WEIGHTED);
   SetIndexBuffer(0,momentumBuffer,INDICATOR_DATA);
   ArraySetAsSeries(momentumBuffer,true);

   ichiHandle=iIchimoku(_Symbol,_Period,9,26,52);
   SetIndexBuffer(0,ichiTenkanSenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ichiKijunSenBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ichiSenkouSpanABuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ichiSenkouSpanBBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,ichiChinkouSpanBuffer,INDICATOR_DATA);
   ArraySetAsSeries(ichiTenkanSenBuffer,true);
   ArraySetAsSeries(ichiKijunSenBuffer,true);
   ArraySetAsSeries(ichiSenkouSpanABuffer,true);
   ArraySetAsSeries(ichiSenkouSpanBBuffer,true);
   ArraySetAsSeries(ichiChinkouSpanBuffer,true);

  }


void process()
  {
   MqlTick last_tick;
   if(!SymbolInfoTick(Symbol(),last_tick))
     {
      Print("SymbolInfoTick() failed, error = "+IntegerToString(GetLastError()));
      return;
     }
   customPrint("last_tick.time = "+IntegerToString((long)last_tick.time));

   processClose();

   int to_copy=shift+1;

   int iCurrent=CopyRates(_Symbol,_Period,0,to_copy,rates_array);
   int iCurrentCompare=CopyRates(compare,_Period,0,to_copy,rates_array_compare);
   activeTime=rates_array[shift].time;

   customPrint("nextVigencia innn="+nextVigencia);
   if((nextVigencia!=NULL) && (activeTime<nextVigencia) && (lastTotalPositions==0))
     {
      customPrint("nextVigencia out="+nextVigencia);
      return;
     }

   CopyBuffer(maHandle,0,0,to_copy,maBuffer);
   CopyBuffer(maCompareHandle,0,0,to_copy,maCompareBuffer);
   CopyBuffer(macdHandle,0,0,to_copy,macdMainBuffer);
   CopyBuffer(macdHandle,1,0,to_copy,macdSignalBuffer);
   CopyBuffer(sarHandle,0,0,to_copy,sarBuffer);
   CopyBuffer(adxHandle,0,0,to_copy,adxMainBuffer);
   CopyBuffer(adxHandle,1,0,to_copy,adxPlusBuffer);
   CopyBuffer(adxHandle,2,0,to_copy,adxMinusBuffer);
   CopyBuffer(rsiHandle,0,0,to_copy,rsiBuffer);
   CopyBuffer(bandsHandle,1,0,to_copy,bandsUpperBuffer);
   CopyBuffer(bandsHandle,2,0,to_copy,bandsLowerBuffer);
   CopyBuffer(momentumHandle,0,0,to_copy,momentumBuffer);
   CopyBuffer(ichiHandle,0,0,to_copy,ichiTenkanSenBuffer);
   CopyBuffer(ichiHandle,1,0,to_copy,ichiKijunSenBuffer);
   CopyBuffer(ichiHandle,2,0,to_copy,ichiSenkouSpanABuffer);
   CopyBuffer(ichiHandle,3,0,to_copy,ichiSenkouSpanBBuffer);
   CopyBuffer(ichiHandle,4,0,to_copy,ichiChinkouSpanBuffer);

   double ma=NormalizeDouble(maBuffer[shift],_Digits);
   double macdV = NormalizeDouble(macdMainBuffer[shift], _Digits);
   double macdS = NormalizeDouble(macdSignalBuffer[shift], _Digits);
   double maCompare=NormalizeDouble(maCompareBuffer[shift],(int)SymbolInfoInteger(compare,SYMBOL_DIGITS));

   double closeCompare=NormalizeDouble(rates_array_compare[shift].close,(int)SymbolInfoInteger(compare,SYMBOL_DIGITS));

   double sar=NormalizeDouble(sarBuffer[shift],_Digits);
   double adxValue= NormalizeDouble(adxMainBuffer[shift],_Digits);
   double adxPlus = NormalizeDouble(adxPlusBuffer[shift],_Digits);
   double adxMinus= NormalizeDouble(adxMinusBuffer[shift],_Digits);
   double rsi=NormalizeDouble(rsiBuffer[shift],_Digits);
   double bollingerUpper = NormalizeDouble(bandsUpperBuffer[shift], _Digits);
   double bollingerLower = NormalizeDouble(bandsLowerBuffer[shift], _Digits);
   double momentum=NormalizeDouble(momentumBuffer[shift],_Digits);
   double ichiTenkanSen= NormalizeDouble(ichiTenkanSenBuffer[shift],_Digits);
   double ichiKijunSen = NormalizeDouble(ichiKijunSenBuffer[shift],_Digits);
   double ichiSpanA = NormalizeDouble(ichiSenkouSpanABuffer[shift],_Digits);
   double ichiSpanB = NormalizeDouble(ichiSenkouSpanBBuffer[shift],_Digits);
   double ichiChinkouSpan=NormalizeDouble(ichiChinkouSpanBuffer[shift],_Digits);
//Print("ichiChinkouSpan="+ichiChinkouSpan);

   double low=NormalizeDouble(rates_array[shift].low,_Digits);
   double high=NormalizeDouble(rates_array[shift].high,_Digits);
   //string date1=TimeToString(activeTime);

   Difference *difference=new Difference;
   difference.maDiff=NormalizeDouble(ma-last_tick.bid,_Digits);
   difference.macdDiff=NormalizeDouble(macdV-macdS,_Digits);
   difference.maCompareDiff=NormalizeDouble(maCompare-closeCompare,_Digits);
   difference.sarDiff = NormalizeDouble(sar - last_tick.bid,_Digits);
   difference.adxDiff = NormalizeDouble(adxValue * (adxPlus-adxMinus),_Digits);
   difference.rsiDiff = NormalizeDouble(rsi,_Digits);
   difference.bollingerDiff= NormalizeDouble(bollingerUpper-bollingerLower,_Digits);
   difference.momentumDiff = NormalizeDouble(momentum,_Digits);
   difference.ichiTrendDiff= NormalizeDouble((ichiSpanA-ichiSpanB)-last_tick.bid,_Digits);
   difference.ichiSignalDiff=NormalizeDouble(ichiChinkouSpan *(ichiTenkanSen-ichiKijunSen),_Digits);

   int openPositionByProcess=1;
   double minLot=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double maxLot=SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   customPrint("BEGINNNNN    XXXXX");
   for(int i=0; i<ArraySize(estrategias); i++)
     {
      if(PositionSelect(_Symbol))
        {
         double open=PositionGetDouble(POSITION_PRICE_OPEN);
         double close= PositionGetDouble(POSITION_PRICE_CURRENT);
         double pips =(open-close)/_Point;
         customPrint("Pips actuales = "+pips+" Open price="+open+" Current price="+close);
        }

      Estrategy *currentEstrategia=estrategias[i];
      nextVigencia(currentEstrategia, activeTime);
      customPrint("currentEstrategia.EstrategiaId="+currentEstrategia.EstrategiaId+" currentEstrategia.active="+currentEstrategia.active);
      if(((!currentEstrategia.active) || (currentEstrategia.VigenciaLower>activeTime)) && (!currentEstrategia.open))
        {
         customPrint("currentEstrategia.VigenciaLower="+currentEstrategia.VigenciaLower+" activeTime="+activeTime);
         continue;
        }
      customPrint("END    XXXXX");
      if(print)
        {
         printCloseBuyEvaluation(difference,currentEstrategia,low-last_tick.bid);
        }
      if((currentEstrategia.open==true)
         && (currentEstrategia.orderType==ORDER_TYPE_BUY)
         && (currentEstrategia.closeIndicator==true)
         && (currentEstrategia.openDate!=activeTime)
         //&&((low-last_tick.bid)<=pipsFixer)
         && (difference.maDiff >=currentEstrategia.closeMaLower)
         && (difference.maDiff <= currentEstrategia.closeMaHigher)
         && (difference.macdDiff >= currentEstrategia.closeMacdLower)
         && (difference.macdDiff <= currentEstrategia.closeMacdHigher)
         && (difference.maCompareDiff >= currentEstrategia.closeMaCompareLower)
         && (difference.maCompareDiff <= currentEstrategia.closeMaCompareHigher)
         && (difference.sarDiff >= currentEstrategia.closeSarLower)
         && (difference.sarDiff <= currentEstrategia.closeSarHigher)
         && (difference.adxDiff >= currentEstrategia.closeAdxLower)
         && (difference.adxDiff <= currentEstrategia.closeAdxHigher)
         && (difference.rsiDiff >= currentEstrategia.closeRsiLower)
         && (difference.rsiDiff <= currentEstrategia.closeRsiHigher)
         && (difference.bollingerDiff >= currentEstrategia.closeBollingerLower)
         && (difference.bollingerDiff <= currentEstrategia.closeBollingerHigher)
         && (difference.momentumDiff >= currentEstrategia.closeMomentumLower)
         && (difference.momentumDiff <= currentEstrategia.closeMomentumHigher)
         && (difference.ichiTrendDiff >= currentEstrategia.closeIchiTrendLower)
         && (difference.ichiTrendDiff <= currentEstrategia.closeIchiTrendHigher)
         && (difference.ichiSignalDiff >= currentEstrategia.closeIchiSignalLower)
         && (difference.ichiSignalDiff <= currentEstrategia.closeIchiSignalHigher)
         )
        {
         if(PositionSelect(_Symbol))
           {
            string comment=PositionGetString(POSITION_COMMENT);
            if(comment==currentEstrategia.Index+"-"+currentEstrategia.EstrategiaId)
               //if(comment==currentEstrategia.EstrategiaId)
              {
               trading.PositionClose(_Symbol);
               currentEstrategia.openDate=NULL;
              }
           }
        }

      difference.maDiff=NormalizeDouble(ma-last_tick.ask,_Digits);
      difference.sarDiff=NormalizeDouble(sar-last_tick.ask,_Digits);
      difference.ichiTrendDiff=NormalizeDouble((ichiSpanA-ichiSpanB)-last_tick.ask,_Digits);      
      if(print)
        {
         printCloseSellEvaluation(difference,currentEstrategia,low-last_tick.bid);
        }
      if((currentEstrategia.open==true)
         && (currentEstrategia.orderType==ORDER_TYPE_SELL)
         && (currentEstrategia.closeIndicator==true)
         && (currentEstrategia.openDate!=activeTime)
         //&& ((last_tick.ask-high)<=pipsFixer)
         && (difference.maDiff >= currentEstrategia.closeMaLower)
         && (difference.maDiff <= currentEstrategia.closeMaHigher)
         && (difference.macdDiff >= currentEstrategia.closeMacdLower)
         && (difference.macdDiff <= currentEstrategia.closeMacdHigher)
         && (difference.maCompareDiff >= currentEstrategia.closeMaCompareLower)
         && (difference.maCompareDiff <= currentEstrategia.closeMaCompareHigher)
         && (difference.sarDiff >= currentEstrategia.closeSarLower)
         && (difference.sarDiff <= currentEstrategia.closeSarHigher)
         && (difference.adxDiff >= currentEstrategia.closeAdxLower)
         && (difference.adxDiff <= currentEstrategia.closeAdxHigher)
         && (difference.rsiDiff >= currentEstrategia.closeRsiLower)
         && (difference.rsiDiff <= currentEstrategia.closeRsiHigher)
         && (difference.bollingerDiff >= currentEstrategia.closeBollingerLower)
         && (difference.bollingerDiff <= currentEstrategia.closeBollingerHigher)
         && (difference.momentumDiff >= currentEstrategia.closeMomentumLower)
         && (difference.momentumDiff <= currentEstrategia.closeMomentumHigher)
         && (difference.ichiTrendDiff >= currentEstrategia.closeIchiTrendLower)
         && (difference.ichiTrendDiff <= currentEstrategia.closeIchiTrendHigher)
         && (difference.ichiSignalDiff >= currentEstrategia.closeIchiSignalLower)
         && (difference.ichiSignalDiff <= currentEstrategia.closeIchiSignalHigher)
         )
        {
         if(PositionSelect(_Symbol))
           {
            string comment=PositionGetString(POSITION_COMMENT);
            //if(comment==currentEstrategia.EstrategiaId)
            if(comment==currentEstrategia.Index+"-"+currentEstrategia.EstrategiaId)
              {
               trading.PositionClose(_Symbol);
               currentEstrategia.openDate=NULL;
              }
           }
        }
      if((nextVigencia!=NULL) && (activeTime<nextVigencia) && (lastTotalPositions==0))
        {
         customPrint("nextVigencia out 2="+nextVigencia);
         return;
        }

      if((currentEstrategia.active) && (currentEstrategia.VigenciaHigher<activeTime) && (!currentEstrategia.open))
        {
         customPrint("currentEstrategia.VigenciaHigher="+currentEstrategia.VigenciaHigher+" activeTime="+activeTime);
         currentEstrategia.active=false;
         nextVigencia=NULL;
        }


      if(endEstrategias)
        {
         continue;
        }
        

      if(currentEstrategia.open==false)
        {
         if(currentEstrategia.pair!=Symbol())
           {
            customPrint("1.1");
            continue;
           }
         if(!((activeTime>=currentEstrategia.VigenciaLower) && (activeTime<=currentEstrategia.VigenciaHigher)))
           {
            customPrint("1.2 activeTime="+activeTime+" currentEstrategia.VigenciaLower="+currentEstrategia.VigenciaLower+" currentEstrategia.VigenciaHigher="+currentEstrategia.VigenciaHigher);
            string dateVigencia1 = TimeToString(currentEstrategia.VigenciaLower);
            string dateVigencia2 = TimeToString(currentEstrategia.VigenciaHigher);
            string dateActive=TimeToString(activeTime);
            continue;
           }
         customPrint("1.3");
         customPrint("2");

         difference.maDiff=NormalizeDouble(ma-last_tick.ask,_Digits);
         difference.macdDiff=NormalizeDouble(macdV-macdS,_Digits);
         difference.maCompareDiff=NormalizeDouble(maCompare-closeCompare,_Digits);
         difference.sarDiff = NormalizeDouble(sar - last_tick.ask,_Digits);
         difference.adxDiff = NormalizeDouble(adxValue*(adxPlus-adxMinus),_Digits);
         difference.rsiDiff = NormalizeDouble(rsi,_Digits);
         difference.bollingerDiff= NormalizeDouble(bollingerUpper-bollingerLower,_Digits);
         difference.momentumDiff = NormalizeDouble(momentum,_Digits);
         difference.ichiTrendDiff=NormalizeDouble((ichiSpanA-ichiSpanB)-last_tick.ask,_Digits);
         difference.ichiSignalDiff=NormalizeDouble(ichiChinkouSpan *(ichiTenkanSen-ichiKijunSen),_Digits);

         customPrint("3");

         if(print)
           {
            printBuyEvaluation(difference,currentEstrategia,last_tick.ask-high);
           }
         if((currentEstrategia.open==false)
            && (currentEstrategia.orderType==ORDER_TYPE_BUY))
           {
            if(//((last_tick.ask-high)<=pipsFixer) && 
               (difference.maDiff>=currentEstrategia.openMaLower)
               && (difference.maDiff<=currentEstrategia.openMaHigher)
               && (difference.macdDiff >= currentEstrategia.openMacdLower)
               && (difference.macdDiff <= currentEstrategia.openMacdHigher)
               && (difference.maCompareDiff >= currentEstrategia.openMaCompareLower)
               && (difference.maCompareDiff <= currentEstrategia.openMaCompareHigher)
               && (difference.sarDiff >= currentEstrategia.openSarLower)
               && (difference.sarDiff <= currentEstrategia.openSarHigher)
               && (difference.adxDiff >= currentEstrategia.openAdxLower)
               && (difference.adxDiff <= currentEstrategia.openAdxHigher)
               && (difference.rsiDiff >= currentEstrategia.openRsiLower)
               && (difference.rsiDiff <= currentEstrategia.openRsiHigher)
               && (difference.bollingerDiff >= currentEstrategia.openBollingerLower)
               && (difference.bollingerDiff <= currentEstrategia.openBollingerHigher)
               && (difference.momentumDiff >= currentEstrategia.openMomentumLower)
               && (difference.momentumDiff <= currentEstrategia.openMomentumHigher)
               && (difference.ichiTrendDiff >= currentEstrategia.openIchiTrendLower)
               && (difference.ichiTrendDiff <= currentEstrategia.openIchiTrendHigher)
               && (difference.ichiSignalDiff >= currentEstrategia.openIchiSignalLower)
               && (difference.ichiSignalDiff <= currentEstrategia.openIchiSignalHigher)
               )
              {
               if(endEstrategias && (oneByPeriod || onceAtTime))
                 {
                  customPrint("(endEstrategias && oneByPeriod && onceAtTime)-->currentEstrategia.active=false");
                  currentEstrategia.active=false;
                  nextVigencia=NULL;
                  continue;
                 }
               double lot=currentEstrategia.Lote;
               if(calculateLot)
                 {
                  double lotCalc=nextLot(currentEstrategia);
                  lot=lotCalc;
                 }
               if(currentEstrategia.active)
                 {
                  bool executed=false;
                  while(!executed)
                    {
                     if(trading.ResultRetcode()!=TRADE_RETCODE_NO_MONEY)
                       {
                        lot=NormalizeDouble(MathMax(lot/openPositionByProcess,minLot),2);
                       }
                     executed=trading.PositionOpen(_Symbol,ORDER_TYPE_BUY,lot,last_tick.ask,last_tick.ask-currentEstrategia.StopLoss*_Point,last_tick.ask+currentEstrategia.TakeProfit*_Point,currentEstrategia.Index+"-"+currentEstrategia.EstrategiaId);
                     if(executed)
                       {
                        currentEstrategia.openDate=activeTime;
                        if(oneByPeriod)
                          {
                           currentEstrategia.active=false;
                           nextVigencia=NULL;
                          }
                        openPositionByProcess++;
                        endEstrategias=onceAtTime;
                        Print("Orden de compra creada. "+currentEstrategia.Index+"-"+currentEstrategia.EstrategiaId+"Bid="+last_tick.bid+" Ask="+last_tick.ask+" Last="+last_tick.last+" Spread="+SymbolInfoInteger(Symbol(),SYMBOL_SPREAD));
                          }else{
                        if(trading.ResultRetcode()==TRADE_RETCODE_NO_MONEY)
                          {
                           lot=NormalizeDouble(lot/2,2);
                             }else{
                           executed=true;
                          }
                        Print("Error al crear orden de compra "+currentEstrategia.Index+"-"+currentEstrategia.EstrategiaId+" Lote="+DoubleToString(lot)+"-TakeProfit="+DoubleToString(currentEstrategia.TakeProfit)+"-Stoploss="+DoubleToString(currentEstrategia.StopLoss));
                       }
                    }
                 }
               lastTime=activeTime;
               customPrint("lastTime="+lastTime);
              }
           }

         difference.maDiff=NormalizeDouble(ma-last_tick.bid,_Digits);
         difference.sarDiff=NormalizeDouble(sar-last_tick.bid,_Digits);
         difference.ichiTrendDiff=NormalizeDouble((ichiSpanA-ichiSpanB)-last_tick.bid,_Digits);
         //Print("4.0 ichiSpanA="+ichiSpanA+";ichiSpanB="+ichiSpanB+";last_tick.bid="+last_tick.bid+";difference.ichiTrendDiff="+difference.ichiTrendDiff);
         //Print("4.0.1 currentEstrategia.openIchiTrendLower="+currentEstrategia.openIchiTrendLower);
         if(print)
           {           
            if (currentEstrategia.EstrategiaId=="1342064824281.87571"){
               printSellEvaluation(difference,currentEstrategia,low-last_tick.bid);
               }
           }
         if((currentEstrategia.open==false)
            && (currentEstrategia.orderType==ORDER_TYPE_SELL))
           {
            if(//((low-last_tick.bid)<=pipsFixer)&& 
               (difference.maDiff>=currentEstrategia.openMaLower)
               && (difference.maDiff<=currentEstrategia.openMaHigher)
               && (difference.macdDiff >= currentEstrategia.openMacdLower)
               && (difference.macdDiff <= currentEstrategia.openMacdHigher)
               && (difference.maCompareDiff >= currentEstrategia.openMaCompareLower)
               && (difference.maCompareDiff <= currentEstrategia.openMaCompareHigher)
               && (difference.sarDiff >= currentEstrategia.openSarLower)
               && (difference.sarDiff <= currentEstrategia.openSarHigher)
               && (difference.adxDiff >= currentEstrategia.openAdxLower)
               && (difference.adxDiff <= currentEstrategia.openAdxHigher)
               && (difference.rsiDiff >= currentEstrategia.openRsiLower)
               && (difference.rsiDiff <= currentEstrategia.openRsiHigher)
               && (difference.bollingerDiff >= currentEstrategia.openBollingerLower)
               && (difference.bollingerDiff <= currentEstrategia.openBollingerHigher)
               && (difference.momentumDiff >= currentEstrategia.openMomentumLower)
               && (difference.momentumDiff <= currentEstrategia.openMomentumHigher)
               && (difference.ichiTrendDiff >= currentEstrategia.openIchiTrendLower)
               && (difference.ichiTrendDiff <= currentEstrategia.openIchiTrendHigher)
               && (difference.ichiSignalDiff >= currentEstrategia.openIchiSignalLower)
               && (difference.ichiSignalDiff <= currentEstrategia.openIchiSignalHigher)
               )
              {
               if(endEstrategias && (oneByPeriod || onceAtTime))
                 {
                  customPrint("(endEstrategias && oneByPeriod && onceAtTime)-->currentEstrategia.active=false");
                  //currentEstrategia.active=false;
                  nextVigencia=NULL;
                  continue;
                 }
               double lot=currentEstrategia.Lote;
               if(calculateLot)
                 {
                  double lotCalc=nextLot(currentEstrategia);
                  lot=lotCalc;
                 }
               if(currentEstrategia.active)
                 {
                  bool executed=false;
                  while(!executed)
                    {
                     //Print("TEST ma="+ma+" maCompare="+maCompare+" difference.maCompareDiff="+difference.maCompareDiff+" closeCompare="+closeCompare+" macdV="+macdV+" macdS="+macdS+" sar="+sar+" adxValue="+adxValue+" adxPlus="+adxPlus+" adxMinus="+adxMinus+" rsi="+rsi+" bollingerUpper="+bollingerUpper+" bollingerLower="+bollingerLower+" momentum="+momentum);
                     //Print("TEST 2 currentEstrategia.openMaCompareLower="+currentEstrategia.openMaCompareLower+" currentEstrategia.openMaCompareHigher="+currentEstrategia.openMaCompareLower);
                     
                     executed=trading.PositionOpen(_Symbol,ORDER_TYPE_SELL,lot,last_tick.bid,last_tick.bid+currentEstrategia.StopLoss*_Point,last_tick.bid-currentEstrategia.TakeProfit*_Point,currentEstrategia.Index+"-"+currentEstrategia.EstrategiaId);
                     if(executed)
                       {
                        currentEstrategia.openDate=activeTime;
                        if(oneByPeriod)
                          {
                           currentEstrategia.active=false;
                           nextVigencia=NULL;
                          }
                        openPositionByProcess++;
                        endEstrategias=onceAtTime;
                        Print("Orden de venta creada."+currentEstrategia.Index+"-"+currentEstrategia.EstrategiaId+" Bid="+last_tick.bid+" Ask="+last_tick.ask+" Last="+last_tick.last+" Spread="+IntegerToString(SymbolInfoInteger(Symbol(),SYMBOL_SPREAD)));
                          }else{
                        if(trading.ResultRetcode()==TRADE_RETCODE_NO_MONEY)
                          {
                           lot=NormalizeDouble(lot/2,2);
                             }else{
                           executed=true;
                          }
                        Print("Error al crear orden de venta. "+currentEstrategia.Index+"-"+currentEstrategia.EstrategiaId+" Error code "+IntegerToString(GetLastError())+" Lote="+DoubleToString(lot)+"-TakeProfit="+DoubleToString(currentEstrategia.TakeProfit)+"-Stoploss="+DoubleToString(currentEstrategia.StopLoss));
                       }
                    }
                 }
               lastTime=activeTime;
               customPrint("lastTime="+lastTime);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void loadEstrategias()
  {
//---
   Print("TERMINAL_PATH = ",TerminalInfoString(TERMINAL_PATH));
   Print("TERMINAL_DATA_PATH = ",TerminalInfoString(TERMINAL_DATA_PATH));
   Print("TERMINAL_COMMONDATA_PATH = ",TerminalInfoString(TERMINAL_COMMONDATA_PATH));
   ResetLastError();
   string fullFileName = "estrategias\\"+fileName;
   //string fullFileName = fileName;
   datetime modifyTime = FileGetInteger(fullFileName, FILE_MODIFY_DATE,true);

   if((fileLastReadTime!=NULL) && (modifyTime<=fileLastReadTime))
     {
      return;
     }
   Print("fileLastReadTime="+IntegerToString(fileLastReadTime));
   int handle=FileOpen(fullFileName,FILE_READ|FILE_ANSI|FILE_COMMON);
   fileLastReadTime=modifyTime;
   if(handle>0)
     {
      int i;
      for(i=0; !FileIsEnding(handle); i++)
        {
         string str=FileReadString(handle);
         StringTrimLeft(str);
         if(StringLen(str)==0)
           {
            i--;
              } else {
            Print("Estrategia String:"+IntegerToString(i)+" "+str);
            Estrategy *estrategy=new Estrategy;
            estrategy.initEstrategias(str,i+1);
            Print("Estrategia cargada:"+IntegerToString(i)+" "+estrategy.toString());
/*if(estrategy.Index>ArraySize(estrategias)) 
              {
               ArrayResize(estrategias,estrategy.Index+i+1);
              }*/
            ArrayResize(estrategias,i+1);
            estrategias[i]=estrategy;
           }
        }
      FileClose(handle);
        }else{
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      Print("Failed to open the file by the absolute path ");
      Print("Error code "+IntegerToString(GetLastError()));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void processClose()
  {
   int positionsTotal=PositionsTotal();
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(positionsTotal==0)
     {
      endEstrategias=false;
        }else {
      endEstrategias=onceAtTime;
     }
   customPrint("5: PositionsTotal="+IntegerToString(positionsTotal)+" LastPositionsTotal="+IntegerToString(lastTotalPositions));
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(lastTotalPositions!=positionsTotal)
     {
      Print("Balance="+AccountInfoDouble(ACCOUNT_BALANCE));
      customPrint("close 5.0");
      Estrategy *currentEstrategia=NULL;
      for(int i=0; i<ArraySize(estrategias); i++)
        {
         currentEstrategia=estrategias[i];
         currentEstrategia.open=false;
         customPrint("close 5.1");
         if(positionsTotal!=0)
           {
            if(PositionSelect(currentEstrategia.pair))
              {
               string comment=PositionGetString(POSITION_COMMENT);
               //ENUM_ORDER_TYPE orderType=((ENUM_ORDER_TYPE)PositionGetInteger(POSITION_TYPE));
               //if(currentEstrategia.orderType==orderType)
               if(comment==currentEstrategia.Index+"-"+currentEstrategia.EstrategiaId)
                 {
                  customPrint("close 5.2.1 "+comment);
                  customPrint("close 5.2 "+currentEstrategia.EstrategiaId);
                  currentEstrategia.open=true;
                 }
              }
           }
        }
     }
   lastTotalPositions=positionsTotal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double exponent(double base,int exponent)
  {
   double value=base;
   for(int i=0; i<exponent-1; i++)
     {
      value=value*base;
     }
   return(value);
  }

void customPrint(string str)
  {     
   if(print)
     {
     if ((activeTime>StringToTime("2012.08.21 08:12")) && (activeTime<StringToTime("2012.08.23 00:00"))){
      Print(str);
      }
     }
  }

void nextVigencia(Estrategy *currentEstrategia,datetime time)
  {
   if(currentEstrategia.active)
     {
      if(nextVigencia==NULL)
        {
         nextVigencia=currentEstrategia.VigenciaLower;
           }else {
         if(nextVigencia>currentEstrategia.VigenciaLower)
           {
            if((time>=currentEstrategia.VigenciaLower) && (time<=currentEstrategia.VigenciaHigher))
              {
               nextVigencia=currentEstrategia.VigenciaLower;
                 }else {
               if(currentEstrategia.VigenciaLower>time)
                 {
                  nextVigencia=currentEstrategia.VigenciaLower;
                 }
              }
           }
        }
     }
   if(time>nextVigencia)
     {
      nextVigencia=time;
     }
//  Print("next vigencia = ",nextVigencia);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double nextLot(Estrategy *currentEstrategia)
  {
   HistorySelect(0,TimeCurrent());
   ulong    ticket=0;
   double   profit;
   string comment=NULL;
   string symbol;
   long inPositionId=0;
   long outPositionId=0;
   double nextLot=currentEstrategia.Lote;
   double balanceActual=AccountInfoDouble(ACCOUNT_BALANCE);
   double currentProfit=0;
   maxBalance=MathMax(maxBalance,balanceActual);
   double maxProfit=balanceActual-maxBalance;
   int currentNum=0;
   int last=0;
   long entry;
   uint     total=HistoryDealsTotal();
//Print("total="+total);
   for(uint i=total;i>0;i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      //Print("i="+i);
      if((ticket=HistoryDealGetTicket(i-1))>0)
        {
         //Print("select "+i);
         symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
         entry =HistoryDealGetInteger(ticket,DEAL_ENTRY);
         if(symbol!=currentEstrategia.pair){continue;}
         if(entry==DEAL_ENTRY_IN)
           {
            comment=HistoryDealGetString(ticket,DEAL_COMMENT);
            inPositionId=HistoryDealGetInteger(ticket,DEAL_POSITION_ID);
            if((comment!=NULL) && (comment!=currentEstrategia.EstrategiaId)){continue;}
           }
         else if(entry==DEAL_ENTRY_OUT)
           {
            profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);
            outPositionId=HistoryDealGetInteger(ticket,DEAL_POSITION_ID);
           }
         if((inPositionId==0) || (outPositionId==0) || (inPositionId!=outPositionId)){continue;}
         if(((last>0) && (profit>0)) || ((last<0) && (profit<0)))
           {
            currentProfit=currentProfit+profit;
            currentNum++;
              }else {
            if(last==0)
              {
               currentProfit=profit;
               currentNum=1;
              }
           }
         if((last!=0) && (((last>0) && (profit<0)) || ((last<0) && (profit>0))))
           {
            break;
              }else {
            if(profit>0)
              {
               last=1;
                 }else {
               last=-1;
              }
           }
           }else{
         Print(IntegerToString(GetLastError())+" select "+IntegerToString(i));
         break;
        }
     }
//   Print("Comment="+comment+" EstrategiaId="+currentEstrategia.EstrategiaId+" currentNum="+currentNum);
//   Print(" currentProfit="+currentProfit+" MaxProfit="+maxProfit+" MaxBalance="+maxBalance+" Balance actual="+balanceActual);
   double minLot=SymbolInfoDouble(currentEstrategia.pair,SYMBOL_VOLUME_MIN);
   double maxLot=SymbolInfoDouble(currentEstrategia.pair, SYMBOL_VOLUME_MAX);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(currentProfit<0)
     {
      //if(currentNum>currentEstrategia.maxConsecutiveLostOperationsNumber)
      if(currentNum>0)
        {
         currentEstrategia.active=!doInactive;
         nextLot=0;
        }
      else if(currentNum>=currentEstrategia.maxConsecutiveLostOperationsNumber)
        {
         double maxProfitLote=0;
         if(maxProfit<0)
           {
            double loteProfit=(MathAbs(maxProfit)/currentEstrategia.TakeProfit);
            maxProfitLote=(0.1)*loteProfit;
           }
         double loteProfit=(MathAbs(currentProfit)/currentEstrategia.TakeProfit);
         nextLot=MathMax(nextLot,(1.5)*(maxProfitLote+loteProfit));
         nextLot=MathMax(nextLot,currentEstrategia.Lote);
           }else if(currentNum>=currentEstrategia.minConsecutiveLostOperationsNumber){
         nextLot=currentEstrategia.Lote;
           }else {
         nextLot=minLot;
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else if(currentProfit>0)
     {
      if(currentNum>=currentEstrategia.maxConsecutiveWonOperationsNumber)
        {
         currentEstrategia.maxConsecutiveWonOperationsNumber=currentNum;
         nextLot=minLot;
           }else if(currentNum>currentEstrategia.averageConsecutiveWonOperationsNumber){
         nextLot=(currentEstrategia.Lote)
                 /(currentEstrategia.maxConsecutiveWonOperationsNumber-currentEstrategia.averageConsecutiveWonOperationsNumber)
                 *(currentNum-currentEstrategia.averageConsecutiveWonOperationsNumber+1);
           }else if((currentNum<=0) || (currentNum>=currentEstrategia.minConsecutiveWonOperationsNumber)){
         nextLot=currentEstrategia.Lote;
           }else {
         nextLot=currentEstrategia.Lote*1.2;
        }
     }

   nextLot = MathMax(minLot, nextLot);
   nextLot = MathMin(maxLot, nextLot);
   nextLot = NormalizeDouble(nextLot, 2);
   customPrint("Lote calculado="+DoubleToString(nextLot));
   return nextLot;
  }
//+------------------------------------------------------------------+

void printBuyEvaluation(Difference *difference,Estrategy *currentEstrategia,double pipsComparer)
  {
   if(!(currentEstrategia.open==false))
     {
      customPrint("(currentEstrategia.open==false) FAILED");
        } else if(!(currentEstrategia.orderType==ORDER_TYPE_BUY)) {
      customPrint("(currentEstrategia.orderType==ORDER_TYPE_BUY) FAILED");
      //        } else if(!(pipsComparer<=pipsFixer)) {
      //    customPrint("((last_tick.ask-high)<=pipsFixer) FAILED");
        } else if(!(difference.maDiff>=currentEstrategia.openMaLower)) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      customPrint("(difference.maDiff >= currentEstrategia.openMaLower) FAILED: difference.maDiff="+DoubleToString(difference.maDiff)+",currentEstrategia.openMaLower="+DoubleToString(currentEstrategia.openMaLower));
        } else if(!(difference.maDiff<=currentEstrategia.openMaHigher)) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      customPrint("(difference.maDiff <= currentEstrategia.openMaHigher) FAILED");
        } else if(!(difference.macdDiff>=currentEstrategia.openMacdLower)) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      customPrint("(difference.macdDiff >= currentEstrategia.openMacdLower) FAILED");
        } else if(!(difference.macdDiff<=currentEstrategia.openMacdHigher)) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      customPrint("(difference.macdDiff <= currentEstrategia.openMacdHigher) FAILED");
        } else if(!(difference.maCompareDiff>=currentEstrategia.openMaCompareLower)) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      customPrint("(difference.maCompareDiff >= currentEstrategia.openMaCompareLower) FAILED");
        } else if(!(difference.maCompareDiff<=currentEstrategia.openMaCompareHigher)) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      customPrint("(difference.maCompareDiff <= currentEstrategia.openMaCompareHigher) FAILED");
        } else if(!(difference.sarDiff>=currentEstrategia.openSarLower)) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      customPrint("(difference.sarDiff >= currentEstrategia.openSarLower) FAILED");
        } else if(!(difference.sarDiff<=currentEstrategia.openSarHigher)) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      customPrint("(difference.sarDiff <= currentEstrategia.openSarHigher) FAILED");
        } else if(!(difference.adxDiff>=currentEstrategia.openAdxLower)) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      customPrint("(difference.adxDiff >= currentEstrategia.openAdxLower) FAILED");
        } else if(!(difference.adxDiff<=currentEstrategia.openAdxHigher)) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      customPrint("(difference.adxDiff <= currentEstrategia.openAdxHigher) FAILED");
        } else if(!(difference.rsiDiff>=currentEstrategia.openRsiLower)) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      customPrint("(difference.rsiDiff >= currentEstrategia.openRsiLower) FAILED");
        } else if(!(difference.rsiDiff<=currentEstrategia.openRsiHigher)) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      customPrint("(difference.rsiDiff <= currentEstrategia.openRsiHigher) FAILED");
        } else if(!(difference.bollingerDiff>=currentEstrategia.openBollingerLower)) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      customPrint("(difference.bollingerDiff >= currentEstrategia.openBollingerLower) FAILED");
        } else if(!(difference.bollingerDiff<=currentEstrategia.openBollingerHigher)) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      customPrint("(difference.bollingerDiff <= currentEstrategia.openBollingerHigher) FAILED");
        } else if(!(difference.momentumDiff>=currentEstrategia.openMomentumLower)) {
      customPrint("(difference.momentumDiff >= currentEstrategia.openMomentumLower) FAILED");
        } else if(!(difference.momentumDiff<=currentEstrategia.openMomentumHigher)) {
      customPrint("(difference.momentumDiff <= currentEstrategia.openMomentumHigher) FAILED");
        } else if(!(difference.ichiTrendDiff>=currentEstrategia.openIchiTrendLower)) {
      customPrint("(difference.ichiTrendDiff >= currentEstrategia.openIchiTrendLower) FAILED: difference.ichiTrendDiff="+DoubleToString(difference.ichiTrendDiff)+",currentEstrategia.openIchiTrendLower="+DoubleToString(currentEstrategia.openIchiTrendLower));
        } else if(!(difference.ichiTrendDiff<=currentEstrategia.openIchiTrendHigher)) {
      customPrint("(difference.ichiTrendDiff <= currentEstrategia.openIchiTrendHigher) FAILED: difference.ichiTrendDiff="+DoubleToString(difference.ichiTrendDiff)+",currentEstrategia.openIchiTrendHigher="+DoubleToString(currentEstrategia.openIchiTrendHigher));
        } else if(!(difference.ichiSignalDiff>=currentEstrategia.openIchiSignalLower)) {
      customPrint("(difference.ichiSignalDiff >= currentEstrategia.openIchiSignalLower) FAILED: difference.ichiSignalDiff="+DoubleToString(difference.ichiSignalDiff)+",currentEstrategia.openIchiSignalLower="+DoubleToString(currentEstrategia.openIchiSignalLower));
        } else if(!(difference.ichiSignalDiff<=currentEstrategia.openIchiSignalHigher)) {
      customPrint("(difference.ichiSignalDiff <= currentEstrategia.openIchiSignalHigher) FAILED: difference.ichiSignalDiff="+DoubleToString(difference.ichiSignalDiff)+",currentEstrategia.openIchiSignalHigher="+DoubleToString(currentEstrategia.openIchiSignalHigher));
     }
  }

void printSellEvaluation(Difference *difference,Estrategy *currentEstrategia,double pipsComparer)
  {
   customPrint("printSellEvaluation");
   if(!(currentEstrategia.open==false))
     {
      customPrint("((sellActiveOperation[index] == false) FAILED");
        }else if(!(currentEstrategia.orderType==ORDER_TYPE_SELL)) {
      customPrint("(currentEstrategia.orderType==ORDER_TYPE_SELL) FAILED");
      //} else if(!(pipsComparer<=pipsFixer)) {
      customPrint("((low-last_tick.bid)<=pipsFixer) FAILED");
     }
   if(!(difference.maDiff>=currentEstrategia.openMaLower))
     {
      customPrint("(difference.maDiff >= currentEstrategia.openMaLower) FAILED: difference.maDiff="+DoubleToString(difference.maDiff)+",currentEstrategia.openMaLower="+DoubleToString(currentEstrategia.openMaLower));
     }
   if(!(difference.maDiff<=currentEstrategia.openMaHigher))
     {
      customPrint("(difference.maDiff <= currentEstrategia.openMaHigher) FAILED: difference.maDiff="+DoubleToString(difference.maDiff)+",currentEstrategia.openMaHigher="+DoubleToString(currentEstrategia.openMaHigher));
     }
   if(!(difference.macdDiff>=currentEstrategia.openMacdLower))
     {
      customPrint("(difference.macdDiff >= currentEstrategia.openMacdLower) FAILED");
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!(difference.macdDiff<=currentEstrategia.openMacdHigher))
     {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      customPrint("(difference.macdDiff <= currentEstrategia.openMacdHigher) FAILED");
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!(difference.maCompareDiff>=currentEstrategia.openMaCompareLower))
     {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      customPrint("(difference.maCompareDiff >= currentEstrategia.openMaCompareLower) FAILED");
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!(difference.maCompareDiff<=currentEstrategia.openMaCompareHigher))
     {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      customPrint("(difference.maCompareDiff <= currentEstrategia.openMaCompareHigher) FAILED");
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!(difference.sarDiff>=currentEstrategia.openSarLower))
     {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+      
      customPrint("(difference.sarDiff >= currentEstrategia.openSarLower) FAILED: difference.sarDiff="+DoubleToString(difference.sarDiff)+",currentEstrategia.openSarLower="+DoubleToString(currentEstrategia.openSarLower));
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!(difference.sarDiff<=currentEstrategia.openSarHigher))
     {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      customPrint("(difference.sarDiff <= currentEstrategia.openSarHigher) FAILED: difference.sarDiff="+DoubleToString(difference.sarDiff)+",currentEstrategia.openSarHigher="+DoubleToString(currentEstrategia.openSarHigher));
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!(difference.adxDiff>=currentEstrategia.openAdxLower))
     {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      customPrint("(difference.adxDiff >= currentEstrategia.openAdxLower) FAILED: difference.adxDiff="+DoubleToString(difference.adxDiff)+",currentEstrategia.openAdxLower="+DoubleToString(currentEstrategia.openAdxLower));
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!(difference.adxDiff<=currentEstrategia.openAdxHigher))
     {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      customPrint("(difference.adxDiff <= currentEstrategia.openAdxHigher) FAILED: difference.adxDiff="+DoubleToString(difference.adxDiff)+",currentEstrategia.openAdxHigher="+DoubleToString(currentEstrategia.openAdxHigher));
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!(difference.rsiDiff>=currentEstrategia.openRsiLower))
     {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+      
      customPrint("(difference.rsiDiff >= currentEstrategia.openRsiLower) FAILED: difference.rsiDiff="+DoubleToString(difference.rsiDiff)+",currentEstrategia.openRsiLower="+DoubleToString(currentEstrategia.openRsiLower));
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!(difference.rsiDiff<=currentEstrategia.openRsiHigher))
     {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      customPrint("(difference.rsiDiff <= currentEstrategia.openRsiHigher) FAILED: difference.rsiDiff="+DoubleToString(difference.rsiDiff)+",currentEstrategia.openRsiHigher="+DoubleToString(currentEstrategia.openRsiHigher));
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!(difference.bollingerDiff>=currentEstrategia.openBollingerLower))
     {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      customPrint("(difference.bollingerDiff >= currentEstrategia.openBollingerLower) FAILED: difference.bollingerDiff="+DoubleToString(difference.bollingerDiff)+",currentEstrategia.openBollingerLower="+DoubleToString(currentEstrategia.openBollingerLower));
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!(difference.bollingerDiff<=currentEstrategia.openBollingerHigher))
     {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      customPrint("(difference.bollingerDiff <= currentEstrategia.openBollingerHigher) FAILED: difference.bollingerDiff="+DoubleToString(difference.bollingerDiff)+",currentEstrategia.openBollingerHigher="+DoubleToString(currentEstrategia.openBollingerHigher));
     }
   if(!(difference.momentumDiff>=currentEstrategia.openMomentumLower))
     {
      customPrint("(difference.momentumDiff >= currentEstrategia.openMomentumLower) FAILED");
     }
   if(!(difference.momentumDiff<=currentEstrategia.openMomentumHigher))
     {
      customPrint("(difference.momentumDiff <= currentEstrategia.openMomentumHigher) FAILED");
     }
   if(!(difference.ichiTrendDiff>=currentEstrategia.openIchiTrendLower))
     {
      customPrint("(difference.ichiTrendDiff >= currentEstrategia.openIchiTrendLower) FAILED: difference.ichiTrendDiff="+DoubleToString(difference.ichiTrendDiff)+",currentEstrategia.openIchiTrendLower="+DoubleToString(currentEstrategia.openIchiTrendLower));
     }
   if(!(difference.ichiTrendDiff<=currentEstrategia.openIchiTrendHigher))
     {
      customPrint("(difference.ichiTrendDiff <= currentEstrategia.openIchiTrendHigher) FAILED: difference.ichiTrendDiff="+DoubleToString(difference.ichiTrendDiff)+",currentEstrategia.openIchiTrendHigher="+DoubleToString(currentEstrategia.openIchiTrendHigher));
     }
   if(!(difference.ichiSignalDiff>=currentEstrategia.openIchiSignalLower))
     {
      customPrint("(difference.ichiSignalDiff >= currentEstrategia.openIchiSignalLower) FAILED: difference.ichiSignalDiff="+DoubleToString(difference.ichiSignalDiff)+",currentEstrategia.openIchiSignalLower="+DoubleToString(currentEstrategia.openIchiSignalLower));
     }
   if(!(difference.ichiSignalDiff<=currentEstrategia.openIchiSignalHigher))
     {
      customPrint("(difference.ichiSignalDiff <= currentEstrategia.openIchiSignalHigher) FAILED: difference.ichiSignalDiff="+DoubleToString(difference.ichiSignalDiff)+",currentEstrategia.openIchiSignalHigher="+DoubleToString(currentEstrategia.openIchiSignalHigher));
     }

   customPrint("printSellEvaluation END");
  }

void printCloseBuyEvaluation(Difference *difference,Estrategy *currentEstrategia,double pipsComparer)
  {

   if(!(currentEstrategia.open==true))
     {
      customPrint("(currentEstrategia.close==true) FAILED");
        } else if(!(currentEstrategia.orderType==ORDER_TYPE_BUY)) {
      customPrint("(currentEstrategia.orderType==ORDER_TYPE_BUY) FAILED");
      //        } else if(!(pipsComparer<=pipsFixer)) {
      //    customPrint("((last_tick.ask-high)<=pipsFixer) FAILED");
        } else if(!(difference.maDiff>=currentEstrategia.closeMaLower)) {
      customPrint("(difference.maDiff >= currentEstrategia.closeMaLower) FAILED: difference.maDiff="+DoubleToString(difference.maDiff)+",currentEstrategia.closeMaLower="+DoubleToString(currentEstrategia.closeMaLower));
        } else if(!(difference.maDiff<=currentEstrategia.closeMaHigher)) {
      customPrint("(difference.maDiff <= currentEstrategia.closeMaHigher) FAILED");
        } else if(!(difference.macdDiff>=currentEstrategia.closeMacdLower)) {
      customPrint("(difference.macdDiff >= currentEstrategia.closeMacdLower) FAILED");
        } else if(!(difference.macdDiff<=currentEstrategia.closeMacdHigher)) {
      customPrint("(difference.macdDiff <= currentEstrategia.closeMacdHigher) FAILED");
        } else if(!(difference.maCompareDiff>=currentEstrategia.closeMaCompareLower)) {
      customPrint("(difference.maCompareDiff >= currentEstrategia.closeMaCompareLower) FAILED");
        } else if(!(difference.maCompareDiff<=currentEstrategia.closeMaCompareHigher)) {
      customPrint("(difference.maCompareDiff <= currentEstrategia.closeMaCompareHigher) FAILED");
        } else if(!(difference.sarDiff>=currentEstrategia.closeSarLower)) {
      customPrint("(difference.sarDiff >= currentEstrategia.closeSarLower) FAILED");
        } else if(!(difference.sarDiff<=currentEstrategia.closeSarHigher)) {
      customPrint("(difference.sarDiff <= currentEstrategia.closeSarHigher) FAILED");
        } else if(!(difference.adxDiff>=currentEstrategia.closeAdxLower)) {
      customPrint("(difference.adxDiff >= currentEstrategia.closeAdxLower) FAILED");
        } else if(!(difference.adxDiff<=currentEstrategia.closeAdxHigher)) {
      customPrint("(difference.adxDiff <= currentEstrategia.closeAdxHigher) FAILED");
        } else if(!(difference.rsiDiff>=currentEstrategia.closeRsiLower)) {
      customPrint("(difference.rsiDiff >= currentEstrategia.closeRsiLower) FAILED");
        } else if(!(difference.rsiDiff<=currentEstrategia.closeRsiHigher)) {
      customPrint("(difference.rsiDiff <= currentEstrategia.closeRsiHigher) FAILED");
        } else if(!(difference.bollingerDiff>=currentEstrategia.closeBollingerLower)) {
      customPrint("(difference.bollingerDiff >= currentEstrategia.closeBollingerLower) FAILED");
        } else if(!(difference.bollingerDiff<=currentEstrategia.closeBollingerHigher)) {
      customPrint("(difference.bollingerDiff <= currentEstrategia.closeBollingerHigher) FAILED");
        } else if(!(difference.momentumDiff>=currentEstrategia.closeMomentumLower)) {
      customPrint("(difference.momentumDiff >= currentEstrategia.closeMomentumLower) FAILED");
        } else if(!(difference.momentumDiff<=currentEstrategia.closeMomentumHigher)) {
      customPrint("(difference.momentumDiff <= currentEstrategia.closeMomentumHigher) FAILED");
        } else if(!(difference.ichiTrendDiff>=currentEstrategia.closeIchiTrendLower)) {
      customPrint("(difference.ichiTrendDiff >= currentEstrategia.closeIchiTrendLower) FAILED: difference.ichiTrendDiff="+DoubleToString(difference.ichiTrendDiff)+",currentEstrategia.closeIchiTrendLower="+DoubleToString(currentEstrategia.closeIchiTrendLower));
        } else if(!(difference.ichiTrendDiff<=currentEstrategia.closeIchiTrendHigher)) {
      customPrint("(difference.ichiTrendDiff <= currentEstrategia.closeIchiTrendHigher) FAILED: difference.ichiTrendDiff="+DoubleToString(difference.ichiTrendDiff)+",currentEstrategia.closeIchiTrendHigher="+DoubleToString(currentEstrategia.closeIchiTrendHigher));
        } else if(!(difference.ichiSignalDiff>=currentEstrategia.closeIchiSignalLower)) {
      customPrint("(difference.ichiSignalDiff >= currentEstrategia.closeIchiSignalLower) FAILED: difference.ichiSignalDiff="+DoubleToString(difference.ichiSignalDiff)+",currentEstrategia.closeIchiSignalLower="+DoubleToString(currentEstrategia.closeIchiSignalLower));
        } else if(!(difference.ichiSignalDiff<=currentEstrategia.closeIchiSignalHigher)) {
      customPrint("(difference.ichiSignalDiff <= currentEstrategia.closeIchiSignalHigher) FAILED: difference.ichiSignalDiff="+DoubleToString(difference.ichiSignalDiff)+",currentEstrategia.closeIchiSignalHigher="+DoubleToString(currentEstrategia.closeIchiSignalHigher));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void printCloseSellEvaluation(Difference *difference,Estrategy *currentEstrategia,double pipsComparer)
  {
   customPrint("printCloseSellEvaluation");
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!(currentEstrategia.open==true))
     {
      customPrint("((sellActiveOperation[index] == false) FAILED");
        }else if(!(currentEstrategia.orderType==ORDER_TYPE_SELL)) {
      customPrint("(currentEstrategia.orderType==ORDER_TYPE_SELL) FAILED");
      //} else if(!(pipsComparer<=pipsFixer)) {
      customPrint("((low-last_tick.bid)<=pipsFixer) FAILED");
        }else {
      if(!(difference.maDiff>=currentEstrategia.closeMaLower))
        {
         customPrint("(difference.maDiff >= currentEstrategia.closeMaLower) FAILED: difference.maDiff="+DoubleToString(difference.maDiff)+",currentEstrategia.closeMaLower="+DoubleToString(currentEstrategia.closeMaLower));
        }
      if(!(difference.maDiff<=currentEstrategia.closeMaHigher))
        {
         customPrint("(difference.maDiff <= currentEstrategia.closeMaHigher) FAILED: difference.maDiff="+DoubleToString(difference.maDiff)+",currentEstrategia.closeMaHigher="+DoubleToString(currentEstrategia.closeMaHigher));
        }
      if(!(difference.macdDiff>=currentEstrategia.closeMacdLower))
        {
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         customPrint("(difference.macdDiff >= currentEstrategia.closeMacdLower) FAILED: difference.macdDiff="+DoubleToString(difference.macdDiff)+",currentEstrategia.closeMacdLower="+DoubleToString(currentEstrategia.closeMacdLower));
        }
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      if(!(difference.macdDiff<=currentEstrategia.closeMacdHigher))
        {
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         customPrint("(difference.macdDiff <= currentEstrategia.closeMacdHigher) FAILED: difference.macdDiff="+DoubleToString(difference.macdDiff)+",currentEstrategia.closeMacdHigher="+DoubleToString(currentEstrategia.closeMacdHigher));
        }
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      if(!(difference.maCompareDiff>=currentEstrategia.closeMaCompareLower))
        {
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         customPrint("(difference.maCompareDiff >= currentEstrategia.closeMaCompareLower) FAILED: difference.maCompareDiff="+DoubleToString(difference.maCompareDiff)+",currentEstrategia.closeMaCompareLower="+DoubleToString(currentEstrategia.closeMaCompareLower));
        }
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      if(!(difference.maCompareDiff<=currentEstrategia.closeMaCompareHigher))
        {
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         customPrint("(difference.maCompareDiff <= currentEstrategia.closeMaCompareLower) FAILED: difference.maCompareDiff="+DoubleToString(difference.maCompareDiff)+",currentEstrategia.closeMaCompareHigher="+DoubleToString(currentEstrategia.closeMaCompareHigher));
        }
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      if(!(difference.sarDiff>=currentEstrategia.closeSarLower))
        {
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         customPrint("(difference.sarDiff >= currentEstrategia.closeSarLower) FAILED: difference.sarDiff="+DoubleToString(difference.sarDiff)+",currentEstrategia.closeSarLower="+DoubleToString(currentEstrategia.closeSarLower));
        }
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      if(!(difference.sarDiff<=currentEstrategia.closeSarHigher))
        {
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         customPrint("(difference.sarDiff <= currentEstrategia.closeSarHigher) FAILED: difference.sarDiff="+DoubleToString(difference.sarDiff)+",currentEstrategia.closeSarHigher="+DoubleToString(currentEstrategia.closeSarHigher));
        }
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      if(!(difference.adxDiff>=currentEstrategia.closeAdxLower))
        {
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         customPrint("(difference.adxDiff >= currentEstrategia.closeAdxLower) FAILED: difference.adxDiff="+DoubleToString(difference.adxDiff)+",currentEstrategia.closeAdxLower="+DoubleToString(currentEstrategia.closeAdxLower));
        }
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      if(!(difference.adxDiff<=currentEstrategia.closeAdxHigher))
        {
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         customPrint("(difference.adxDiff <= currentEstrategia.closeAdxHigher) FAILED: difference.adxDiff="+DoubleToString(difference.adxDiff)+",currentEstrategia.closeAdxHigher="+DoubleToString(currentEstrategia.closeAdxHigher));
        }
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      if(!(difference.rsiDiff>=currentEstrategia.closeRsiLower))
        {
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         customPrint("(difference.rsiDiff >= currentEstrategia.closeRsiLower) FAILED: difference.rsiDiff="+DoubleToString(difference.rsiDiff)+",currentEstrategia.closeRsiLower="+DoubleToString(currentEstrategia.closeRsiLower));
        }
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      if(!(difference.rsiDiff<=currentEstrategia.closeRsiHigher))
        {
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         customPrint("(difference.rsiDiff <= currentEstrategia.closeRsiHigher) FAILED: difference.rsiDiff="+DoubleToString(difference.rsiDiff)+",currentEstrategia.closeRsiHigher="+DoubleToString(currentEstrategia.closeRsiHigher));
        }
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      if(!(difference.bollingerDiff>=currentEstrategia.closeBollingerLower))
        {
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         customPrint("(difference.bollingerDiff >= currentEstrategia.closeBollingerLower) FAILED: difference.bollingerDiff="+DoubleToString(difference.bollingerDiff)+",currentEstrategia.closeBollingerLower="+DoubleToString(currentEstrategia.closeBollingerLower));
        }
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      if(!(difference.bollingerDiff<=currentEstrategia.closeBollingerHigher))
        {
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         customPrint("(difference.bollingerDiff <= currentEstrategia.closeBollingerHigher) FAILED: difference.bollingerDiff="+DoubleToString(difference.bollingerDiff)+",currentEstrategia.closeBollingerHigher="+DoubleToString(currentEstrategia.closeBollingerHigher));
        }
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      if(!(difference.momentumDiff>=currentEstrategia.closeMomentumLower))
        {
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         customPrint("(difference.momentumDiff <= currentEstrategia.closeMomentumLower) FAILED: difference.momentumDiff="+DoubleToString(difference.momentumDiff)+",currentEstrategia.closeMomentumLower="+DoubleToString(currentEstrategia.closeMomentumLower));
           }  if(!(difference.momentumDiff<=currentEstrategia.closeMomentumHigher)) {
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         customPrint("(difference.momentumDiff <= currentEstrategia.closeMomentumHigher) FAILED: difference.momentumDiff="+DoubleToString(difference.momentumDiff)+",currentEstrategia.closeMomentumHigher="+DoubleToString(currentEstrategia.closeMomentumHigher));
        }

      if(!(difference.ichiTrendDiff>=currentEstrategia.closeIchiTrendLower))
        {
         customPrint("(difference.ichiTrendDiff >= currentEstrategia.closeIchiTrendLower) FAILED: difference.ichiTrendDiff="+DoubleToString(difference.ichiTrendDiff)+",currentEstrategia.closeIchiTrendLower="+DoubleToString(currentEstrategia.closeIchiTrendLower));
        }
      if(!(difference.ichiTrendDiff<=currentEstrategia.closeIchiTrendHigher))
        {
         customPrint("(difference.ichiTrendDiff <= currentEstrategia.closeIchiTrendHigher) FAILED: difference.ichiTrendDiff="+DoubleToString(difference.ichiTrendDiff)+",currentEstrategia.closeIchiTrendHigher="+DoubleToString(currentEstrategia.closeIchiTrendHigher));
        }

      if(!(difference.ichiSignalDiff>=currentEstrategia.closeIchiSignalLower))
        {
         customPrint("(difference.ichiSignalDiff >= currentEstrategia.closeIchiSignalLower) FAILED: difference.ichiSignalDiff="+DoubleToString(difference.ichiSignalDiff)+",currentEstrategia.closeIchiSignalLower="+DoubleToString(currentEstrategia.closeIchiSignalLower));
        }
      if(!(difference.ichiSignalDiff<=currentEstrategia.closeIchiSignalHigher))
        {
         customPrint("(difference.ichiSignalDiff <= currentEstrategia.closeIchiSignalHigher) FAILED: difference.ichiSignalDiff="+DoubleToString(difference.ichiSignalDiff)+",currentEstrategia.closeIchiSignalHigher="+DoubleToString(currentEstrategia.closeIchiSignalHigher));
        }
     }
   customPrint("printCloseSellEvaluation END");
  }
//+------------------------------------------------------------------+
