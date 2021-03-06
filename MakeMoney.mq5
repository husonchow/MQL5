//+------------------------------------------------------------------+
//|                                                    MakeMoney.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\AccountInfo.mqh>//账户信息
#include <Trade\DealInfo.mqh>//交易类 只针对已经发生了交易的
#include <Trade\HistoryOrderInfo.mqh>//历史订单，可能包括没有交易成功的订单
#include <Trade\OrderInfo.mqh>//订单类
#include <Trade\SymbolInfo.mqh>//货币基础类
#include <Trade\PositionInfo.mqh>//仓位
#include <Trade\Trade.mqh>//交易类
//创建基本对象
CPositionInfo     myPosition;  //持仓对象
CSymbolInfo mySymbol;//品种(货币)对象
CAccountInfo myAccount;//账户对象
CHistoryOrderInfo myHistoryOrderInfo;//
CTrade myTrade;//交易对象
CDealInfo myDealInfo;//已经交易的订单对象（已经交易）
double lastMinutePrice;//最近一次整分钟点的价格（时时最新）
double mvLastMinutePrice;//最近一次整分钟点的价格（25日移动平均线）Moving Average
bool isSsynchronism=true;//是否线程同步，只有等目前没有挂单的时候才可以交易,也就是上一次的交易已经被完全执行
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//进行初始化前的安全校验
   bool checkInitTrade=checkInitTrade();
   if(!checkInitTrade)
     {
      printf("校验没有通过 不可以交易");
      return(INIT_FAILED);//校验没有通过 不可以交易
     }
     
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+
//检查当前是否可以交易（仅仅用在初始化的时候）
bool checkInitTrade()
  {

//查看当前交易品种
   if(!mySymbol.Name("EURUSD"))
     {
      printf("当前品种不是EURUSD,不进行交易！！！");
      return false;
     }
//查看当前账号
//long  accountId = 7345113 ;
   long  accountId=8436620;
   if(!myAccount.Login()==accountId)
     {
      printf("当前登录账号不对,不能进行交易！！！");
      return false;
     }
//查看当前交易模式
   if(!myAccount.TradeMode()==ACCOUNT_TRADE_MODE_DEMO)
     {
      printf("当前账号交易模式不是模拟账户,不进行交易！！！");
      return false;
     }
//确保是线程安全！！！！
   if(!myAccount.TradeAllowed() || !myAccount.TradeExpert() || !mySymbol.IsSynchronized())
     {
      printf("账户异常,不能交易！！！");
      return false;
     }
   int ordersTotal=OrdersTotal();//当前挂单量
   if(ordersTotal>0)
     {
      printf("当前账户有未完成的订单，不能继续交易！！");
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
