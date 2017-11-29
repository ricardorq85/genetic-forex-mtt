//+------------------------------------------------------------------+
//|                                            DynamicRS_3CLines.mq5 |
//|                           Copyright © 2006, Renato P. dos Santos |
//|                   inspired on 4xtraderCY's and SchaunRSA's ideas |
//|   http://www.strategybuilderfx.com/forums/showthread.php?t=16086 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Renato P. dos Santos"
#property link "http://www.strategybuilderfx.com/forums/showthread.php?t=16086"
//--- indicator version
#property version   "1.00"
//--- indicator description
#property description ""
//--- drawing the indicator in the main window
#property indicator_chart_window 
//--- three buffers are used for the indicator calculation and drawing
#property indicator_buffers 3
//---- three plots are used
#property indicator_plots   3
//+----------------------------------------------+
//|  Upper line 1 drawing parameters             |
//+----------------------------------------------+
//--- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//--- DarkOrange is used as the color of the indicator line
#property indicator_color1  clrDarkOrange
//--- the line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//--- indicator 1 line width is equal to 2
#property indicator_width1  2
//--- displaying the indicator label
#property indicator_label1  "Top"
//+----------------------------------------------+
//| Line 2 drawing parameters                    |
//+----------------------------------------------+
//--- drawing indicator 2 as a line
#property indicator_type2   DRAW_LINE
//--- the MediumPurple color is used as the color of the indicator line
#property indicator_color2  clrMediumPurple
//--- the line of the indicator 2 is a continuous curve
#property indicator_style2  STYLE_SOLID
//--- indicator 2 line width is equal to 2
#property indicator_width2  2
//--- displaying the indicator label
#property indicator_label2  "ExtMap"
//+----------------------------------------------+
//| Line 3 drawing parameters                    |
//+----------------------------------------------+
//--- drawing indicator 3 as a line
#property indicator_type3   DRAW_LINE
//--- the Lime color is used as the color of the indicator bearish line
#property indicator_color3  clrLime
//--- the line of the indicator 3 is a continuous curve
#property indicator_style3  STYLE_SOLID
//--- indicator 3 line width is equal to 2
#property indicator_width3  2
//--- display of the bearish indicator label
#property indicator_label3  "Bottom"
//+----------------------------------------------+
//| declaration of constants                     |
//+----------------------------------------------+
#define RESET 0  // A constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input int    Shift=0; // Horizontal shift of the indicator in bars
//+----------------------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double Ind1Buffer[];
double Ind2Buffer[];
double Ind3Buffer[];
//--- declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=2;
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,Ind1Buffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- shifting the starting point for drawing indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Ind1Buffer,true);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(1,Ind2Buffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//--- shifting the starting point for drawing indicator 2 by min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Ind2Buffer,true);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(2,Ind3Buffer,INDICATOR_DATA);
//--- shifting the indicator 3 horizontally by Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//--- shifting the starting point for drawing indicator 3 by min_rates_total
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Ind3Buffer,true);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"DynamicRS_3CLines");
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- initialization end
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the calculation of indicator
                const double& low[],      // price array of price lows for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total) return(RESET);
//--- declarations of local variables 
   int limit,bar;
//--- apply timeseries indexing to array elements  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- calculations of the necessary amount of data to be copied
//--- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-1-min_rates_total; // starting index for the calculation of all bars
      bar=limit+1;
      double res=(high[bar]+low[bar])/2;
      Ind1Buffer[bar]=res;
      Ind2Buffer[bar]=res;
      Ind3Buffer[bar]=res;
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
     }
//--- main calculation loop of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      Ind1Buffer[bar]=Ind1Buffer[bar+1];
      Ind2Buffer[bar]=Ind2Buffer[bar+1];
      Ind3Buffer[bar]=Ind3Buffer[bar+1];

      if(high[bar]<high[bar+1] && high[bar]<Ind2Buffer[bar+1])
        {
         Ind2Buffer[bar]=high[bar];
         Ind3Buffer[bar]=high[bar];
         Ind1Buffer[bar]=Ind1Buffer[bar+1];
        }
      else if(low[bar]>low[bar+1] && low[bar]>Ind2Buffer[bar+1])
        {
         Ind2Buffer[bar]=low[bar];
         Ind1Buffer[bar]=low[bar];
         Ind3Buffer[bar]=Ind3Buffer[bar+1];
        }
      else
        {
         Ind2Buffer[bar]=Ind2Buffer[bar+1];
         if(Ind2Buffer[bar+1]==Ind1Buffer[bar+1])
           {
            Ind1Buffer[bar]=Ind2Buffer[bar+1];
            Ind3Buffer[bar]=Ind3Buffer[bar+1];
           }
         else if(Ind2Buffer[bar+1]==Ind3Buffer[bar+1])
           {
            Ind3Buffer[bar]=Ind2Buffer[bar+1];
            Ind1Buffer[bar]=Ind1Buffer[bar+1];
           }
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
