//+------------------------------------------------------------------+
//|                                             GestionMonetaria.mqh |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"

#include <Estrategy.mqh>

class GestionMonetaria
  {
private:

public:

   GestionMonetaria();
  ~GestionMonetaria();
  
  void toggleActiveEstrategia(Estrategy *currentEstrategia, bool inactive);
  
  double calculateLot(Estrategy *currentEstrategia, double maxBalance, bool doInactive);
  };
  
GestionMonetaria::GestionMonetaria()
  {
  }

GestionMonetaria::~GestionMonetaria()
  {
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
            if ( profit<0 )
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

double GestionMonetaria::calculateLot(Estrategy *currentEstrategia, double maxBalance, bool doInactive)
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
   
//   Print("Comment="+comment+" EstrategiaId="+currentEstrategia.EstrategiaId+" currentNum="+currentNum);
//   Print(" currentProfit="+currentProfit+" MaxProfit="+maxProfit+" MaxBalance="+maxBalance+" Balance actual="+balanceActual);
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