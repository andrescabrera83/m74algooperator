


         // M74 ALGO ////////////////////////////////////////////////////////////////////////////////////////
         
         // ANDRÉS CABRERA - 2024 //////////////////////////////////////////////////////////////////////////
         
         /*
         
             this code
             serves as a trusty assistant to myself in navigating the intricacies of forex markets.
             the algorithm extracts simple technical indicators and market data to ellaborate new
             technical aproaches in order to make well-informed trading decisions.
             
         
         */
         
         //SETUPS/////////////////////////////////////////////////////////////////////////////////////////////
         
         #include <Trade\Trade.mqh>
         
         CTrade trade;
         
         bool autostops = false;
         bool rubberExtreme = false;
         
         
         // DATA COLLECTION ///////////////////////////////////////////////////////////////////////////////////
         
         
         double pips;
         
         bool isAlertTriggered = false;
        
         
         //Why the Average True Range?? -answer.
         
         // ATR INDICATOR
         
         int atrPeriod = 20; // You can adjust this period as needed
         double atrValue; // The ATR value will be stored in here.
         
         //Define an Array to store ATR values 
         int atrHandle;
         double atrBuffer[];
         
         // Function to get ATR value on a specific tick
         
         double getATR() {
            
               // Take ATR   
               ArraySetAsSeries(atrBuffer, true);
               atrHandle = iATR(_Symbol, _Period,atrPeriod);
               CopyBuffer(atrHandle,0,0,30,atrBuffer);
               
               atrValue = NormalizeDouble(atrBuffer[0],_Digits);
               return atrValue;
                        
         }



         // BOLLINGER BANDS INDICATOR

         int bbPeriod = 20; // period parameter
         double bbDeviation  = 1.75;  //deviation parameter
         
         double bbUpperValue; // store for bbupper value
         double bblowerValue; // store for bblower value
         
         // Define an array to store BB values
         
         int bbUpperHandle;
         int bbLowerHandle;
         double bbUpperBuffer[];
         double bbLowerBuffer[];
         
         double getUpperBB(){
                  
               ArraySetAsSeries(bbUpperBuffer, true);
               bbUpperHandle = iBands(_Symbol,_Period,bbPeriod,0,bbDeviation,PRICE_CLOSE);
               CopyBuffer(bbUpperHandle,1,0,5,bbUpperBuffer);
               
               bbUpperValue = NormalizeDouble(bbUpperBuffer[0],_Digits);
               
               return bbUpperValue;
                  
         }
            
         double getLowerBB(){
                  
               ArraySetAsSeries(bbLowerBuffer, true);
               bbLowerHandle = iBands(_Symbol,_Period,bbPeriod,0,bbDeviation,PRICE_CLOSE);
               CopyBuffer(bbLowerHandle,2,0,5,bbLowerBuffer);
               
               bblowerValue = NormalizeDouble(bbLowerBuffer[0],_Digits);
               
               return bblowerValue;
                  
         }
         
         
         //GET MOVING AVERAGES 
         
         // MOVING AVERAGE FOR THE CURRENT TIME FRAME
         
         int MaPeriod = 15; // You can adjust this period as needed
         double MaValue; // store for the ma values.
         
         //Define an Array to store ATR values 
         int maHandle;
         double maBuffer[];
         
         // Function to get MA on current time frame
         
         double getMA(){
         
            // Take MA   
               ArraySetAsSeries(maBuffer, true);
               maHandle = iMA(_Symbol, PERIOD_CURRENT,MaPeriod,0,MODE_SMA,PRICE_CLOSE);
               CopyBuffer(maHandle,0,0,30,maBuffer);
              
               MaValue = NormalizeDouble(maBuffer[0],6);
               return MaValue;
         

         }
         
         // MOVING AVERAGE FOR THE 30M
         
         int Ma30Period = 15; // You can adjust this period as needed
         double Ma30Value; // store for the ma values.
         
         //Define an Array to store ATR values 
         int ma30Handle;
         double ma30Buffer[];
         
         // Function to get ATR value on a specific tick
         
         double getMAM30() {
            
               // Take MA30M   
               ArraySetAsSeries(ma30Buffer, true);
               ma30Handle = iMA(_Symbol, PERIOD_M30,Ma30Period,0,MODE_SMA,PRICE_CLOSE);
               CopyBuffer(ma30Handle,0,0,30,ma30Buffer);
               
               Ma30Value = NormalizeDouble(ma30Buffer[0],6);
               return Ma30Value;
                        
         }
         
          // DOUBLE EXPOENTIAL MOVING AVERAGE (DEMA) FOR THE 30M
         
         int DemaPeriod = 10; // You can adjust this period as needed
         double DemaValue; // store for the ma values.
         
         //Define an Array to store ATR values 
         int DemaHandle;
         double DemaBuffer[];
         
         // Function to get ATR value on a specific tick
         
         double getDEMAM30() {
            
               // Take DEMA   
               ArraySetAsSeries(DemaBuffer, true);
               DemaHandle = iDEMA(_Symbol,PERIOD_M30,DemaPeriod,0,PRICE_CLOSE);
               CopyBuffer(DemaHandle,0,0,30,DemaBuffer);
               
               DemaValue = NormalizeDouble(DemaBuffer[0],6);
               return DemaValue;
                        
         }
         
          // GET LOWERBAND2 VALUE
         
         
         double getLB2(){
         
         double thisMa  = getMA();
         double thisLowerB = getLowerBB();
         double lb2Value = (thisMa + thisLowerB)/2;

         return lb2Value; 
            
         
         }
         
         double getUB2(){
         
         double thisMa  = getMA();
         double thisUpperB = getUpperBB();
         double ub2Value = (thisMa + thisUpperB)/2;

         return ub2Value; 
            
         
         }
         
         
         
         // why are we getting values for the ma and dema on 30minute timeframe?
         // thats simply because we want to determine under what circustances can we trade.
         // although thats really not the case here, we actually want to know what will be the type of the order.
         // is it gonna be a buy order or sell order? 
         // How do I determine that?
         // Well, as we are dealing with stochastic events normally this comes from the trader experience.
         // but as we are trying to systematize our trading plan we will have to adapt to numbers instead of gut.
         // The first step is getting two numbers, the first one is the Moving Average, and the second
         // one is the Double Exponential Moving Average. for more details about the function of moving averages check here ===> {imagine an explanation}
         // The second step is that we'll just simply see if dema is above or below the MA.
         // if Dema is above the Ma we´ll establish that we are on an Uptrend therefore, we can only Buy
         // if Dema is below the Ma then we'll just stablish the opposite, we can only sell.
         
         bool buyType = false;
         bool sellType = false;
         
         // the calculation will be determine on tick.
         
         
         
         // MAXIMUM RISK ALLOWED
         
         double risk = 0.015;
         double balance;
         
         
              
         // CHECK STOPS ///////////////////////////////////////////////////////////////////
         
         void CheckStops(){
         
         double theATR = getATR();
          
         pips = theATR * 1.5;
         
         double theAsk = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         double theBid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         double currentTakeProfit = PositionGetDouble(POSITION_TP);
         
        
               
               // Loop through all open positions
               for(int i = 0; i < PositionsTotal(); i++)
               {
               // Get the position ticket
               ulong ticket = PositionGetTicket(i);
               string symbol = PositionGetSymbol(i);
               
               // Check if the position exists
               if(ticket != -1 && _Symbol==symbol)
               {
               
               
               // Get the position type (OP_BUY or OP_SELL)
               ENUM_POSITION_TYPE positionType = PositionGetInteger(POSITION_TYPE);
               double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
               
               //double stoploss 
               
                double TP;
         
               
               double SLB;
               double SLS;
               
               // Determine if it's a buy or sell order
               if(positionType == POSITION_TYPE_BUY){
               
                     if (theAsk > openPrice){
                     
                        SLB = NormalizeDouble(theAsk - pips,_Digits);
                        TP = getUB2();
                        trade.PositionModify(ticket,SLB,TP);
                        
                     
                     }else if(theAsk <= openPrice){
                     
                        SLB = NormalizeDouble(openPrice - pips, _Digits);
                        TP = getMA();
                        trade.PositionModify(ticket,SLB,TP);
                     }
               }
               
               
               else if(positionType == POSITION_TYPE_SELL){
               
                     
                       if (theBid < openPrice){
                     
                        SLS = NormalizeDouble(theAsk + pips,_Digits);
                        TP = getLB2();
                        trade.PositionModify(ticket,SLS,TP);
                        
                     
                       }else if(theBid >= openPrice){
                     
                        SLS = NormalizeDouble(openPrice + pips, _Digits);
                        TP = getMA();
                        trade.PositionModify(ticket,SLS,TP);
                     }
                  }
               }
             }
         
         } 
         
         void CustomAlert(string message) {
            if (!isAlertTriggered) {
               Alert(message); // Display the alert message
               isAlertTriggered = true; // Set the flag to true indicating that alert has been triggered for this candle
            }
         }
         
         int counter = 0;
         int lastCounter;
         
         
          
         
         // ON TICK FUNCTION ////////////////////////////////////////////////////////////////////////////////////////////////////////


         void OnTick()
         {
         
         
         

   
         double currentATR;
         
         if(Symbol() == "BTCUSD"){
           currentATR = getATR() * 100;
         }else{
            currentATR = getATR();
         }
         double multipliedATR = currentATR * 1.25;
         double dividedATR = currentATR * 0.5;
         double normalizedMultipliedATR = NormalizeDouble(multipliedATR,_Digits);
         
         //GET BB VALUES
         double currentUpperBB = getUpperBB();
         double currentLowerBB = getLowerBB();
         
         double currentMA = getMA();
         
         //GET MA 30MINUTES VALUE
         double currentMA30M = getMAM30();
         //Print("MA 30M: ", currentMA30M);
         
         //GET DEMA VALUE
         double currentDEMA30M = getDEMAM30();
         //Print("DEMA 30M: ", currentDEMA30M);
         
         
         //ASK AND BID 
         double currentBid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         double currentAsk = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         
         //GET CURRENT PRICE
         double currentPrice = iClose(_Symbol,_Period,0);
         
         //GET CURRENT SPREAD
         long currentSpreadPoints = SymbolInfoInteger(Symbol(), SYMBOL_SPREAD);
         
         //GET CONTRACT SIZE
         double contractSize = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_CONTRACT_SIZE);
         
         //GET TICK SIZE
         double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE); 
         
         
         
         //DETERMINE WETHER IF DEMA IS ABOVE OR BELOW THE MA AND ESTABLISH THE TREND
         
         
         if(DemaValue > MaValue){
            
            buyType = true;
            //Print("UPTREND");
         
         }else if(DemaValue < MaValue){
         
            sellType = true;
            //Print("DOWNTREND");
         }else if(DemaValue == MaValue){
            
            //Print("Market's dead, no trend");
            buyType = false;
            sellType = false;
         
         }
         
         // pips to risk 
         
         double pipstoRisk  = currentATR * 1.5; 
         
         double pipsFull = NormalizeDouble((pipstoRisk * contractSize),_Digits);
         
    
    
         // CALCULATE LOT SIZE ////////////////////////////////////////////////////////////////////////////////////////////////////////
         
         //Calculate the Dollar Risk per Trade
         
         balance = AccountInfoDouble(ACCOUNT_BALANCE);
         
         double riskPerTrade = balance * risk; //the first parameter must be the account balance
         
         //Determine the Value of Each Pip
         
         double pipValue = riskPerTrade / pipsFull; 
         
         //Calculate the Lot Size
         
         double lotSize;
         
         if(currentATR > 0.00025){ // we establish we can only trade over 0.00035 ATR
         
            lotSize = pipValue / (tickSize * contractSize);
            lotSize = NormalizeDouble(lotSize,2);
            Comment("LOTS: ",lotSize, " TRADES ALLOWED");
         
         }
         
         else if (currentATR < 0.00025){
         
            lotSize = 0;
            Comment("LOTS: ",lotSize, " LOW ATR / NO TRADES ALLOWED");
         }
         
         
         
         //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
         
         
         // TRAILING PROFIT ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
         
         if (PositionsTotal()>0){
         
            if(autostops){
               CheckStops();
           }
         
         }
         
         
         // TICK COUNTING RECORDS AND EVENTS SYSTEM ////////////////////////////////////////////////////////////////////////////////////////////////////
         
         
         datetime currentTime = TimeCurrent();
         datetime currentCandle = iTime(_Symbol,PERIOD_CURRENT,0);
         datetime pastCandle = iTime(_Symbol, PERIOD_CURRENT, 1);

         if(currentTime == currentCandle){
            
            Print("new candle");
            counter = 0;
         }else if(currentCandle != pastCandle){
               
               if(currentPrice < currentLowerBB || currentPrice > currentUpperBB || currentPrice == currentMA)
               {
                     
                     isAlertTriggered = true;
                     //Print(isAlertTriggered);
                     
                     lastCounter += 1;
                     Print(counter + " : " + lastCounter);
      
                     }else{
                        counter += 1;
                        lastCounter = 0;
                        isAlertTriggered = false;
                        Print(counter + " : " + lastCounter);
                }
                     
                if(lastCounter == 1){
                     
                     Alert("Atention.. market under possibly favorable conditions");
                } 
               
          }
          
          
          
          
        
         //  DRAW EXTREME BANDS  ////////////////////////////////////////////////////////////////////////////////////
         
         double bbplusATR = currentUpperBB + dividedATR;
         double bbminusATR = currentLowerBB - dividedATR;
        
       
          if(currentPrice > bbplusATR){
          
               ObjectCreate(_Symbol,"line1",OBJ_HLINE,0,0,currentUpperBB);
               ObjectSetInteger(0,"line1",OBJPROP_COLOR,clrBlue);
               ObjectSetInteger(0,"line1",OBJPROP_WIDTH,1);
               ObjectMove(_Symbol,"line1",0,0,currentUpperBB);
               
               ObjectCreate(_Symbol,"line2",OBJ_HLINE,0,0,currentBid);
               ObjectSetInteger(0,"line2",OBJPROP_COLOR,clrCoral);
               ObjectSetInteger(0,"line2",OBJPROP_WIDTH,1);
               ObjectMove(_Symbol,"line2",0,0,currentBid);
          
          }else if(currentPrice < bbminusATR){
          
               ObjectCreate(_Symbol,"line1",OBJ_HLINE,0,0,currentLowerBB);
               ObjectSetInteger(0,"line1",OBJPROP_COLOR,clrBlue);
               ObjectSetInteger(0,"line1",OBJPROP_WIDTH,1);
               ObjectMove(_Symbol,"line1",0,0,currentLowerBB);
               
               ObjectCreate(_Symbol,"line2",OBJ_HLINE,0,0,currentAsk);
               ObjectSetInteger(0,"line2",OBJPROP_COLOR,clrCoral);
               ObjectSetInteger(0,"line2",OBJPROP_WIDTH,1);
               ObjectMove(_Symbol,"line2",0,0,currentAsk);
               
          }
          
          
         else{
         
               ObjectDelete(0,"line1");
               ObjectDelete(0,"line2");
         
         
         }
         
         //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////     TEXT ON THE CHART
         
         //DISPLAY ATR ON CHART    
       
         string oName="Name";
         string text= DoubleToString(currentATR,_Digits);
         datetime tim=iTime(_Symbol,PERIOD_CURRENT,1);
         double price=iHigh(_Symbol,PERIOD_CURRENT,1);
         ObjectCreate(0,oName,OBJ_TEXT,0,tim,price);
         ObjectSetString(0,oName,OBJPROP_TEXT,text);
       
         }
         
         
         
