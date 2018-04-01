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
      void   saveTendencias(string parentName, Tendencia& tendencias[]);
      void   loadProperties(string fileName, GeneticProperty& properties[]);
      void   deleteFile(string fileName);
};

GeneticFileUtil::GeneticFileUtil() {}
GeneticFileUtil::~GeneticFileUtil() {}

void GeneticFileUtil::saveTendencias(string parentName, Tendencia& tendencias[]) {   
   static int FILE_COUNT=1;
   string fullFileName = parentName + (TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES));
   StringReplace(fullFileName, " ", "_");
   StringReplace(fullFileName, ".", "");
   StringReplace(fullFileName, ":", "");
   StringAdd(fullFileName, "-"+FILE_COUNT);
   FILE_COUNT++;
   
   StringAdd(fullFileName, ".csv");
   ResetLastError();
   bool created = false;      
   int fileHandle;
   for(int i=0; i<ArraySize(tendencias); i++) {
      if (tendencias[i].active) {
         if (!created) {
            fileHandle=FileOpen(fullFileName,FILE_WRITE|FILE_ANSI|FILE_COMMON);
            created = true;
         }
         if(fileHandle != INVALID_HANDLE) {
            FileWrite(fileHandle,tendencias[i].strTendencia);               
         }else {
            Print("FileOpen Error code "+IntegerToString(GetLastError()));
            break;
         }
      }
   }
   if (created && (fileHandle != INVALID_HANDLE)) {
      FileClose(fileHandle);
   }
}

void GeneticFileUtil::deleteFile(string fileName) { 
   ResetLastError();  
   bool deleteStatus = FileDelete(fileName, FILE_COMMON);
   if (!deleteStatus) {
      Print("Deleting Error code "+IntegerToString(GetLastError()));
   }
}

void GeneticFileUtil::loadAllTendencias(string directorySourceName, Tendencia& tendencias[]) {
   ResetLastError();
   string fileName;
   long search_handle=FileFindFirst((directorySourceName+"*"), fileName, FILE_COMMON);
   if(search_handle!=INVALID_HANDLE) {
   	do {
   	 ResetLastError();
   	 string loadFileName;
   	 StringConcatenate(loadFileName, directorySourceName,fileName);
   	 loadTendencias(loadFileName, tendencias);
   	 string targetFileName = loadFileName;
   	 StringReplace(targetFileName, "live", "processed");
   	 FileMove(loadFileName, FILE_COMMON, targetFileName, FILE_COMMON);
   	 if (GetLastError() != 0) {
   	   Print("Moving Error code: "+ loadFileName + ":" +IntegerToString(GetLastError()));
   	 }
   	} while(FileFindNext(search_handle,fileName));
	} else {
	   Print("No hay archivos");
	}
	FileFindClose(search_handle); 
}

void GeneticFileUtil::loadTendencias(string fileName, Tendencia& tendencias[])
  {
   //Print("TERMINAL_PATH = ",TerminalInfoString(TERMINAL_PATH));
   //Print("TERMINAL_DATA_PATH = ",TerminalInfoString(TERMINAL_DATA_PATH));
   //Print("TERMINAL_COMMONDATA_PATH = ",TerminalInfoString(TERMINAL_COMMONDATA_PATH));
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
            //Print("Tendencia cargada:"+IntegerToString(arrayIndex+1));
           }
        }
      FileClose(handle);
        }else{

      Print("Failed to open the file by the absolute path ");
      Print("Error code:" +fullFileName + ":" + IntegerToString(GetLastError()));
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
            //Print("Property cargada:"+IntegerToString(i));
           }
        }
      FileClose(handle);
     }else{
         Print("Failed to open the file by the absolute path ");
         Print("Error code "+IntegerToString(GetLastError()));
     }
  }