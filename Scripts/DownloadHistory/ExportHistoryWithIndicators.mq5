//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2010, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
/*
   Export Indicator Values
*/
#property description "This Script Export History Values to CSV File."
#property copyright "RROJASQ"
#property version   "1.00"

#property script_show_inputs

input string  compare="EURUSD";
input string  fechaInicio="2017.02.07 00:05";
input string  fechaFin=NULL;
input string  fechaCorte="2018.01.01 00:00";
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+

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
//|                                                                  |
//+------------------------------------------------------------------+
void  OnStart()
  {
   int bars=Bars(_Symbol,PERIOD_CURRENT);
   int to_copy=bars;

   int maHandle=iMA(_Symbol,_Period,60,0,MODE_SMA,PRICE_WEIGHTED);
   SetIndexBuffer(0,maBuffer,INDICATOR_DATA);
   CopyBuffer(maHandle,0,0,to_copy,maBuffer);
   ArraySetAsSeries(maBuffer,true);

   int maCompareHandle=iMA(compare,_Period,60,0,MODE_SMA,PRICE_WEIGHTED);
   SetIndexBuffer(0,maCompareBuffer,INDICATOR_DATA);
   CopyBuffer(maCompareHandle,0,0,to_copy,maCompareBuffer);
   ArraySetAsSeries(maCompareBuffer,true);

   int macdHandle=iMACD(_Symbol,_Period,12,26,9,PRICE_WEIGHTED);
   SetIndexBuffer(0,macdMainBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,macdSignalBuffer,INDICATOR_DATA);
   CopyBuffer(macdHandle,0,0,to_copy,macdMainBuffer);
   CopyBuffer(macdHandle,1,0,to_copy,macdSignalBuffer);
   ArraySetAsSeries(macdMainBuffer,true);
   ArraySetAsSeries(macdSignalBuffer,true);

   int sarHandle=iSAR(_Symbol,_Period,0.02,0.2);
   SetIndexBuffer(0,sarBuffer,INDICATOR_DATA);
   CopyBuffer(sarHandle,0,0,to_copy,sarBuffer);
   ArraySetAsSeries(sarBuffer,true);

   int adxHandle=iADX(_Symbol,_Period,14);
   SetIndexBuffer(0,adxMainBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,adxPlusBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,adxMinusBuffer,INDICATOR_DATA);
   CopyBuffer(adxHandle,0,0,to_copy,adxMainBuffer);
   CopyBuffer(adxHandle,1,0,to_copy,adxPlusBuffer);
   CopyBuffer(adxHandle,2,0,to_copy,adxMinusBuffer);
   ArraySetAsSeries(adxMainBuffer,true);
   ArraySetAsSeries(adxPlusBuffer,true);
   ArraySetAsSeries(adxMinusBuffer,true);

   int rsiHandle=iRSI(_Symbol,_Period,28,PRICE_WEIGHTED);
   SetIndexBuffer(0,rsiBuffer,INDICATOR_DATA);
   CopyBuffer(rsiHandle,0,0,to_copy,rsiBuffer);
   ArraySetAsSeries(rsiBuffer,true);
 
   int bandsHandle=iBands(_Symbol,_Period,20,2,2,PRICE_WEIGHTED);
   SetIndexBuffer(1,bandsUpperBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,bandsLowerBuffer,INDICATOR_DATA);
   CopyBuffer(bandsHandle,1,0,to_copy,bandsUpperBuffer);
   CopyBuffer(bandsHandle,2,0,to_copy,bandsLowerBuffer);
   ArraySetAsSeries(bandsUpperBuffer,true);
   ArraySetAsSeries(bandsLowerBuffer,true);

   int momentumHandle=iMomentum(_Symbol,_Period,28,PRICE_WEIGHTED);
   SetIndexBuffer(0,momentumBuffer,INDICATOR_DATA);
   CopyBuffer(momentumHandle,0,0,to_copy,momentumBuffer);
   ArraySetAsSeries(momentumBuffer,true);
   
   int ichiHandle=iIchimoku(_Symbol,_Period,9,26,52);
   SetIndexBuffer(0,ichiTenkanSenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ichiKijunSenBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ichiSenkouSpanABuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ichiSenkouSpanBBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,ichiChinkouSpanBuffer,INDICATOR_DATA);
   CopyBuffer(ichiHandle,0,0,to_copy,ichiTenkanSenBuffer);
   CopyBuffer(ichiHandle,1,0,to_copy,ichiKijunSenBuffer);
   CopyBuffer(ichiHandle,2,0,to_copy,ichiSenkouSpanABuffer);
   CopyBuffer(ichiHandle,3,0,to_copy,ichiSenkouSpanBBuffer);
   CopyBuffer(ichiHandle,4,0,to_copy,ichiChinkouSpanBuffer);
   ArraySetAsSeries(ichiTenkanSenBuffer,true);
   ArraySetAsSeries(ichiKijunSenBuffer,true);
   ArraySetAsSeries(ichiSenkouSpanABuffer,true);
   ArraySetAsSeries(ichiSenkouSpanBBuffer,true);
   ArraySetAsSeries(ichiChinkouSpanBuffer,true);

   int ma1200Handle=iMA(_Symbol,_Period,1200,0,MODE_SMA,PRICE_WEIGHTED);
   SetIndexBuffer(0,ma1200Buffer,INDICATOR_DATA);
   CopyBuffer(ma1200Handle,0,0,to_copy,ma1200Buffer);
   ArraySetAsSeries(ma1200Buffer,true);

   int macd20xHandle=iMACD(_Symbol,_Period,240,529,180,PRICE_WEIGHTED);
   SetIndexBuffer(0,macd20xMainBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,macd20xSignalBuffer,INDICATOR_DATA);
   CopyBuffer(macd20xHandle,0,0,to_copy,macd20xMainBuffer);
   CopyBuffer(macd20xHandle,1,0,to_copy,macd20xSignalBuffer);
   ArraySetAsSeries(macd20xMainBuffer,true);
   ArraySetAsSeries(macd20xSignalBuffer,true);

   int maCompare1200Handle=iMA(compare,_Period,1200,0,MODE_SMA,PRICE_WEIGHTED);
   SetIndexBuffer(0,maCompare1200Buffer,INDICATOR_DATA);
   CopyBuffer(maCompare1200Handle,0,0,to_copy,maCompare1200Buffer);
   ArraySetAsSeries(maCompare1200Buffer,true);

   //---------------
   
   int sar1200Handle=iSAR(_Symbol,_Period,24,240);
   SetIndexBuffer(0,sar1200Buffer,INDICATOR_DATA);
   CopyBuffer(sar1200Handle,0,0,to_copy,sar1200Buffer);
   ArraySetAsSeries(sar1200Buffer,true);

   int adx168Handle=iADX(_Symbol,_Period,168);
   SetIndexBuffer(0,adxMain168Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,adxPlus168Buffer,INDICATOR_DATA);
   SetIndexBuffer(2,adxMinus168Buffer,INDICATOR_DATA);
   CopyBuffer(adx168Handle,0,0,to_copy,adxMain168Buffer);
   CopyBuffer(adx168Handle,1,0,to_copy,adxPlus168Buffer);
   CopyBuffer(adx168Handle,2,0,to_copy,adxMinus168Buffer);
   ArraySetAsSeries(adxMain168Buffer,true);
   ArraySetAsSeries(adxPlus168Buffer,true);
   ArraySetAsSeries(adxMinus168Buffer,true);

   int rsi84Handle=iRSI(_Symbol,_Period,84,PRICE_WEIGHTED);
   SetIndexBuffer(0,rsi84Buffer,INDICATOR_DATA);
   CopyBuffer(rsi84Handle,0,0,to_copy,rsi84Buffer);
   ArraySetAsSeries(rsi84Buffer,true);

   int bands240Handle=iBands(_Symbol,_Period,240,24,24,PRICE_WEIGHTED);
   SetIndexBuffer(1,bandsUpper240Buffer,INDICATOR_DATA);
   SetIndexBuffer(2,bandsLower240Buffer,INDICATOR_DATA);
   CopyBuffer(bands240Handle,1,0,to_copy,bandsUpper240Buffer);
   CopyBuffer(bands240Handle,2,0,to_copy,bandsLower240Buffer);
   ArraySetAsSeries(bandsUpper240Buffer,true);
   ArraySetAsSeries(bandsLower240Buffer,true);

   int momentum1200Handle=iMomentum(_Symbol,_Period,16800,PRICE_WEIGHTED);
   SetIndexBuffer(0,momentum1200Buffer,INDICATOR_DATA);
   CopyBuffer(momentum1200Handle,0,0,to_copy,momentum1200Buffer);
   ArraySetAsSeries(momentum1200Buffer,true);
   
   int ichi6Handle=iIchimoku(_Symbol,_Period,54,156,312);
   SetIndexBuffer(0,ichiTenkanSen6Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,ichiKijunSen6Buffer,INDICATOR_DATA);
   SetIndexBuffer(2,ichiSenkouSpanA6Buffer,INDICATOR_DATA);
   SetIndexBuffer(3,ichiSenkouSpanB6Buffer,INDICATOR_DATA);
   SetIndexBuffer(4,ichiChinkouSpan6Buffer,INDICATOR_DATA);
   CopyBuffer(ichi6Handle,0,0,to_copy,ichiTenkanSen6Buffer);
   CopyBuffer(ichi6Handle,1,0,to_copy,ichiKijunSen6Buffer);
   CopyBuffer(ichi6Handle,2,0,to_copy,ichiSenkouSpanA6Buffer);
   CopyBuffer(ichi6Handle,3,0,to_copy,ichiSenkouSpanB6Buffer);
   CopyBuffer(ichi6Handle,4,0,to_copy,ichiChinkouSpan6Buffer);
   ArraySetAsSeries(ichiTenkanSen6Buffer,true);
   ArraySetAsSeries(ichiKijunSen6Buffer,true);
   ArraySetAsSeries(ichiSenkouSpanA6Buffer,true);
   ArraySetAsSeries(ichiSenkouSpanB6Buffer,true);
   ArraySetAsSeries(ichiChinkouSpan6Buffer,true);
   
   outHistory();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void outHistory()
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

   datetime currentTime = TimeCurrent();
   datetime fechaFinProceso = NULL;   
   if ((fechaFin == NULL) || (fechaFin > currentTime)) {
      fechaFinProceso = currentTime;
   } else {
      fechaFinProceso = StringToTime(fechaFin);
   }
   
   Comment("Copying ... Please wait... ");
   int MaxBar=Bars(_Symbol,PERIOD_CURRENT, StringToTime(fechaInicio), fechaFinProceso);
   //int iCurrent=CopyRates(_Symbol,_Period,0,MaxBar,rates_array);
   int iCurrent=CopyRates(_Symbol,_Period,StringToTime(fechaInicio),fechaFinProceso,rates_array);
   int MaxBarCompare=Bars(compare,PERIOD_CURRENT, StringToTime(fechaInicio), fechaFinProceso);
   //int iCurrentCompare=CopyRates(compare,_Period,0,MaxBarCompare,rates_array_compare);
   int iCurrentCompare=CopyRates(compare,_Period,StringToTime(fechaInicio),fechaFinProceso,rates_array_compare);
   //int spreads=CopySpread(_Symbol,_Period,0,MaxBar,spread_int);
   int spreads=CopySpread(_Symbol,_Period,StringToTime(fechaInicio),fechaFinProceso,spread_int);
   Comment("Copied "+iCurrent+"... Please wait... ");
   
   int fileCounter=1;
   int fileSize1= 25000;
   int fileSize2=1440;
   string id=TimeToString(TimeCurrent());
   StringReplace(id," ","");
   StringReplace(id,".","");
   StringReplace(id,":","");
   int iCounter=iCurrent-1;
   int j=MaxBarCompare-1;
   for(int i=iCurrent-1; i>0; i--)
     {
      datetime date1=rates_array[i].time;
      if((date1>fechaFinProceso)) {
         break;
      }
      string strDate1=TimeToString(date1,TIME_DATE);
      StringReplace(strDate1,".","/");
      string strTime1=TimeToString(date1,TIME_MINUTES);

      if((date1>=StringToTime(fechaInicio)))
        {
         if((iCounter==iCurrent-1)
            || ((((iCurrent-iCounter)%fileSize1)==0) && (date1<StringToTime(fechaCorte)))
            || ((((iCurrent-iCounter)%fileSize2)==0) && (date1>=StringToTime(fechaCorte)))
            )
           {
            if(fileHandle!=INVALID_HANDLE)
              {
               FileClose(fileHandle);
              }
            string fname=_Symbol+"-"+id+"-"+IntegerToString(fileCounter)+".csv";
            fileHandle=FileOpen(fname,FILE_WRITE|FILE_ANSI,",");
            if(fileHandle!=INVALID_HANDLE)
              {
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
            Comment("Operation FileOpen failed, error ",GetLastError());
           }
         iCounter--;
        }
     }
   FileClose(fileHandle);
   Comment("Exported Successfully");
  }
//+------------------------------------------------------------------+
//| Converting Timeframe ENUM to string                                   |
//+------------------------------------------------------------------+
string PeriodToStr(ENUM_TIMEFRAMES period,string &strPeriod)
  {
//---
   switch(period)
     {
      case PERIOD_MN1 : strPeriod="MN1"; break;
      case PERIOD_W1 :  strPeriod="W1";  break;
      case PERIOD_D1 :  strPeriod="D1";  break;
      case PERIOD_H1 :  strPeriod="H1";  break;
      case PERIOD_H2 :  strPeriod="H2";  break;
      case PERIOD_H3 :  strPeriod="H3";  break;
      case PERIOD_H4 :  strPeriod="H4";  break;
      case PERIOD_H6 :  strPeriod="H6";  break;
      case PERIOD_H8 :  strPeriod="H8";  break;
      case PERIOD_H12 : strPeriod="H12"; break;
      case PERIOD_M1 :  strPeriod="M1";  break;
      case PERIOD_M2 :  strPeriod="M2";  break;
      case PERIOD_M3 :  strPeriod="M3";  break;
      case PERIOD_M4 :  strPeriod="M4";  break;
      case PERIOD_M5 :  strPeriod="M5";  break;
      case PERIOD_M6 :  strPeriod="M6";  break;
      case PERIOD_M10 : strPeriod="M10"; break;
      case PERIOD_M12 : strPeriod="M12"; break;
      case PERIOD_M15 : strPeriod="M15"; break;
      case PERIOD_M20 : strPeriod="M20"; break;
      case PERIOD_M30 : strPeriod="M30"; break;
     }
//---
   return(strPeriod);
  }
//+------------------------------------------------------------------+
