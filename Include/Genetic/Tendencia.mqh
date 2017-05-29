//+------------------------------------------------------------------+
//|                                                    Tendencia.mqh |
//|                                                      ricardorq85 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "ricardorq85"
#property link      "https://www.mql5.com"
#include <Genetic\StringUtil.mqh>

class Tendencia
  {
private:
   StringUtil *stringUtil;

public:
   datetime          fechaTendencia;
   datetime          VigenciaLower;
   datetime          VigenciaHigher;   
   double            precioCalculado;
   double            lote;
   double            tp;
   double            sl;
   double            pendiente;
   int               index;
   bool              active;
   bool              open;
   string            id;
   string            name;
   string            tipoOperacion;

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

bool Tendencia::isValidForOpen(datetime activeTime) {
   if ((!active) || (open)) {
         return false;
      }
      if ((activeTime < VigenciaLower) || (activeTime > VigenciaHigher)) {
         return false;
      }
      double pipsTP = MathAbs(precioCalculado - tp)/_Point;
      double pipsSL = MathAbs(precioCalculado - sl)/_Point;
      if ((pipsTP < 200) || (pipsSL < 200)) {
         Print("TakeProfit o StopLoss no valido");
         return false;
      }
      if (MathAbs(pendiente) < 0.001) {
         Print("Pendiente no valida");
         return false;
      }
      
      return true;
}

void Tendencia::initTendencia(string strEstrategia,int indexParam)
  {   
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
   fechaTendencia=StringToTime(v);
   precioCalculado=StringToDouble(stringUtil.getValue(strEstrategia,"PRECIO_CALCULADO"));
   tp=StringToDouble(stringUtil.getValue(strEstrategia,"TAKE_PROFIT"));
   sl=StringToDouble(stringUtil.getValue(strEstrategia,"STOP_LOSS"));
   lote=StringToDouble(stringUtil.getValue(strEstrategia,"LOTE"));
   pendiente=StringToDouble(stringUtil.getValue(strEstrategia,"PENDIENTE"));

   v=stringUtil.getValue(strEstrategia,"TIPO_OPERACION");
   StringToUpper(v);
   if(v=="BUY") {
      tipoOperacion = ORDER_TYPE_BUY;
    } else if(v=="SELL") {
      tipoOperacion=ORDER_TYPE_SELL;
    }
   name = stringUtil.getValue(strEstrategia,"NAME");
   id = index + "-" + name;
   
   v = stringUtil.getValue(strEstrategia,"VIGENCIALOWER");
   VigenciaLower = StringToTime(v);
   v = stringUtil.getValue(strEstrategia,"VIGENCIAHIGHER");
   VigenciaHigher = StringToTime(v);
   
  }
