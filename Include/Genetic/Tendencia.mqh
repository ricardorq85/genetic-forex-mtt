//+------------------------------------------------------------------+
//|                                                    Tendencia.mqh |
//|                                                      ricardorq85 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "ricardorq85"
#property link      "https://www.mql5.com"
#include <Genetic\StringUtil.mqh>
#include <Genetic\IParaOperar.mqh>

class Tendencia : public IParaOperar
  {
private:
   StringUtil *stringUtil;

public:
   string            strTendencia;
   string            periodo;
   datetime          fechaTendencia;
   datetime          VigenciaLower;
   datetime          VigenciaHigher;   
   double            tp;
   double            sl;
   double            stopApertura;
   double            limitApertura;
   double            pendiente;
   bool              open;
   string            name;
   int               tipoOperacion;
   bool              limitSuperado;

                     Tendencia();
                    ~Tendencia();
                    Tendencia(const Tendencia &);
  void               initTendencia(string strEstrategia,int indexParam);
  bool               isValidForOpen(datetime currentTime);
  };

Tendencia::Tendencia(const Tendencia &){
   stringUtil = new StringUtil();
}

Tendencia::Tendencia()
  {
      stringUtil = new StringUtil();
  }

Tendencia::~Tendencia()
  {
  }

bool Tendencia::isValidForOpen(datetime inActiveTime) {
   if ((!active) || (open)) {
         return false;
      }
   if ((inActiveTime < VigenciaLower) || (inActiveTime > VigenciaHigher)) {
      if (inActiveTime > VigenciaHigher) {
         active = false;
      }
      return false;
   }
   //if (id == "927-1521312170642-4.0D" ) {
     // Print(id);
   //}   
   double pipsTP = MathAbs(precioCalculado - tp)/_Point;
   double pipsSL = MathAbs(precioCalculado - sl)/_Point;
   if ((pipsTP < 200) || (pipsSL < 200)) {
      //Print(id + " TakeProfit o StopLoss muy pequeno");
      active = false;
      return false;
   }
   if ((pipsSL > 100000)) {
      //Print(id + " StopLoss muy grande");
      active = false;
      return false;
   }
   //if (periodo != "EXTREMO") {
      //if (MathAbs(pendiente) < 0.0001) {
      //if (false) {
         //Print(id + " Pendiente no valida");
        // active = false;
         //return false;
      //}
   //}
      
   return true;
}

void Tendencia::initTendencia(string strEstrategia,int indexParam)
  {   
   strTendencia = strEstrategia;
   active=true;   
   open=false;
   index=indexParam;
   StringToUpper(strEstrategia);
   string v = stringUtil.getValue(strEstrategia,"ACTIVE");
   StringToUpper(v);
   if(v=="TRUE") {
      active=true;
   } else if(v=="FALSE") {
      active=false;
   }

   v = stringUtil.getValue(strEstrategia,"FECHA_TENDENCIA");
   StringReplace(v,"/",".");
   fechaTendencia=StringToTime(v);
   precioCalculado=StringToDouble(stringUtil.getValue(strEstrategia,"PRECIO_CALCULADO"));
   tp=StringToDouble(stringUtil.getValue(strEstrategia,"TAKE_PROFIT"));
   sl=StringToDouble(stringUtil.getValue(strEstrategia,"STOP_LOSS"));
   stopApertura=StringToDouble(stringUtil.getValue(strEstrategia,"STOP_APERTURA"));
   limitApertura=StringToDouble(stringUtil.getValue(strEstrategia,"LIMIT_APERTURA"));
   lote=StringToDouble(stringUtil.getValue(strEstrategia,"LOTE"));
   pendiente=StringToDouble(stringUtil.getValue(strEstrategia,"PENDIENTE"));

   if (limitApertura > 0) {
      limitSuperado = false;
   } else {
      limitSuperado = true;
   }
   v=stringUtil.getValue(strEstrategia,"TIPO_OPERACION");
   StringToUpper(v);
   if(v=="BUY") {
      tipoOperacion = ORDER_TYPE_BUY;
    } else if(v=="SELL") {
      tipoOperacion=ORDER_TYPE_SELL;
    }
   periodo = stringUtil.getValue(strEstrategia,"PERIOD");
   pair = stringUtil.getValue(strEstrategia,"PAIR");
   name = stringUtil.getValue(strEstrategia,"NAME");
   id = IntegerToString(index) + "-" + name + "-" + periodo;
   
   v = stringUtil.getValue(strEstrategia,"VIGENCIALOWER");
   StringReplace(v,"/",".");
   VigenciaLower = StringToTime(v);
   v = stringUtil.getValue(strEstrategia,"VIGENCIAHIGHER");
   StringReplace(v,"/",".");
   VigenciaHigher = StringToTime(v);      
  }
