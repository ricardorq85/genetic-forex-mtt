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
#include <Genetic\GestionMonetariaXProfit.mqh>

//--- input parameters 
//input string   FileName="TendenciaGenetica.csv";
input string   FileName="estrategias\\live\\";
input bool   print=false;
input bool   generarEnTick=false;
input bool   live=true;
input bool   gestionMonetariaXLotes=false;

GestionMonetariaXProfit   *gestionMonetaria;
MqlRates  rates_array[];
datetime nextVigencia=NULL;
datetime fileLastReadTime=NULL;
int lastTotalPositions=0;
datetime activeTime = NULL;
int digitsIndicators=5;
bool open = false;
double initialBalance=0.0;
double balanceMaximoCuenta=0.0;
double diferenciaPuntosLimites = 0.01;

Tendencia      tendencias[];
int            indexLastOpen=0;
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
   EventSetTimer(5*60*1);
   
   Print("TERMINAL_PATH = ",TerminalInfoString(TERMINAL_PATH));
   Print("TERMINAL_DATA_PATH = ",TerminalInfoString(TERMINAL_DATA_PATH));
   Print("TERMINAL_COMMONDATA_PATH = ",TerminalInfoString(TERMINAL_COMMONDATA_PATH));
     
   gestionMonetaria=new GestionMonetariaXProfit();
   initialBalance=AccountInfoDouble(ACCOUNT_BALANCE);
   balanceMaximoCuenta=initialBalance;
   
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
void OnTimer() {
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
   activeTime = TimeCurrent();
   printManager.customPrint("last_tick.time = "+IntegerToString((long)last_tick.time));
   printManager.customPrint("Active time = "+activeTime);
   bool indexSet = false;
   for(int i=indexLastOpen; i<ArraySize(tendencias); i++) {
      if (!tendencias[i].isValidForOpen(activeTime)) {
         printManager.customPrint(tendencias[i].id + " is not valid for open");
         continue;
      }      
      bool wasOrdenGenerated = false;
      printManager.customPrint(tendencias[i].id);
      balanceMaximoCuenta=MathMax(balanceMaximoCuenta,AccountInfoDouble(ACCOUNT_BALANCE));
      IParaOperar paraOperar = dynamic_cast<IParaOperar *>(&tendencias[i]); 
      double loteParaOperar=tendencias[i].lote;
      loteParaOperar=gestionMonetaria.getLot(&paraOperar,balanceMaximoCuenta,false,gestionMonetariaXLotes);
      if (tendencias[i].tipoOperacion == ORDER_TYPE_BUY) {         
         if (generarEnTick) {
            if (last_tick.ask < tendencias[i].tp) {
               printManager.customPrint("BUY generarEnTick,last_tick.ask="+last_tick.ask);
               wasOrdenGenerated = trading.Buy(loteParaOperar, NULL, tendencias[i].precioCalculado, tendencias[i].sl, 
                  tendencias[i].tp, tendencias[i].id);
            }
         }
         double diffAsk = MathAbs(last_tick.ask - tendencias[i].precioCalculado);
         if (diffAsk > diferenciaPuntosLimites) {
            if (!indexSet) {
               indexLastOpen = i;
               indexSet = true;
            }
            continue;            
         }
         if (tendencias[i].precioCalculado == last_tick.ask) {
            if (!generarEnTick) {
               printManager.customPrint("BUY,tendencias[i].precioCalculado="+tendencias[i].precioCalculado);
               wasOrdenGenerated = trading.Buy(loteParaOperar, NULL, tendencias[i].precioCalculado, tendencias[i].sl, 
                  tendencias[i].tp, tendencias[i].id);
            }
         } else if (tendencias[i].precioCalculado < last_tick.ask) {
            printManager.customPrint("BUY LIMIT");
            wasOrdenGenerated = trading.BuyLimit(loteParaOperar, tendencias[i].precioCalculado, NULL, tendencias[i].sl, 
               tendencias[i].tp, ORDER_TIME_SPECIFIED, tendencias[i].VigenciaHigher, tendencias[i].id);
         } else {
            printManager.customPrint("BUY STOP");
            wasOrdenGenerated = trading.BuyStop(loteParaOperar, tendencias[i].precioCalculado, NULL, tendencias[i].sl, 
               tendencias[i].tp, ORDER_TIME_SPECIFIED, tendencias[i].VigenciaHigher, tendencias[i].id);
         }
      } else {
         double diffBid = MathAbs(last_tick.bid - tendencias[i].precioCalculado);
         if (diffBid > diferenciaPuntosLimites) {
            if (!indexSet) {
               indexLastOpen = i;
               indexSet = true;
            }
            continue;
         }
         if (generarEnTick) {
            if (last_tick.bid > tendencias[i].tp) {
               printManager.customPrint("SELL generarEnTick,last_tick.bid="+last_tick.bid);
               wasOrdenGenerated = trading.Sell(loteParaOperar, NULL, tendencias[i].precioCalculado, tendencias[i].sl, 
                     tendencias[i].tp, tendencias[i].id);
            }
         }      
         if (tendencias[i].tipoOperacion == ORDER_TYPE_SELL) {
            if (tendencias[i].precioCalculado == last_tick.bid) {
               if (!generarEnTick) {
                  printManager.customPrint("SELL");
                  wasOrdenGenerated = trading.Sell(loteParaOperar, NULL, tendencias[i].precioCalculado, tendencias[i].sl, 
                     tendencias[i].tp, tendencias[i].id);
               }
            } else if (tendencias[i].precioCalculado > last_tick.bid) {
               printManager.customPrint("SELL LIMIT. Precio calculado=" + tendencias[i].precioCalculado +
                  ";last_tick.bid=" + last_tick.bid);
               wasOrdenGenerated = trading.SellLimit(loteParaOperar, tendencias[i].precioCalculado, NULL, tendencias[i].sl, 
                  tendencias[i].tp, ORDER_TIME_SPECIFIED, tendencias[i].VigenciaHigher, tendencias[i].id);                 
            } else {
               printManager.customPrint("SELL STOP");
               wasOrdenGenerated = trading.SellStop(loteParaOperar, tendencias[i].precioCalculado, NULL, tendencias[i].sl, 
                  tendencias[i].tp, ORDER_TIME_SPECIFIED, tendencias[i].VigenciaHigher, tendencias[i].id);
            }
         }
      }
      Print("trading.ResultRetcode:" + trading.ResultRetcode());
      if ((trading.ResultRetcode()!=TRADE_RETCODE_PLACED) && (trading.ResultRetcode()!=TRADE_RETCODE_DONE)) {
         if (trading.ResultRetcode() == TRADE_RETCODE_LIMIT_ORDERS) {
            Print("<"+tendencias[i].id+">" + "Error. Numero limite de operaciones pendientes alcanzado:" + trading.ResultRetcode());
            break;
         } else if (trading.ResultRetcode() == TRADE_RETCODE_NO_MONEY) {
            Print("<"+tendencias[i].id+">" + "Error. No hay dinero suficiente:" + trading.ResultRetcode());
            break;
         }else {
            Print("<"+tendencias[i].id+">" + "ERROR EN LA EJECUCION DE LA ORDEN:" + trading.ResultRetcode());
         }
      }

      tendencias[i].open = wasOrdenGenerated;
      if (wasOrdenGenerated == true) {
         if (!indexSet) {
            indexLastOpen = i;
            indexSet = true;
         }
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

