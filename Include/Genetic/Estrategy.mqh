//+------------------------------------------------------------------+
//|                                                    Estrategy.mqh |
//|                                                          RROJASQ |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "RROJASQ"
#property link      ""
#property version   "1.00"

#include <Genetic\Indicador.mqh>

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
   int               cantidadVigencia;

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
   Indicador         *indicadorMa1200;
   Indicador         *indicadorMacd20x;
   Indicador         *indicadorMaCompare1200;
   Indicador         *indicadorSar1200;
   Indicador         *indicadorAdx168;
   Indicador         *indicadorRsi84;
   Indicador         *indicadorBollinger240;
   Indicador         *indicadorMomentum1200;
   Indicador         *indicadorIchiTrend6;
   Indicador         *indicadorIchiSignal6;   
   
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
   indicadorMa1200 = new Indicador();
   indicadorMacd20x = new Indicador();
   indicadorMaCompare1200 = new Indicador();
   indicadorSar1200 = new Indicador();
   indicadorAdx168 = new Indicador();
   indicadorRsi84 = new Indicador();
   indicadorBollinger240 = new Indicador();
   indicadorMomentum1200 = new Indicador();
   indicadorIchiSignal6 = new Indicador();
   indicadorIchiTrend6 = new Indicador();

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
   
   cantidadVigencia = (int)StringToInteger(getValue(strEstrategia,"CANTIDAD_VIGENCIA"));

   maxConsecutiveLostOperationsNumber=(int)StringToInteger(getValue(strEstrategia,"MaxConsecutiveLostOperationsNumber","0"));
   maxConsecutiveWonOperationsNumber=(int)StringToInteger(getValue(strEstrategia,"MaxConsecutiveWonOperationsNumber","0"));
   minConsecutiveLostOperationsNumber=(int)StringToInteger(getValue(strEstrategia,"MinConsecutiveLostOperationsNumber","0"));
   minConsecutiveWonOperationsNumber=(int)StringToInteger(getValue(strEstrategia,"MinConsecutiveWonOperationsNumber","0"));
   averageConsecutiveLostOperationsNumber=(int)StringToDouble(getValue(strEstrategia,"AverageConsecutiveLostOperationsNumber","0"));
   averageConsecutiveWonOperationsNumber=(int)StringToDouble(getValue(strEstrategia,"AverageConsecutiveWonOperationsNumber","0"));

   obtenerValorIndicador("openMa", "openMa", indicadorMa, true, strEstrategia);
   obtenerValorIndicador("closeMa", "closeMa", indicadorMa, false, strEstrategia);

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
   obtenerValorIndicador("closeMomentum", "closeMomentum", indicadorMomentum, false, strEstrategia);

   obtenerValorIndicador("openIchiTrend", "openICHIMOKU_TREND", indicadorIchiTrend, true, strEstrategia);
   obtenerValorIndicador("closeIchiTrend", "closeICHIMOKU_TREND", indicadorIchiTrend, false, strEstrategia);
   
   obtenerValorIndicador("openIchiSignal", "openICHIMOKU_SIGNAL", indicadorIchiSignal, true, strEstrategia);
   obtenerValorIndicador("openIchiSignal", "openICHIMOKU_SIGNAL", indicadorIchiSignal, false, strEstrategia);
   
   obtenerValorIndicador("openMa1200", "openMa1200", indicadorMa1200, true, strEstrategia);
   obtenerValorIndicador("closeMa1200", "CloseMa1200", indicadorMa1200, false, strEstrategia);

   obtenerValorIndicador("openMacd20x", "openMacd20x", indicadorMacd20x, true, strEstrategia);
   obtenerValorIndicador("closeMacd20x", "closeMacd20x", indicadorMacd20x, false, strEstrategia);
   
   obtenerValorIndicador("openMaCompare1200", "openCompare1200_MA", indicadorMaCompare1200, true, strEstrategia);
   obtenerValorIndicador("closeMaCompare1200", "closeCompare1200_MA", indicadorMaCompare1200, false, strEstrategia);
   
   obtenerValorIndicador("openSar1200", "openSar1200", indicadorSar1200, true, strEstrategia);
   obtenerValorIndicador("closeSar1200", "closeSar1200", indicadorSar1200, false, strEstrategia);

   obtenerValorIndicador("openAdx168", "openAdx168", indicadorAdx168, true, strEstrategia);
   obtenerValorIndicador("closeAdx168", "closeAdx168", indicadorAdx168, false, strEstrategia);

   obtenerValorIndicador("openRsi84", "openRsi84", indicadorRsi84, true, strEstrategia);
   obtenerValorIndicador("closeRsi84", "closeRsi84", indicadorRsi84, false, strEstrategia);

   obtenerValorIndicador("openBollinger240", "openBollinger240", indicadorBollinger240, true, strEstrategia);
   obtenerValorIndicador("closeBollinger240", "closeBollinger240", indicadorBollinger240, false, strEstrategia);

   obtenerValorIndicador("openMomentum1200", "openMomentum1200", indicadorMomentum1200, true, strEstrategia);
   obtenerValorIndicador("closeMomentum1200", "closeMomentum1200", indicadorMomentum1200, false, strEstrategia);

   obtenerValorIndicador("openIchiTrend6", "openICHIMOKU_TREND6", indicadorIchiTrend6, true, strEstrategia);
   obtenerValorIndicador("closeIchiTrend6", "closeICHIMOKU_TREND6", indicadorIchiTrend6, false, strEstrategia);
   
   obtenerValorIndicador("openIchiSignal6", "openICHIMOKU_SIGNAL6", indicadorIchiSignal6, true, strEstrategia);
   obtenerValorIndicador("openIchiSignal6", "openICHIMOKU_SIGNAL6", indicadorIchiSignal6, false, strEstrategia);
   
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
   ";indicadorMa1200.openLower="+DoubleToString(indicadorMa1200.openLower)+
   ";indicadorMa1200.openHigher="+DoubleToString(indicadorMa1200.openHigher)+
   ";indicadorMacd20x.openLower="+DoubleToString(indicadorMacd20x.openLower)+
   ";indicadorMacd20x.openHigher="+DoubleToString(indicadorMacd20x.openHigher)+
   ";indicadorMaCompare1200.openLower="+DoubleToString(indicadorMaCompare1200.openLower)+
   ";indicadorMaCompare1200.openHigher="+DoubleToString(indicadorMaCompare1200.openHigher)+
   ";indicadorAdx168.openLower="+DoubleToString(indicadorAdx168.openLower)+
   ";indicadorAdx168.openHigher="+DoubleToString(indicadorAdx168.openHigher)+
   ";indicadorBollinger240.openLower="+DoubleToString(indicadorBollinger240.openLower)+
   ";indicadorBollinger240.openHigher="+DoubleToString(indicadorBollinger240.openHigher)+
   ";openIchiSignalLower6.openLower="+DoubleToString(indicadorIchiSignal6.openLower)+
   ";openIchiSignalHigher6.openHigher="+DoubleToString(indicadorIchiSignal6.openHigher)+
   ";openIchiTrendLower6.openLower="+DoubleToString(indicadorIchiTrend6.openLower)+
   ";openIchiTrendHigher6.openHigher="+DoubleToString(indicadorIchiTrend6.openHigher)+
   ";indicadorMomentum1200.openLower="+DoubleToString(indicadorMomentum1200.openLower)+
   ";indicadorMomentum1200.openHigher="+DoubleToString(indicadorMomentum1200.openHigher)+
   ";indicadorRsi84.openLower="+DoubleToString(indicadorRsi84.openLower)+
   ";indicadorRsi84.openHigher="+DoubleToString(indicadorRsi84.openHigher)+
   ";indicadorSar1200.openLower="+DoubleToString(indicadorSar1200.openLower)+
   ";indicadorSar1200.openHigher="+DoubleToString(indicadorSar1200.openHigher)+   
   
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
   ";indicadorRsi.closeHigher="+DoubleToString(indicadorRsi.closeHigher)+
   ";indicadorMa1200.closeLower="+DoubleToString(indicadorMa1200.closeLower)+
   ";indicadorMa1200.closeHigher="+DoubleToString(indicadorMa1200.closeHigher)+
   ";indicadorMacd20x.closeLower="+DoubleToString(indicadorMacd20x.closeLower)+   
   ";indicadorMacd20x.closeHigher="+DoubleToString(indicadorMacd20x.closeHigher)+
   ";indicadorMaCompare1200.closeLower="+DoubleToString(indicadorMaCompare1200.closeLower)+
   ";indicadorMaCompare1200.closeHigher="+DoubleToString(indicadorMaCompare1200.closeHigher)+
   ";indicadorAdx168.closeLower="+DoubleToString(indicadorAdx168.closeLower)+
   ";indicadorAdx168.closeHigher="+DoubleToString(indicadorAdx168.closeHigher)+
   ";indicadorBollinger240.closeLower="+DoubleToString(indicadorBollinger240.closeLower)+
   ";indicadorBollinger240.closeHigher="+DoubleToString(indicadorBollinger240.closeHigher)+
   ";openIchiSignalLower6.closeLower="+DoubleToString(indicadorIchiSignal6.closeLower)+
   ";openIchiSignalHigher6.closeHigher="+DoubleToString(indicadorIchiSignal6.closeHigher)+
   ";openIchiTrendLower6.closeLower="+DoubleToString(indicadorIchiTrend6.closeLower)+
   ";openIchiTrendHigher6.closeHigher="+DoubleToString(indicadorIchiTrend6.closeHigher)+
   ";indicadorMomentum1200.closeLower="+DoubleToString(indicadorMomentum1200.closeLower)+
   ";indicadorMomentum1200.closeHigher="+DoubleToString(indicadorMomentum1200.closeHigher)+
   ";indicadorRsi84.closeLower="+DoubleToString(indicadorRsi84.closeLower)+
   ";indicadorRsi84.closeHigher="+DoubleToString(indicadorRsi84.closeHigher)+
   ";indicadorSar1200.closeLower="+DoubleToString(indicadorSar1200.closeLower)+
   ";indicadorSar1200.closeHigher="+DoubleToString(indicadorSar1200.closeHigher)
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
