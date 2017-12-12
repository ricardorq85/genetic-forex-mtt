//+------------------------------------------------------------------+
//|                                            TendenciaGeneticaCustom.mq5 |
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
#include <Indicators\Trend.mqh>

//--- input parameters 
//input string   FileName="TendenciaGenetica.csv";
input string   FileName="estrategias\\live\\";
input bool   print=false;
input bool   generarEnTick=false;
input bool   live=true;
input bool   incluirIndicadorCustom=false;
input bool   gestionMonetariaXLotes=false;
input double   porcentajeCambioRequeridoParaGestionMonetaria=0.5;
input double   balanceMinimoParaGestionMonetaria=2000;
input double diffPipsLimitesParaApertura = 50;
input int    cantidadMaximaOrdenesAbiertas = 100;
input double diffPipsPrecioLimiteCerrarPendiente = 50;

GestionMonetariaXProfit   *gestionMonetaria;
MqlRates  rates_array[];
int lastTotalPositions=0;
datetime activeTime = NULL;
int digitsIndicators=5;
bool open = false;
double initialBalance=0.0;
double balanceMaximoCuenta=0.0;
double diffLimiteParaApertura;
double diffPrecioLimiteParaCerrarPendiente;

Tendencia      tendencias[];
int            indexLastOpen=0;
CTrade     *trading;
CDateUtil *dateUtil;

PrintManager *printManager;

//Custom
   double H4TopBuffer[], M30TopBuffer[], M5TopBuffer[];
   double H4ExtMapBuffer[], M30ExtMapBuffer[], M5ExtMapBuffer[];
   double H4BottonBuffer[], M30BottonBuffer[], M5BottonBuffer[];
   int clinesH4Handle, clinesM30Handle, clinesM5Handle;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   inicializar();
   //process();
   return(INIT_SUCCEEDED);
  }
  
void inicializar()
  {
   Print("Inicio... ");
   //--- create timer   
   EventSetTimer(10*60*1);
   
   Print("TERMINAL_PATH = ",TerminalInfoString(TERMINAL_PATH));
   Print("TERMINAL_DATA_PATH = ",TerminalInfoString(TERMINAL_DATA_PATH));
   Print("TERMINAL_COMMONDATA_PATH = ",TerminalInfoString(TERMINAL_COMMONDATA_PATH));
   
   gestionMonetaria=new GestionMonetariaXProfit(porcentajeCambioRequeridoParaGestionMonetaria, balanceMinimoParaGestionMonetaria);
   initialBalance=AccountInfoDouble(ACCOUNT_BALANCE);
   balanceMaximoCuenta=initialBalance;
   diffLimiteParaApertura = (diffPipsLimitesParaApertura * _Point) * 10;
   diffPrecioLimiteParaCerrarPendiente = (diffPipsPrecioLimiteCerrarPendiente * _Point) * 10;
   
   trading=new CTrade();
   dateUtil = new CDateUtil();
   trading.SetExpertMagicNumber(1);     // magic
   //trading.SetDeviationInPoints
   printManager=new PrintManager(print);       
   initCustom();
   if (!live) {
      initProcess(); 
   }
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
   datetime ct = TimeCurrent();
   gestionMonetaria.borrarPendientesXCantidad(cantidadMaximaOrdenesAbiertas, diffPrecioLimiteParaCerrarPendiente);
   process();
  }
  
void initCustom() {
   if (!incluirIndicadorCustom) {
      return;
   }
   ArraySetAsSeries(H4TopBuffer,true);
   ArraySetAsSeries(M30TopBuffer,true);
   ArraySetAsSeries(M5TopBuffer,true);
   ArraySetAsSeries(H4ExtMapBuffer,true);
   ArraySetAsSeries(M30ExtMapBuffer,true);
   ArraySetAsSeries(M5ExtMapBuffer,true);
   ArraySetAsSeries(H4BottonBuffer,true);
   ArraySetAsSeries(M30BottonBuffer,true);
   ArraySetAsSeries(M5BottonBuffer,true);   
   
   clinesH4Handle = iCustom(_Symbol, PERIOD_H4, "dynamicrs_3clines.ex5");
   clinesM30Handle = iCustom(_Symbol, PERIOD_M30, "dynamicrs_3clines.ex5");
   clinesM5Handle = iCustom(_Symbol, PERIOD_M5, "dynamicrs_3clines.ex5");

   SetIndexBuffer(0,H4TopBuffer,INDICATOR_DATA);
   SetIndexBuffer(0,M30TopBuffer,INDICATOR_DATA);
   SetIndexBuffer(0,M5TopBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,H4ExtMapBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,M30ExtMapBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,M5ExtMapBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,H4BottonBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,M30BottonBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,M5BottonBuffer,INDICATOR_DATA);

}

void process() {     
   if (live) {
      initProcess();
   }
   putPendingOrders();
   saveActiveTendencias();
}

void saveActiveTendencias () {
   if (live) {
      datetime ct = TimeCurrent();
      GeneticFileUtil *fileUtil = new GeneticFileUtil();
      fileUtil.saveTendencias(FileName, tendencias);
   }
}

void initProcess() {
   open = false;
   indexLastOpen = 0;
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
   //printManager.customPrint("last_tick.time = "+IntegerToString((long)last_tick.time));
   //printManager.customPrint("Active time = "+activeTime);
   bool indexSet = false;   
   int operacionValidaCustomIndicators = cumpleCustomIndicators();
   if (operacionValidaCustomIndicators == -1) {
      printManager.customPrint("Indicador customizado NO valido: -1");
      return;
   }

   double loteParaOperar = gestionMonetaria.getLot(balanceMaximoCuenta,false,gestionMonetariaXLotes);
   gestionMonetaria.modificarPendientes(loteParaOperar);
   gestionMonetaria.setLoteActual(loteParaOperar);
   for(int i=indexLastOpen; i<ArraySize(tendencias); i++) {
      if (!tendencias[i].isValidForOpen(activeTime)) {
         //printManager.customPrint(tendencias[i].id + " is not valid for open");
         continue;
      }
      if ((incluirIndicadorCustom) && (operacionValidaCustomIndicators != tendencias[i].tipoOperacion)) {
         printManager.customPrint(tendencias[i].id + " no cumple custom indicator");
         continue;
      }

      bool wasOrdenGenerated = false;
      //printManager.customPrint(tendencias[i].id);
      balanceMaximoCuenta=MathMax(balanceMaximoCuenta,AccountInfoDouble(ACCOUNT_BALANCE));
      if (!gestionMonetariaXLotes) {
         loteParaOperar = tendencias[i].lote;      
      }      
      if (tendencias[i].tipoOperacion == ORDER_TYPE_BUY) {
         loteParaOperar = gestionMonetaria.calcularLoteXBalance(loteParaOperar, tendencias[i].pair, tendencias[i].precioCalculado, ORDER_TYPE_BUY);
         if (generarEnTick) {
            if (last_tick.ask < tendencias[i].tp) {               
               printManager.customPrint("BUY generarEnTick,last_tick.ask="+last_tick.ask);
               wasOrdenGenerated = trading.Buy(loteParaOperar, tendencias[i].pair, tendencias[i].precioCalculado, tendencias[i].sl, 
                  tendencias[i].tp, tendencias[i].id);
            }
         }
         double diffAsk = MathAbs(last_tick.ask - tendencias[i].precioCalculado);
         if (diffAsk > diffLimiteParaApertura) {
            printManager.customPrint(tendencias[i].id + " diferencia con el punto de apertura muy grande");
            if (!indexSet) {
               indexLastOpen = i;
               indexSet = true;
            }
            continue;
         }
         if (tendencias[i].precioCalculado == last_tick.ask) {
            if (!generarEnTick) {
               printManager.customPrint("BUY,tendencias[i].precioCalculado="+tendencias[i].precioCalculado);
               wasOrdenGenerated = trading.Buy(loteParaOperar, tendencias[i].pair, tendencias[i].precioCalculado, tendencias[i].sl, 
                  tendencias[i].tp, tendencias[i].id);
            }
         } else if (tendencias[i].precioCalculado < last_tick.ask) {
            printManager.customPrint("BUY LIMIT");
            wasOrdenGenerated = trading.BuyLimit(loteParaOperar, tendencias[i].precioCalculado, tendencias[i].pair, tendencias[i].sl, 
               tendencias[i].tp, ORDER_TIME_SPECIFIED, tendencias[i].VigenciaHigher, tendencias[i].id);
         } else {
            printManager.customPrint("BUY STOP");
            wasOrdenGenerated = trading.BuyStop(loteParaOperar, tendencias[i].precioCalculado, tendencias[i].pair, tendencias[i].sl, 
               tendencias[i].tp, ORDER_TIME_SPECIFIED, tendencias[i].VigenciaHigher, tendencias[i].id);
         }
      } else {
         double diffBid = MathAbs(last_tick.bid - tendencias[i].precioCalculado);
         if (diffBid > diffLimiteParaApertura) {
            printManager.customPrint(tendencias[i].id + " diferencia con el punto de apertura muy grande");
            if (!indexSet) {
               indexLastOpen = i;
               indexSet = true;
            }            
            continue;
         }
         if (generarEnTick) {
            if (last_tick.bid > tendencias[i].tp) {
               printManager.customPrint("SELL generarEnTick,last_tick.bid="+last_tick.bid);
               wasOrdenGenerated = trading.Sell(loteParaOperar, tendencias[i].pair, tendencias[i].precioCalculado, tendencias[i].sl, 
                     tendencias[i].tp, tendencias[i].id);
            }
         }      
         if (tendencias[i].tipoOperacion == ORDER_TYPE_SELL) {
            loteParaOperar = gestionMonetaria.calcularLoteXBalance(loteParaOperar, tendencias[i].pair, tendencias[i].precioCalculado, ORDER_TYPE_SELL);
            if (tendencias[i].precioCalculado == last_tick.bid) {
               if (!generarEnTick) {
                  printManager.customPrint("SELL");
                  wasOrdenGenerated = trading.Sell(loteParaOperar, tendencias[i].pair, tendencias[i].precioCalculado, tendencias[i].sl, 
                     tendencias[i].tp, tendencias[i].id);
               }
            } else if (tendencias[i].precioCalculado > last_tick.bid) {
               printManager.customPrint("SELL LIMIT. Precio calculado=" + tendencias[i].precioCalculado +
                  ";last_tick.bid=" + last_tick.bid);
               wasOrdenGenerated = trading.SellLimit(loteParaOperar, tendencias[i].precioCalculado, tendencias[i].pair, tendencias[i].sl, 
                  tendencias[i].tp, ORDER_TIME_SPECIFIED, tendencias[i].VigenciaHigher, tendencias[i].id);                 
            } else {
               printManager.customPrint("SELL STOP");
               wasOrdenGenerated = trading.SellStop(loteParaOperar, tendencias[i].precioCalculado, tendencias[i].pair, tendencias[i].sl, 
                  tendencias[i].tp, ORDER_TIME_SPECIFIED, tendencias[i].VigenciaHigher, tendencias[i].id);
            }
         }
      }
      printManager.customPrint("trading.ResultRetcode:" + trading.ResultRetcode());      
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
      if (wasOrdenGenerated) {
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

int cumpleCustomIndicators() {
   if (!incluirIndicadorCustom) {
      return 0;
   }
   int bufferH4Top = CopyBuffer(clinesH4Handle,0,0,1,H4TopBuffer);
   int bufferM30Top = CopyBuffer(clinesM30Handle,0,0,1,M30TopBuffer);
   int bufferM5Top = CopyBuffer(clinesM5Handle,0,0,1,M5TopBuffer);
   int bufferH4ExtMap = CopyBuffer(clinesH4Handle,1,0,1,H4ExtMapBuffer);
   int bufferM30ExtMap = CopyBuffer(clinesM30Handle,1,0,1,M30ExtMapBuffer);
   int bufferM5ExtMap = CopyBuffer(clinesM5Handle,1,0,1,M5ExtMapBuffer);
   int bufferH4Botton = CopyBuffer(clinesH4Handle,2,0,1,H4BottonBuffer);
   int bufferM30Botton = CopyBuffer(clinesM30Handle,2,0,1,M30BottonBuffer);
   int bufferM5Botton = CopyBuffer(clinesM5Handle,2,0,1,M5BottonBuffer);
   
   //Print("TimeCurrent="+TimeCurrent());
   //Print ("Count copied=" + bufferH4Top);
   //Print ("Top="+H4TopBuffer[0]+","+M30TopBuffer[0]+","+M5TopBuffer[0]);
   //Print ("ExtMap="+H4ExtMapBuffer[0]+","+M30ExtMapBuffer[0]+","+M5ExtMapBuffer[0]);
   //Print ("Botton="+H4BottonBuffer[0]+","+M30BottonBuffer[0]+","+M5BottonBuffer[0]);
   int operacionValida = ORDER_TYPE_SELL;
   if (H4ExtMapBuffer[0] != H4BottonBuffer[0]) {
      operacionValida = -1;
   }
   if (M30ExtMapBuffer[0] != M30BottonBuffer[0]) {
      operacionValida = -1;
   }
   /*if (M5ExtMapBuffer[0] != M5BottonBuffer[0]) {
      operacionValida = -1;
   }*/
   if (H4TopBuffer[0] <= H4ExtMapBuffer[0]) {
      operacionValida = -1;
   }      
   if (H4TopBuffer[0] <= H4BottonBuffer[0]) {
      operacionValida = -1;
   }
   if (M30TopBuffer[0] <= M30ExtMapBuffer[0]) {
      operacionValida = -1;
   }      
   if (M30TopBuffer[0] <= M30BottonBuffer[0]) {
      operacionValida = -1;
   }
   /*if (M5TopBuffer[0] <= M5ExtMapBuffer[0]) {
      operacionValida = -1;
   }     
   if (M5TopBuffer[0] <= M5BottonBuffer[0]) {
      operacionValida = -1;
   }*/      
   
   if (operacionValida == -1) {
      operacionValida = ORDER_TYPE_BUY;
   } else {
      return operacionValida;
   }
   
   if (H4ExtMapBuffer[0] != H4TopBuffer[0]) {
      operacionValida = -1;
   }
   if (M30ExtMapBuffer[0] != M30TopBuffer[0]) {
      operacionValida = -1;
   }
   /*if (M5ExtMapBuffer[0] != M5TopBuffer[0]) {
      operacionValida = -1;
   }*/
   if (H4BottonBuffer[0] >= H4ExtMapBuffer[0]) {
      operacionValida = -1;
   }      
   if (H4BottonBuffer[0] >= H4TopBuffer[0]) {
      operacionValida = -1;
   }
   if (M30BottonBuffer[0] >= M30ExtMapBuffer[0]) {
      operacionValida = -1;
   }      
   if (M30BottonBuffer[0] >= M30TopBuffer[0]) {
      operacionValida = -1;
   }
   /*if (M5BottonBuffer[0] >= M5ExtMapBuffer[0]) {
      operacionValida = -1;
   }      
   if (M5BottonBuffer[0] >= M5TopBuffer[0]) {
      operacionValida = -1;
   } */        
   return operacionValida;
}

