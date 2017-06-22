//+------------------------------------------------------------------+
//|                                            ExportHistoryLive.mq5 |
//|                                                      ricardorq85 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "ricardorq85"
#property link      "https://www.mql5.com"
#property version   "1.00"
input string   compare="EURUSD";

int indexLastCompleted = 1;
int to_copy = 1;
int indexBuffer = 0;

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
int spread_int[];

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
//------------------
double sar1200Buffer[];
double adxMain168Buffer[];
double adxPlus168Buffer[];
double adxMinus168Buffer[];
double rsi84Buffer[];
double bandsUpper240Buffer[];
double bandsLower240Buffer[];
double momentum1200Buffer[];
double ichiTenkanSen6Buffer[];
double ichiKijunSen6Buffer[];
double ichiSenkouSpanA6Buffer[];
double ichiSenkouSpanB6Buffer[];
double ichiChinkouSpan6Buffer[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetTimer(60);
   //Alert("Alert");
   string terminal_commondata_path=TerminalInfoString(TERMINAL_COMMONDATA_PATH); 
   Print("terminal_commondata_path:" + terminal_commondata_path);
   //MessageBox("mb");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {}

void OnTimer()  {
   processExport();   
  }

void processExport() {
   //loadBuffers();

   MqlDateTime fileDate;   
   TimeCurrent(fileDate);      
   string nameId="XXX"; //fileDate.year + fileDate.mon + fileDate.day + fileDate.hour;
   string fileName=_Symbol+"-"+nameId+".csv";
   
   ResetLastError();
   bool fileExists = FileIsExist(fileName, FILE_COMMON);
   int fileHandle=FileOpen(fileName,FILE_WRITE|FILE_ANSI|FILE_COMMON,",");
   Print("FileOpen error:" + GetLastError());
   Print("File handle:" + fileHandle);

   if (!fileExists) {
      FileWrite(fileHandle, getHeader());
      Print("NO exists, FileWrite error:" + GetLastError());
   }
   /*else {
      FileWrite(fileHandle, "RRQ");
   }
   
   //writeData(fileHandle);
   Print(" error:" + GetLastError());
   FileFlush(fileHandle);
   Print("FileWrite error:" + GetLastError());
   FileClose(fileHandle);
   Print("FileClose error:" + GetLastError());*/

}

void writeData(int currentFileHandle) {   
   long spread=spread_int[indexBuffer];
   if(spread<10) {
      spread=SymbolInfoInteger(Symbol(),SYMBOL_SPREAD);
   }
   
   datetime dataDate = rates_array[indexBuffer].time;
   string dataStringDate = TimeToString(dataDate,TIME_DATE);
   StringReplace(dataStringDate,".","/");
   string dataStringTime=TimeToString(dataDate,TIME_MINUTES);
   
   double closeCompare=0.0;
   double maCompare=0.0;
   double maCompare1200=0.0;
   if(rates_array[indexBuffer].time==rates_array_compare[indexBuffer].time) {
      closeCompare=rates_array_compare[indexBuffer].close;
      maCompare=maCompareBuffer[indexBuffer];
      maCompare1200=maCompare1200Buffer[indexBuffer];
   }
   
   Print("dataDates=" + dataDate);
   FileWrite(currentFileHandle,0,_Symbol,_Period,compare,dataStringDate,dataStringTime,
      rates_array[indexBuffer].open,rates_array[indexBuffer].low,rates_array[indexBuffer].high,
      rates_array[indexBuffer].close,rates_array[indexBuffer].tick_volume,spread,
      (indexBuffer<ArraySize(maBuffer))?(NormalizeDouble(maBuffer[indexBuffer],_Digits)) : 0,
      (indexBuffer<ArraySize(macdMainBuffer))?(NormalizeDouble(macdMainBuffer[indexBuffer],_Digits)) : 0,
      (indexBuffer<ArraySize(macdSignalBuffer))?(NormalizeDouble(macdSignalBuffer[indexBuffer],_Digits)) : 0,
      closeCompare,maCompare,
      (indexBuffer<ArraySize(sarBuffer))?(NormalizeDouble(sarBuffer[indexBuffer],_Digits)) : 0,
      (indexBuffer<ArraySize(adxMainBuffer))? (NormalizeDouble(adxMainBuffer[indexBuffer],_Digits)) : 0,
      (indexBuffer<ArraySize(adxPlusBuffer))? (NormalizeDouble(adxPlusBuffer[indexBuffer],_Digits)) : 0,
      (indexBuffer<ArraySize(adxMinusBuffer))?(NormalizeDouble(adxMinusBuffer[indexBuffer],_Digits)) : 0,
      (indexBuffer<ArraySize(rsiBuffer))?(NormalizeDouble(rsiBuffer[indexBuffer],_Digits)) : 0,
      (indexBuffer<ArraySize(bandsUpperBuffer))? (NormalizeDouble(bandsUpperBuffer[indexBuffer],_Digits)) : 0,
      (indexBuffer<ArraySize(bandsLowerBuffer))? (NormalizeDouble(bandsLowerBuffer[indexBuffer],_Digits)) : 0,
      (indexBuffer<ArraySize(momentumBuffer))?(NormalizeDouble(momentumBuffer[indexBuffer],_Digits)) : 0,                      
      (indexBuffer<ArraySize(ichiTenkanSenBuffer))?(NormalizeDouble(ichiTenkanSenBuffer[indexBuffer],_Digits)) : 0,
      (indexBuffer<ArraySize(ichiKijunSenBuffer))?(NormalizeDouble(ichiKijunSenBuffer[indexBuffer],_Digits)) : 0,
      (indexBuffer<ArraySize(ichiSenkouSpanABuffer))?(NormalizeDouble(ichiSenkouSpanABuffer[indexBuffer],_Digits)) : 0,
      (indexBuffer<ArraySize(ichiSenkouSpanBBuffer))?(NormalizeDouble(ichiSenkouSpanBBuffer[indexBuffer],_Digits)) : 0,
      (indexBuffer<ArraySize(ichiChinkouSpanBuffer))?(NormalizeDouble(ichiChinkouSpanBuffer[indexBuffer],_Digits)) : 0,
      (indexBuffer<ArraySize(ma1200Buffer))?(NormalizeDouble(ma1200Buffer[indexBuffer],_Digits)) : 0,
      (indexBuffer<ArraySize(macd20xMainBuffer))?(NormalizeDouble(macd20xMainBuffer[indexBuffer],_Digits)) : 0,
      (indexBuffer<ArraySize(macd20xSignalBuffer))?(NormalizeDouble(macd20xSignalBuffer[indexBuffer],_Digits)) : 0,
      maCompare1200,
      (indexBuffer<ArraySize(sar1200Buffer))?(NormalizeDouble(sar1200Buffer[indexBuffer],_Digits)) : 0,
      (indexBuffer<ArraySize(adxMain168Buffer))? (NormalizeDouble(adxMain168Buffer[indexBuffer],_Digits)) : 0,
      (indexBuffer<ArraySize(adxPlus168Buffer))? (NormalizeDouble(adxPlus168Buffer[indexBuffer],_Digits)) : 0,
      (indexBuffer<ArraySize(adxMinus168Buffer))?(NormalizeDouble(adxMinus168Buffer[indexBuffer],_Digits)) : 0,
      (indexBuffer<ArraySize(rsi84Buffer))?(NormalizeDouble(rsi84Buffer[indexBuffer],_Digits)) : 0,
      (indexBuffer<ArraySize(bandsUpper240Buffer))? (NormalizeDouble(bandsUpper240Buffer[indexBuffer],_Digits)) : 0,
      (indexBuffer<ArraySize(bandsLower240Buffer))? (NormalizeDouble(bandsLower240Buffer[indexBuffer],_Digits)) : 0,
      (indexBuffer<ArraySize(momentum1200Buffer))?(NormalizeDouble(momentum1200Buffer[indexBuffer],_Digits)) : 0,                      
      (indexBuffer<ArraySize(ichiTenkanSen6Buffer))?(NormalizeDouble(ichiTenkanSen6Buffer[indexBuffer],_Digits)) : 0,
      (indexBuffer<ArraySize(ichiKijunSen6Buffer))?(NormalizeDouble(ichiKijunSen6Buffer[indexBuffer],_Digits)) : 0,
      (indexBuffer<ArraySize(ichiSenkouSpanA6Buffer))?(NormalizeDouble(ichiSenkouSpanA6Buffer[indexBuffer],_Digits)) : 0,
      (indexBuffer<ArraySize(ichiSenkouSpanB6Buffer))?(NormalizeDouble(ichiSenkouSpanB6Buffer[indexBuffer],_Digits)) : 0,
      (indexBuffer<ArraySize(ichiChinkouSpan6Buffer))?(NormalizeDouble(ichiChinkouSpan6Buffer[indexBuffer],_Digits)) : 0
      );   
   
}

string getHeader() {
 string header = "iCounter,Moneda,Periodo,MonedaComparacion,Date,Time,Open,Low,High,Close,Volume,Spread,Average(60),MACD Value, MACD Signal, close "+compare+
                         ", Average(60) "+compare+
                         ", SAR(0.02;0.2), ADX Value, ADX Plus, ADX Minus, RSI(28)"+
                         ", Bollinger Upper(20;2), Bollinger Lower(20;2)"+
                         ", Momentum(28), IchimokuTenkanSen, IchimokuKijunSen, IchimokuSenkouSpanA, IchimokuSenkpuSpanB, IchimokuChinkouSpan"+
                         ", Ma1200, MACD20x Value, MACD20x Signal, Average(1200) "+compare+
                         ", SAR(24;240), ADX168 Value, ADX168 Plus, ADX168 Minus, RSI(84)"+
                         ", Bollinger Upper(240;24;24), Bollinger Lower(240;24;24)"+
                         ", Momentum(1200x), IchimokuTenkanSen6x, IchimokuKijunSen6x, IchimokuSenkouSpanA6x, IchimokuSenkpuSpanB6x, IchimokuChinkouSpan6x";
   return header;
}

void loadBuffers() {
   CopyRates(_Symbol,_Period,indexLastCompleted,to_copy,rates_array);
   CopyRates(compare,_Period,indexLastCompleted,to_copy,rates_array_compare);
   CopySpread(_Symbol,_Period,indexLastCompleted,to_copy,spread_int);
   
   CopyBuffer(maHandle,0,indexLastCompleted, to_copy,maBuffer);
   CopyBuffer(maCompareHandle,0,indexLastCompleted, to_copy,maCompareBuffer);
   CopyBuffer(macdHandle,0,indexLastCompleted, to_copy,macdMainBuffer);
   CopyBuffer(macdHandle,1,indexLastCompleted, to_copy,macdSignalBuffer);
   CopyBuffer(sarHandle,0,indexLastCompleted, to_copy,sarBuffer);
   CopyBuffer(adxHandle,0,indexLastCompleted, to_copy,adxMainBuffer);
   CopyBuffer(adxHandle,1,indexLastCompleted, to_copy,adxPlusBuffer);
   CopyBuffer(adxHandle,2,indexLastCompleted, to_copy,adxMinusBuffer);
   CopyBuffer(rsiHandle,0,indexLastCompleted, to_copy,rsiBuffer);
   CopyBuffer(bandsHandle,1,indexLastCompleted, to_copy,bandsUpperBuffer);
   CopyBuffer(bandsHandle,2,indexLastCompleted, to_copy,bandsLowerBuffer);
   CopyBuffer(momentumHandle,0,indexLastCompleted, to_copy,momentumBuffer);
   CopyBuffer(ichiHandle,0,indexLastCompleted, 27,ichiTenkanSenBuffer);
   CopyBuffer(ichiHandle,1,indexLastCompleted, 27,ichiKijunSenBuffer);
   CopyBuffer(ichiHandle,2,indexLastCompleted, 27,ichiSenkouSpanABuffer);
   CopyBuffer(ichiHandle,3,indexLastCompleted, 27,ichiSenkouSpanBBuffer);
   CopyBuffer(ichiHandle,4,indexLastCompleted, 27,ichiChinkouSpanBuffer);
   CopyBuffer(ma1200Handle,0,indexLastCompleted, to_copy,ma1200Buffer);
   CopyBuffer(macd20xHandle,0,indexLastCompleted, to_copy,macd20xMainBuffer);
   CopyBuffer(macd20xHandle,1,indexLastCompleted, to_copy,macd20xSignalBuffer);
   CopyBuffer(maCompare1200Handle,0,indexLastCompleted, to_copy,maCompare1200Buffer);
   CopyBuffer(sar1200Handle,0,indexLastCompleted, to_copy,sar1200Buffer);
   CopyBuffer(adx168Handle,0,indexLastCompleted, to_copy,adxMain168Buffer);
   CopyBuffer(adx168Handle,1,indexLastCompleted, to_copy,adxPlus168Buffer);
   CopyBuffer(adx168Handle,2,indexLastCompleted, to_copy,adxMinus168Buffer);
   CopyBuffer(rsi84Handle,0,indexLastCompleted, to_copy,rsi84Buffer);
   CopyBuffer(bands240Handle,1,indexLastCompleted, to_copy,bandsUpper240Buffer);
   CopyBuffer(bands240Handle,2,indexLastCompleted, to_copy,bandsLower240Buffer);
   CopyBuffer(momentum1200Handle,0,indexLastCompleted, to_copy,momentum1200Buffer);
   CopyBuffer(ichi6Handle,0,indexLastCompleted, 157,ichiTenkanSen6Buffer);
   CopyBuffer(ichi6Handle,1,indexLastCompleted, 157,ichiKijunSen6Buffer);
   CopyBuffer(ichi6Handle,2,indexLastCompleted, 157,ichiSenkouSpanA6Buffer);
   CopyBuffer(ichi6Handle,3,indexLastCompleted, 157,ichiSenkouSpanB6Buffer);
   CopyBuffer(ichi6Handle,4,indexLastCompleted, 157,ichiChinkouSpan6Buffer);      
}

void loadHandles()
  {
   ArraySetAsSeries(rates_array,true);
   ArraySetAsSeries(rates_array_compare,true);
   ArraySetAsSeries(spread_int,true);

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