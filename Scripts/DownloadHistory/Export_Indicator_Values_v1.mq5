/*
   Export Indicator Values
*/
#property description "This Script Export Indicators Values to CSV File.  (you can change the icustom function Parameters to change what indicator to export)"
#property copyright "NFTrader"
#property version   "1.00"

string    ExtFileName; // ="XXXXXX_PERIOD.CSV";

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+

void  OnStart()
  {
  
   MqlRates  rates_array[];
   string sSymbol=Symbol();
   string  sPeriod;
   PeriodToStr(Period(),sPeriod);

   Comment("Exporting ... Please wait... ");
// prepare file name, e.g: EURUSD1
   ExtFileName=sSymbol;
   StringConcatenate(ExtFileName,sSymbol,"_",sPeriod,".CSV");
   ArraySetAsSeries(rates_array,true);
   int MaxBar=TerminalInfoInteger(TERMINAL_MAXBARS);
  
   int iCurrent=CopyRates(sSymbol,Period(),0,MaxBar,rates_array);


    double IndicatorBuffer[];
    SetIndexBuffer(0,IndicatorBuffer,INDICATOR_DATA);

    int bars = Bars(sSymbol,PERIOD_CURRENT);
    int to_copy= bars;                           
    
   //------------------------------------------------------------------
    int rsiHandle = iCustom(sSymbol,PERIOD_CURRENT,"Examples\\RSI");       // Change here.
  //-------------------------------------------------------------------
 
    CopyBuffer(rsiHandle,0,0,to_copy,IndicatorBuffer);
    ArraySetAsSeries(IndicatorBuffer, true);

    int fileHandle = FileOpen(ExtFileName,FILE_WRITE|FILE_CSV);
       
   
      for(int i=iCurrent-1; i>0; i--)
      {

           string dateAndTime =  StringFormat("%s",TimeToString(rates_array[i].time,TIME_DATE));
           dateAndTime+=","+TimeToString(rates_array[i].time,TIME_MINUTES);
         
           FileWrite(fileHandle,dateAndTime,",",(NormalizeDouble(IndicatorBuffer[i],2)));
      
         
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
