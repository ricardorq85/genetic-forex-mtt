//+------------------------------------------------------------------+
//|                                                    Indicador.mqh |
//|                                                      ricardorq85 |
//+------------------------------------------------------------------+
#property copyright "ricardorq85"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Indicador
  {
private:

public:
   string            name;
   double            openLower;
   double            openHigher;
   bool              hasOpen;

   double            closeLower;
   double            closeHigher;
   bool              hasClose;

                     Indicador(string n);
                    ~Indicador();
   bool              open(double value);
   bool              close(double value);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Indicador::Indicador(string n)
  {
   name=n;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Indicador::~Indicador()
  {
  }
//+------------------------------------------------------------------+

bool Indicador::open(double value) 
  {
   bool val=false;

   val=((!hasOpen)
        ||((value>=openLower)
        && (value<=openHigher)));
   return val;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Indicador::close(double value) 
  {
   bool val=false;

   val=((!hasClose)
        ||((value>=closeLower)
        && (value<=closeHigher)));
   return val;
  }
//+------------------------------------------------------------------+
