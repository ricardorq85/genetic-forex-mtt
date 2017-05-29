//+------------------------------------------------------------------+
//|                                    ExportHistoryRefactorized.mq5 |
//|                                                      ricardorq85 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "ricardorq85"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property script_show_inputs

#include <Genetic\ExportHistory.mqh>

input string  compare="EURUSD";
input string  fechaInicio="2017.05.10 00:05";
input string  fechaFin=NULL;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//--      
   ExportHistory *exporter = new ExportHistory(compare, fechaInicio, fechaFin);
   exporter.startHistory();
   exporter.outHistory();
  }
//+------------------------------------------------------------------+
