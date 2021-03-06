//+------------------------------------------------------------------+
//|                                       GestionMonetariaXProfit.mqh |
//|                                               ricardorq85        |
//+------------------------------------------------------------------+
#property copyright "ricardorq85"

#include <Genetic\IParaOperar.mqh>
#include <Genetic\Vigencia.mqh>
#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class GestionMonetariaXProfit
  {
private:
   double            profitAcumulado;
   double            balanceBase, equityBase;
   double            loteActual;
   CTrade     *trading;
   double            loteBase;
   double            porcentajeCambioRequerido, balanceMinimo;
   double            calcularlote(double maxBalance,bool inactivar);   

public:
                     GestionMonetariaXProfit(double pcr, double bm);
                    ~GestionMonetariaXProfit();
   void              GestionMonetariaXProfit::borrarPendientesXCantidad(int cantidadMaxima, double diffPrecioLimite);
   double            calcularLoteXBalance(double lote, string pair, double precioCalculado, ENUM_ORDER_TYPE tipo);   

   void              toggleActiveEstrategia(bool inactive);

   double            getLot(double maxBalance,bool inactivar,bool calcularlote);
   double            getSimpleLot();
   void            modificarPendientes(double nuevoLote);
   void            setLoteActual(double nuevoLote){loteActual=nuevoLote;}

   double getLotDivide() const { return 10.0;}
   double getMaxLot() const { return 1.0;}
   double getMinLot() const { return 0.01;}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
GestionMonetariaXProfit::GestionMonetariaXProfit(double pcr, double bm)
  {
   loteBase = 0.01;
   loteActual = -1;
   profitAcumulado=0;
   porcentajeCambioRequerido = pcr;
   balanceMinimo = bm;
   trading=new CTrade();
   balanceBase=AccountInfoDouble(ACCOUNT_BALANCE);
   equityBase=AccountInfoDouble(ACCOUNT_EQUITY);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
GestionMonetariaXProfit::~GestionMonetariaXProfit()
  {

  }

double GestionMonetariaXProfit::getSimpleLot() 
  {
   return (loteBase);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GestionMonetariaXProfit::getLot(double maxBalance,bool inactivar,bool calcularlote) 
  {
   double lot;
   double nuevoBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double nuevoEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   if ((calcularlote) && (nuevoBalance > balanceMinimo)) {
      lot = calcularlote(maxBalance,inactivar);
   }else {
      lot=getSimpleLot();
      lot = MathMax(getMinLot(), lot);
      lot = MathMin(getMaxLot(), lot);
      lot = NormalizeDouble(lot, 2);
     }
   return lot;
  }
  
double GestionMonetariaXProfit::calcularlote(double maxBalance,bool inactivar) {
   double minLot=getMinLot();
   double maxLot=getMaxLot();
   if (loteActual == -1) {
      loteActual = loteBase;
      return loteActual;
   }
   
   HistorySelect(0,TimeCurrent());
   uint     total=HistoryDealsTotal();
   double nuevoLote = loteActual;
   double nuevoBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double nuevoEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   //nuevoBalance = MathMin(nuevoBalance, nuevoEquity);
   if (nuevoBalance < 0) {
      nuevoLote = getMinLot();
   } else if ((total > 1)) {
      double diferenciaBalance = (nuevoBalance - balanceBase);
      double balanceComparacion = balanceBase;
      if ((nuevoBalance>0) && (diferenciaBalance > 0)) {
         balanceComparacion = MathMax(balanceMinimo, balanceBase);
      }
      double cambioRequerido = (balanceComparacion * porcentajeCambioRequerido);
      
      double porcentajeCambio = ((diferenciaBalance) / cambioRequerido);
      double loteTemp = loteActual;
      //if ((diferenciaBalance<0) || (MathAbs(diferenciaBalance) >= cambioRequerido)) {
      if ((MathAbs(diferenciaBalance) >= cambioRequerido)) {
            loteTemp += (loteBase * porcentajeCambio);
      }
      /*if ((diferenciaBalance>0) && (diferenciaBalance >= cambioRequerido)) {
            loteTemp += (loteBase);
      } else if ((diferenciaBalance<0) && (diferenciaBalance <= -cambioRequerido)) {
            loteTemp += (loteBase * porcentajeCambio);
      }*/
      if (diferenciaBalance != 0) {
         nuevoLote = MathMax(minLot, loteTemp);
         nuevoLote = MathMin(maxLot, nuevoLote);
         nuevoLote = NormalizeDouble(nuevoLote, 2);
      }
      if(nuevoLote!=loteActual) {
         balanceBase = AccountInfoDouble(ACCOUNT_BALANCE);
         nuevoEquity = AccountInfoDouble(ACCOUNT_EQUITY);
      }
   }
   return nuevoLote;
}
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool esTipoPendiente(long t) {
   if (t==ORDER_TYPE_BUY_LIMIT){
      return true;
   }
   if (t==ORDER_TYPE_SELL_LIMIT){
      return true;
   }
   if (t==ORDER_TYPE_BUY_STOP){
      return true;
   }
   if (t==ORDER_TYPE_SELL_STOP){
      return true;
   }
   if (t==ORDER_TYPE_BUY_STOP_LIMIT){
      return true;
   }
   if (t==ORDER_TYPE_SELL_STOP_LIMIT){
      return true;
   }              
   return false; 
}

void GestionMonetariaXProfit::modificarPendientes(double nuevoLote)
  {
   if (loteActual == nuevoLote) {
      return;
   }
   int totalOrdenes = OrdersTotal();
   if(totalOrdenes > 0) {
      for(int i=0;i<totalOrdenes;i++) {
         ulong ticket = OrderGetTicket(i);
         bool selected = OrderSelect(ticket);
         if (selected) {
            ENUM_ORDER_TYPE order_type = OrderGetInteger(ORDER_TYPE);
            long tipo = OrderGetInteger(ORDER_TYPE);
            bool isPending = esTipoPendiente(tipo);
            if (isPending) {
               long estado = OrderGetInteger(ORDER_STATE);               
               long orderId = OrderGetInteger(ORDER_POSITION_ID);
               long positionId = OrderGetInteger(ORDER_POSITION_ID);
               double price = OrderGetDouble(ORDER_PRICE_OPEN);
               double sl = OrderGetDouble(ORDER_SL);
               double tp = OrderGetDouble(ORDER_TP);
               double volume = OrderGetDouble(ORDER_VOLUME_CURRENT);
               ENUM_ORDER_TYPE_TIME type_time = OrderGetInteger(ORDER_TYPE_TIME);
               datetime expiration = OrderGetInteger(ORDER_TIME_EXPIRATION);
               string comment = OrderGetString(ORDER_COMMENT);
               string symbol = OrderGetString(ORDER_SYMBOL);
               if ((estado == ORDER_STATE_PLACED)) {
                  bool deleted = trading.OrderDelete(ticket);
                  //Print("Order ID=" + orderId + ",Position ID=" + positionId + ",Ticket="+ticket+",Tipo=" + tipo + ",Comment="+comment + "borrada="+deleted+",trading.ResultRetcode:" + trading.ResultRetcode());
                  trading.OrderOpen(symbol,order_type,nuevoLote,0.0,price,sl,tp,type_time,expiration,comment);
                  //Print("Order ID=" + orderId + ",Position ID=" + positionId + ",Ticket="+ticket+",Tipo=" + tipo + ",Comment="+comment + "creada con nuevo lote="+deleted+",trading.ResultRetcode:" + trading.ResultRetcode());
               }
            }
         }
      }
   }
  }

double GestionMonetariaXProfit::calcularLoteXBalance(double lote, string pair, double precioCalculado, ENUM_ORDER_TYPE tipo){
   double nuevoLote = lote;
   bool valid = trading.CheckVolume(pair, nuevoLote, precioCalculado, tipo);
   while (!valid && nuevoLote>getMinLot() && nuevoLote<getMaxLot()) {
      nuevoLote -= loteBase;
      nuevoLote = MathMax(getMinLot(), nuevoLote);
      nuevoLote = MathMin(getMaxLot(), nuevoLote);
      nuevoLote = NormalizeDouble(nuevoLote, 2);
      valid = trading.CheckVolume(pair, nuevoLote, precioCalculado, tipo);
   }
   return nuevoLote;
}

void GestionMonetariaXProfit::borrarPendientesXCantidad(int cantidadMaxima, double diffPrecioLimite)
  {
   int totalOrdenes = OrdersTotal();
   int totalPosiciones = PositionsTotal();
   MqlTick last_tick;
   if(!SymbolInfoTick(Symbol(),last_tick)) {
      return;
   }  
   if(totalPosiciones >= cantidadMaxima) {
      for(int i=0;i<totalOrdenes;i++) {
         ulong ticket = OrderGetTicket(i);
         bool selected = OrderSelect(ticket);
         if (selected) {
            ENUM_ORDER_TYPE order_type = OrderGetInteger(ORDER_TYPE);
            double price = OrderGetDouble(ORDER_PRICE_OPEN);
            if ((order_type = ORDER_TYPE_BUY_LIMIT) || (order_type = ORDER_TYPE_BUY_STOP) || (order_type = ORDER_TYPE_BUY_STOP_LIMIT)) {
               if (MathAbs(price - last_tick.ask) > diffPrecioLimite) {
                  continue;
               }
            } else if ((order_type = ORDER_TYPE_SELL_LIMIT) || (order_type = ORDER_TYPE_SELL_STOP) || (order_type = ORDER_TYPE_SELL_STOP_LIMIT)) {
               if (MathAbs(price - last_tick.bid) > diffPrecioLimite) {
                  continue;
               }
            }
            long tipo = OrderGetInteger(ORDER_TYPE);
            bool isPending = esTipoPendiente(tipo);
            if (isPending) {
               long estado = OrderGetInteger(ORDER_STATE);
               string comment = OrderGetString(ORDER_COMMENT);
               if ((estado == ORDER_STATE_PLACED)) {
                  bool deleted = trading.OrderDelete(ticket);
                  //Print("Deleted Order ID=" + ticket + ",Comment="+comment + "borrada="+deleted+",trading.ResultRetcode:" + trading.ResultRetcode());
               }
            }
         }
      }
   }
}


