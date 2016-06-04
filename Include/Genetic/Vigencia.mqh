//+------------------------------------------------------------------+
//|                                                    Estrategy.mqh |
//|                                                          RROJASQ |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "RROJASQ"
#property link      ""
#property version   "1.00"

#include <Genetic\Indicador.mqh>

class Vigencia
  {
public:
   datetime          VigenciaLower;
   datetime          VigenciaHigher;
   int               cantidadVigencia;

                     Vigencia();
                    ~Vigencia();
private:
  };
  
Vigencia::Vigencia()
  {
  }

Vigencia::~Vigencia()
  {
  }

