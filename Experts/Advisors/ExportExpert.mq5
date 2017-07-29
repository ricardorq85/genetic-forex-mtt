//+------------------------------------------------------------------+
//|                                                 ExportExpert.mq5 |
//|                                                      ricardorq85 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "ricardorq85"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Genetic\ExportHistory.mqh>
#include <Genetic\GeneticFileUtil.mqh>

GeneticProperty   properties[];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60*60*1);
   process();
      
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   process();
  }

void process() {
      string compare = "EURUSD";
      string fileName = "export\\Export.properties";      
      GeneticFileUtil *fileUtil = new GeneticFileUtil();
      fileUtil.loadProperties(fileName, properties);
      if (ArraySize(properties)>0) {
         string fechaInicio = properties[0].fechaInicio;
         string fechaFin = properties[0].fechaFin;
         datetime dt = TimeCurrent();
         if (dt>fechaInicio) {
            ExportHistory *exporter = new ExportHistory(compare, fechaInicio, fechaFin);
            Print("Starting history...");
            exporter.startHistory();
            Print("Outing history...");
            exporter.outHistory();
            Print("End history...");
            Print("Deleting properties file...");
            ResetLastError();
            fileUtil.deleteFile(fileName);
            Print("Deleting Error code "+IntegerToString(GetLastError()));
         }
         Print("End");
      }
      ArrayFree(properties);
  }
//+------------------------------------------------------------------+
