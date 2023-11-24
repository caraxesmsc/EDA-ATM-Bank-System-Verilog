module ATMmodule(

input clk;
input [3:0] pin, correctPin;
input [7:0] cardno;
input [1:0] language; //00 is default ---- 01 is English ----- 10 is German
input [2:0] service; // 000 is default ---- 001 deposit ---- 010 withdraw ---- 011 checkBalance ---- 100 101 111
input [4:0] amount; //money to deposit or withdraw
input anotherServiceBit; // 0 is default means no another service if changed to 1 then go back to serviceSate
output reg [4:0] balance; //money in your bank acc.

integer timerCounter;
//0000 0001 0010 0011 0100 0101 0110 0111 1000 1001 1010 1011 1100 1101 1110 1111
localparam [3:0]
idleState=4'b0000,
languageState=4'b0001, //input language 
pinState=4'b0010,//input password
depositState=4'b0100, //deposit
withdrawState=4'b1000, //withdraw
serviceState=4'b0011, //choose a service
anotherServiceState=4'b0101,
balanceState=4'b0110, //balance
)

//********************//


reg [3:0] state, nextState;
reg [4:0] bal;

always @(posedge clk ) 
begin
    state=nextState;
end

always@(*)
begin
	case(state)
        // The Idle State of the System
        idleState:  
            begin
                if(cardno != 8'b0 )
                    nextState=languageState;
                else
                    nextState=state;
            end

        languageState: 
            begin
                timerCounter=0;
                if(language == 2'b01)
                    begin
                        $monitor("English Language is chosen");
                        #2 nextState=pinState;
                    end
                else if (language == 2'b10)
                    begin
                        $monitor("German Language is chosen");
                        #2 nextState=pinState;
                    end
                else
                    begin
                        timerCounter=timerCounter+1;
                        if(timerCounter<5)
                            nextState=state;
                        else
                            begin
                                $monitor("No Action taken");
                                #1 nextState=idleState;
                            end
                    end
            end

        pinState:
            begin
            timerCounter=0;
                if(pin == correctPin)
                    begin
                        nextState=serviceState;
                    end
                else
                    begin
                        timerCounter=timerCounter+1;
                        if(timerCounter<5)
                            nextState=state;
                        else
                            begin
                                $monitor("No Action taken");
                                #1 nextState=idleState;
                            end
                    end
            end

        serviceState:
            begin
            // timerCounter=0;
                case(service)

                    3'b000: nextState=state;
                    3'b001: nextState=depositState;
                    3'b010: nextState=withdrawState;
                    3'b011: nextState=balanceState;
                    // 3'b100:
                endcase
                
            end
            
        depositState:
            begin
                if(amount<=0)
                    begin
                        $monitor("Can't Deposit Negative Amount");
                        nextState=idleState;
                    end
                else
                    begin
                        $monitor("%d Amount Deposited into your Account",amount);
                        balance=balance+amount;
                        nextState=anotherServiceState;
                    end

            end

        withdrawState:
            begin
                if(amount>=balance)
                    begin
                        nextState=idleState;
                    end
                else
                    begin
                        balance=balance-amount;
                        nextState=anotherServiceState;
                    end
            end

        balanceState:
            begin
                $monitor("Your Balance is : %d ",balance);
                nextState=anotherServiceState;
            end

        anotherServiceState:
            begin

                $monitor("Do you want to make another service");
                if(anotherServiceBit)
                    nextState=serviceState;
                else
                    nextState=endState;
            end
    endcase
    
end
