//+------------------------------------------------------------------+
//|                                                    Estrategy.mqh |
//|                                                          RROJASQ |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "RROJASQ"
#property link      ""
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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

   double            openMaLower;
   double            openMaHigher;
   double            closeMaLower;
   double            closeMaHigher;

   double            openMacdLower;
   double            openMacdHigher;
   double            closeMacdLower;
   double            closeMacdHigher;

   double            closeMaCompareLower;
   double            closeMaCompareHigher;
   double            openMaCompareLower;
   double            openMaCompareHigher;

   double            closeSarLower;
   double            closeSarHigher;
   double            openSarLower;
   double            openSarHigher;

   double            openAdxLower;
   double            openAdxHigher;
   double            closeAdxLower;
   double            closeAdxHigher;

   double            openRsiLower;
   double            openRsiHigher;
   double            closeRsiLower;
   double            closeRsiHigher;

   double            openBollingerLower;
   double            openBollingerHigher;
   double            closeBollingerLower;
   double            closeBollingerHigher;

   double            openMomentumLower;
   double            openMomentumHigher;
   double            closeMomentumLower;
   double            closeMomentumHigher;

   double            openIchiTrendLower;
   double            openIchiTrendHigher;
   double            closeIchiTrendLower;
   double            closeIchiTrendHigher;

   double            openIchiSignalLower;
   double            openIchiSignalHigher;
   double            closeIchiSignalLower;
   double            closeIchiSignalHigher;
   
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
   void              initEstrategias(string strEstrategia,int index);
   string            toString();

private:
   double            divide;
   string            getValue(string strEstrategia,string name);
   string            getValue(string strEstrategia,string name,string defaultValue);   
   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Estrategy::Estrategy()
  {
   divide=100;
   open=false;
   closeIndicator=false;
   openDate=NULL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Estrategy::~Estrategy()
  {
  }
//+------------------------------------------------------------------+
void Estrategy::initEstrategias(string strEstrategia,int indexParam)
  {
   active=true;
   StringToUpper(strEstrategia);
   string v=getValue(strEstrategia,"Active");
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

   openMaLower=NormalizeDouble(StringToDouble(getValue(strEstrategia,"openMaLower"))/divide,_Digits);
   openMaHigher=NormalizeDouble(StringToDouble(getValue(strEstrategia,"openMaHigher"))/divide,_Digits);

   openMacdLower=NormalizeDouble(StringToDouble(getValue(strEstrategia,"openMacdLower"))/divide,_Digits);
   openMacdHigher=NormalizeDouble(StringToDouble(getValue(strEstrategia,"openMacdHigher"))/divide,_Digits);

   openMaCompareLower=NormalizeDouble(StringToDouble(getValue(strEstrategia,"openMaCompareLower"))/divide,_Digits);
   openMaCompareHigher=NormalizeDouble(StringToDouble(getValue(strEstrategia,"openMaCompareHigher"))/divide,_Digits);
   if ((openMaCompareLower==-10000)||(openMaCompareHigher==10000)){
      openMaCompareLower=NormalizeDouble(StringToDouble(getValue(strEstrategia,"openCompare_MALower"))/divide,_Digits);
      openMaCompareHigher=NormalizeDouble(StringToDouble(getValue(strEstrategia,"openCompare_MAHigher"))/divide,_Digits);   
   }

   openSarLower=NormalizeDouble(StringToDouble(getValue(strEstrategia,"openSarLower"))/divide,_Digits);
   openSarHigher=NormalizeDouble(StringToDouble(getValue(strEstrategia,"openSarHigher"))/divide,_Digits);

   openAdxLower=NormalizeDouble(StringToDouble(getValue(strEstrategia,"openAdxLower"))/divide,_Digits);
   openAdxHigher=NormalizeDouble(StringToDouble(getValue(strEstrategia,"openAdxHigher"))/divide,_Digits);

   closeMaLower=NormalizeDouble(StringToDouble(getValue(strEstrategia,"closeMaLower"))/divide,_Digits);
   closeMaHigher=NormalizeDouble(StringToDouble(getValue(strEstrategia,"closeMaHigher"))/divide,_Digits);

   closeMacdLower=NormalizeDouble(StringToDouble(getValue(strEstrategia,"closeMacdLower"))/divide,_Digits);
   closeMacdHigher=NormalizeDouble(StringToDouble(getValue(strEstrategia,"closeMacdHigher"))/divide,_Digits);

   closeMaCompareLower=NormalizeDouble(StringToDouble(getValue(strEstrategia,"closeMaCompareLower"))/divide,_Digits);
   closeMaCompareHigher=NormalizeDouble(StringToDouble(getValue(strEstrategia,"closeMaCompareHigher"))/divide,_Digits);
   if ((closeMaCompareLower==-10000)||(closeMaCompareHigher==10000)){
      closeMaCompareLower=NormalizeDouble(StringToDouble(getValue(strEstrategia,"closeCompare_MALower"))/divide,_Digits);
      closeMaCompareHigher=NormalizeDouble(StringToDouble(getValue(strEstrategia,"closeCompare_MAHigher"))/divide,_Digits);   
   }

   closeSarLower=NormalizeDouble(StringToDouble(getValue(strEstrategia,"closeSarLower"))/divide,_Digits);
   closeSarHigher=NormalizeDouble(StringToDouble(getValue(strEstrategia,"closeSarHigher"))/divide,_Digits);

   closeAdxLower=NormalizeDouble(StringToDouble(getValue(strEstrategia,"closeAdxLower"))/divide,_Digits);
   closeAdxHigher=NormalizeDouble(StringToDouble(getValue(strEstrategia,"closeAdxHigher"))/divide,_Digits);

   openRsiLower=NormalizeDouble(StringToDouble(getValue(strEstrategia,"openRsiLower"))/divide,_Digits);
   openRsiHigher=NormalizeDouble(StringToDouble(getValue(strEstrategia,"openRsiHigher"))/divide,_Digits);

   closeRsiLower=NormalizeDouble(StringToDouble(getValue(strEstrategia,"closeRsiLower"))/divide,_Digits);
   closeRsiHigher=NormalizeDouble(StringToDouble(getValue(strEstrategia,"closeRsiHigher"))/divide,_Digits);

   openBollingerLower=NormalizeDouble(StringToDouble(getValue(strEstrategia,"openBollingerLower"))/divide,_Digits);
   openBollingerHigher=NormalizeDouble(StringToDouble(getValue(strEstrategia,"openBollingerHigher"))/divide,_Digits);

   closeBollingerLower=NormalizeDouble(StringToDouble(getValue(strEstrategia,"closeBollingerLower"))/divide,_Digits);
   closeBollingerHigher=NormalizeDouble(StringToDouble(getValue(strEstrategia,"closeBollingerHigher"))/divide,_Digits);

   openMomentumLower=NormalizeDouble(StringToDouble(getValue(strEstrategia,"openMomentumLower"))/divide,_Digits);
   openMomentumHigher=NormalizeDouble(StringToDouble(getValue(strEstrategia,"openMomentumHigher"))/divide,_Digits);

   closeMomentumLower=NormalizeDouble(StringToDouble(getValue(strEstrategia,"closeMomentumLower"))/divide,_Digits);
   closeMomentumHigher=NormalizeDouble(StringToDouble(getValue(strEstrategia,"closeMomentumHigher"))/divide,_Digits);
   
   openIchiTrendLower=NormalizeDouble(StringToDouble(getValue(strEstrategia,"openIchiTrendLower"))/divide,_Digits);
   openIchiTrendHigher=NormalizeDouble(StringToDouble(getValue(strEstrategia,"openIchiTrendHigher"))/divide,_Digits);
   if ((openIchiTrendLower==-10000)||(openIchiTrendHigher==10000)){
      openIchiTrendLower=NormalizeDouble(StringToDouble(getValue(strEstrategia,"openICHIMOKU_TRENDLower"))/divide,_Digits);
      openIchiTrendHigher=NormalizeDouble(StringToDouble(getValue(strEstrategia,"openICHIMOKU_TRENDHigher"))/divide,_Digits);   
   }

   closeIchiTrendLower=NormalizeDouble(StringToDouble(getValue(strEstrategia,"closeIchiTrendLower"))/divide,_Digits);
   closeIchiTrendHigher=NormalizeDouble(StringToDouble(getValue(strEstrategia,"closeIchiTrendHigher"))/divide,_Digits);
   if ((closeIchiTrendLower==-10000)||(closeIchiTrendHigher==10000)){
      closeIchiTrendLower=NormalizeDouble(StringToDouble(getValue(strEstrategia,"closeICHIMOKU_TRENDLower"))/divide,_Digits);
      closeIchiTrendHigher=NormalizeDouble(StringToDouble(getValue(strEstrategia,"closeICHIMOKU_TRENDHigher"))/divide,_Digits);
   }

   openIchiSignalLower=NormalizeDouble(StringToDouble(getValue(strEstrategia,"openIchiSignalLower"))/divide,_Digits);
   openIchiSignalHigher=NormalizeDouble(StringToDouble(getValue(strEstrategia,"openIchiSignalHigher"))/divide,_Digits);
   if ((openIchiSignalLower==-10000)||(openIchiSignalHigher==10000)){
      openIchiSignalLower=NormalizeDouble(StringToDouble(getValue(strEstrategia,"openICHIMOKU_SIGNALLower"))/divide,_Digits);
      openIchiSignalHigher=NormalizeDouble(StringToDouble(getValue(strEstrategia,"openICHIMOKU_SIGNALHigher"))/divide,_Digits);   
   }

   closeIchiSignalLower=NormalizeDouble(StringToDouble(getValue(strEstrategia,"closeIchiSignalLower"))/divide,_Digits);
   closeIchiSignalHigher=NormalizeDouble(StringToDouble(getValue(strEstrategia,"closeIchiSignalHigher"))/divide,_Digits);   
   if ((closeIchiSignalLower==-10000)||(closeIchiSignalHigher==10000)){
      closeIchiSignalLower=NormalizeDouble(StringToDouble(getValue(strEstrategia,"closeICHIMOKU_SIGNALLower"))/divide,_Digits);
      closeIchiSignalHigher=NormalizeDouble(StringToDouble(getValue(strEstrategia,"closeICHIMOKU_SIGNALHigher"))/divide,_Digits);
   }
  }
//+------------------------------------------------------------------+

string Estrategy::toString(){
 string str = "EstrategiaId="+EstrategiaId+";StopLoss="+IntegerToString((long)StopLoss)+";TakeProfit="+IntegerToString((long)TakeProfit)+
   ";openAdxLower="+IntegerToString((long)openAdxLower)+
   ";openAdxHigher="+IntegerToString((long)openAdxHigher)+
   ";openBollingerLower="+IntegerToString((long)openBollingerLower)+
   ";openBollingerHigher="+IntegerToString((long)openBollingerHigher)+
   ";openIchiSignalLower="+IntegerToString((long)openIchiSignalLower)+
   ";openIchiSignalHigher="+IntegerToString((long)openIchiSignalHigher)+
   ";openIchiTrendLower="+IntegerToString((long)openIchiTrendLower)+
   ";openIchiTrendHigher="+IntegerToString((long)openIchiTrendHigher)+
   ";openMaCompareLower="+IntegerToString((long)openMaCompareLower)+
   ";openMaCompareHigher="+IntegerToString((long)openMaCompareHigher)+
   ";openMaLower="+IntegerToString((long)openMaLower)+
   ";openMaHigher="+IntegerToString((long)openMaHigher)+
   ";openMacdLower="+IntegerToString((long)openMacdLower)+
   ";openMacdHigher="+IntegerToString((long)openMacdHigher)+
   ";openMomentumLower="+IntegerToString((long)openMomentumLower)+
   ";openMomentumHigher="+IntegerToString((long)openMomentumHigher)+
   ";openRsiLower="+IntegerToString((long)openRsiLower)+
   ";openRsiHigher="+IntegerToString((long)openRsiHigher)+
   ";openSarLower="+IntegerToString((long)openSarLower)+
   ";openSarHigher="+IntegerToString((long)openSarHigher)+
   ";closeAdxLower="+IntegerToString((long)closeAdxLower)+
   ";closeAdxHigher="+IntegerToString((long)closeAdxHigher)+
   ";closeBollingerLower="+IntegerToString((long)closeBollingerLower)+
   ";closeBollingerHigher="+IntegerToString((long)closeBollingerHigher)+
   ";closeIchiSignalLower="+IntegerToString((long)closeIchiSignalLower)+
   ";closeIchiSignalHigher="+IntegerToString((long)closeIchiSignalHigher)+
   ";closeIchiTrendLower="+IntegerToString((long)closeIchiTrendLower)+
   ";closeIchiTrendHigher="+IntegerToString((long)closeIchiTrendHigher)+
   ";closeMaCompareLower="+IntegerToString((long)closeMaCompareLower)+
   ";closeMaCompareHigher="+IntegerToString((long)closeMaCompareHigher)+
   ";closeMaLower="+IntegerToString((long)closeMaLower)+
   ";closeMaHigher="+IntegerToString((long)closeMaHigher)+
   ";closeMacdLower="+IntegerToString((long)closeMacdLower)+
   ";closeMacdHigher="+IntegerToString((long)closeMacdHigher)+
   ";closeMomentumLower="+IntegerToString((long)closeMomentumLower)+
   ";closeMomentumHigher="+IntegerToString((long)closeMomentumHigher)+
   ";closeRsiLower="+IntegerToString((long)closeRsiLower)+
   ";closeRsiHigher="+IntegerToString((long)closeRsiHigher)+
   ";closeSarLower="+IntegerToString((long)closeSarLower)+
   ";closeRsiHigher="+IntegerToString((long)closeRsiHigher)
   ;
 return str;
}

//+------------------------------------------------------------------+
string Estrategy::getValue(string strEstrategia,string name)
  {
   return getValue(strEstrategia,name,NULL);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
