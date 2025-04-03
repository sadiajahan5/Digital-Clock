module project(clk, break, reset, an0, an1, an2, an3, an4, an5, inputVal, clk_endtime, countdown_clk, phase);

input clk, reset, break; // clock, reset, and break
input countdown_clk,clk_endtime; // clock signals for end of time and countdown 
output [6:0] an0, an1, an2, an3, an4, an5; // 7 segment display outputs
input [5:0] inputVal;  // 6 bit input value
input [1:0] phase; // determines which phase (stopwatch, timer etc) the system is in

// internal registers 
 
reg sec_blinker = 1'd0; // second should blink on the display  
reg mins_blinkerdata = 1'd0; // minute should blink on the display 
reg hour_blinkerdata = 1'd0; // hour should blink on the display 
reg [16:0] countdown_input = 17'd0;  // to store the current countdown
reg reset_countdown = 1'd1;  
reg break_countdowndata = 1'd1; 
reg userdatareset = 1'd1; 
reg userdata_break = 1'd1; 
reg [5:0] inputVal_user= 6'd0;      //to store the user input data
reg [16:0] cOut_data= 17'd0;             //to store the clock 
reg [16:0] clktime_input = 17'd0;  
reg reset_clk = 1'd1;
reg break_clk = 1'd1;    
reg [3:0] output_loop= 4'd0;  
reg Break_stopwatch = 1'd0; 
reg [18:0] cOut_stopwatch = 19'd0;   
reg loop_stopwatchdata = 1'd1;  
reg Resetstopwatchdata = 1'd1;  

// internal wire declarations for connecting modules
wire user_secblinker;
wire user_minblinker;
wire user_hourblinker;
wire secBlinker_countdown;
wire minuteBlinker_countdown;
wire hourBlinker_countdown;
wire [16:0] userReset;
wire [16:0] user_break;
wire [16:0] userCout;
wire [5:0] userinputValue;
wire [16:0] clkCout;
wire [16:0] inputclktime;
wire [16:0] breakclk;
wire [16:0] resetclk;
wire [16:0] countdowntime_input;
wire [16:0] countdown_Reset;
wire [16:0] countdownBreak;
wire [16:0] countdownCout;
wire [16:0] stopwatchReset;
wire [16:0] stopwatchBreak;
wire [18:0] stopwatchCout;    
wire [3:0] loopOutput;

 
wire [18:0] ss;  //seconds
wire [18:0] mm;  //minutes
wire [18:0] hh;  //seconds
wire [18:0] Cout;

wire [3:0] ss0;
wire [3:0] ss1;

wire [3:0] mm0;
wire [3:0] mm1;

wire [3:0] hh0;
wire [3:0] hh1;

wire blinkled_second;
wire blinkled_minute;
wire blinkled_hour;


parameter case0 = 2'b00;
parameter case1 = 2'b01;
parameter case2 = 2'b10;
 

 // submodules instantiated in this system
clockk clock(.clk(clk), .Cout(clkCout), .break(breakclk), .reset(resetclk), .clkIntime(inputclktime));    
countdown cd(.clk(clk), .Cout(countdownCout), .break(countdownBreak), .reset(countdown_Reset), .clkIntime(countdowntime_input), .secondBlinkerOutput(secBlinker_countdown), .minuteBlinkerOut(minuteBlinker_countdown), .hourBlinkerOut(hourBlinker_countdown));
stopwatch stopW(.clk(clk), .Cout(stopwatchCout), .reset(stopwatchReset), .sw(loopOutput), .loop(loop_stopwatch), .strtStopwatch(stopwatchBreak));
userIn inp(.clk(clk), .Cout(userCout), .reset(user_Reset), .clicker(user_break), .inputVal(userinputValue), .secondBlinkerOutput(user_secblinker), .minuteBlinkerOut(user_minblinker), .hourBlinkerOut(user_hourblinker));

 
// This is the logic for how each phase( stopwatch, clock etc) works 
always @(posedge clk)  // defines the logic 
begin
    case (phase)
	 // Countdown phase 
    case1: begin
	 // assign countdown values to internal registers
    cOut_data<= countdownCout;
	 
	 userdata_break <= 1'd1;
    userdatareset <= 1'd1;
	 
	 break_countdowndata <= break;
    reset_countdown <= reset;
    inputVal_user[5:0] <= 6'd0;
	 
	 break_clk <= 1'd1;
    reset_clk <= 1'd1;
    loop_stopwatchdata <= 1'd1;
    Resetstopwatchdata <= 1'd1;
    output_loop[3:0] <= 4'd0;
	 
// the led blinks during countdown phase 
sec_blinker <= secBlinker_countdown;
mins_blinkerdata <= minuteBlinker_countdown;  
 hour_blinkerdata <= hourBlinker_countdown;
   
    end
    // case for user input phase
	   case0:  begin
	 // Assign to internal registers the user input values 
    cOut_data <= userCout; // userCout as output 
	 userdata_break <= break;
    userdatareset <= reset;
    inputVal_user[5:0] <= inputVal [5:0];
	 // Set clock, stopwatch and countdown 
	 break_countdowndata <= 1'd1;
    reset_countdown <= 1'd1;
    break_clk <= 1'd1;
    reset_clk <= 1'd1;
    loop_stopwatchdata <= 1'd1;
    Resetstopwatchdata <= 1'd1;
    output_loop [3:0] <= 4'd0;
	 
// The leds blink based on user input 
sec_blinker <= user_secblinker;
mins_blinkerdata <= user_minblinker;  
 hour_blinkerdata <= user_hourblinker;
   
   
    end
	 //clock phase
	 case2: begin
	 // assign clock values to internal registers 
    cOut_data <= clkCout;
    
	 break_clk <= break;
	 reset_clk <= reset;
    inputVal_user[5:0] <= 6'd0;
	 
	 break_countdowndata <= 1'd1;
    reset_countdown <= 1'd1;
	 output_loop[3:0] <= 4'd0;
    loop_stopwatchdata <= 1'd1;
    Resetstopwatchdata <= 1'd1;
	 userdata_break <= 1'd1;
    userdatareset <= 1'd1;
	 
	 sec_blinker <= 1'd0;
	 mins_blinkerdata <= 1'd0;
	 hour_blinkerdata <= 1'd0;
 
   
    end
	 
	 //default case 
    default: begin
	 // internal registers were assigned the stopwatch values
    cOut_stopwatch <= stopwatchCout;
	 
	 userdata_break <= 1'd1;
    userdatareset <= 1'd1;
	 break_countdowndata <= 1'd1;
    reset_countdown <= 1'd1;
	 reset_clk <= 1'd1;
	 break_clk <= 1'd1;
    inputVal_user[5:0] <= 6'd0;
	 Resetstopwatchdata <= reset;
    loop_stopwatchdata <= break;
    Break_stopwatch <= inputVal [5];
    output_loop[3:0] <= inputVal [3:0];
	 sec_blinker <= 1'd0; 
	 mins_blinkerdata <= 1'd0;  
	 hour_blinkerdata <= 1'd0;
   
    end
    endcase
end
 

// Always block that updates the clock time and countdown
 always @(posedge clk, posedge clk_endtime, posedge countdown_clk) 
 begin
    if (clk_endtime == 1) begin

    if (countdown_clk == 1) begin
	 // no change in clock time or countdown
    countdown_input <= countdown_input;
clktime_input <= clktime_input;
   
    end else begin
	 // update countdown data
	 countdown_input <= cOut_data;
clktime_input <= clktime_input;
    end
    end 
	 else begin

    if (countdown_clk == 1) begin
	 // update clock time based on countdown 
	 countdown_input <= countdown_input;
clktime_input <= cOut_data;

    end else begin
	 // update the clock time and countdown 
	 countdown_input <= cOut_data;
clktime_input <= cOut_data;
    end
    end
   
end
 

assign Cout = (phase == 2'b11) ? cOut_stopwatch: cOut_data;

assign blinkled_second = sec_blinker;
assign blinkled_minute = mins_blinkerdata;
assign blinkled_hour = hour_blinkerdata;
assign inputclktime = clktime_input;
assign breakclk = break_clk;
assign user_break = userdata_break;
assign resetclk = reset_clk;
assign userinputValue = inputVal_user;
assign user_Reset = userdatareset;  
assign stopwatchReset = Resetstopwatchdata;
assign stopwatchBreak = Break_stopwatch;
assign loopOutput = output_loop;
assign loop_stopwatch = loop_stopwatchdata;
assign countdownBreak = break_countdowndata;
assign countdown_Reset = reset_countdown;  
assign countdowntime_input = countdown_input;

assign hh= (phase == 2'b11) ? ((Cout >= 100) ? ((Cout >= 6000) ?
(Cout/6000) : (19'd0) ) : (19'd0)) : ((Cout >= 60) ? ( (Cout >= 3600) ? (Cout/3600) : (17'd0) ) : (17'd0));
assign mm = (phase == 2'b11) ? ((Cout >= 100) ? ( (Cout >= 6000) ? ((Cout%6000)/100) : (Cout / 100) ) : (19'd0)) : ((Cout >= 60) ? ( (Cout >= 3600) ? ((Cout%3600)/60) : (Cout / 60) ) : (17'd0));
assign ss = (phase == 2'b11) ? ((Cout >= 100) ? ( (Cout >= 6000) ? ((Cout%6000)%100) : (Cout % 100) ) : (Cout)) : ((Cout >= 60) ? ( (Cout >= 3600) ? ( (Cout%3600)%60) : (Cout % 60) ) : (Cout));

 

assign hh0 = (phase == 2'b11) ? (hh% 19'd10) : (hh% 17'd10);
assign hh1 = (phase == 2'b11) ? (hh/ 19'd10) : (hh/ 17'd10);
assign mm0 = (phase == 2'b11) ? (mm % 19'd10) : (mm % 17'd10);
assign mm1 = (phase == 2'b11) ? (mm / 19'd10) : (mm / 17'd10);
assign ss0 = (phase == 2'b11) ? (ss % 19'd10) : (ss % 17'd10);
assign ss1 = (phase == 2'b11) ? (ss / 19'd10) : (ss / 17'd10);



    assign an0[0] = (blinkled_second == 1) ? (1'b1) : (ss0[0]&~ss0[1]&~ss0[2]&~ss0[3]) | (~ss0[0]&~ss0[1]&ss0[2]&~ss0[3]);
    assign an0[1] = (blinkled_second == 1) ? (1'b1) : (ss0[0]&~ss0[1]&ss0[2]&~ss0[3]) | (~ss0[0]&ss0[1]&ss0[2]&~ss0[3]);
    assign an0[2] = (blinkled_second == 1) ? (1'b1) : (~ss0[0]&ss0[1]&~ss0[2]&~ss0[3]);
    assign an0[3] = (blinkled_second == 1) ? (1'b1) : (ss0[0]&~ss0[1]&~ss0[2]&~ss0[3]) | (~ss0[0]&~ss0[1]&ss0[2]&~ss0[3]) | (ss0[0]&ss0[1]&ss0[2]&~ss0[3]);
    assign an0[4] = (blinkled_second == 1) ? (1'b1) : (ss0[0]&~ss0[1]&~ss0[2]&~ss0[3]) | (ss0[0]&ss0[1]&~ss0[2]&~ss0[3]) | (~ss0[0]&~ss0[1]&ss0[2]&~ss0[3]) | (ss0[0]&~ss0[1]&ss0[2]&~ss0[3]) | (ss0[0]&ss0[1]&ss0[2]&~ss0[3]) | (ss0[0]&~ss0[1]&~ss0[2]&ss0[3]);
    assign an0[5] = (blinkled_second == 1) ? (1'b1) : (ss0[0]&~ss0[1]&~ss0[2]&~ss0[3]) | (~ss0[0]&ss0[1]&~ss0[2]&~ss0[3]) | (ss0[0]&ss0[1]&~ss0[2]&~ss0[3]) | (ss0[0]&ss0[1]&ss0[2]&~ss0[3]);
    assign an0[6] = (blinkled_second == 1) ? (1'b1) : (~ss0[0]&~ss0[1]&~ss0[2]&~ss0[3]) | (ss0[0]&~ss0[1]&~ss0[2]&~ss0[3]) | (ss0[0]&ss0[1]&ss0[2]&~ss0[3]);

    assign an1[0] = (blinkled_second == 1) ? (1'b1) : (ss1[0]&~ss1[1]&~ss1[2]&~ss1[3]) | (~ss1[0]&~ss1[1]&ss1[2]&~ss1[3]);
    assign an1[1] = (blinkled_second == 1) ? (1'b1) : (ss1[0]&~ss1[1]&ss1[2]&~ss1[3]) | (~ss1[0]&ss1[1]&ss1[2]&~ss1[3]);
    assign an1[2] = (blinkled_second == 1) ? (1'b1) : (~ss1[0]&ss1[1]&~ss1[2]&~ss1[3]);
    assign an1[3] = (blinkled_second == 1) ? (1'b1) : (ss1[0]&~ss1[1]&~ss1[2]&~ss1[3]) | (~ss1[0]&~ss1[1]&ss1[2]&~ss1[3]) | (ss1[0]&ss1[1]&ss1[2]&~ss1[3]);
    assign an1[4] = (blinkled_second == 1) ? (1'b1) : (ss1[0]&~ss1[1]&~ss1[2]&~ss1[3]) | (ss1[0]&ss1[1]&~ss1[2]&~ss1[3]) | (~ss1[0]&~ss1[1]&ss1[2]&~ss1[3]) | (ss1[0]&~ss1[1]&ss1[2]&~ss1[3]) | (ss1[0]&ss1[1]&ss1[2]&~ss1[3]) | (ss1[0]&~ss1[1]&~ss1[2]&ss1[3]);
    assign an1[5] = (blinkled_second == 1) ? (1'b1) : (ss1[0]&~ss1[1]&~ss1[2]&~ss1[3]) | (~ss1[0]&ss1[1]&~ss1[2]&~ss1[3]) | (ss1[0]&ss1[1]&~ss1[2]&~ss1[3]) | (ss1[0]&ss1[1]&ss1[2]&~ss1[3]);
    assign an1[6] = (blinkled_second == 1) ? (1'b1) : (~ss1[0]&~ss1[1]&~ss1[2]&~ss1[3]) | (ss1[0]&~ss1[1]&~ss1[2]&~ss1[3]) | (ss1[0]&ss1[1]&ss1[2]&~ss1[3]);

    assign an2[0] = (blinkled_minute == 1) ? (1'b1) : (mm0[0]&~mm0[1]&~mm0[2]&~mm0[3]) | (~mm0[0]&~mm0[1]&mm0[2]&~mm0[3]);
    assign an2[1] = (blinkled_minute == 1) ? (1'b1) : (mm0[0]&~mm0[1]&mm0[2]&~mm0[3]) | (~mm0[0]&mm0[1]&mm0[2]&~mm0[3]);
    assign an2[2] = (blinkled_minute == 1) ? (1'b1) : (~mm0[0]&mm0[1]&~mm0[2]&~mm0[3]);
    assign an2[3] = (blinkled_minute == 1) ? (1'b1) : (mm0[0]&~mm0[1]&~mm0[2]&~mm0[3]) | (~mm0[0]&~mm0[1]&mm0[2]&~mm0[3]) | (mm0[0]&mm0[1]&mm0[2]&~mm0[3]);
    assign an2[4] = (blinkled_minute == 1) ? (1'b1) : (mm0[0]&~mm0[1]&~mm0[2]&~mm0[3]) | (mm0[0]&mm0[1]&~mm0[2]&~mm0[3]) | (~mm0[0]&~mm0[1]&mm0[2]&~mm0[3]) | (mm0[0]&~mm0[1]&mm0[2]&~mm0[3]) | (mm0[0]&mm0[1]&mm0[2]&~mm0[3]) | (mm0[0]&~mm0[1]&~mm0[2]&mm0[3]);
    assign an2[5] = (blinkled_minute == 1) ? (1'b1) : (mm0[0]&~mm0[1]&~mm0[2]&~mm0[3]) | (~mm0[0]&mm0[1]&~mm0[2]&~mm0[3]) | (mm0[0]&mm0[1]&~mm0[2]&~mm0[3]) | (mm0[0]&mm0[1]&mm0[2]&~mm0[3]);
    assign an2[6] = (blinkled_minute == 1) ? (1'b1) : ((~mm0[0])&(~mm0[1])&(~mm0[2])&(~mm0[3])) | (mm0[0]&~mm0[1]&~mm0[2]&~mm0[3]) | (mm0[0]&mm0[1]&mm0[2]&~mm0[3]);

    assign an3[0] = (blinkled_minute == 1) ? (1'b1) : (mm1[0]&~mm1[1]&~mm1[2]&~mm1[3]) | (~mm1[0]&~mm1[1]&mm1[2]&~mm1[3]);
    assign an3[1] = (blinkled_minute == 1) ? (1'b1) : (mm1[0]&~mm1[1]&mm1[2]&~mm1[3]) | (~mm1[0]&mm1[1]&mm1[2]&~mm1[3]);
    assign an3[2] = (blinkled_minute == 1) ? (1'b1) : (~mm1[0]&mm1[1]&~mm1[2]&~mm1[3]);
    assign an3[3] = (blinkled_minute == 1) ? (1'b1) : (mm1[0]&~mm1[1]&~mm1[2]&~mm1[3]) | (~mm1[0]&~mm1[1]&mm1[2]&~mm1[3]) | (mm1[0]&mm1[1]&mm1[2]&~mm1[3]);
    assign an3[4] = (blinkled_minute == 1) ? (1'b1) : (mm1[0]&~mm1[1]&~mm1[2]&~mm1[3]) | (mm1[0]&mm1[1]&~mm1[2]&~mm1[3]) | (~mm1[0]&~mm1[1]&mm1[2]&~mm1[3]) | (mm1[0]&~mm1[1]&mm1[2]&~mm1[3]) | (mm1[0]&mm1[1]&mm1[2]&~mm1[3]) | (mm1[0]&~mm1[1]&~mm1[2]&mm1[3]);
    assign an3[5] = (blinkled_minute == 1) ? (1'b1) : (mm1[0]&~mm1[1]&~mm1[2]&~mm1[3]) | (~mm1[0]&mm1[1]&~mm1[2]&~mm1[3]) | (mm1[0]&mm1[1]&~mm1[2]&~mm1[3]) | (mm1[0]&mm1[1]&mm1[2]&~mm1[3]);
	 assign an3[6] = (blinkled_minute == 1) ? (1'b1) : ((~mm1[0])&(~mm1[1])&(~mm1[2])&(~mm1[3])) | (mm1[0]&~mm1[1]&~mm1[2]&~mm1[3]) | (mm1[0]&mm1[1]&mm1[2]&~mm1[3]);

	 assign an4[0] = (blinkled_hour == 1) ? (1'b1) : (hh0[0]&~hh0[1]&~hh0[2]&~hh0[3]) | (~hh0[0]&~hh0[1]&hh0[2]&~hh0[3]);
	 assign an4[1] = (blinkled_hour == 1) ? (1'b1) : (hh0[0]&~hh0[1]&hh0[2]&~hh0[3]) | (~hh0[0]&hh0[1]&hh0[2]&~hh0[3]);
	 assign an4[2] = (blinkled_hour == 1) ? (1'b1) : (~hh0[0]&hh0[1]&~hh0[2]&~hh0[3]);
	 assign an4[3] = (blinkled_hour == 1) ? (1'b1) : (hh0[0]&~hh0[1]&~hh0[2]&~hh0[3]) | (~hh0[0]&~hh0[1]&hh0[2]&~hh0[3]) | (hh0[0]&hh0[1]&hh0[2]&~hh0[3]);
	 assign an4[4] = (blinkled_hour == 1) ? (1'b1) : (hh0[0]&~hh0[1]&~hh0[2]&~hh0[3]) | (hh0[0]&hh0[1]&~hh0[2]&~hh0[3]) | (~hh0[0]&~hh0[1]&hh0[2]&~hh0[3]) | (hh0[0]&~hh0[1]&hh0[2]&~hh0[3]) | (hh0[0]&hh0[1]&hh0[2]&~hh0[3]) | (hh0[0]&~hh0[1]&~hh0[2]&hh0[3]);
	 assign an4[5] = (blinkled_hour == 1) ? (1'b1) : (hh0[0]&~hh0[1]&~hh0[2]&~hh0[3]) | (~hh0[0]&hh0[1]&~hh0[2]&~hh0[3]) | (hh0[0]&hh0[1]&~hh0[2]&~hh0[3]) | (hh0[0]&hh0[1]&hh0[2]&~hh0[3]);
	 assign an4[6] = (blinkled_hour == 1) ? (1'b1) : (~hh0[0]&~hh0[1]&~hh0[2]&~hh0[3]) | (hh0[0]&~hh0[1]&~hh0[2]&~hh0[3]) | (hh0[0]&hh0[1]&hh0[2]&~hh0[3]);

	 assign an5[0] = (blinkled_hour == 1) ? (1'b1) : (hh1[0]&~hh1[1]&~hh1[2]&~hh1[3]) | (~hh1[0]&~hh1[1]&hh1[2]&~hh1[3]);
	 assign an5[1] = (blinkled_hour == 1) ? (1'b1) : (hh1[0]&~hh1[1]&hh1[2]&~hh1[3]) | (~hh1[0]&hh1[1]&hh1[2]&~hh1[3]);
	 assign an5[2] = (blinkled_hour == 1) ? (1'b1) : (~hh1[0]&hh1[1]&~hh1[2]&~hh1[3]);
	 assign an5[3] = (blinkled_hour == 1) ? (1'b1) : (hh1[0]&~hh1[1]&~hh1[2]&~hh1[3]) | (~hh1[0]&~hh1[1]&hh1[2]&~hh1[3]) | (hh1[0]&hh1[1]&hh1[2]&~hh1[3]);
	 assign an5[4] = (blinkled_hour == 1) ? (1'b1) : (hh1[0]&~hh1[1]&~hh1[2]&~hh1[3]) | (hh1[0]&hh1[1]&~hh1[2]&~hh1[3]) | (~hh1[0]&~hh1[1]&hh1[2]&~hh1[3]) | (hh1[0]&~hh1[1]&hh1[2]&~hh1[3]) | (hh1[0]&hh1[1]&hh1[2]&~hh1[3]) | (hh1[0]&~hh1[1]&~hh1[2]&hh1[3]);
	 assign an5[5] = (blinkled_hour == 1) ? (1'b1) : (hh1[0]&~hh1[1]&~hh1[2]&~hh1[3]) | (~hh1[0]&hh1[1]&~hh1[2]&~hh1[3]) | (hh1[0]&hh1[1]&~hh1[2]&~hh1[3]) | (hh1[0]&hh1[1]&hh1[2]&~hh1[3]);
	 assign an5[6] = (blinkled_hour == 1) ? (1'b1) : (~hh1[0]&~hh1[1]&~hh1[2]&~hh1[3]) | (hh1[0]&~hh1[1]&~hh1[2]&~hh1[3]) | (hh1[0]&hh1[1]&hh1[2]&~hh1[3]);

endmodule 