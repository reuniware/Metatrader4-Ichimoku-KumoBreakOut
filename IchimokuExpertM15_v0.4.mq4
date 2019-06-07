//+------------------------------------------------------------------+
//|                                            IchimokuExpertM15.mq4 |
//|                     Copyright 2017, https://ntic974.blogspot.com |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, https://ntic974.blogspot.com"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int file_handle=INVALID_HANDLE; // File handle
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
                                //string exportPath = "C:\\Users\\InvesdataSystems\\Documents\\NetBeansProjects\\investdata\\public_html\\alerts\\data_history";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetTimer(10);
   printf("exportDir = "+TerminalInfoString(TERMINAL_COMMONDATA_PATH));
   MqlDateTime mqd;
   TimeCurrent(mqd);
   string timestamp=string(mqd.year)+IntegerToString(mqd.mon,2,'0')+IntegerToString(mqd.day,2,'0')+IntegerToString(mqd.hour,2,'0')+IntegerToString(mqd.min,2,'0')+IntegerToString(mqd.sec,2,'0');

   file_handle=FileOpen(timestamp+"_backup.csv",FILE_CSV|FILE_WRITE|FILE_ANSI|FILE_COMMON);
   if(file_handle>0)
     {
      FileWrite(file_handle,"Timestamp;Name;Buy;Sell;Spread;Broker");
     }
   else 
     {
      printf("error : "+GetLastError());
     }

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
//--- Close the file
   FileClose(file_handle);

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
MqlDateTime mqd_ot;
MqlTick last_tick_ot;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   int stotal=SymbolsTotal(true); // seulement les symboles dans le marketwatch (false)
   string sname="";

   for(int sindex=0; sindex<stotal; sindex++)
     {
      sname=SymbolName(sindex,true);
      //printf("processing "+sname);

      // export des données :)
      if(file_handle>0)
        {
         TimeCurrent(mqd_ot);
         string timestamp=string(mqd_ot.year)+"-"+IntegerToString(mqd_ot.mon,2,'0')+"-"+IntegerToString(mqd_ot.day,2,'0')+" "+IntegerToString(mqd_ot.hour,2,'0')+":"+IntegerToString(mqd_ot.min,2,'0')+":"+IntegerToString(mqd_ot.sec,2,'0')+"."+GetTickCount();

         double prix_achat;
         double prix_vente;
         double spread;

         if(SymbolInfoTick(sname,last_tick_ot))
           {
            prix_achat = last_tick_ot.ask;
            prix_vente = last_tick_ot.bid;

            string str_prix_achat = DoubleToString(prix_achat);
            string str_prix_vente = DoubleToString(prix_vente);
            string str_spread = DoubleToString(prix_achat-prix_vente);
            string str_broker = AccountCompany();

            FileWrite(file_handle,timestamp+";"+sname+";"+str_prix_achat+";"+str_prix_vente+";"+str_spread+";"+str_broker);
            //sell affiché par défaut dans MT5
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
double open_arrayM15[];
double high_arrayM15[];
double low_arrayM15[];
double close_arrayM15[];

bool first_run_done=false;
static datetime LastBarTime[];//=-1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(first_run_done==false)
     {
      int stotal=SymbolsTotal(true); // seulement les symboles dans le marketwatch (false)

      ArrayResize(LastBarTime,stotal);

      //initialisation de tout le tableau à false car sinon la première valeur vaut true par défaut (bug?).
      for(int sindex=0; sindex<stotal; sindex++)
        {
         LastBarTime[sindex]=-1;
        }

      first_run_done=true;
     }

   int stotal=SymbolsTotal(true); // seulement les symboles dans le marketwatch (false)

   for(int sindex=0; sindex<stotal; sindex++)
     {
      string sname=SymbolName(sindex,true);
      //printf("processing "+sname);

      // export des données :)
/*if(file_handle>0)
        {
         MqlDateTime mqd;
         TimeCurrent(mqd);
         string timestamp=string(mqd.year)+"-"+IntegerToString(mqd.mon,2,'0')+"-"+IntegerToString(mqd.day,2,'0')+" "+IntegerToString(mqd.hour,2,'0')+":"+IntegerToString(mqd.min,2,'0')+":"+IntegerToString(mqd.sec,2,'0')+"."+GetTickCount();

         MqlTick last_tick;
         double prix_achat;
         double prix_vente;
         double spread;

         if(SymbolInfoTick(sname,last_tick))
           {
            prix_achat = last_tick.ask;
            prix_vente = last_tick.bid;
            FileWrite(file_handle,timestamp+";"+sname+";"+DoubleToString(prix_achat)+";"+DoubleToString(prix_vente)+";"+DoubleToString(prix_achat-prix_vente)+";"+AccountCompany());
            //sell affiché par défaut dans MT5
           }
        }*/

      MqlTick last_tick;
      double prix_achat;
      double prix_vente;
      double spread;

      bool positionFound=false;
      if(SymbolInfoTick(sname,last_tick))
        {
         prix_achat = last_tick.ask;
         prix_vente = last_tick.bid;
         spread=prix_achat-prix_vente;
         //if(spread<0.00010)
         //{
         //Print(sname+" : "+last_tick.time,": PV=",prix_vente," PA=",prix_achat," Volume=",last_tick.volume," Spread="+spread);

         int total=OrdersTotal();
         for(int pos=0;pos<total;pos++)
           {
            if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
            //printf(OrderTicket()+" "+OrderOpenPrice()+" "+OrderOpenTime()+" "+OrderSymbol()+" "+OrderLots());

            bool showOrderProfit=false;
            bool closeOrderIfProfitOver=true;
            if(showOrderProfit) printf(OrderSymbol()+" : profit = "+OrderProfit());
            if(OrderProfit()>5)
              {
               if(closeOrderIfProfitOver) OrderClose(OrderTicket(),0.1,prix_achat,3,Red);
              }

            if(OrderSymbol()==sname)
              {
               positionFound=true;
              }
           }

         if(positionFound)
           {
            //printf(sname+" : Position(s) existing");
              } else {
            //printf(sname+" : No Position(s) existing");
           }
         //}
        }
      else Print("SymbolInfoTick() failed, error = ",GetLastError());

      double cs26=iIchimoku(sname,PERIOD_M15,9,26,52,MODE_CHIKOUSPAN,26);
      double cs27=iIchimoku(sname,PERIOD_M15,9,26,52,MODE_CHIKOUSPAN,27);
      double tenkan_sen=iIchimoku(sname,PERIOD_M15,9,26,52,MODE_TENKANSEN,1);
      double kijun_sen=iIchimoku(sname,PERIOD_M15,9,26,52,MODE_KIJUNSEN,1);
      double ssa=iIchimoku(sname,PERIOD_M15,9,26,52,MODE_SENKOUSPANA,1); // ssa bougie precedente
      double ssb=iIchimoku(sname,PERIOD_M15,9,26,52,MODE_SENKOUSPANB,1); // ssb bougie precedente
      double ssa26=iIchimoku(sname,PERIOD_M15,9,26,52,MODE_SENKOUSPANA,26); // ssa bougie precedente
      double ssb26=iIchimoku(sname,PERIOD_M15,9,26,52,MODE_SENKOUSPANB,26); // ssb bougie precedente
      double ssa27=iIchimoku(sname,PERIOD_M15,9,26,52,MODE_SENKOUSPANA,27); // ssa bougie precedente
      double ssb27=iIchimoku(sname,PERIOD_M15,9,26,52,MODE_SENKOUSPANB,27); // ssb bougie precedente
      
      bool chikouSpanCrossedKumoTopWhileUp=false;
      if (ssa26>ssb26 && ssa27>ssb27){
         if (cs27<ssa27 && cs26>ssa26){
            chikouSpanCrossedKumoTopWhileUp=true;
         }
      }
      if (ssb26>ssa26 && ssb27>ssb27){
         if (cs27<ssb27 && cs26>ssb26){
            chikouSpanCrossedKumoTopWhileUp=true;
         }
      }
 
      if (chikouSpanCrossedKumoTopWhileUp){
         printf(sname + " : Chikou Span croosed kumo while up.");
      }
 
      bool chikouSpanIsOverKumo=false;
      if (cs26>ssa26 && cs26>ssb26){
         chikouSpanIsOverKumo=true;
      }
      
      if(sname=="GBPCAD")
        {
         printf(sname+" : cs26 = "+DoubleToString(cs26));
         printf(sname+" : cs27 = "+DoubleToString(cs27));
         printf(sname+" : ssa26 = "+DoubleToString(ssa26));
         printf(sname+" : ssb26 = "+DoubleToString(ssb26));
         /*printf(sname+" : kijun sen = "+DoubleToString(kijun_sen));
         printf(sname+" : tenkan sen = "+DoubleToString(tenkan_sen));
         printf(sname+" : PA = "+DoubleToString(prix_achat));
         printf(sname+" : PV = "+DoubleToString(prix_vente));*/
         /*if (prix_achat<ssb) printf("PA<SSB");
         if (prix_achat>ssb) printf("PA>SSB");
         if (prix_vente<ssb) printf("PV<SSB");
         if (prix_vente>ssb) printf("PV>SSB");*/
        }


      datetime ThisBarTime=(datetime)SeriesInfoInteger(sname,PERIOD_M15,SERIES_LASTBAR_DATE);
      if(ThisBarTime==LastBarTime[sindex])
        {
         //printf("Same bar time ("+sname+")");
        }
      else
        {
         if(LastBarTime[sindex]==-1)
           {
            //printf("First bar ("+sname+")");
            LastBarTime[sindex]=ThisBarTime;
           }
         else
           {
            //printf("New bar time ("+sname+")");
            LastBarTime[sindex]=ThisBarTime;

            ArraySetAsSeries(open_arrayM15,true);
            int numO=CopyOpen(sname,PERIOD_M15,0,32,open_arrayM15);
            ArraySetAsSeries(high_arrayM15,true);
            int numH=CopyHigh(sname,PERIOD_M15,0,32,high_arrayM15);
            ArraySetAsSeries(low_arrayM15,true);
            int numL=CopyLow(sname,PERIOD_M15,0,32,low_arrayM15);
            ArraySetAsSeries(close_arrayM15,true);
            int numC=CopyClose(sname,PERIOD_M15,0,32,close_arrayM15);

            //printf(sname+" : jcs(-1) open = "+DoubleToString(open_arrayM1[1]));
            //printf(sname+" : jcs(-1) close = "+DoubleToString(close_arrayM1[1]));

            bool priceCrossedKumoTopWhileUp=false;
            bool currentJCSIsOverKumoTop=false;
            if(ssa>ssb)
              {
               if(open_arrayM15[1]<ssa && close_arrayM15[1]>ssa)
                 {
                  SendNotification(sname+" : jcs(m15(-1)) has crossed kumo top (ssa>ssb) while up.");
                  priceCrossedKumoTopWhileUp=true;

                  if(open_arrayM15[0]>ssa && close_arrayM15[0]>ssa)
                    {
                     SendNotification(sname+" : *** and current jcs is over kumo top (ssa>ssb). ***");
                     currentJCSIsOverKumoTop=true;
                    }

                 }
              }
            if(ssb>ssa)
              {
               if(open_arrayM15[1]<ssb && close_arrayM15[1]>ssb)
                 {
                  SendNotification(sname+" : jcs(m15(-1)) has crossed kumo top (ssb>ssa) while up.");
                  priceCrossedKumoTopWhileUp=true;

                  if(open_arrayM15[0]>ssb && close_arrayM15[0]>ssb)
                    {
                     SendNotification(sname+" : *** and current jcs is over kumo top (ssb>ssa). ***");
                    }
                 }
              }

            if(priceCrossedKumoTopWhileUp && currentJCSIsOverKumoTop && chikouSpanIsOverKumo)
              {
               if(!positionFound && spread<0.00015)
                 {
                  //double stoploss=prix_achat-0.00015*5;
                  double stoploss=0;
                  double takeprofit=prix_achat+spread+0.00010;

                  bool enableTrading=false;
                  if(enableTrading)
                    {
                     int ticket=OrderSend(sname,OP_BUY,0.01,prix_achat,3,stoploss,takeprofit,"My order",16384,0,clrGreen);
                     if(ticket<0)
                       {
                        Print(sname+" : OrderSend failed with error #",GetLastError());
                       }
                     else
                        Print(sname+" : OrderSend placed successfully");
                    }

                 }

              }

            if(open_arrayM15[1]<kijun_sen && close_arrayM15[1]>kijun_sen)
              {
               SendNotification(sname+" : jcs(m15(-1)) has crossed kijun while up.");
              }

           }
        }

     }
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---

  }
//+------------------------------------------------------------------+
