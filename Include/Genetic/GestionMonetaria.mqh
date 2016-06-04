//+------------------------------------------------------------------+
//|                                             GestionMonetaria.mqh |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"

#include <Genetic\Estrategy.mqh>
#include <Genetic\Vigencia.mqh>

class GestionMonetaria
  {
private:
   double calcularLote(Estrategy *currentEstrategia, double maxBalance, bool inactivar);
   
public:
   GestionMonetaria();
  ~GestionMonetaria();
  
  void toggleActiveEstrategia(Estrategy *currentEstrategia, bool inactive);
  
  double getLot(Estrategy *currentEstrategia, double maxBalance, bool inactivar, bool calcularLote);
  double getSimpleLot(Estrategy *currentEstrategia);
  void test(Vigencia *src_array);
   
  double getLotDivide() const { return 10.0;}
  double getMaxLot() const { return 5.0;}
  double getMinLot() const { return 0.01;}
  };
  
GestionMonetaria::GestionMonetaria()
  {

  }

GestionMonetaria::~GestionMonetaria()
  {

  }    

void GestionMonetaria::test(Vigencia  *src_array){
   
}

double GestionMonetaria::getSimpleLot(Estrategy *currentEstrategia) {
   //return (currentEstrategia.Lote * currentEstrategia.cantidadVigencia) / getLotDivide();
   return (currentEstrategia.Lote);
   //return (getMaxLot() - (currentEstrategia.Lote * currentEstrategia.cantidadVigencia)) / getLotDivide();
   //return (currentEstrategia.StopLoss / currentEstrategia.TakeProfit) / getLotDivide();
}

double GestionMonetaria::getLot(Estrategy *currentEstrategia, double maxBalance, bool inactivar, bool calcularLote) {
   double lot;
   if (calcularLote) {
      lot = calcularLote(currentEstrategia, maxBalance, inactivar);
   }else {
      lot=getSimpleLot(currentEstrategia);
      lot = MathMax(getMinLot(), lot);
      lot = MathMin(getMaxLot(), lot);
      lot = NormalizeDouble(lot, 2);               
   }
   return lot;
}
  
double GestionMonetaria::calcularLote(Estrategy *currentEstrategia, double maxBalance, bool inactivar)
  {
   HistorySelect(0,TimeCurrent());
   ulong    ticket=0;
   double   profit;
   string comment=NULL;
   string symbol;
   long inPositionId=0;
   long outPositionId=0;
   double nextLot=currentEstrategia.Lote;
   double balanceActual=AccountInfoDouble(ACCOUNT_BALANCE);
   double currentProfit=0;
   maxBalance=MathMax(maxBalance,balanceActual);
   double maxProfit=balanceActual-maxBalance;
   int currentNum=0;
   int last=0;
   long entry;
   uint     total=HistoryDealsTotal();
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
            outPositionId=HistoryDealGetInteger(ticket,DEAL_POSITION_ID);
           }
         if((inPositionId==0) || (outPositionId==0) || (inPositionId!=outPositionId)){continue;}
         if(((last>0) && (profit>0)) || ((last<0) && (profit<0)))
           {
            currentProfit=currentProfit+profit;
            currentNum++;
              }else {
            if(last==0)
              {
               currentProfit=profit;
               currentNum=1;
              }
           }
         if((last!=0) && (((last>0) && (profit<0)) || ((last<0) && (profit>0))))
           {
            break;
              }else {
            if(profit>0)
              {
               last=1;
                 }else {
               last=-1;
              }
           }
           }else{
         Print(IntegerToString(GetLastError())+" select "+IntegerToString(i));
         break;
        }
     }
   double minLot=getMinLot();//SymbolInfoDouble(currentEstrategia.pair,SYMBOL_VOLUME_MIN);
   double maxLot=getMaxLot();//SymbolInfoDouble(currentEstrategia.pair, SYMBOL_VOLUME_MAX);
   if(currentProfit<0)
     {
      currentEstrategia.active=!inactivar;
      if(currentNum>3)
        {
         nextLot = getSimpleLot(currentEstrategia);
        }else if(currentNum>0) {
         nextLot=currentEstrategia.Lote;
        }
     }
    else if(currentProfit>0)
     {
     if(currentNum<2){
         nextLot=currentEstrategia.Lote;
      }else if(currentNum>=5){
         nextLot = getSimpleLot(currentEstrategia);;
      }else if(currentNum>=2)
        {
         nextLot=(getSimpleLot(currentEstrategia))*currentNum;
         }
     }

   nextLot = MathMax(minLot, nextLot);
   nextLot = MathMin(maxLot, nextLot);
   nextLot = NormalizeDouble(nextLot, 2);
   return nextLot;
  }  
  

void GestionMonetaria::toggleActiveEstrategia(Estrategy *currentEstrategia, bool inactive)
  {
   if (!inactive){return;}
   
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
         if((comment!=NULL) && (comment==(currentEstrategia.Index+"-"+currentEstrategia.EstrategiaId))){         
            if (profit<0)
              {
               currentEstrategia.active = false;
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

/*
double GestionMonetaria::calcularLote(Estrategy *currentEstrategia, double maxBalance, bool inactivar)
  {
   HistorySelect(0,TimeCurrent());
   ulong    ticket=0;
   double   profit;
   string comment=NULL;
   string symbol;
   double nextLot=currentEstrategia.Lote;
   double balanceActual=AccountInfoDouble(ACCOUNT_BALANCE);
   double maxProfit=balanceActual-maxBalance;
   int currentNum=0;
   int last=0;
   long entry;
   uint     total=HistoryDealsTotal();
   
   double minLot=SymbolInfoDouble(currentEstrategia.pair,SYMBOL_VOLUME_MIN);
   double maxLot=SymbolInfoDouble(currentEstrategia.pair, SYMBOL_VOLUME_MAX);
   if(balanceActual<maxBalance)
     {
      double loteProfit=(MathAbs(maxProfit)/currentEstrategia.TakeProfit);
      nextLot=MathMax(nextLot,(1.2)*(loteProfit));
      nextLot=MathMax(nextLot,currentEstrategia.Lote);    
     }
   nextLot = MathMax(minLot, nextLot);
   nextLot = MathMin(maxLot, nextLot);
   nextLot = NormalizeDouble(nextLot, 2);
   return nextLot;
  }
*/
  