//+------------------------------------------------------------------+
//|                                                    Tendencia.mq5 |
//|                                                      ricardorq85 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include <Genetic\Tendencia.mqh>
#include <Genetic\GeneticFileUtil.mqh>

//#property indicator_separate_window
#property copyright "ricardorq85"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot Label1
//#property indicator_label1  "Tendencia"
#property indicator_type1   DRAW_LINE
//#property indicator_color1  clrDeepSkyBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input string   FileName="Tendencias.csv";
//--- indicator buffers
double         TendenciaBuffer[];
Tendencia      tendencias[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
   return inicializar();
}

int inicializar()
  {
   GeneticFileUtil *fileUtil = new GeneticFileUtil();
   string fName = "estrategias\\" + FileName;
   fileUtil.loadTendencias(fName, tendencias);
   SetIndexBuffer(0,TendenciaBuffer,INDICATOR_DATA);
   
   string name = FileName;
   StringReplace(name,".csv","");
   IndicatorSetString(INDICATOR_SHORTNAME,name);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetString(0,PLOT_LABEL,name);
   PlotIndexSetInteger(0,PLOT_SHIFT,0);
   
   string strFileName = FileName;
   StringToUpper(strFileName);
   if (StringFind(strFileName,"12H")>=0) {
      PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,clrSnow);   
   } else if (StringFind(strFileName,"2H")>=0) {
      PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,clrDarkOrchid);
   } else if (StringFind(strFileName,"6H")>=0) {      
      PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,clrRed); 
   } else if (StringFind(strFileName,"1D")>=0) {
      PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,clrBlue); 
   } else if (StringFind(strFileName,"2D")>=0) {
      PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,clrGreen); 
   } else if (StringFind(strFileName,"3D")>=0) {
      PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,clrFireBrick);       
   } else if (StringFind(strFileName,"5D")>=0) {
      PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,clrDeepSkyBlue);
   } else if (StringFind(strFileName,"6D")>=0) {
      PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,clrChocolate);      
   } else if (StringFind(strFileName,"7D")>=0) {
      PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,clrBlanchedAlmond);
   } else if (StringFind(strFileName,"8D")>=0) {
      PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,clrDarkCyan);
   } else if (StringFind(strFileName,"9D")>=0) {
      PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,clrDarkOrange);      
   } else if (StringFind(strFileName,"10D")>=0) {
      PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,clrDarkBlue);      
   } else {
      PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,clrDarkOrange); 
   }   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int rt = rates_total;
   if (time[rates_total-1]>=tendencias[0].fechaTendencia) {
      int tSize = ArraySize(tendencias);
      for(int shift=prev_calculated;shift<rates_total && !IsStopped();shift++) {
         if (time[shift]<=tendencias[tSize-1].fechaTendencia) {
            for(int t=0;t<tSize && !IsStopped();t++) {
               datetime nextTime = TimeCurrent();
               if (t < tSize-1){
                  nextTime = tendencias[t+1].fechaTendencia;
               }
               if ((time[shift]>=tendencias[t].fechaTendencia)&&(time[shift]<nextTime)) {
                  TendenciaBuffer[shift] = tendencias[t].precioCalculado;
                  break;
               } else if ((shift>0)&&(tendencias[t].fechaTendencia)>(time[shift])) {            
                  TendenciaBuffer[shift] = TendenciaBuffer[shift-1];
                  break;
               }
            }
         }
      }      
   }   
   return(rt);
  }

void OnChartEvent(const int id,         // Event ID 
                  const long& lparam,   // Parameter of type long event 
                  const double& dparam, // Parameter of type double event 
                  const string& sparam  // Parameter of type string events 
                  )
                  {
      //inicializar();
  }