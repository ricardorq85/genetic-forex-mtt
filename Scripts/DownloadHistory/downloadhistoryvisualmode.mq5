//+------------------------------------------------------------------+
//|                                    downloadhistoryvisualmode.mq5 |
//|                                                    2011, etrader |
//|                                             http://efftrading.ru |
//+------------------------------------------------------------------+
#property copyright "2011, etrader"
#property link      "http://efftrading.ru"
#property version   "1.00"
#property description "The script downloads historical data on the current symbol"
#property description " or for all symbols from Market Watch window"

#property script_show_inputs

#include <CDownLoadHistory.mqh> 

input ENUM_DOWNLOADHISTORYMODE DMode;  // history download mode
void OnStart()
{
  CDownLoadHistory downloader; 
  downloader.Create( (DMode==DOWNLOADHISTORYMODE_CURRENTSYMBOL)?Symbol():NULL, true );
  if( downloader.Execute( )<0)
  {
    Print("Error in loading of historical data: ", downloader.ErrorDescription( downloader.LastError() ));
    return;
  }
  Print("Download complete.");
}  

//+------------------------------------------------------------------+
