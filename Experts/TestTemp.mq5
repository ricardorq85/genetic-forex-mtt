//+------------------------------------------------------------------+
//|                                                     TestTemp.mq5 |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

     int to_copy=2;
     int shift=1;
int ichiHandle;
double ichiTenkanSenBuffer[];
double ichiKijunSenBuffer[];
double ichiSenkouSpanABuffer[];
double ichiSenkouSpanBBuffer[];
double ichiChinkouSpanBuffer[];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print("Inicio... ");
   loadHandles();
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   ichiHandle=iIchimoku(_Symbol,_Period,9,26,52);
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

   double ichiTenkanSen= NormalizeDouble(ichiTenkanSenBuffer[shift],_Digits);
   double ichiKijunSen = NormalizeDouble(ichiKijunSenBuffer[shift],_Digits);
   double ichiSpanA = NormalizeDouble(ichiSenkouSpanABuffer[shift],_Digits);
   double ichiSpanB = NormalizeDouble(ichiSenkouSpanBBuffer[shift],_Digits);
   double ichiChinkouSpan=NormalizeDouble(ichiChinkouSpanBuffer[shift],_Digits);   
   Print("ichiSpanA="+DoubleToString(ichiSpanA));
   Print("ichiSpanB="+DoubleToString(ichiSpanB));
   Print("ichiChinkouSpan="+DoubleToString(ichiChinkouSpan));
   
  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---
   
  }
//+------------------------------------------------------------------+
void loadHandles()
  {

  }
