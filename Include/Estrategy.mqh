//+------------------------------------------------------------------+
//|                                                    Estrategy.mqh |
//|                                                          RROJASQ |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "RROJASQ"
#property link      ""
#property version   "1.00"

#include <Indicador.mqh>

class Estrategy
  {
public:
   string            EstrategiaId;
   int               Index;
   string            pair;
   ENUM_ORDER_TYPE   orderType;
   datetime          VigenciaLower;
   datetime          VigenciaHigher;

   double            TakeProfit;
   double            StopLoss;
   double            Lote;

   Indicador         *indicadorMa;
   Indicador         *indicadorMacd;
   Indicador         *indicadorMaCompare;
   Indicador         *indicadorSar;
   Indicador         *indicadorAdx;
   Indicador         *indicadorRsi;
   Indicador         *indicadorBollinger;
   Indicador         *indicadorMomentum;
   Indicador         *indicadorIchiTrend;
   Indicador         *indicadorIchiSignal;
   
   int               maxConsecutiveLostOperationsNumber;
   int               maxConsecutiveWonOperationsNumber;
   int               minConsecutiveLostOperationsNumber;
   int               minConsecutiveWonOperationsNumber;
   double            averageConsecutiveLostOperationsNumber;
   double            averageConsecutiveWonOperationsNumber;

   int               Ticket;

   double            currentLot;
   bool              open;
   bool              active;
   bool              closeIndicator;
   datetime          openDate;

                     Estrategy();
                    ~Estrategy();
   void              obtenerValorIndicador(string name, string name2, Indicador *indicador, bool isOpen, string strEstrategia);
   void              initEstrategias(string strEstrategia,int index);
   string            toString();

private:
   string            cadenaEstrategias;
   double            divide;   
   string            getValue(string strEstrategia,string name);
   string            getValue(string strEstrategia,string name,string defaultValue);   
  };
  
Estrategy::Estrategy()
  {
   divide=100;
   open=false;
   closeIndicator=false;
   openDate=NULL;

   indicadorMa = new Indicador();
   indicadorMacd = new Indicador();
   indicadorMaCompare = new Indicador();
   indicadorSar = new Indicador();
   indicadorAdx = new Indicador();
   indicadorRsi = new Indicador();
   indicadorBollinger = new Indicador();
   indicadorMomentum = new Indicador();
   indicadorIchiSignal = new Indicador();
   indicadorIchiTrend = new Indicador();
  }

Estrategy::~Estrategy()
  {

  }

void Estrategy::initEstrategias(string strEstrategia,int indexParam)
  {
   active=true;
   StringToUpper(strEstrategia);
   string v = getValue(strEstrategia,"Active");
   StringToUpper(v);
   if(v=="TRUE")
     {
      active=true;
        }else if(v=="FALSE") {
      active=false;
     }
     //Print (index," ", active);

   pair=getValue(strEstrategia,"Pair");

   v=getValue(strEstrategia,"VigenciaLower");
   VigenciaLower=StringToTime(v);
   v=getValue(strEstrategia,"VigenciaHigher");
   VigenciaHigher=StringToTime(v);

   v=getValue(strEstrategia,"Operation");
   StringToUpper(v);
   if(v=="BUY")
     {
      orderType=ORDER_TYPE_BUY;
        }else if(v=="SELL") {
      orderType=ORDER_TYPE_SELL;
     }

   Lote=StringToDouble(getValue(strEstrategia,"Lote"));
   currentLot=Lote;

   TakeProfit=StringToDouble(getValue(strEstrategia,"TakeProfit"));
   StopLoss=StringToDouble(getValue(strEstrategia,"StopLoss"));

   EstrategiaId=getValue(strEstrategia,"EstrategiaId");
   Index=indexParam;

   maxConsecutiveLostOperationsNumber=(int)StringToInteger(getValue(strEstrategia,"MaxConsecutiveLostOperationsNumber","0"));
   maxConsecutiveWonOperationsNumber=(int)StringToInteger(getValue(strEstrategia,"MaxConsecutiveWonOperationsNumber","0"));
   minConsecutiveLostOperationsNumber=(int)StringToInteger(getValue(strEstrategia,"MinConsecutiveLostOperationsNumber","0"));
   minConsecutiveWonOperationsNumber=(int)StringToInteger(getValue(strEstrategia,"MinConsecutiveWonOperationsNumber","0"));
   averageConsecutiveLostOperationsNumber=(int)StringToDouble(getValue(strEstrategia,"AverageConsecutiveLostOperationsNumber","0"));
   averageConsecutiveWonOperationsNumber=(int)StringToDouble(getValue(strEstrategia,"AverageConsecutiveWonOperationsNumber","0"));

   obtenerValorIndicador("openMa", "openMa", indicadorMa, true, strEstrategia);
   obtenerValorIndicador("closeMa", "CloseMa", indicadorMa, false, strEstrategia);

   obtenerValorIndicador("openMacd", "openMacd", indicadorMacd, true, strEstrategia);
   obtenerValorIndicador("closeMacd", "closeMacd", indicadorMacd, false, strEstrategia);

   obtenerValorIndicador("openMaCompare", "openCompare_MA", indicadorMaCompare, true, strEstrategia);
   obtenerValorIndicador("closeMaCompare", "closeCompare_MA", indicadorMaCompare, false, strEstrategia);

   obtenerValorIndicador("openSar", "openSar", indicadorSar, true, strEstrategia);
   obtenerValorIndicador("closeSar", "closeSar", indicadorSar, false, strEstrategia);

   obtenerValorIndicador("openAdx", "openAdx", indicadorAdx, true, strEstrategia);
   obtenerValorIndicador("closeAdx", "closeAdx", indicadorAdx, false, strEstrategia);

   obtenerValorIndicador("openRsi", "openRsi", indicadorRsi, true, strEstrategia);
   obtenerValorIndicador("closeRsi", "closeRsi", indicadorRsi, false, strEstrategia);

   obtenerValorIndicador("openBollinger", "openBollinger", indicadorBollinger, true, strEstrategia);
   obtenerValorIndicador("closeBollinger", "closeBollinger", indicadorBollinger, false, strEstrategia);

   obtenerValorIndicador("openMomentum", "openMomentum", indicadorMomentum, true, strEstrategia);
   obtenerValorIndicador("closeMomentum", "cloaseMomentum", indicadorMomentum, false, strEstrategia);

   obtenerValorIndicador("openIchiTrend", "openICHIMOKU_TREND", indicadorIchiTrend, true, strEstrategia);
   obtenerValorIndicador("closeIchiTrend", "closeICHIMOKU_TREND", indicadorIchiTrend, false, strEstrategia);
   
   obtenerValorIndicador("openIchiSignal", "openICHIMOKU_SIGNAL", indicadorIchiSignal, true, strEstrategia);
   obtenerValorIndicador("openIchiSignal", "openICHIMOKU_SIGNAL", indicadorIchiSignal, false, strEstrategia);
  }
  

string Estrategy::toString(){

 string str = "EstrategiaId="+EstrategiaId+";StopLoss="+DoubleToString(StopLoss)+";TakeProfit="+DoubleToString(TakeProfit)+
   ";indicadorAdx.openLower="+DoubleToString(indicadorAdx.openLower)+
   ";indicadorAdx.openHigher="+DoubleToString(indicadorAdx.openHigher)+
   ";indicadorBollinger.openLower="+DoubleToString(indicadorBollinger.openLower)+
   ";indicadorBollinger.openHigher="+DoubleToString(indicadorBollinger.openHigher)+
   ";openIchiSignalLower="+DoubleToString(indicadorIchiSignal.openLower)+
   ";openIchiSignalHigher="+DoubleToString(indicadorIchiSignal.openHigher)+
   ";openIchiTrendLower="+DoubleToString(indicadorIchiTrend.openLower)+
   ";openIchiTrendHigher="+DoubleToString(indicadorIchiTrend.openHigher)+
   ";indicadorMaCompare.openLower="+DoubleToString(indicadorMaCompare.openLower)+
   ";indicadorMaCompare.openHigher="+DoubleToString(indicadorMaCompare.openHigher)+
   ";indicadorMa.openLower="+DoubleToString(indicadorMa.openLower)+
   ";indicadorMa.openHigher="+DoubleToString(indicadorMa.openHigher)+
   ";indicadorMacd.openLower="+DoubleToString(indicadorMacd.openLower)+
   ";indicadorMacd.openHigher="+DoubleToString(indicadorMacd.openHigher)+
   ";indicadorMomentum.openLower="+DoubleToString(indicadorMomentum.openLower)+
   ";indicadorMomentum.openHigher="+DoubleToString(indicadorMomentum.openHigher)+
   ";indicadorRsi.openLower="+DoubleToString(indicadorRsi.openLower)+
   ";indicadorRsi.openHigher="+DoubleToString(indicadorRsi.openHigher)+
   ";indicadorSar.openLower="+DoubleToString(indicadorSar.openLower)+
   ";indicadorSar.openHigher="+DoubleToString(indicadorSar.openHigher)+
   ";indicadorAdx.closeLower="+DoubleToString(indicadorAdx.closeLower)+
   ";indicadorAdx.closeHigher="+DoubleToString(indicadorAdx.closeHigher)+
   ";indicadorBollinger.closeLower="+DoubleToString(indicadorBollinger.closeLower)+
   ";indicadorBollinger.closeHigher="+DoubleToString(indicadorBollinger.closeHigher)+
   ";closeIchiSignalLower="+DoubleToString(indicadorIchiSignal.closeLower)+
   ";closeIchiSignalHigher="+DoubleToString(indicadorIchiSignal.closeHigher)+
   ";closeIchiTrendLower="+DoubleToString(indicadorIchiTrend.closeLower)+
   ";closeIchiTrendHigher="+DoubleToString(indicadorIchiTrend.closeHigher)+
   ";indicadorMaCompare.closeLower="+DoubleToString(indicadorMaCompare.closeLower)+
   ";indicadorMaCompare.closeHigher="+DoubleToString(indicadorMaCompare.closeHigher)+
   ";indicadorMa.closeLower="+DoubleToString(indicadorMa.closeLower)+
   ";indicadorMa.closeHigher="+DoubleToString(indicadorMa.closeHigher)+
   ";indicadorMacd.closeLower="+DoubleToString(indicadorMacd.closeLower)+
   ";indicadorMacd.closeHigher="+DoubleToString(indicadorMacd.closeHigher)+
   ";indicadorMomentum.closeLower="+DoubleToString(indicadorMomentum.closeLower)+
   ";indicadorMomentum.closeHigher="+DoubleToString(indicadorMomentum.closeHigher)+
   ";indicadorRsi.closeLower="+DoubleToString(indicadorRsi.closeLower)+
   ";indicadorRsi.closeHigher="+DoubleToString(indicadorRsi.closeHigher)+
   ";indicadorSar.closeLower="+DoubleToString(indicadorSar.closeLower)+
   ";indicadorRsi.closeHigher="+DoubleToString(indicadorRsi.closeHigher)
   ;
 return str;
}

//+------------------------------------------------------------------+
string Estrategy::getValue(string strEstrategia,string name)
  {
   return getValue(strEstrategia,name,NULL);
  }

string Estrategy::getValue(string strEstrategia,string name,string defaultValue)
  {
   string value;
   string strValue="";
   StringToUpper(name);
   int indexName=StringFind(strEstrategia,name,0);
   if(indexName<0)
     {
      strValue="null";
        } else {
      int indexEqual = StringFind(strEstrategia,"=",indexName);
      int indexComma = StringFind(strEstrategia,",",indexName);
      strValue=StringSubstr(strEstrategia,indexEqual+1,indexComma-indexEqual-1);
      if (StringLen(strValue)==0)
      {
         strValue="null";
      }
     }
   if((strValue=="null"))
     {
      if(defaultValue!=NULL)
        {
         value=defaultValue;
           }else {
         /*int closeLower=StringFind(name,"CLOSE",0);
         if(closeLower>=0)
           {
            value="0";
              }else {*/
            int indexLower= StringFind(name,"LOWER",0);
            if(indexLower>=0)
              {
               value="-1000000";
                }else {
               value="1000000";
              }
           //}
        }
        }else {
        int closeLower=StringFind(name,"CLOSE",0);
         if(closeLower>=0)
           {
            closeIndicator=true;
           }
      value=(strValue);
     }
   return(value);
  }

void Estrategy::obtenerValorIndicador(string name, string name2, Indicador *indicador, bool isOpen, string strEstrategia) {
   double tmpLower = NormalizeDouble(StringToDouble(getValue(strEstrategia,name+"Lower"))/divide,_Digits);
   double tmpHigher = NormalizeDouble(StringToDouble(getValue(strEstrategia,name+"Higher"))/divide,_Digits);
   if ((tmpLower==-10000)||(tmpHigher==10000)){
      tmpLower=NormalizeDouble(StringToDouble(getValue(strEstrategia, name2+"Lower"))/divide,_Digits);
      tmpHigher=NormalizeDouble(StringToDouble(getValue(strEstrategia,name2+"Higher"))/divide,_Digits);
      if ((tmpLower==-10000)||(tmpHigher==10000)){
         if (isOpen) {
            indicador.openLower = 0.0;
            indicador.openHigher = 0.0;
            indicador.hasOpen = false;
         } else {
            indicador.closeLower = 0.0;
            indicador.closeHigher = 0.0;
            indicador.hasClose= false;
         }
      } else {
         if (isOpen) {
            indicador.openLower = tmpLower;
            indicador.openHigher = tmpHigher;      
            indicador.hasOpen = true;
         } else {
            indicador.closeLower = tmpLower;
            indicador.closeHigher = tmpHigher;      
            indicador.hasClose = true;         
         }
      }
   } else {
      if (isOpen) {
         indicador.openLower = tmpLower;
         indicador.openHigher = tmpHigher;      
         indicador.hasOpen = true;
      } else {
         indicador.closeLower = tmpLower;
         indicador.closeHigher = tmpHigher;      
         indicador.hasClose = true;         
      }
   }   
}
