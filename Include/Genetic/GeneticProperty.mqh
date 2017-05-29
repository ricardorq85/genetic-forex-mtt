//+------------------------------------------------------------------+
//|                                              GeneticProperty.mqh |
//|                                                      ricardorq85 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "ricardorq85"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Genetic\StringUtil.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class GeneticProperty
  {
private:
   StringUtil *stringUtil;
public:
                     GeneticProperty();
                    ~GeneticProperty();                    
void                 initProperty(string strEstrategia,int indexParam);

string             fechaInicio, fechaFin;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
GeneticProperty::GeneticProperty()
  {
   stringUtil = new StringUtil();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
GeneticProperty::~GeneticProperty()
  {
  }
//+------------------------------------------------------------------+
void GeneticProperty::initProperty(string strEstrategia,int indexParam)
  {   
   StringToUpper(strEstrategia);
   string v = stringUtil.getValue(strEstrategia,"FECHA_INICIO");
   fechaInicio=v;
   v = stringUtil.getValue(strEstrategia,"FECHA_FIN");
   fechaFin=v;
  }
