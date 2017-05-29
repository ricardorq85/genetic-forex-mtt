//+------------------------------------------------------------------+
//|                                       GestionMonetariaProfit.mqh |
//|                                               ricardorq85        |
//+------------------------------------------------------------------+
#property copyright "ricardorq85"

#include <Genetic\Estrategy.mqh>
#include <Genetic\Vigencia.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class GestionMonetariaProfit
  {
private:
   double            profitAcumulado;
   double            balanceBase;

   double            calcularLote(Estrategy *currentEstrategia,double maxBalance,bool inactivar);

public:
                     GestionMonetariaProfit();
                    ~GestionMonetariaProfit();

   void              toggleActiveEstrategia(Estrategy *currentEstrategia,bool inactive);

   double            getLot(Estrategy *currentEstrategia,double maxBalance,bool inactivar,bool calcularLote);
   double            getSimpleLot(Estrategy *currentEstrategia);
   void              test(Vigencia *src_array);

   double getLotDivide() const { return 10.0;}
   double getMaxLot() const { return 5.0;}
   double getMinLot() const { return 0.01;}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
GestionMonetariaProfit::GestionMonetariaProfit()
  {
   profitAcumulado=0;
   balanceBase=AccountInfoDouble(ACCOUNT_BALANCE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
GestionMonetariaProfit::~GestionMonetariaProfit()
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GestionMonetariaProfit::test(Vigencia  *src_array)
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GestionMonetariaProfit::getSimpleLot(Estrategy *currentEstrategia) 
  {
//return (currentEstrategia.Lote * currentEstrategia.cantidadVigencia) / getLotDivide();
   return (currentEstrategia.Lote);
//return (getMaxLot() - (currentEstrategia.Lote * currentEstrategia.cantidadVigencia)) / getLotDivide();
//return (currentEstrategia.StopLoss / currentEstrategia.TakeProfit) / getLotDivide();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GestionMonetariaProfit::getLot(Estrategy *currentEstrategia,double maxBalance,bool inactivar,bool calcularLote) 
  {
   double lot;
   if(calcularLote) 
     {
      lot=calcularLote(currentEstrategia,maxBalance,inactivar);
        }else {
      lot=getSimpleLot(currentEstrategia);
      lot = MathMax(getMinLot(), lot);
      lot = MathMin(getMaxLot(), lot);
      lot = NormalizeDouble(lot, 2);
     }
   return lot;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GestionMonetariaProfit::calcularLote(Estrategy *currentEstrategia,double maxBalance,bool inactivar)
  {
   HistorySelect(0,TimeCurrent());
   ulong    ticket=0;
   double   profit=0;
   string comment=NULL;
   string symbol;
   long inPositionId=0;
   long outPositionId=0;
   double loteActual = currentEstrategia.Lote;
   double nuevoLote=currentEstrategia.Lote;
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
               //if((comment!=NULL) && (comment!=(currentEstrategia.Index+"-"+currentEstrategia.EstrategiaId))){continue;}
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

      nuevoLote = MathMax(minLot, loteTemp);
      nuevoLote = MathMin(maxLot, nuevoLote);
      nuevoLote = NormalizeDouble(nuevoLote, 2);

      if(nuevoLote!=loteActual) 
        {
         balanceBase=AccountInfoDouble(ACCOUNT_BALANCE);
         profitAcumulado=profitTemp;
        }
     }
   return nuevoLote;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GestionMonetariaProfit::toggleActiveEstrategia(Estrategy *currentEstrategia,bool inactive)
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

            if((comment!=NULL) && (comment!=(currentEstrategia.Index+"-"+currentEstrategia.EstrategiaId))){continue;}
           }
         else if(entry==DEAL_ENTRY_OUT)
           {
            profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);
            outPositionId=HistoryDealGetInteger(ticket,DEAL_POSITION_ID);
           }
         if((inPositionId==0) || (outPositionId==0) || (inPositionId!=outPositionId)){continue;}
         if((comment!=NULL) && (comment==(currentEstrategia.Index+"-"+currentEstrategia.EstrategiaId)))
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
//   Print("Comment="+comment+" EstrategiaId="+currentEstrategia.EstrategiaId+" currentNum="+currentNum);
//   Print(" currentProfit="+currentProfit+" MaxProfit="+maxProfit+" MaxBalance="+maxBalance+" Balance actual="+balanceActual);

  }
//+------------------------------------------------------------------+
