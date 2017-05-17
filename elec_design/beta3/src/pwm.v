module  pwm(
        // system signals 
        input                   sclk                    ,
        input                   s_rst_n                 ,
        // input signals
        input                   enable                  ,       //控制开关
        input                   direct                  ,       //控制方向
        input           [ 2:0]  cnt                     ,
        //output signals
        output                  flag                    ,
        output          [ 1:0]  MA                              //电机控制
);

//============================================================\
// ========= Define Parameter and Internal Signals ==========
//============================================================/ 
parameter       CLK_DIV_CYCLE   =       'd14            ;
parameter       LED_PERIOD      =       'd999           ;

reg     [ 1:0]                  MA_r                    ;
reg     [ 5:0]                  cnt_clk                 ;
reg                             div100_clk              ;
reg     [15:0]                  cnt_2ms                 ;
reg     [ 9:0]                  cnt_n                   ;
reg                             flag_1s                 ;
reg                             pulseout                ;
reg                             flag_2s                 ;       // 每次只完成一个周期转动
//===========================================================================
// **************     Main     Code    **************
//===========================================================================
assign  MA      =       MA_r;
assign  flag    =       flag_2s;

always  @(posedge div100_clk or negedge s_rst_n ) begin  
        if (!s_rst_n)
                MA_r    <=      2'b00;
        else if (!enable)
                MA_r    <=      2'b00;
        else if(direct)      
                MA_r    <=      {~pulseout,1'b1};
        else
                MA_r    <=      {1'b1,~pulseout};
end

always  @(posedge div100_clk or negedge s_rst_n ) begin
        if(!s_rst_n)
                flag_2s <=      1'b0;
        else if(flag_1s == 1'b1 && cnt_n == 1'b0)
                flag_2s <=      1'b1;
        else
                flag_2s <=      1'b0;
end

/* Div_Clk */
always  @(posedge sclk or negedge s_rst_n) begin
        if(!s_rst_n)
                cnt_clk     <=      6'b0000_00;
        else if(cnt_clk >= CLK_DIV_CYCLE)
                cnt_clk     <=      6'b0000_00;
        else
                cnt_clk     <=      cnt_clk + 1'b1;
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(!s_rst_n)
                div100_clk      <=      1'b0;
        else if(cnt_clk == 0)
                div100_clk      <=       ~div100_clk;
end

/* Counter_2ms */
always  @(posedge div100_clk or negedge s_rst_n) begin
        if(!s_rst_n)
                cnt_2ms <=      'd0;
        else if(cnt_2ms >= LED_PERIOD || !enable)
                cnt_2ms <=      'd0;
        else if(enable)
                cnt_2ms <=      cnt_2ms + 1'b1;
end

/* Connecter */
always  @(posedge div100_clk or negedge s_rst_n) begin
        if(!s_rst_n)
                cnt_n   <=      'd0;
        else if(!enable)
                cnt_n   <=      'd0;
        else begin
                if(cnt_2ms >= LED_PERIOD && flag_1s == 1'b0)
                        cnt_n   <=      cnt_n + 1'b1;
                if(cnt_2ms >= LED_PERIOD && flag_1s == 1'b1)
                        cnt_n   <=      cnt_n - 1'b1;
        end
end

/* flag_1s to Change Director of Slide */
always  @(posedge div100_clk or negedge s_rst_n) begin
        if(!s_rst_n)
                flag_1s    <=      1'b0;
        else if(cnt_n == 0)
                flag_1s    <=      1'b0;
        else if(cnt_n >= LED_PERIOD)
                flag_1s    <=      1'b1;
end

/* Signal of Pulse */
always  @(posedge div100_clk or negedge s_rst_n) begin
        if(!s_rst_n)
                pulseout     <=      1'b0;
        else if(cnt_2ms <= cnt_n)
                pulseout     <=      1'b1;
        else
                pulseout     <=      1'b0;
end  
             
endmodule