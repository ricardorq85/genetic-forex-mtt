//+------------------------------------------------------------------+
//|                                                   StringUtil.mqh |
//|                                                      ricardorq85 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "ricardorq85"
#property link      "https://www.mql5.com"

class StringUtil {
   private:

   public:
      StringUtil();
      ~StringUtil();
      string            getValue(string strEstrategia,string name);
      string            getValue(string strEstrategia,string name,string defaultValue);

};

StringUtil::StringUtil()
  {
  }

StringUtil::~StringUtil()
  {
  }

string StringUtil::getValue(string strEstrategia,string name)
  {
   return getValue(strEstrategia,name,NULL);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string StringUtil::getValue(string strEstrategia,string name,string defaultValue)
  {
   string value;
   string strValue="";
   StringToUpper(name);
   int indexName=StringFind(strEstrategia,name,0);
   if(indexName<0) {
      strValue="null";
   } else {
      int indexEqual = StringFind(strEstrategia,"=",indexName);
      int indexComma = StringFind(strEstrategia,",",indexName);
      strValue=StringSubstr(strEstrategia,indexEqual+1,indexComma-indexEqual-1);
      if(StringLen(strValue)==0) {
         strValue="null";
      }
   }
   if((strValue=="null")) {
      value=defaultValue;
   } else {
      value=(strValue);
   }
   return(value);
}
