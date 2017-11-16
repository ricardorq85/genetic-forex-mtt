//+------------------------------------------------------------------+
//|                                       GestionMonetariaXProfit.mqh |
//|                                               ricardorq85        |
//+------------------------------------------------------------------+
#property copyright "ricardorq85"

#include <Genetic\IParaOperar.mqh>
#include <Genetic\Vigencia.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class GestionMonetariaXProfit
  {
private:
   double            profitAcumulado;
   double            balanceBase;
   double            loteActual;

   double            calcularlote(IParaOperar *currentEstrategia,double maxBalance,bool inactivar);
   double            calcularlote2(IParaOperar *currentEstrategia,double maxBalance,bool inactivar);

public:
                     GestionMonetariaXProfit();
                    ~GestionMonetariaXProfit();

   void              toggleActiveEstrategia(IParaOperar *currentEstrategia,bool inactive);

   double            getLot(IParaOperar *currentEstrategia,double maxBalance,bool inactivar,bool calcularlote);
   double            getSimpleLot(IParaOperar *currentEstrategia);
   void              test(Vigencia *src_array);

   double getLotDivide() const { return 10.0;}
   double getMaxLot() const { return 5.0;}
   double getMinLot() const { return 0.01;}
   double getPorcentajeCambioRequerido() const { return 0.2;}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
GestionMonetariaXProfit::GestionMonetariaXProfit()
  {
   loteActual = -1;
   profitAcumulado=0;
   balanceBase=AccountInfoDouble(ACCOUNT_BALANCE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
GestionMonetariaXProfit::~GestionMonetariaXProfit()
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GestionMonetariaXProfit::test(Vigencia  *src_array)
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GestionMonetariaXProfit::getSimpleLot(IParaOperar *currentEstrategia) 
  {
//return (currentEstrategia.lote * currentEstrategia.cantidadVigencia) / getLotDivide();
   return (currentEstrategia.lote);
//return (getMaxLot() - (currentEstrategia.lote * currentEstrategia.cantidadVigencia)) / getLotDivide();
//return (currentEstrategia.StopLoss / currentEstrategia.TakeProfit) / getLotDivide();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GestionMonetariaXProfit::getLot(IParaOperar *currentEstrategia,double maxBalance,bool inactivar,bool calcularlote) 
  {
   double lot;
   if(calcularlote) 
     {
      lot=calcularlote(currentEstrategia,maxBalance,inactivar);
        }else {
      lot=getSimpleLot(currentEstrategia);
      lot = MathMax(getMinLot(), lot);
      lot = MathMin(getMaxLot(), lot);
      lot = NormalizeDouble(lot, 2);
     }
   return lot;
  }
  
double GestionMonetariaXProfit::calcularlote(IParaOperar *currentEstrategia,double maxBalance,bool inactivar) {
   double minLot=getMinLot();
   double maxLot=getMaxLot();   
   double loteBase = currentEstrategia.lote;
   if (loteActual == -1) {
      loteActual = loteBase;
   }
   
   HistorySelect(0,TimeCurrent());
   uint     total=HistoryDealsTotal();   
   double nuevoLote = loteActual;
   if (total > 0) {
      double nuevoBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      double cambioRequerido = (balanceBase * getPorcentajeCambioRequerido());
      double diferenciaBalance = (nuevoBalance - balanceBase);
      //double profitTemp = MathMod(diferenciaBalance,(balanceBase*0.1));
      double porcentajeCambio = ((diferenciaBalance) / cambioRequerido);
      double loteTemp = loteActual;
      if (MathAbs(diferenciaBalance) >= cambioRequerido) {
         loteTemp += (loteBase * porcentajeCambio);
      }
      if (diferenciaBalance != 0) {
         nuevoLote = MathMax(minLot, loteTemp);
         nuevoLote = MathMin(maxLot, nuevoLote);
         nuevoLote = NormalizeDouble(nuevoLote, 2);
      }
      if(nuevoLote!=loteActual) {
         balanceBase=AccountInfoDouble(ACCOUNT_BALANCE);
      }
   }
   loteActual = nuevoLote;
   return nuevoLote;
}
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GestionMonetariaXProfit::calcularlote2(IParaOperar *currentEstrategia,double maxBalance,bool inactivar)
  {
   HistorySelect(0,TimeCurrent());
   ulong    ticket=0;
   double   profit=0;
   string comment=NULL;
   string symbol;
   long inPositionId=0;
   long outPositionId=0;
   double loteActual = currentEstrategia.lote;
   double nuevolote=currentEstrategia.lote;
   int last=0;
   long entry;
   uint     total=HistoryDealsTotal();
   if(total>1) 
     {
      for(uint i=total;i>0;i--)
        {
         if((ticket=HistoryDealGetTicket(i-1))>0)
           {
            symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
            entry =HistoryDealGetInteger(ticket,DEAL_ENTRY);
            if(symbol!=currentEstrategia.pair){continue;}
            if(entry==DEAL_ENTRY_IN)
              {
               comment=HistoryDealGetString(ticket,DEAL_COMMENT);
               inPositionId=HistoryDealGetInteger(ticket,DEAL_POSITION_ID);
               //if((comment!=NULL) && (comment!=(currentEstrategia.index+"-"+currentEstrategia.id))){continue;}
              }
            else if(entry==DEAL_ENTRY_OUT)
              {
               profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);
               loteActual=HistoryDealGetDouble(ticket,DEAL_VOLUME);
               outPositionId=HistoryDealGetInteger(ticket,DEAL_POSITION_ID);
              }
            if(outPositionId!=0)
              {
               break;
              }
              }else{
            Print(IntegerToString(GetLastError())+" select "+IntegerToString(i));
            break;
           }
        }
      double minLot=getMinLot();
      double maxLot=getMaxLot();
      if(profit<0)
        {
         currentEstrategia.active=!inactivar;
        }
      profitAcumulado+=profit;

      double profitTemp=MathMod(profitAcumulado,(balanceBase*0.1));
      double porcentajeCambio=((profitAcumulado-profitTemp)/balanceBase);
      double loteTemp=loteActual *(1+porcentajeCambio);

      nuevolote = MathMax(minLot, loteTemp);
      nuevolote = MathMin(maxLot, nuevolote);
      nuevolote = NormalizeDouble(nuevolote, 2);

      if(nuevolote!=loteActual) 
        {
         balanceBase=AccountInfoDouble(ACCOUNT_BALANCE);
         profitAcumulado=profitTemp;
        }
     }
   return nuevolote;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GestionMonetariaXProfit::toggleActiveEstrategia(IParaOperar *currentEstrategia,bool inactive)
  {
   if(!inactive){return;}

   HistorySelect(0,TimeCurrent());
   ulong    ticket=0;
   double   profit;
   string comment=NULL;
   string symbol;
   long inPositionId=0;
   long outPositionId=0;

   double balanceActual=AccountInfoDouble(ACCOUNT_BALANCE);
   double currentProfit=0;

   int currentNum=0;

   long entry;
   uint     total=HistoryDealsTotal();

//Print("total="+total);
   for(uint i=total;i>0;i--)
     {
      //Print("i="+i);
      if((ticket=HistoryDealGetTicket(i-1))>0)
        {
         //Print("select "+i);
         symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
         entry =HistoryDealGetInteger(ticket,DEAL_ENTRY);

         if(symbol!=currentEstrategia.pair){continue;}

         if(entry==DEAL_ENTRY_IN)
           {
            comment=HistoryDealGetString(ticket,DEAL_COMMENT);
            inPositionId=HistoryDealGetInteger(ticket,DEAL_POSITION_ID);

            if((comment!=NULL) && (comment!=(currentEstrategia.index+"-"+currentEstrategia.id))){continue;}
           }
         else if(entry==DEAL_ENTRY_OUT)
           {
            profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);
            outPositionId=HistoryDealGetInteger(ticket,DEAL_POSITION_ID);
           }
         if((inPositionId==0) || (outPositionId==0) || (inPositionId!=outPositionId)){continue;}
         if((comment!=NULL) && (comment==(currentEstrategia.index+"-"+currentEstrategia.id)))
           {
            if(profit<0)
              {
               currentEstrategia.active=false;
               break;
              }
           }
           }else{
         Print(IntegerToString(GetLastError())+" select "+IntegerToString(i));
         break;
        }
     }
//   Print("Comment="+comment+" id="+currentEstrategia.id+" currentNum="+currentNum);
//   Print(" currentProfit="+currentProfit+" MaxProfit="+maxProfit+" MaxBalance="+maxBalance+" Balance actual="+balanceActual);

  }
//+------------------------------------------------------------------+
