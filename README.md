# Metatrader4-Ichimoku-KumoBreakOut
Simple MQL4 code that opens a trade when the price gets over the top of the kumo

The source may highly change, so I strongly advise that you review it entirely. It may be used as a good starting point for understanding the basics of MQL4 programming in Metatrader 4, as I myself created this code while trying to port MQL5 C code to MQL4 C Code.

Beware that this is financial stuff and that may be of high risk if used on real account. This is purely experimental.

I write Metatrader 5 algorithm since more than 3 years and I now write Metatrader 4 algorithms.

This is why I am now trying to port my MQL5 code to MQL4.

This is a basic trading algorithm based on Ichimoku break out very basic strategy.

I don't know if this is going to make you earn money.
This is a basic code that you will have to improve and adapt with eventually other indicators, or with more criterias from the ichimoku kinko hyo indicator.

Use on demo account.

Only the M15 version (IchimokuExpertM15.mq4) contains the most recent code.
While trying to compile the first time, there will be an error because I commented the line that sends orders. For compiling properly you will have to uncomment this line (but it will trade) or remove the line and the condition that is just after it in the code.

https://ichimoku-expert.blogspot.com
https://ntic974.blogspot.com

The trades are opened only for financial instruments with spreads that are lower than 0.00010
You can adapt this limitation in the code.

All financial instruments in the Market Watch window will be analyzed by the algorithm.

Only when a 15 minute new candle will appear, it will detect ichimoku criterias for all the financial instruments in the Market Watch window.

It will test if the previous 15 minute candlestick has its open price under the kumo top and has its close price over the kumo top.
If yes, then it will try to open a buy (long) position for the financial instrument being processed.

If you need support or for any inquiries contact me at the following email addresses (with object "Metatrader inquiry") :

reuniware@gmail.com

investdatasystems@yahoo.com

