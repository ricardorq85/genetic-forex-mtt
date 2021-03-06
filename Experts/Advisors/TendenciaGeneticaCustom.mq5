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
#include <Genetic\GeneticTrading.mqh>

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
input double diffPipsMaximosParaApertura = 100;
input int    cantidadMaximaOrdenesAbiertas = 1000;
input double diffPipsPrecioLimiteCerrarPendienteXCantidad = 50;
input bool   cerrarPendienteXStopApertura=false;
input bool   abrirPendienteXLimitApertura=true;

GestionMonetariaXProfit   *gestionMonetaria;
GeneticTrading            * geneticTrading;
MqlRates  rates_array[];
int lastTotalPositions=0;
datetime activeTime = NULL;
int digitsIndicators=5;
bool open = false;
double initialBalance=0.0;
double balanceMaximoCuenta=0.0;
double diffLimiteParaApertura;
double diffPrecioLimiteParaCerrarPendiente;
datetime lastProcessedTime;

Tendencia      tendencias[];
Tendencia      tendenciasPlaced[];
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
   EventSetTimer(1*60*1);
   
   Print("TERMINAL_PATH = ",TerminalInfoString(TERMINAL_PATH));
   Print("TERMINAL_DATA_PATH = ",TerminalInfoString(TERMINAL_DATA_PATH));
   Print("TERMINAL_COMMONDATA_PATH = ",TerminalInfoString(TERMINAL_COMMONDATA_PATH));
   
   geneticTrading = new GeneticTrading();
   gestionMonetaria=new GestionMonetariaXProfit(porcentajeCambioRequeridoParaGestionMonetaria, balanceMinimoParaGestionMonetaria);   
   initialBalance=AccountInfoDouble(ACCOUNT_BALANCE);
   balanceMaximoCuenta=initialBalance;
   diffLimiteParaApertura = (diffPipsMaximosParaApertura * _Point) * 10;
   diffPrecioLimiteParaCerrarPendiente = (diffPipsPrecioLimiteCerrarPendienteXCantidad * _Point) * 10;
   
   ArrayFree(tendenciasPlaced);
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
   gestionMonetaria.borrarPendientesXCantidad(cantidadMaximaOrdenesAbiertas, diffPrecioLimiteParaCerrarPendiente);
   if (cerrarPendienteXStopApertura) {
      actualizarOrdenesConStopApertura();
   }
   if (live) {
      initProcess();
   }
   putPendingOrders();
   saveActiveTendencias();
   lastProcessedTime = TimeCurrent();
}

void saveActiveTendencias () {
   if (live) {      
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
      if (!abrirPendienteXLimitApertura) {
         tendencias[i].limitSuperado = true;
      } else {
         if (!tendencias[i].limitSuperado) {
            if (tendencias[i].limitApertura > 0) {
               if (tendencias[i].tipoOperacion == ORDER_TYPE_BUY) {
                  double diff = tendencias[i].limitApertura - last_tick.bid;
                  //if ((MathAbs(last_tick.bid - tendencias[i].limitApertura) < (10 * _Point)))  {
                   // Diferencia de 10 pips
                  if ((diff > 0) || (diff/_Point > -100)) {
                     tendencias[i].limitSuperado = true;
                  }
               } else {
                  double diff = tendencias[i].limitApertura - last_tick.ask;
                   //if ((MathAbs(last_tick.ask - tendencias[i].limitApertura) < (10 * _Point)))  {
                   // Diferencia de 10 pips
                  if ((diff < 0) || (diff/_Point < 100)) {
                     tendencias[i].limitSuperado = true;
                  }                  
               }               
            }
         }
      }
      if (cerrarPendienteXStopApertura) {
         if (tendencias[i].tipoOperacion == ORDER_TYPE_BUY) {
            double diff = tendencias[i].stopApertura - last_tick.ask;
            //if (MathAbs(tendencias[i].stopApertura - last_tick.ask) <= (50 * _Point)) {
            if ((diff < 0) || (diff/_Point < 50)) {
               tendencias[i].active = false;
            }
         } else {
            double diff = tendencias[i].stopApertura - last_tick.bid;
//            if (MathAbs(tendencias[i].stopApertura - last_tick.bid) <= (50 * _Point)) {
            if ((diff > 0) || (diff/_Point > -50)) {
               tendencias[i].active = false;
            }
         }
      }
      if (!tendencias[i].limitSuperado) {
         if (!indexSet) {
            indexLastOpen = i;
            indexSet = true;
         }
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
      /*
      double lowest = last_tick.bid;
      double highest = last_tick.ask;
      geneticTrading.getLowestAndHighestPrice(lastProcessedTime, TimeCurrent(), lowest, highest);
      */

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
         tendencias[i].active = false;
         int arrayIndex = ArraySize(tendenciasPlaced);
         ArrayResize(tendenciasPlaced,arrayIndex + 1);
         tendenciasPlaced[arrayIndex] = tendencias[i];         
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
   //process();
   
  }

int searchTendenciaById(string idTendencia) {
   for(int i=0; i<ArraySize(tendenciasPlaced); i++) {
      if (tendenciasPlaced[i].id == idTendencia) {
         return i;
      }
   }
   return -1;
}  

void actualizarOrdenesConStopApertura() {
   int totalOrdenes = OrdersTotal();
   MqlTick last_tick;
   if(!SymbolInfoTick(Symbol(), last_tick)) {
      return;
   }
   if (totalOrdenes == 0) {
      ArrayFree(tendenciasPlaced);
      return;
   }
   for(int i=0;i<totalOrdenes;i++) {
      ulong ticket = OrderGetTicket(i);
      bool selected = OrderSelect(ticket);
      if (selected) {
         ENUM_ORDER_TYPE order_type = OrderGetInteger(ORDER_TYPE);
         string comment = OrderGetString(ORDER_COMMENT);
         int indexTendencia = searchTendenciaById(comment);
         if (indexTendencia < 0) {
            continue;
         }
         long tipo = OrderGetInteger(ORDER_TYPE);
         bool isPending = esTipoPendiente(tipo);
         if (isPending) {
            long estado = OrderGetInteger(ORDER_STATE);
            if ((estado == ORDER_STATE_PLACED)) {
               bool deleted = false;
               if ((order_type = ORDER_TYPE_BUY_LIMIT) || (order_type = ORDER_TYPE_BUY_STOP) || (order_type = ORDER_TYPE_BUY_STOP_LIMIT)) {
                  double diff = tendenciasPlaced[indexTendencia].stopApertura - last_tick.ask;
                  //if (MathAbs(tendenciasPlaced[indexTendencia].stopApertura - last_tick.ask) <= (50 * _Point)) {
                  if ((diff < 0) || (diff/_Point < 50)) {            
                     deleted = trading.OrderDelete(ticket);
                  }
               } else if ((order_type = ORDER_TYPE_SELL_LIMIT) || (order_type = ORDER_TYPE_SELL_STOP) || (order_type = ORDER_TYPE_SELL_STOP_LIMIT)) {
                  double diff = tendenciasPlaced[indexTendencia].stopApertura - last_tick.bid;
                  //if (MathAbs(tendenciasPlaced[indexTendencia].stopApertura - last_tick.bid) <= (50 * _Point)) {
                  if ((diff > 0) || (diff/_Point > -50)) {
                     deleted = trading.OrderDelete(ticket);
                  }
               }
               //Print("Deleted Order ID=" + ticket + ",Comment="+comment + "borrada="+deleted+",trading.ResultRetcode:" + trading.ResultRetcode());
            }
         }
      }
   }   
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

