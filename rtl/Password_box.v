module Password_box(
input wire sys_clk , //系统时钟12MHz
input wire sys_rst_n , //全局复位
input wire confirm , //确认密码
input [3:0]cin , //输入四位密码

output reg [7:0]led,//显示剩余输入密码次数 led低电平点亮
output reg [8:0]seg1,//数码管1 MSB~LSB=DIG、DP、G、F、E、D、C、B、A
output reg [8:0]seg2,//数码管2 MSB~LSB=DIG、DP、G、F、E、D、C、B、A
output reg [2:0]tricolor_light1,//三色灯1 从高位到地位为RGB
output reg [2:0]tricolor_light2//三色灯2 从高位到地位为RGB
);

//状态机
 parameter ORIGINAL = 4'b0001;
 parameter RIGHT    = 4'b0010;
 parameter WRONG    = 4'b0100;
 parameter LOCK     = 4'b1000;
 
//三色灯
 parameter RED    = 3'b011;
 parameter GREEN  = 3'b101;
 parameter YELLOW = 3'b001;
 parameter BLUE   = 3'b110;
 
 
//状态 
 reg [3:0] state ;
 
//正确密码
 parameter PASSWORD = 4'b0100;
 
//错误计数器
 reg number_of_wrong;
 
//倒计时结束标志位
 wire countdown_finish;

//启用倒计时模块标志位
 reg flag;

//显存
 wire [3:0] seg1_value;
 wire [3:0] seg2_value;
 
//数码管显示
 reg [8:0] seg [9:0]; // 声明reg型数组变量  
 initial begin  
  seg[0] = 9'h3f; // 对存储器中第一个数赋值  
  seg[1] = 9'h06;  
  seg[2] = 9'h5b;  
  seg[3] = 9'h4f;  
  seg[4] = 9'h66;  
  seg[5] = 9'h6d;  
  seg[6] = 9'h7d;  
  seg[7] = 9'h07;  
  seg[8] = 9'h7f;  
  seg[9] = 9'h6f;  
end
  
//第一段状态机，描述当前状态state如何根据输入跳转到下一状态
 always@(posedge sys_clk or negedge sys_rst_n)
 if(sys_rst_n == 1'b0)
 state <= ORIGINAL; //任何情况下只要按复位就回到初始状态
 else case(state)
 ORIGINAL : if(cin == PASSWORD && !confirm ) // 判断密码输入状况
 state <= RIGHT;
 else if(cin != PASSWORD && !confirm )
 state <= WRONG;
 else
 state <=ORIGINAL;

 RIGHT : if(cin != PASSWORD && !confirm )
 state <= WRONG;
 else
 state <= RIGHT;

 WRONG : if(cin == PASSWORD && !confirm && number_of_wrong<9)
 state <= RIGHT;
 else if(number_of_wrong>=9)
 state <= LOCK;
 else
 state <= WRONG;
 
 LOCK  : if(countdown_finish)
 state <= ORIGINAL;
 else 
 state <= LOCK;
 //如果状态机跳转到编码的状态之外也回到初始状态
 default: state <= ORIGINAL;
 endcase
 
 
 //第二段状态机，描述当前状态state不同行为
 always@(posedge sys_clk or negedge sys_rst_n)
 if(sys_rst_n == 1'b0)
 begin
 led <= 8'b1111_1111;
 seg1 <= 9'b0_0000_0000;
 seg2 <= 9'b0_0000_0000;
 tricolor_light1 <= YELLOW;
 tricolor_light2 <= YELLOW;
 number_of_wrong <= 1'b0;
 flag <= 1'b0;
 end
 
 else case(state)
 ORIGINAL :
 begin 
 tricolor_light1 <= YELLOW;
 tricolor_light2 <= YELLOW;
 led <= 8'b1111_1111;
 flag <= 1'b0;
 if(cin != PASSWORD && !confirm )
 number_of_wrong <= number_of_wrong+1'b1;
 else
 number_of_wrong <= number_of_wrong;
 end
 
 RIGHT : 
 begin
 tricolor_light1 <= GREEN;
 tricolor_light2 <= GREEN;
 led <= 8'b1111_1111;
 number_of_wrong <= 1'b0;
 seg1 <= 9'b0_0011_1111;//显示o
 seg2 <= 9'b0_0011_0111;//显示n
 flag <= 1'b0;
 if(cin != PASSWORD && !confirm )
 number_of_wrong <= number_of_wrong+1'b1;
 else
 number_of_wrong <= number_of_wrong;
 end
 
 WRONG : 
 begin
 tricolor_light1 <= RED;
 tricolor_light2 <= RED;
 seg1 <= 9'b0_1000_0000;//显示-
 seg2 <= 9'b0_1000_0000;//显示-
 flag <= 1'b0;
 case(number_of_wrong)
 4'd0:led<=8'b0000_0000;
 4'd1:led<=8'b0000_0001;
 4'd2:led<=8'b0000_0011;
 4'd3:led<=8'b0000_0111;
 4'd4:led<=8'b0000_1111;
 4'd5:led<=8'b0001_1111;
 4'd6:led<=8'b0011_1111;
 4'd7:led<=8'b0111_1111;
 4'd8:led<=8'b1111_1111;
 endcase
 if(cin != PASSWORD && !confirm )
 number_of_wrong <= number_of_wrong+1'b1;
 else
 number_of_wrong <= number_of_wrong;
 end
 
 LOCK  : 
 begin
 tricolor_light1 <= BLUE;
 tricolor_light2 <= BLUE;
 number_of_wrong <= 0;
 flag <= 1'b1;
 seg1 <= seg[seg1_value];
 seg2 <= seg[seg2_value];
 end
 endcase
 
//调用倒计时模块
countdown my_countdown (  
  .clk (sys_clk),
  .enable(flag),  
  .countdown_finish(countdown_finish),  
  .seg1_value (seg1_value),  
  .seg2_value (seg2_value)
);
 
  endmodule