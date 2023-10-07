module countdown
 (
 input clk,//系统时钟12MHz
 input enable,//模块启用标志位
  
 output reg countdown_finish,
 output reg [3:0]seg1_value,//数码管1显存
 output reg [3:0]seg2_value//数码管2显存
 );
 
  parameter CNT_MAX = 25'd11_999_999;
 
  reg [8:0] seg [9:0]; // 声明reg型数组变量  
  
 reg [7:0]countdown_times;
 
 //reg define
 reg [24:0] cnt ; //经计算得需要25位宽的寄存器才够500ms
 reg cnt_flag;

 //cnt:计数器计数，当计数到CNT_MAX的值时清零
 always@(posedge clk )
 if(cnt == CNT_MAX || !enable)
 cnt <= 25'b0;
 else
 cnt <= cnt + 1'b1;

 //cnt_flag:计数到最大值产生的标志信号，每当计数满标志信号有效时取反
 always@(posedge clk )
 if(cnt == (CNT_MAX - 25'b1) && enable)
 cnt_flag <= 1'b1;
 else
 cnt_flag <= 1'b0;

 
 //输出控制倒计时
 always@(posedge clk )
 if(cnt_flag == 1'b1 && countdown_times >= 0 && enable)
 countdown_times <= countdown_times-1;
 else if(!enable)
 countdown_times <= 8'd60;
 else
 countdown_times <= countdown_times;
 
 //产生显存
 always@(posedge clk )
 if(enable) begin
 seg1_value <= countdown_times % 10;
 seg2_value <= countdown_times / 10;
 end
 
 //产生标志位
 always@(posedge clk )
 if(countdown_times==0)
 countdown_finish <= 1'b1;
 else
 countdown_finish <= 1'b0;
 
 endmodule