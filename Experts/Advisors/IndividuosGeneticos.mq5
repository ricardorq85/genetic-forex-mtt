//+------------------------------------------------------------------+
//|                                            IndividuoGeneticos.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, RROJASQ"
#property link      ""
#property version   "1.00"

#include <Trade\Trade.mqh>
#include <Genetic\Estrategy.mqh>
#include <Genetic\Vigencia.mqh>
#include <Genetic\Difference.mqh>
#include <Genetic\GestionMonetaria.mqh>
#include <Genetic\ClosingManager.mqh>

//--- input parameters 
input string   fileName="estrategias.csv";
input string   compare="EURUSD";
input bool   print=false;
input bool   calculateLot=false;
input bool   cerrarPorCantidad=false;
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
int ma1200Handle;
int macd20xHandle;
int maCompare1200Handle;
int sar1200Handle;
int adx168Handle;
int rsi84Handle;
int bands240Handle;
int momentum1200Handle;
int ichi6Handle;

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
double ma1200Buffer[];
double macd20xMainBuffer[];
double macd20xSignalBuffer[];
double maCompare1200Buffer[];
double sar1200Buffer[];
double adxMain168Buffer[];
double adxPlus168Buffer[];
double adxMinus168Buffer[];
double rsi84Buffer[];
double bandsLower240Buffer[];
double bandsUpper240Buffer[];
double momentum1200Buffer[];
double ichiTenkanSen6Buffer[];
double ichiKijunSen6Buffer[];
double ichiSenkouSpanA6Buffer[];
double ichiSenkouSpanB6Buffer[];
double ichiChinkouSpan6Buffer[];

double ichiTenkanSen;
double ichiKijunSen;
double ichiSpanA;
double ichiSpanB;
double ichiChinkouSpan;
double ichiTenkanSen6;
double ichiKijunSen6;
double ichiSpanA6;
double ichiSpanB6;
double ichiChinkouSpan6;


double initialBalance=0.0;
double balanceMaximoCuenta=0.0;
datetime lastTime=0;
datetime nextVigencia=NULL;
int shift=1;
double pipsFixer=0.0;
bool endEstrategias=false;
datetime fileLastReadTime=NULL;
int lastTotalPositions=0;
datetime activeTime=NULL;
datetime printBalance=NULL;
int counter=1;
int nextInitialIndex=0;

Vigencia *lastVigencia;
Estrategy   *estrategias[];
Vigencia   vigencias[];
GestionMonetaria   *gestionMonetaria;
ClosingManager *closingManager;
Estrategy *estrategiaOpenPosition;
CTrade     *trading;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print("Inicio... ");

//string common_data_path=TerminalInfoString(TERMINAL_COMMONDATA_PATH);
   loadEstrategias();
   loadHandles();
   pipsFixer=0/exponent(10,_Digits);
   trading=new CTrade();
   trading.SetExpertMagicNumber(1);     // magic
   initialBalance=AccountInfoDouble(ACCOUNT_BALANCE);
   balanceMaximoCuenta=initialBalance;
   
   gestionMonetaria = new GestionMonetaria();
   closingManager = new ClosingManager();
   estrategiaOpenPosition = new Estrategy();
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
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

  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
   updateClosedPosition();   
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
   SetIndexBuffer(0,ichiTenkanSenBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(1,ichiKijunSenBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,ichiSenkouSpanABuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,ichiSenkouSpanBBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,ichiChinkouSpanBuffer,INDICATOR_CALCULATIONS);
   ArraySetAsSeries(ichiTenkanSenBuffer,true);
   ArraySetAsSeries(ichiKijunSenBuffer,true);
   ArraySetAsSeries(ichiSenkouSpanABuffer,true);
   ArraySetAsSeries(ichiSenkouSpanBBuffer,true);
   ArraySetAsSeries(ichiChinkouSpanBuffer,true);
   
   ma1200Handle=iMA(_Symbol,_Period,1200,0,MODE_SMA,PRICE_WEIGHTED);
   SetIndexBuffer(0,ma1200Buffer,INDICATOR_DATA);
   ArraySetAsSeries(ma1200Buffer,true);   

   macd20xHandle=iMACD(_Symbol,_Period,12*20,26*20,9*20,PRICE_WEIGHTED);
   SetIndexBuffer(0,macd20xMainBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,macd20xSignalBuffer,INDICATOR_DATA);
   ArraySetAsSeries(macd20xMainBuffer,true);
   ArraySetAsSeries(macd20xSignalBuffer,true);

   maCompare1200Handle=iMA(compare,_Period,1200,0,MODE_SMA,PRICE_WEIGHTED);
   SetIndexBuffer(0,maCompare1200Buffer,INDICATOR_DATA);
   ArraySetAsSeries(maCompare1200Buffer,true);


   sar1200Handle=iSAR(_Symbol,_Period,24,240);
   SetIndexBuffer(0,sar1200Buffer,INDICATOR_DATA);
   ArraySetAsSeries(sar1200Buffer,true);

   adx168Handle=iADX(_Symbol,_Period,168);
   SetIndexBuffer(0,adxMain168Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,adxPlus168Buffer,INDICATOR_DATA);
   SetIndexBuffer(2,adxMinus168Buffer,INDICATOR_DATA);
   ArraySetAsSeries(adxMain168Buffer,true);
   ArraySetAsSeries(adxPlus168Buffer,true);
   ArraySetAsSeries(adxMinus168Buffer,true);

   rsi84Handle=iRSI(_Symbol,_Period,84,PRICE_WEIGHTED);
   SetIndexBuffer(0,rsi84Buffer,INDICATOR_DATA);
   ArraySetAsSeries(rsi84Buffer,true);

   bands240Handle=iBands(_Symbol,_Period,240,24,24,PRICE_WEIGHTED);
   SetIndexBuffer(0,bandsUpper240Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,bandsLower240Buffer,INDICATOR_DATA);
   ArraySetAsSeries(bandsUpper240Buffer,true);
   ArraySetAsSeries(bandsLower240Buffer,true);

   momentum1200Handle=iMomentum(_Symbol,_Period,16800,PRICE_WEIGHTED);
   SetIndexBuffer(0,momentum1200Buffer,INDICATOR_DATA);
   ArraySetAsSeries(momentum1200Buffer,true);

   ichi6Handle=iIchimoku(_Symbol,_Period,54,156,312);
   SetIndexBuffer(0,ichiTenkanSen6Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(1,ichiKijunSen6Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,ichiSenkouSpanA6Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,ichiSenkouSpanB6Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,ichiChinkouSpan6Buffer,INDICATOR_CALCULATIONS);
   ArraySetAsSeries(ichiTenkanSen6Buffer,true);
   ArraySetAsSeries(ichiKijunSen6Buffer,true);
   ArraySetAsSeries(ichiSenkouSpanA6Buffer,true);
   ArraySetAsSeries(ichiSenkouSpanB6Buffer,true);
   ArraySetAsSeries(ichiChinkouSpan6Buffer,true);

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
   
   if ((obtenerDiferenciaEnHoras(printBalance, last_tick.time)>=10)) {
     Print("Balance entre días="+AccountInfoDouble(ACCOUNT_BALANCE));
     printBalance = last_tick.time;
   }
  
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
   CopyBuffer(ichiHandle,0,0,27,ichiTenkanSenBuffer);
   CopyBuffer(ichiHandle,1,0,27,ichiKijunSenBuffer);
   CopyBuffer(ichiHandle,2,0,27,ichiSenkouSpanABuffer);
   CopyBuffer(ichiHandle,3,0,27,ichiSenkouSpanBBuffer);
   CopyBuffer(ichiHandle,4,0,27,ichiChinkouSpanBuffer);
   CopyBuffer(ma1200Handle,0,0,to_copy,ma1200Buffer);
   CopyBuffer(macd20xHandle,0,0,to_copy,macd20xMainBuffer);
   CopyBuffer(macd20xHandle,1,0,to_copy,macd20xSignalBuffer);
   CopyBuffer(maCompare1200Handle,0,0,to_copy,maCompare1200Buffer);
   CopyBuffer(sar1200Handle,0,0,to_copy,sar1200Buffer);
   CopyBuffer(adx168Handle,0,0,to_copy,adxMain168Buffer);
   CopyBuffer(adx168Handle,1,0,to_copy,adxPlus168Buffer);
   CopyBuffer(adx168Handle,2,0,to_copy,adxMinus168Buffer);
   CopyBuffer(rsi84Handle,0,0,to_copy,rsi84Buffer);
   CopyBuffer(bands240Handle,1,0,to_copy,bandsUpper240Buffer);
   CopyBuffer(bands240Handle,2,0,to_copy,bandsLower240Buffer);
   CopyBuffer(momentum1200Handle,0,0,to_copy,momentum1200Buffer);
   CopyBuffer(ichi6Handle,0,0,157,ichiTenkanSen6Buffer);
   CopyBuffer(ichi6Handle,1,0,157,ichiKijunSen6Buffer);
   CopyBuffer(ichi6Handle,2,0,157,ichiSenkouSpanA6Buffer);
   CopyBuffer(ichi6Handle,3,0,157,ichiSenkouSpanB6Buffer);
   CopyBuffer(ichi6Handle,4,0,157,ichiChinkouSpan6Buffer);

   double ma=NormalizeDouble(maBuffer[shift],_Digits);
   double macdV = NormalizeDouble(macdMainBuffer[shift], _Digits);
   double macdS = NormalizeDouble(macdSignalBuffer[shift], _Digits);
   double maCompare=NormalizeDouble(maCompareBuffer[shift],(int)SymbolInfoInteger(compare,SYMBOL_DIGITS));
   double maCompare1200=NormalizeDouble(maCompare1200Buffer[shift],(int)SymbolInfoInteger(compare,SYMBOL_DIGITS));

   double closeCompare=NormalizeDouble(rates_array_compare[shift].close,(int)SymbolInfoInteger(compare,SYMBOL_DIGITS));

   double sar=NormalizeDouble(sarBuffer[shift],_Digits);
   double adxValue= NormalizeDouble(adxMainBuffer[shift],_Digits);
   double adxPlus = NormalizeDouble(adxPlusBuffer[shift],_Digits);
   double adxMinus= NormalizeDouble(adxMinusBuffer[shift],_Digits);
   double rsi=NormalizeDouble(rsiBuffer[shift],_Digits);
   double bollingerUpper = NormalizeDouble(bandsUpperBuffer[shift], _Digits);
   double bollingerLower = NormalizeDouble(bandsLowerBuffer[shift], _Digits);
   double momentum=NormalizeDouble(momentumBuffer[shift],_Digits);
   double ma1200=NormalizeDouble(ma1200Buffer[shift],_Digits);
   double macd20xV = NormalizeDouble(macd20xMainBuffer[shift], _Digits);
   double macd20xS = NormalizeDouble(macd20xSignalBuffer[shift], _Digits);
   
   ichiTenkanSen= NormalizeDouble(ichiTenkanSenBuffer[shift],_Digits);
   ichiKijunSen = NormalizeDouble(ichiKijunSenBuffer[shift],_Digits);
   ichiSpanA = NormalizeDouble(ichiSenkouSpanABuffer[shift],_Digits);
   ichiSpanB = NormalizeDouble(ichiSenkouSpanBBuffer[shift],_Digits);
   ichiChinkouSpan=NormalizeDouble(ichiChinkouSpanBuffer[26],_Digits);

   double sar1200 = NormalizeDouble(sar1200Buffer[shift],_Digits);
   double adxValue168 = NormalizeDouble(adxMain168Buffer[shift],_Digits);
   double adxPlus168 = NormalizeDouble(adxPlus168Buffer[shift],_Digits);
   double adxMinus168 = NormalizeDouble(adxMinus168Buffer[shift],_Digits);
   double rsi84 = NormalizeDouble(rsi84Buffer[shift],_Digits);
   double bollingerUpper240 = NormalizeDouble(bandsUpper240Buffer[shift], _Digits);
   double bollingerLower240 = NormalizeDouble(bandsLower240Buffer[shift], _Digits);
   double momentum1200=NormalizeDouble(momentum1200Buffer[shift],_Digits);

   ichiTenkanSen6 = NormalizeDouble(ichiTenkanSen6Buffer[shift],_Digits);
   ichiKijunSen6 = NormalizeDouble(ichiKijunSen6Buffer[shift],_Digits);
   ichiSpanA6 = NormalizeDouble(ichiSenkouSpanA6Buffer[shift],_Digits);
   ichiSpanB6 = NormalizeDouble(ichiSenkouSpanB6Buffer[shift],_Digits);
   ichiChinkouSpan6 = NormalizeDouble(ichiChinkouSpan6Buffer[156],_Digits);

   double low=NormalizeDouble(rates_array[shift].low,_Digits);
   double high=NormalizeDouble(rates_array[shift].high,_Digits);

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
   difference.ma1200Diff=NormalizeDouble(ma1200-last_tick.bid,_Digits);
   difference.macd20xDiff=NormalizeDouble(macd20xV+macd20xS,_Digits);
   difference.maCompare1200Diff=NormalizeDouble(maCompare1200-closeCompare,_Digits);
   difference.sar1200Diff = NormalizeDouble(sar1200 - last_tick.bid,_Digits);
   difference.adx168Diff = NormalizeDouble(adxValue168 * (adxPlus168-adxMinus168),_Digits);
   difference.rsi84Diff = NormalizeDouble(rsi84,_Digits);
   difference.bollinger240Diff= NormalizeDouble(bollingerUpper240-bollingerLower240,_Digits);
   difference.momentum1200Diff = NormalizeDouble(momentum1200,_Digits);
   difference.ichiTrend6Diff= NormalizeDouble((ichiSpanA6-ichiSpanB6)-last_tick.bid,_Digits);
   difference.ichiSignal6Diff=NormalizeDouble(ichiChinkouSpan6 *(ichiTenkanSen6-ichiKijunSen6),_Digits);
   
   int openPositionByProcess=1;
   double minLot=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double maxLot=SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);

   if ((estrategiaOpenPosition != NULL) && (estrategiaOpenPosition.open)) {
      if(print && PositionSelect(_Symbol)) {
         double open=PositionGetDouble(POSITION_PRICE_OPEN);
         double close= PositionGetDouble(POSITION_PRICE_CURRENT);
         double pips =(open-close)/_Point;
         customPrint("Pips actuales = "+pips+" Open price="+open+" Current price="+close);
        }

   	if(print) {
            printCloseEvaluation(difference,estrategiaOpenPosition, ORDER_TYPE_BUY);
      }
   	closingManager.closeByIndicator(trading, estrategiaOpenPosition, difference, activeTime, ORDER_TYPE_BUY);
   
   	difference.maDiff=NormalizeDouble(ma-last_tick.ask,_Digits);
   	difference.sarDiff=NormalizeDouble(sar-last_tick.ask,_Digits);
   	difference.ichiTrendDiff=NormalizeDouble((ichiSpanA-ichiSpanB)-last_tick.ask,_Digits);
   	difference.ma1200Diff=NormalizeDouble(ma1200-last_tick.ask,_Digits);
   	difference.sar1200Diff=NormalizeDouble(sar1200-last_tick.ask,_Digits);
   	difference.ichiTrend6Diff=NormalizeDouble((ichiSpanA6-ichiSpanB6)-last_tick.ask,_Digits);

   	if(print) {
         printCloseEvaluation(difference,estrategiaOpenPosition, ORDER_TYPE_SELL);
      }
   	closingManager.closeByIndicator(trading, estrategiaOpenPosition, difference, activeTime, ORDER_TYPE_SELL);
   	
      if((estrategiaOpenPosition.VigenciaHigher<activeTime) && (!estrategiaOpenPosition.open))
        {
            nextInitialIndex = estrategiaOpenPosition.Index + 1;
        }
   
      if (cerrarPorCantidad) {
         if ((lastVigencia == NULL) || (activeTime > lastVigencia.VigenciaHigher)) {
            int i;
            bool found = false;
            for(i=0; i<ArraySize(vigencias); i++) {
               if (vigencias[i].VigenciaLower <= activeTime &&  activeTime < vigencias[i].VigenciaHigher) {
                  found = true;
                  break;
               } 
            } 
            if (!found) { 
               closingManager.closeByCantidadVigencia(trading, estrategiaOpenPosition, 0, activeTime);
               lastVigencia = NULL;
            } else if (found && (vigencias[i].cantidadVigencia > 0)) {      
               if (vigencias[i].VigenciaLower > estrategiaOpenPosition.VigenciaLower) {
                  closingManager.closeByCantidadVigencia(trading, estrategiaOpenPosition, vigencias[i].cantidadVigencia, activeTime);
               }  
               lastVigencia = new Vigencia();
               lastVigencia.VigenciaLower = vigencias[i].VigenciaLower;
               lastVigencia.VigenciaHigher = vigencias[i].VigenciaHigher;
               lastVigencia.cantidadVigencia = vigencias[i].cantidadVigencia;
            }
         }
      }
   
      if (!estrategiaOpenPosition.open) {
   		estrategiaOpenPosition = NULL;
   	}
    
   	return;
   }

   for(int i=nextInitialIndex; i<ArraySize(estrategias); i++) {
      Estrategy *currentEstrategia=estrategias[i];
      nextVigencia(currentEstrategia, activeTime);
      lastVigencia = NULL;
      customPrint("currentEstrategia.EstrategiaId="+currentEstrategia.EstrategiaId+" currentEstrategia.active="+currentEstrategia.active);
      if(((!currentEstrategia.active) || (currentEstrategia.VigenciaLower>activeTime)) && (!currentEstrategia.open))
        {
         customPrint("currentEstrategia.VigenciaLower="+currentEstrategia.VigenciaLower+" activeTime="+activeTime);
         if (currentEstrategia.VigenciaLower>activeTime) {
            break;
         } else {continue;}
        }
	
      if((nextVigencia!=NULL) && (activeTime<nextVigencia) && (lastTotalPositions==0))
        {
         customPrint("nextVigencia out 2="+nextVigencia);
         return;
        }

      if((currentEstrategia.VigenciaHigher<activeTime) && (!currentEstrategia.open))
        { 
         customPrint("currentEstrategia.VigenciaHigher="+currentEstrategia.VigenciaHigher+" activeTime="+activeTime);
         if ((currentEstrategia.VigenciaHigher<activeTime) && ((estrategiaOpenPosition == NULL) || (!estrategiaOpenPosition.open))) {
            nextInitialIndex = i+1;
         }
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
         difference.ma1200Diff=NormalizeDouble(ma1200-last_tick.ask,_Digits);
         difference.macd20xDiff=NormalizeDouble(macd20xV+macd20xS,_Digits);
         difference.maCompare1200Diff=NormalizeDouble(maCompare1200-closeCompare,_Digits);
         difference.sar1200Diff = NormalizeDouble(sar1200 - last_tick.ask,_Digits);
         difference.adx168Diff = NormalizeDouble(adxValue168*(adxPlus168-adxMinus168),_Digits);
         difference.rsi84Diff = NormalizeDouble(rsi84,_Digits);
         difference.bollinger240Diff= NormalizeDouble(bollingerUpper240-bollingerLower240,_Digits);
         difference.momentum1200Diff = NormalizeDouble(momentum1200,_Digits);
         difference.ichiTrend6Diff=NormalizeDouble((ichiSpanA6-ichiSpanB6)-last_tick.ask,_Digits);
         difference.ichiSignal6Diff=NormalizeDouble(ichiChinkouSpan6 *(ichiTenkanSen6-ichiKijunSen6),_Digits);
         
         if(print)
           {
            printOpenEvaluation(difference,currentEstrategia,ORDER_TYPE_BUY);
           }
         if((currentEstrategia.open==false)
            && (currentEstrategia.orderType==ORDER_TYPE_BUY))
           {
            if((currentEstrategia.indicadorMa.open(difference.maDiff))
               && (currentEstrategia.indicadorMacd.open(difference.macdDiff))
               && (currentEstrategia.indicadorMaCompare.open(difference.maCompareDiff))
               && (currentEstrategia.indicadorSar.open(difference.sarDiff))
               && (currentEstrategia.indicadorAdx.open(difference.adxDiff))
               && (currentEstrategia.indicadorRsi.open(difference.rsiDiff))
               && (currentEstrategia.indicadorBollinger.open(difference.bollingerDiff))
               && (currentEstrategia.indicadorMomentum.open(difference.momentumDiff))
               && (currentEstrategia.indicadorIchiTrend.open(difference.ichiTrendDiff))
               && (currentEstrategia.indicadorIchiSignal.open(difference.ichiSignalDiff))
               && (currentEstrategia.indicadorMa1200.open(difference.ma1200Diff))
               && (currentEstrategia.indicadorMacd20x.open(difference.macd20xDiff))
               && (currentEstrategia.indicadorMaCompare1200.open(difference.maCompare1200Diff))
               )
              {
               if(endEstrategias && (oneByPeriod || onceAtTime))
                 {
                  customPrint("(endEstrategias && oneByPeriod && onceAtTime)-->currentEstrategia.active=false");
                  currentEstrategia.active=false;
                  nextVigencia=NULL;
                  continue;
                 }  
               balanceMaximoCuenta = MathMax(balanceMaximoCuenta,AccountInfoDouble(ACCOUNT_BALANCE));
               double lot=gestionMonetaria.getLot(currentEstrategia, balanceMaximoCuenta, doInactive, calculateLot);

               gestionMonetaria.toggleActiveEstrategia(currentEstrategia, doInactive);
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
                        estrategiaOpenPosition = currentEstrategia;
                        currentEstrategia.openDate=activeTime;
                        currentEstrategia.open = true;
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
         difference.ma1200Diff=NormalizeDouble(ma1200-last_tick.bid,_Digits);
         difference.sar1200Diff=NormalizeDouble(sar1200-last_tick.bid,_Digits);
         difference.ichiTrend6Diff=NormalizeDouble((ichiSpanA6-ichiSpanB6)-last_tick.bid,_Digits);         
         if(print)
           {
               printOpenEvaluation(difference,currentEstrategia,ORDER_TYPE_SELL);
           }
         if((currentEstrategia.open==false)
            && (currentEstrategia.orderType==ORDER_TYPE_SELL))
           {
            if((currentEstrategia.indicadorMa.open(difference.maDiff))
               && (currentEstrategia.indicadorMacd.open(difference.macdDiff))
               && (currentEstrategia.indicadorMaCompare.open(difference.maCompareDiff))
               && (currentEstrategia.indicadorSar.open(difference.sarDiff))
               && (currentEstrategia.indicadorAdx.open(difference.adxDiff))
               && (currentEstrategia.indicadorRsi.open(difference.rsiDiff))
               && (currentEstrategia.indicadorBollinger.open(difference.bollingerDiff))
               && (currentEstrategia.indicadorMomentum.open(difference.momentumDiff))
               && (currentEstrategia.indicadorIchiTrend.open(difference.ichiTrendDiff))
               && (currentEstrategia.indicadorIchiSignal.open(difference.ichiSignalDiff))
               && (currentEstrategia.indicadorMa1200.open(difference.ma1200Diff))
               && (currentEstrategia.indicadorMacd20x.open(difference.macd20xDiff))
               && (currentEstrategia.indicadorMaCompare1200.open(difference.maCompare1200Diff))
               && (currentEstrategia.indicadorSar1200.open(difference.sar1200Diff))
               && (currentEstrategia.indicadorAdx168.open(difference.adx168Diff))
               && (currentEstrategia.indicadorRsi84.open(difference.rsi84Diff))
               && (currentEstrategia.indicadorBollinger240.open(difference.bollinger240Diff))
               && (currentEstrategia.indicadorMomentum1200.open(difference.momentum1200Diff))
               && (currentEstrategia.indicadorIchiTrend6.open(difference.ichiTrend6Diff))
               && (currentEstrategia.indicadorIchiSignal6.open(difference.ichiSignal6Diff))               
               )
              {
               if(endEstrategias && (oneByPeriod || onceAtTime))
                 {
                  customPrint("(endEstrategias && oneByPeriod && onceAtTime)-->currentEstrategia.active=false");
                  nextVigencia=NULL;
                  continue;
                 } 
               balanceMaximoCuenta = MathMax(balanceMaximoCuenta,AccountInfoDouble(ACCOUNT_BALANCE));
               double lot=gestionMonetaria.getLot(currentEstrategia, balanceMaximoCuenta, doInactive, calculateLot);

               gestionMonetaria.toggleActiveEstrategia(currentEstrategia, doInactive);
               if(currentEstrategia.active)
                 {
                  bool executed=false;
                  while(!executed)
                    {
                    
                     executed=trading.PositionOpen(_Symbol,ORDER_TYPE_SELL,lot,last_tick.bid,last_tick.bid+currentEstrategia.StopLoss*_Point,last_tick.bid-currentEstrategia.TakeProfit*_Point,currentEstrategia.Index+"-"+currentEstrategia.EstrategiaId);
                     if(executed)
                       {
                       estrategiaOpenPosition = currentEstrategia;
                       currentEstrategia.openDate=activeTime;
                       currentEstrategia.open = true;
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
     
     delete difference;
     difference = NULL;
  }
  
long obtenerDiferenciaEnHoras(datetime d1, datetime d2) {
   MqlDateTime str1,str2; 
   TimeToStruct(d1,str1);
   TimeToStruct(d2,str2);
      
   // Se debe arreglar para fechas de diferentes años
   long dif = (str2.hour-str1.hour) + (str2.day-str1.day)*24 + (str2.mon-str1.mon)*30*24 + (str2.year-str1.year)*360*24;
   
   return (dif);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void loadEstrategias()
  {
   Print("TERMINAL_PATH = ",TerminalInfoString(TERMINAL_PATH));
   Print("TERMINAL_DATA_PATH = ",TerminalInfoString(TERMINAL_DATA_PATH));
   Print("TERMINAL_COMMONDATA_PATH = ",TerminalInfoString(TERMINAL_COMMONDATA_PATH));
   ResetLastError();
   string fullFileName = "estrategias\\"+fileName;
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
     int j = 0;
      for(int i=0; !FileIsEnding(handle); i++)
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
            ArrayResize(estrategias,i+1);
            estrategias[i]=estrategy;
            
            Vigencia *vigencia = new Vigencia();
            vigencia.VigenciaLower = estrategy.VigenciaLower;
            vigencia.VigenciaHigher = estrategy.VigenciaHigher;
            vigencia.cantidadVigencia = estrategy.cantidadVigencia;            
            if (ArraySize(vigencias)>0) {
               if (vigencias[j-1].VigenciaLower != estrategy.VigenciaLower) {
                  ArrayResize(vigencias, j+1);
                  //vigencias[j] = vigencia;
                  vigencias[j].VigenciaLower = estrategy.VigenciaLower;
                  vigencias[j].VigenciaHigher = estrategy.VigenciaHigher;
                  vigencias[j].cantidadVigencia = estrategy.cantidadVigencia;            
                  j++;
               }
            } else {
               ArrayResize(vigencias, j+1);
               //vigencias[j] = vigencia;
               vigencias[j].VigenciaLower = estrategy.VigenciaLower;
               vigencias[j].VigenciaHigher = estrategy.VigenciaHigher;
               vigencias[j].cantidadVigencia = estrategy.cantidadVigencia;                           
               j++;
            }
           }
        }
      FileClose(handle);
        }else{

      Print("Failed to open the file by the absolute path ");
      Print("Error code "+IntegerToString(GetLastError()));
     }
  }
  
void updateClosedPosition()
  {
   int positionsTotal=PositionsTotal();
   if(positionsTotal==0)
     {
      endEstrategias=false;
        }else {
      endEstrategias=onceAtTime;
     }
   customPrint("5: PositionsTotal="+IntegerToString(positionsTotal)+" LastPositionsTotal="+IntegerToString(lastTotalPositions));

   if(lastTotalPositions != positionsTotal) {
      Print("Balance="+AccountInfoDouble(ACCOUNT_BALANCE));
      if(positionsTotal==0) {
	      estrategiaOpenPosition = NULL;
         for(int i=0; i<ArraySize(estrategias); i++) {
            Estrategy *currentEstrategia=estrategias[i];
            currentEstrategia.open = false;
          }
        }
     }
   lastTotalPositions=positionsTotal;
}    


bool processCloseForEstrategia(Estrategy *estrategia) {
   estrategia.open = false;
   if(PositionSelect(estrategia.pair))
     {
      string comment=PositionGetString(POSITION_COMMENT);
      ENUM_ORDER_TYPE orderType=((ENUM_ORDER_TYPE)PositionGetInteger(POSITION_TYPE));
      if(estrategia.orderType!=orderType) {
        if(comment==estrategia.Index+"-"+estrategia.EstrategiaId) {
         estrategia.open=true;
         return true;
        }
      }
     }
     return false;
}

/*void processCloseOld()
  {
   int positionsTotal=PositionsTotal();
   if(positionsTotal==0)
     {
      endEstrategias=false;
        }else {
      endEstrategias=onceAtTime;
     }
   customPrint("5: PositionsTotal="+IntegerToString(positionsTotal)+" LastPositionsTotal="+IntegerToString(lastTotalPositions));

   if(lastTotalPositions!=positionsTotal)
     {
      Print("Balance="+AccountInfoDouble(ACCOUNT_BALANCE));
      if(positionsTotal!=0) {
         if (!processCloseForEstrategia()){         
            for(int i=0; i<ArraySize(estrategias); i++)
              {
               Estrategy *currentEstrategia=estrategias[i];
               currentEstrategia.open=false;
               if(PositionSelect(currentEstrategia.pair)) {
                  string comment=PositionGetString(POSITION_COMMENT);
                  if(comment==currentEstrategia.Index+"-"+currentEstrategia.EstrategiaId)
                    {
                     currentEstrategia.open=true;
                     break;
                    }
                 }
              }
           }
        }
     }
   lastTotalPositions=positionsTotal;
  }
  */

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
      Print(str);
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
  }

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
   balanceMaximoCuenta=MathMax(balanceMaximoCuenta,balanceActual);
   double maxProfit=balanceActual-balanceMaximoCuenta;
   int currentNum=0;
   int last=0;
   long entry;
   uint     total=HistoryDealsTotal();
   for(uint i=total;i>0;i--)
     { 
      if((ticket=HistoryDealGetTicket(i-1))>0)
        {
         symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
         entry =HistoryDealGetInteger(ticket,DEAL_ENTRY);
         if(symbol!=currentEstrategia.pair){continue;}
         if(entry==DEAL_ENTRY_IN)
           { 
            comment=HistoryDealGetString(ticket,DEAL_COMMENT);
            inPositionId=HistoryDealGetInteger(ticket,DEAL_POSITION_ID);
            if((comment!=NULL) && (comment!=(currentEstrategia.Index+"-"+currentEstrategia.EstrategiaId))){continue;}
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
   double minLot=SymbolInfoDouble(currentEstrategia.pair,SYMBOL_VOLUME_MIN);
   double maxLot=SymbolInfoDouble(currentEstrategia.pair, SYMBOL_VOLUME_MAX);

   if(currentProfit<0)
     {
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

void printOpenEvaluation(Difference *difference,Estrategy *currentEstrategia, ENUM_ORDER_TYPE tipoOperacion)
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

void printCloseEvaluation(Difference *difference,Estrategy *currentEstrategia, ENUM_ORDER_TYPE tipoOperacion)
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

void printCloseSellEvaluation2(Difference *difference,Estrategy *currentEstrategia,double pipsComparer)
  {
   customPrint("printCloseSellEvaluation");
   if(!(currentEstrategia.open==true))
     {
      customPrint("((sellActiveOperation[index] == false) FAILED");
        }else if(!(currentEstrategia.orderType==ORDER_TYPE_SELL)) {
      customPrint("(currentEstrategia.orderType==ORDER_TYPE_SELL) FAILED");
        }else {
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
         customPrint("(difference.macdDiff >= currentEstrategia.indicadorMacd.closeLower) FAILED: difference.macdDiff="+DoubleToString(difference.macdDiff)+",currentEstrategia.indicadorMacd.closeLower="+DoubleToString(currentEstrategia.indicadorMacd.closeLower));
        }
      if(!(difference.macdDiff<=currentEstrategia.indicadorMacd.closeHigher))
        {
         customPrint("(difference.macdDiff <= currentEstrategia.indicadorMacd.closeHigher) FAILED: difference.macdDiff="+DoubleToString(difference.macdDiff)+",currentEstrategia.indicadorMacd.closeHigher="+DoubleToString(currentEstrategia.indicadorMacd.closeHigher));
        }
      if(!(difference.maCompareDiff>=currentEstrategia.indicadorMaCompare.closeLower))
        {
         customPrint("(difference.maCompareDiff >= currentEstrategia.indicadorMaCompare.closeLower) FAILED: difference.maCompareDiff="+DoubleToString(difference.maCompareDiff)+",currentEstrategia.indicadorMaCompare.closeLower="+DoubleToString(currentEstrategia.indicadorMaCompare.closeLower));
        }
      if(!(difference.maCompareDiff<=currentEstrategia.indicadorMaCompare.closeHigher))
        {
         customPrint("(difference.maCompareDiff <= currentEstrategia.indicadorMaCompare.closeLower) FAILED: difference.maCompareDiff="+DoubleToString(difference.maCompareDiff)+",currentEstrategia.indicadorMaCompare.closeHigher="+DoubleToString(currentEstrategia.indicadorMaCompare.closeHigher));
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
         customPrint("(difference.momentumDiff <= currentEstrategia.indicadorMomentum.closeLower) FAILED: difference.momentumDiff="+DoubleToString(difference.momentumDiff)+",currentEstrategia.indicadorMomentum.closeLower="+DoubleToString(currentEstrategia.indicadorMomentum.closeLower));
           }  if(!(difference.momentumDiff<=currentEstrategia.indicadorMomentum.closeHigher)) {
         customPrint("(difference.momentumDiff <= currentEstrategia.indicadorMomentum.closeHigher) FAILED: difference.momentumDiff="+DoubleToString(difference.momentumDiff)+",currentEstrategia.indicadorMomentum.closeHigher="+DoubleToString(currentEstrategia.indicadorMomentum.closeHigher));
        }

      if(!(difference.ichiTrendDiff>=currentEstrategia.indicadorIchiTrend.closeLower))
        {
         customPrint("(difference.ichiTrendDiff >= currentEstrategia.indicadorIchiTrend.closeLower) FAILED: difference.ichiTrendDiff="+DoubleToString(difference.ichiTrendDiff)+",currentEstrategia.indicadorIchiTrend.closeLowe="+DoubleToString(currentEstrategia.indicadorIchiTrend.closeLower));
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
      if(!(difference.maCompare1200Diff>=currentEstrategia.indicadorMaCompare1200.closeLower))
        {
         customPrint("(difference.maCompare1200Diff >= currentEstrategia.indicadorMaCompare1200.closeLower) FAILED: difference.maCompare1200Diff="+DoubleToString(difference.maCompare1200Diff)+",currentEstrategia.indicadorMaCompare1200.closeLower="+DoubleToString(currentEstrategia.indicadorMaCompare1200.closeLower));
        }
      if(!(difference.maCompare1200Diff<=currentEstrategia.indicadorMaCompare1200.closeHigher))
        {
         customPrint("(difference.maCompare1200Diff <= currentEstrategia.indicadorMaCompare1200.closeLower) FAILED: difference.maCompare1200Diff="+DoubleToString(difference.maCompare1200Diff)+",currentEstrategia.indicadorMaCompare1200.closeHigher="+DoubleToString(currentEstrategia.indicadorMaCompare1200.closeHigher));
        }        
        
     }
   customPrint("printCloseSellEvaluation END");
  }
