//+------------------------------------------------------------------+
//|                                                ExportHistory.mqh |
//|                                                      ricardorq85 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "ricardorq85"
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ExportHistory
  {
private:
   string  compare;
   datetime  fechaInicio;
   datetime  fechaFin;
   datetime  fechaCorte;
   datetime fechaFinProceso;
   datetime fechaInicioIndicadores;

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
   
public:
                     ExportHistory(string paramCompare, string paramFechaInicio, string paramFechaFin);
                    ~ExportHistory();
                    void startHistory();
                    bool outHistory();
                    void release();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ExportHistory::ExportHistory(string paramCompare, string paramFechaInicio, string paramFechaFin)
  {
   compare=paramCompare;
   fechaInicio=StringToTime(paramFechaInicio);
   fechaFin=StringToTime(paramFechaFin);
   fechaCorte=TimeCurrent();
   datetime currentTime = TimeCurrent();
   fechaFinProceso = NULL;
   if ((fechaFin == NULL) || (paramFechaFin == "") || (fechaFin > currentTime)) {
      fechaFinProceso = currentTime;
      //fechaFinProceso = fechaInicio + (6* 30 * 24 * 60 * 60);
   } else {
      fechaFinProceso = fechaFin;
   }
   fechaInicioIndicadores = fechaInicio;
   //int secondsPrevious = (1 * 30 * 24 * 60 * 60);
   //fechaInicioIndicadores = fechaInicio - (secondsPrevious);     
   //Print("fechaInicioIndicadores: " + TimeToString(fechaInicioIndicadores));
  }
  
//Destructor
ExportHistory::~ExportHistory()
  {
   release();    
  }
  
void ExportHistory::release() {
   Print("Releasing...");
   IndicatorRelease(maHandle);
   IndicatorRelease(maCompareHandle);
   IndicatorRelease(macdHandle);
   IndicatorRelease(sarHandle);
   IndicatorRelease(adxHandle);
   IndicatorRelease(rsiHandle);
   IndicatorRelease(bandsHandle);
   IndicatorRelease(momentumHandle);
   IndicatorRelease(ichiHandle);
   IndicatorRelease(ma1200Handle);
   IndicatorRelease(macd20xHandle);
   IndicatorRelease(maCompare1200Handle);
   IndicatorRelease(sar1200Handle);
   IndicatorRelease(adx168Handle);
   IndicatorRelease(rsi84Handle);
   IndicatorRelease(bands240Handle);
   IndicatorRelease(momentum1200Handle);
   IndicatorRelease(ichi6Handle);
}
//+------------------------------------------------------------------+
void ExportHistory::startHistory()
  {     
   //int bars=Bars(_Symbol,PERIOD_CURRENT);
   //int to_copy=bars;

   maHandle=iMA(_Symbol,_Period,60,0,MODE_SMA,PRICE_WEIGHTED);
   SetIndexBuffer(0,maBuffer,INDICATOR_DATA);
   CopyBuffer(maHandle,0,fechaInicioIndicadores,fechaFinProceso,maBuffer);
   ArraySetAsSeries(maBuffer,true);
   Print ("maBuffer size=" + ArraySize(maBuffer));

   maCompareHandle=iMA(compare,_Period,60,0,MODE_SMA,PRICE_WEIGHTED);
   SetIndexBuffer(0,maCompareBuffer,INDICATOR_DATA);
   CopyBuffer(maCompareHandle,0,fechaInicioIndicadores, fechaFinProceso,maCompareBuffer);
   ArraySetAsSeries(maCompareBuffer,true);
   Print ("maCompareBuffer size=" + ArraySize(maCompareBuffer));

   macdHandle=iMACD(_Symbol,_Period,12,26,9,PRICE_WEIGHTED);
   SetIndexBuffer(0,macdMainBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,macdSignalBuffer,INDICATOR_DATA);
   CopyBuffer(macdHandle,0,fechaInicioIndicadores, fechaFinProceso,macdMainBuffer);
   CopyBuffer(macdHandle,1,fechaInicioIndicadores, fechaFinProceso,macdSignalBuffer);
   ArraySetAsSeries(macdMainBuffer,true);
   ArraySetAsSeries(macdSignalBuffer,true);

   sarHandle=iSAR(_Symbol,_Period,0.02,0.2);
   SetIndexBuffer(0,sarBuffer,INDICATOR_DATA);
   CopyBuffer(sarHandle,0,fechaInicioIndicadores, fechaFinProceso,sarBuffer);
   ArraySetAsSeries(sarBuffer,true);

   adxHandle=iADX(_Symbol,_Period,14);
   SetIndexBuffer(0,adxMainBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,adxPlusBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,adxMinusBuffer,INDICATOR_DATA);
   CopyBuffer(adxHandle,0,fechaInicioIndicadores, fechaFinProceso,adxMainBuffer);
   CopyBuffer(adxHandle,1,fechaInicioIndicadores, fechaFinProceso,adxPlusBuffer);
   CopyBuffer(adxHandle,2,fechaInicioIndicadores, fechaFinProceso,adxMinusBuffer);
   ArraySetAsSeries(adxMainBuffer,true);
   ArraySetAsSeries(adxPlusBuffer,true);
   ArraySetAsSeries(adxMinusBuffer,true);

   rsiHandle=iRSI(_Symbol,_Period,28,PRICE_WEIGHTED);
   SetIndexBuffer(0,rsiBuffer,INDICATOR_DATA);
   CopyBuffer(rsiHandle,0,fechaInicioIndicadores, fechaFinProceso,rsiBuffer);
   ArraySetAsSeries(rsiBuffer,true);
 
   bandsHandle=iBands(_Symbol,_Period,20,2,2,PRICE_WEIGHTED);
   SetIndexBuffer(1,bandsUpperBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,bandsLowerBuffer,INDICATOR_DATA);
   CopyBuffer(bandsHandle,1,fechaInicioIndicadores, fechaFinProceso,bandsUpperBuffer);
   CopyBuffer(bandsHandle,2,fechaInicioIndicadores, fechaFinProceso,bandsLowerBuffer);
   ArraySetAsSeries(bandsUpperBuffer,true);
   ArraySetAsSeries(bandsLowerBuffer,true);

   momentumHandle=iMomentum(_Symbol,_Period,28,PRICE_WEIGHTED);
   SetIndexBuffer(0,momentumBuffer,INDICATOR_DATA);
   CopyBuffer(momentumHandle,0,fechaInicioIndicadores, fechaFinProceso,momentumBuffer);
   ArraySetAsSeries(momentumBuffer,true);
   
   ichiHandle=iIchimoku(_Symbol,_Period,9,26,52);
   SetIndexBuffer(0,ichiTenkanSenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ichiKijunSenBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ichiSenkouSpanABuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ichiSenkouSpanBBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,ichiChinkouSpanBuffer,INDICATOR_DATA);
   CopyBuffer(ichiHandle,0,fechaInicioIndicadores, fechaFinProceso,ichiTenkanSenBuffer);
   CopyBuffer(ichiHandle,1,fechaInicioIndicadores, fechaFinProceso,ichiKijunSenBuffer);
   CopyBuffer(ichiHandle,2,fechaInicioIndicadores, fechaFinProceso,ichiSenkouSpanABuffer);
   CopyBuffer(ichiHandle,3,fechaInicioIndicadores, fechaFinProceso,ichiSenkouSpanBBuffer);
   CopyBuffer(ichiHandle,4,fechaInicioIndicadores, fechaFinProceso,ichiChinkouSpanBuffer);
   ArraySetAsSeries(ichiTenkanSenBuffer,true);
   ArraySetAsSeries(ichiKijunSenBuffer,true);
   ArraySetAsSeries(ichiSenkouSpanABuffer,true);
   ArraySetAsSeries(ichiSenkouSpanBBuffer,true);
   ArraySetAsSeries(ichiChinkouSpanBuffer,true);

   ma1200Handle=iMA(_Symbol,_Period,1200,0,MODE_SMA,PRICE_WEIGHTED);
   SetIndexBuffer(0,ma1200Buffer,INDICATOR_DATA);
   CopyBuffer(ma1200Handle,0,fechaInicioIndicadores, fechaFinProceso,ma1200Buffer);
   ArraySetAsSeries(ma1200Buffer,true);

   macd20xHandle=iMACD(_Symbol,_Period,240,529,180,PRICE_WEIGHTED);
   SetIndexBuffer(0,macd20xMainBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,macd20xSignalBuffer,INDICATOR_DATA);
   CopyBuffer(macd20xHandle,0,fechaInicioIndicadores, fechaFinProceso,macd20xMainBuffer);
   CopyBuffer(macd20xHandle,1,fechaInicioIndicadores, fechaFinProceso,macd20xSignalBuffer);
   ArraySetAsSeries(macd20xMainBuffer,true);
   ArraySetAsSeries(macd20xSignalBuffer,true);

   maCompare1200Handle=iMA(compare,_Period,1200,0,MODE_SMA,PRICE_WEIGHTED);
   SetIndexBuffer(0,maCompare1200Buffer,INDICATOR_DATA);
   CopyBuffer(maCompare1200Handle,0,fechaInicioIndicadores, fechaFinProceso,maCompare1200Buffer);
   ArraySetAsSeries(maCompare1200Buffer,true);

   sar1200Handle=iSAR(_Symbol,_Period,24,240);
   SetIndexBuffer(0,sar1200Buffer,INDICATOR_DATA);
   CopyBuffer(sar1200Handle,0,fechaInicioIndicadores, fechaFinProceso,sar1200Buffer);
   ArraySetAsSeries(sar1200Buffer,true);

   adx168Handle=iADX(_Symbol,_Period,168);
   SetIndexBuffer(0,adxMain168Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,adxPlus168Buffer,INDICATOR_DATA);
   SetIndexBuffer(2,adxMinus168Buffer,INDICATOR_DATA);
   CopyBuffer(adx168Handle,0,fechaInicioIndicadores, fechaFinProceso,adxMain168Buffer);
   CopyBuffer(adx168Handle,1,fechaInicioIndicadores, fechaFinProceso,adxPlus168Buffer);
   CopyBuffer(adx168Handle,2,fechaInicioIndicadores, fechaFinProceso,adxMinus168Buffer);
   ArraySetAsSeries(adxMain168Buffer,true);
   ArraySetAsSeries(adxPlus168Buffer,true);
   ArraySetAsSeries(adxMinus168Buffer,true);

   rsi84Handle=iRSI(_Symbol,_Period,84,PRICE_WEIGHTED);
   SetIndexBuffer(0,rsi84Buffer,INDICATOR_DATA);
   CopyBuffer(rsi84Handle,0,fechaInicioIndicadores, fechaFinProceso,rsi84Buffer);
   ArraySetAsSeries(rsi84Buffer,true);

   bands240Handle=iBands(_Symbol,_Period,240,24,24,PRICE_WEIGHTED);
   SetIndexBuffer(1,bandsUpper240Buffer,INDICATOR_DATA);
   SetIndexBuffer(2,bandsLower240Buffer,INDICATOR_DATA);
   CopyBuffer(bands240Handle,1,fechaInicioIndicadores, fechaFinProceso,bandsUpper240Buffer);
   CopyBuffer(bands240Handle,2,fechaInicioIndicadores, fechaFinProceso,bandsLower240Buffer);
   ArraySetAsSeries(bandsUpper240Buffer,true);
   ArraySetAsSeries(bandsLower240Buffer,true);

   momentum1200Handle=iMomentum(_Symbol,_Period,16800,PRICE_WEIGHTED);
   SetIndexBuffer(0,momentum1200Buffer,INDICATOR_DATA);
   CopyBuffer(momentum1200Handle,0,fechaInicioIndicadores, fechaFinProceso,momentum1200Buffer);
   ArraySetAsSeries(momentum1200Buffer,true);
   
   ichi6Handle=iIchimoku(_Symbol,_Period,54,156,312);
   SetIndexBuffer(0,ichiTenkanSen6Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,ichiKijunSen6Buffer,INDICATOR_DATA);
   SetIndexBuffer(2,ichiSenkouSpanA6Buffer,INDICATOR_DATA);
   SetIndexBuffer(3,ichiSenkouSpanB6Buffer,INDICATOR_DATA);
   SetIndexBuffer(4,ichiChinkouSpan6Buffer,INDICATOR_DATA);
   CopyBuffer(ichi6Handle,0,fechaInicioIndicadores, fechaFinProceso,ichiTenkanSen6Buffer);
   CopyBuffer(ichi6Handle,1,fechaInicioIndicadores, fechaFinProceso,ichiKijunSen6Buffer);
   CopyBuffer(ichi6Handle,2,fechaInicioIndicadores, fechaFinProceso,ichiSenkouSpanA6Buffer);
   CopyBuffer(ichi6Handle,3,fechaInicioIndicadores, fechaFinProceso,ichiSenkouSpanB6Buffer);
   CopyBuffer(ichi6Handle,4,fechaInicioIndicadores, fechaFinProceso,ichiChinkouSpan6Buffer);
   ArraySetAsSeries(ichiTenkanSen6Buffer,true);
   ArraySetAsSeries(ichiKijunSen6Buffer,true);
   ArraySetAsSeries(ichiSenkouSpanA6Buffer,true);
   ArraySetAsSeries(ichiSenkouSpanB6Buffer,true);
   ArraySetAsSeries(ichiChinkouSpan6Buffer,true);
  }
  
bool ExportHistory::outHistory()
  {
   int fileHandle=-1;
   MqlRates  rates_array[];
   MqlRates  rates_array_compare[];
   int spread_int[];

//   string  sPeriod;
//   PeriodToStr(_Period,sPeriod);

   Comment("Exporting ... Please wait... ");
   ArraySetAsSeries(rates_array,true);
   ArraySetAsSeries(rates_array_compare,true);
   ArraySetAsSeries(spread_int,true);

   Comment("Copying ... Please wait... ");   
   int iCurrent=CopyRates(_Symbol,_Period,fechaInicioIndicadores,fechaFinProceso,rates_array);
   ResetLastError();
   int iCurrentCompare=CopyRates(compare,_Period,fechaInicioIndicadores,fechaFinProceso,rates_array_compare);
   if (iCurrentCompare < 0) {      
      Print("No se puede realizar la exportación. iCurrentCompare error=" + GetLastError());
      return false;
   }
   if (ArraySize(maCompareBuffer) == 0) {      
      Print("No se puede realizar la exportación. ArraySize(maCompareBuffer)=" + ArraySize(maCompareBuffer));
      return false;
   }
   
   int spreads=CopySpread(_Symbol,_Period,fechaInicioIndicadores,fechaFinProceso,spread_int);
   Comment("Copied "+IntegerToString(iCurrent)+"... Please wait... ");
   Print("Copied "+IntegerToString(iCurrent)+"... Please wait... ");
   
   int fileCounter=1;
   int fileSize1= 25000;
   int fileSize2=1440;
   string id=TimeToString(TimeCurrent());
   StringReplace(id," ","");
   StringReplace(id,".","");
   StringReplace(id,":","");
   int iCounter=iCurrent-1;
   int j=iCurrentCompare-1;
   for(int i=iCurrent-1; i>=0; i--)
     {
      datetime date1=rates_array[i].time;
      if((date1>fechaFinProceso)) {
         break;
      }
      string strDate1=TimeToString(date1,TIME_DATE);
      StringReplace(strDate1,".","/");
      string strTime1=TimeToString(date1,TIME_MINUTES);
      if((date1>=fechaInicio))
        {
         if((iCounter==iCurrent-1)
            || ((((iCurrent-iCounter)%fileSize1)==0) && (date1<(fechaCorte)))
            || ((((iCurrent-iCounter)%fileSize2)==0) && (date1>=(fechaCorte)))
            ) {
            if(fileHandle!=INVALID_HANDLE) {
               FileClose(fileHandle);
            } 
            string fname="export\\exported\\" + _Symbol+"-"+id+"-"+IntegerToString(fileCounter)+".csv";
            //Print("File name=" + fname);
            ResetLastError();
            fileHandle=FileOpen(fname,FILE_WRITE|FILE_ANSI|FILE_COMMON,",");
            //Print("FileHandle open=" + IntegerToString(fileHandle));
            if(fileHandle!=INVALID_HANDLE)
              { 
               Print("Writing Headers...");
               FileWrite(fileHandle,"iCounter,Moneda,Periodo,MonedaComparacion,Date,Time,Open,Low,High,Close,Volume,Spread,Average(60),MACD Value, MACD Signal, close "+compare+
                         ", Average(60) "+compare+
                         ", SAR(0.02;0.2), ADX Value, ADX Plus, ADX Minus, RSI(28)"+
                         ", Bollinger Upper(20;2), Bollinger Lower(20;2)"+
                         ", Momentum(28), IchimokuTenkanSen, IchimokuKijunSen, IchimokuSenkouSpanA, IchimokuSenkpuSpanB, IchimokuChinkouSpan"+
                         ", Ma1200, MACD20x Value, MACD20x Signal, Average(1200) "+compare+
                         ", SAR(24;240), ADX168 Value, ADX168 Plus, ADX168 Minus, RSI(84)"+
                         ", Bollinger Upper(240;24;24), Bollinger Lower(240;24;24)"+
                         ", Momentum(1200x), IchimokuTenkanSen6x, IchimokuKijunSen6x, IchimokuSenkouSpanA6x, IchimokuSenkpuSpanB6x, IchimokuChinkouSpan6x"
                         );
               fileCounter++;                  
                 }else {
               //+------------------------------------------------------------------+
               //|                                                                  |
               //+------------------------------------------------------------------+
               Comment("Operation FileOpen failed, error "+fname,GetLastError());
               Print("Error code "+IntegerToString(GetLastError()));
              }
           }

         if(fileHandle!=INVALID_HANDLE)
           {
            long spread=spread_int[i];
            if(spread<10)
              {
               spread=SymbolInfoInteger(Symbol(),SYMBOL_SPREAD);
               //Comment("Spread ", spread);
              }
            double closeCompare=0.0;
            double maCompare=0.0;
            double maCompare1200=0.0;
            //Print("Writing data...");
            for(; j>=0; j--)
              {
               if(rates_array[i].time<rates_array_compare[j].time)
                 {
                  break;
                    }else if(rates_array[i].time==rates_array_compare[j].time) {
                  closeCompare=rates_array_compare[j].close;
                  maCompare=maCompareBuffer[j];
                  maCompare1200=maCompare1200Buffer[j];
                 }
              }
            ResetLastError();
            FileWrite(fileHandle,iCurrent-iCounter,_Symbol,_Period,compare,strDate1,strTime1,rates_array[i].open,rates_array[i].low,rates_array[i].high,rates_array[i].close,rates_array[i].tick_volume,
                      spread,
                      (i<ArraySize(maBuffer))?(NormalizeDouble(maBuffer[i],_Digits)) : 0,
                      (i<ArraySize(macdMainBuffer))?(NormalizeDouble(macdMainBuffer[i],_Digits)) : 0,
                      (i<ArraySize(macdSignalBuffer))?(NormalizeDouble(macdSignalBuffer[i],_Digits)) : 0,
                      closeCompare,
                      maCompare,
                      (i<ArraySize(sarBuffer))?(NormalizeDouble(sarBuffer[i],_Digits)) : 0,
                      (i < ArraySize(adxMainBuffer))? (NormalizeDouble(adxMainBuffer[i],_Digits)) : 0,
                      (i < ArraySize(adxPlusBuffer))? (NormalizeDouble(adxPlusBuffer[i],_Digits)) : 0,
                      (i<ArraySize(adxMinusBuffer))?(NormalizeDouble(adxMinusBuffer[i],_Digits)) : 0,
                      (i<ArraySize(rsiBuffer))?(NormalizeDouble(rsiBuffer[i],_Digits)) : 0,
                      (i < ArraySize(bandsUpperBuffer))? (NormalizeDouble(bandsUpperBuffer[i],_Digits)) : 0,
                      (i < ArraySize(bandsLowerBuffer))? (NormalizeDouble(bandsLowerBuffer[i],_Digits)) : 0,
                      (i<ArraySize(momentumBuffer))?(NormalizeDouble(momentumBuffer[i],_Digits)) : 0,                      
                      (i<ArraySize(ichiTenkanSenBuffer))?(NormalizeDouble(ichiTenkanSenBuffer[i],_Digits)) : 0,
                      (i<ArraySize(ichiKijunSenBuffer))?(NormalizeDouble(ichiKijunSenBuffer[i],_Digits)) : 0,
                      (i<ArraySize(ichiSenkouSpanABuffer))?(NormalizeDouble(ichiSenkouSpanABuffer[i],_Digits)) : 0,
                      (i<ArraySize(ichiSenkouSpanBBuffer))?(NormalizeDouble(ichiSenkouSpanBBuffer[i],_Digits)) : 0,
                      (i<ArraySize(ichiChinkouSpanBuffer))?(NormalizeDouble(ichiChinkouSpanBuffer[i],_Digits)) : 0,
                      (i<ArraySize(ma1200Buffer))?(NormalizeDouble(ma1200Buffer[i],_Digits)) : 0,
                      (i<ArraySize(macd20xMainBuffer))?(NormalizeDouble(macd20xMainBuffer[i],_Digits)) : 0,
                      (i<ArraySize(macd20xSignalBuffer))?(NormalizeDouble(macd20xSignalBuffer[i],_Digits)) : 0,
                      maCompare1200,
                      (i<ArraySize(sar1200Buffer))?(NormalizeDouble(sar1200Buffer[i],_Digits)) : 0,
                      (i < ArraySize(adxMain168Buffer))? (NormalizeDouble(adxMain168Buffer[i],_Digits)) : 0,
                      (i < ArraySize(adxPlus168Buffer))? (NormalizeDouble(adxPlus168Buffer[i],_Digits)) : 0,
                      (i<ArraySize(adxMinus168Buffer))?(NormalizeDouble(adxMinus168Buffer[i],_Digits)) : 0,
                      (i<ArraySize(rsi84Buffer))?(NormalizeDouble(rsi84Buffer[i],_Digits)) : 0,
                      (i < ArraySize(bandsUpper240Buffer))? (NormalizeDouble(bandsUpper240Buffer[i],_Digits)) : 0,
                      (i < ArraySize(bandsLower240Buffer))? (NormalizeDouble(bandsLower240Buffer[i],_Digits)) : 0,
                      (i<ArraySize(momentum1200Buffer))?(NormalizeDouble(momentum1200Buffer[i],_Digits)) : 0,                      
                      (i<ArraySize(ichiTenkanSen6Buffer))?(NormalizeDouble(ichiTenkanSen6Buffer[i],_Digits)) : 0,
                      (i<ArraySize(ichiKijunSen6Buffer))?(NormalizeDouble(ichiKijunSen6Buffer[i],_Digits)) : 0,
                      (i<ArraySize(ichiSenkouSpanA6Buffer))?(NormalizeDouble(ichiSenkouSpanA6Buffer[i],_Digits)) : 0,
                      (i<ArraySize(ichiSenkouSpanB6Buffer))?(NormalizeDouble(ichiSenkouSpanB6Buffer[i],_Digits)) : 0,
                      (i<ArraySize(ichiChinkouSpan6Buffer))?(NormalizeDouble(ichiChinkouSpan6Buffer[i],_Digits)) : 0
                      );
              }else {
            Comment("File handled failed, error ",GetLastError());
            Print("File handled failed, error ",GetLastError());
           }
         iCounter--;
        }
     }
     ResetLastError();
   FileClose(fileHandle);
   Print("GetLastError: ",GetLastError());
   ResetLastError();
   release();
   Print("GetLastError: ",GetLastError());
   Comment("Exported Successfully");
   Print("Exported Successfully");
   return true;
  }
