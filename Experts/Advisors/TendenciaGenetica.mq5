//+------------------------------------------------------------------+
//|                                            TendenciaGenetica.mq5 |
//|                                                      ricardorq85 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "ricardorq85"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>
#include <Genetic\Vigencia.mqh>
#include <Genetic\PrintManager.mqh>
#include <Genetic\DateUtil.mqh>
#include <Genetic\Tendencia.mqh>
#include <Genetic\GeneticFileUtil.mqh>

//--- input parameters 
//input string   FileName="TendenciaGenetica.csv";
input string   FileName="estrategias\\live\\";
input bool   print=false;
input bool   generarEnTick=false;
input bool   live=true;

MqlRates  rates_array[];
datetime nextVigencia=NULL;
datetime fileLastReadTime=NULL;
int lastTotalPositions=0;
datetime activeTime = NULL;
int digitsIndicators=5;
bool open = false;

Tendencia      tendencias[];
int            indexLastOpen=-1;
CTrade     *trading;
CDateUtil *dateUtil;

PrintManager *printManager;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {   
   inicializar();
   process();
   return(INIT_SUCCEEDED);
  }
  

void inicializar()
  {
   Print("Inicio... ");
   //--- create timer
   EventSetTimer(60*60*1);
   
   Print("TERMINAL_PATH = ",TerminalInfoString(TERMINAL_PATH));
   Print("TERMINAL_DATA_PATH = ",TerminalInfoString(TERMINAL_DATA_PATH));
   Print("TERMINAL_COMMONDATA_PATH = ",TerminalInfoString(TERMINAL_COMMONDATA_PATH));
     
   trading=new CTrade();
   dateUtil = new CDateUtil();
   trading.SetExpertMagicNumber(1);     // magic
   //trading.SetDeviationInPoints
   printManager=new PrintManager(print);       
   initProcess();
  }
    
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  //--- destroy timer
   EventKillTimer();      
   if(trading!=NULL)
     {
      delete trading;
      trading=NULL;
     }
   Print("Fin... ");
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()   
  {
   process();
  }

void process() {  
   if (live) {
      initProcess();
   }
   putPendingOrders();
}

void initProcess() {
   ArrayFree(tendencias);
   GeneticFileUtil *fileUtil = new GeneticFileUtil();
   if (live) {
      fileUtil.loadAllTendencias(FileName, tendencias);
   } else {
      string fName = "estrategias\\" + FileName;
      fileUtil.loadTendencias(fName, tendencias);
   }
}

void putPendingOrders()
  {
   MqlTick last_tick;
   if(!SymbolInfoTick(Symbol(),last_tick)) {
      Print("SymbolInfoTick() failed, error = "+IntegerToString(GetLastError()));
      return;
   }
   printManager.customPrint("last_tick.time = "+IntegerToString((long)last_tick.time));

   activeTime = last_tick.time;
   for(int i=0; i<ArraySize(tendencias); i++) {
      if (!tendencias[i].isValidForOpen(activeTime)) {
         printManager.customPrint(tendencias[i].id + " is not valid for open");
         continue;
      }
      //if ((indexLastOpen>=0) && (tendencias[i].fechaTendencia == tendencias[indexLastOpen].fechaTendencia) 
       //  && (tendencias[i].precioCalculado == tendencias[indexLastOpen].precioCalculado) ) {
          //tendencias[i].active = false;
         //continue;
      //}
      bool ordenGenerada = false;
      printManager.customPrint(tendencias[i].id);
      if (tendencias[i].tipoOperacion == ORDER_TYPE_BUY) {
         if (generarEnTick) {
            if (last_tick.ask < tendencias[i].tp) {
               printManager.customPrint("BUY generarEnTick,last_tick.ask="+last_tick.ask);
               ordenGenerada = trading.Buy(tendencias[i].lote, NULL, tendencias[i].precioCalculado, tendencias[i].sl, 
                  tendencias[i].tp, tendencias[i].id);
            }
         }
         if (tendencias[i].precioCalculado == last_tick.ask) {
            if (!generarEnTick) {
               printManager.customPrint("BUY,tendencias[i].precioCalculado="+tendencias[i].precioCalculado);
               ordenGenerada = trading.Buy(tendencias[i].lote, NULL, tendencias[i].precioCalculado, tendencias[i].sl, 
                  tendencias[i].tp, tendencias[i].id);
            }
         } else if (tendencias[i].precioCalculado < last_tick.ask) {
            printManager.customPrint("BUY LIMIT");
            ordenGenerada = trading.BuyLimit(tendencias[i].lote, tendencias[i].precioCalculado, NULL, tendencias[i].sl, 
               tendencias[i].tp, ORDER_TIME_SPECIFIED, tendencias[i].VigenciaHigher, tendencias[i].id);
         } else {
            printManager.customPrint("BUY STOP");
            ordenGenerada = trading.BuyStop(tendencias[i].lote, tendencias[i].precioCalculado, NULL, tendencias[i].sl, 
               tendencias[i].tp, ORDER_TIME_SPECIFIED, tendencias[i].VigenciaHigher, tendencias[i].id);
         }
      } else {
         if (generarEnTick) {
            if (last_tick.bid > tendencias[i].tp) {
               printManager.customPrint("SELL generarEnTick,last_tick.bid="+last_tick.bid);
               ordenGenerada = trading.Sell(tendencias[i].lote, NULL, tendencias[i].precioCalculado, tendencias[i].sl, 
                     tendencias[i].tp, tendencias[i].id);
            }
         }      
         if (tendencias[i].tipoOperacion == ORDER_TYPE_SELL) {
            if (tendencias[i].precioCalculado == last_tick.bid) {
               if (!generarEnTick) {
                  printManager.customPrint("SELL");
                  ordenGenerada = trading.Sell(tendencias[i].lote, NULL, tendencias[i].precioCalculado, tendencias[i].sl, 
                     tendencias[i].tp, tendencias[i].id);
               }
            } else if (tendencias[i].precioCalculado > last_tick.bid) {
               printManager.customPrint("SELL LIMIT. Precio calculado=" + tendencias[i].precioCalculado +
                  ";last_tick.bid=" + last_tick.bid);
               ordenGenerada = trading.SellLimit(tendencias[i].lote, tendencias[i].precioCalculado, NULL, tendencias[i].sl, 
                  tendencias[i].tp, ORDER_TIME_SPECIFIED, tendencias[i].VigenciaHigher, tendencias[i].id);
            } else {
               printManager.customPrint("SELL STOP");
               ordenGenerada = trading.SellStop(tendencias[i].lote, tendencias[i].precioCalculado, NULL, tendencias[i].sl, 
                  tendencias[i].tp, ORDER_TIME_SPECIFIED, tendencias[i].VigenciaHigher, tendencias[i].id);
            }
         }
      }
      Print("trading.ResultRetcode:" + trading.ResultRetcode());
      if ((trading.ResultRetcode()!=TRADE_RETCODE_PLACED) && (trading.ResultRetcode()!=TRADE_RETCODE_DONE)) {
         Print("ERROR EN LA EJECUCION DE LA ORDEN:" + trading.ResultRetcode());
      }

      tendencias[i].open = ordenGenerada;
      if (tendencias[i].open = true) {
         indexLastOpen = i;
         //break;
      }
     }
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }

