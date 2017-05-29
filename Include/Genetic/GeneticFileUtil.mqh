//+------------------------------------------------------------------+
//|                                              GeneticFileUtil.mqh |
//|                                                      ricardorq85 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "ricardorq85"
#property link      "https://www.mql5.com"
#include <Genetic\Tendencia.mqh>
#include <Genetic\GeneticProperty.mqh>

class GeneticFileUtil {
   private:
   
   public:
                  GeneticFileUtil();
                  ~GeneticFileUtil();
      void   loadTendencias(string fileName, Tendencia& tendencias[]);
      void   loadAllTendencias(string directorySourceName, Tendencia& tendencias[]);
      void   loadProperties(string fileName, GeneticProperty& properties[]);
      void   deleteFile(string fileName);
};

GeneticFileUtil::GeneticFileUtil() {}
GeneticFileUtil::~GeneticFileUtil() {}

void GeneticFileUtil::deleteFile(string fileName) {   
   bool deleteStatus = FileDelete(fileName, FILE_COMMON);
   if (!deleteStatus) {
      Print("Error code "+IntegerToString(GetLastError()));
   }
}

void GeneticFileUtil::loadAllTendencias(string directorySourceName, Tendencia& tendencias[]) {
   ResetLastError();
   string fileName;
   long search_handle=FileFindFirst((directorySourceName+"*"), fileName, FILE_COMMON);
	do {
	 ResetLastError();
	 string loadFileName;
	 StringConcatenate(loadFileName, directorySourceName,fileName);
	 loadTendencias(loadFileName, tendencias);
	 string targetFileName = loadFileName;
	 StringReplace(targetFileName, "live", "processed");
	 FileMove(loadFileName, FILE_COMMON, targetFileName, FILE_COMMON);
	 Print("Moving Error code "+IntegerToString(GetLastError()));
	} while(FileFindNext(search_handle,fileName));
	FileFindClose(search_handle); 
}

void GeneticFileUtil::loadTendencias(string fileName, Tendencia& tendencias[])
  {
   Print("TERMINAL_PATH = ",TerminalInfoString(TERMINAL_PATH));
   Print("TERMINAL_DATA_PATH = ",TerminalInfoString(TERMINAL_DATA_PATH));
   Print("TERMINAL_COMMONDATA_PATH = ",TerminalInfoString(TERMINAL_COMMONDATA_PATH));
   ResetLastError();
   string fullFileName = fileName;
   datetime modifyTime = FileGetInteger(fullFileName, FILE_MODIFY_DATE,true);
   int handle=FileOpen(fullFileName,FILE_READ|FILE_ANSI|FILE_COMMON);

   if(handle>0)
     {
      int j=0;
      for(int i=0; !FileIsEnding(handle); i++)
        {
         string str=FileReadString(handle);
         StringTrimLeft(str);
         if(StringLen(str)==0) {
            i--;
         } else {
            Print("Tendencia String:"+IntegerToString(i)+" "+str);
            int arrayIndex = ArraySize(tendencias);
            ArrayResize(tendencias,arrayIndex+1);
            tendencias[arrayIndex].initTendencia(str,arrayIndex+1);
            Print("Tendencia cargada:"+IntegerToString(arrayIndex+1));
           }
        }
      FileClose(handle);
        }else{

      Print("Failed to open the file by the absolute path ");
      Print("Error code "+IntegerToString(GetLastError()));
     }
  }
  
void GeneticFileUtil::loadProperties(string fileName, GeneticProperty& properties[])
  {
   Print("TERMINAL_PATH = ",TerminalInfoString(TERMINAL_PATH));
   Print("TERMINAL_DATA_PATH = ",TerminalInfoString(TERMINAL_DATA_PATH));
   Print("TERMINAL_COMMONDATA_PATH = ",TerminalInfoString(TERMINAL_COMMONDATA_PATH));
   ResetLastError();
   string fullFileName = fileName;
   datetime modifyTime = FileGetInteger(fullFileName, FILE_MODIFY_DATE,true);
   int handle=FileOpen(fullFileName,FILE_READ|FILE_ANSI|FILE_COMMON);

   if(handle>0)
     {
      int j=0;
      for(int i=0; !FileIsEnding(handle); i++)
        {
         string str=FileReadString(handle);
         StringTrimLeft(str);
         if(StringLen(str)==0) {
            i--;
         } else {
            Print("Property String:"+IntegerToString(i)+" "+str);
            ArrayResize(properties,i+1);
            properties[i].initProperty(str,i+1);
            Print("Property cargada:"+IntegerToString(i));
           }
        }
      FileClose(handle);
     }else{
         Print("Failed to open the file by the absolute path ");
         Print("Error code "+IntegerToString(GetLastError()));
     }
  }