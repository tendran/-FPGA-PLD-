
module  pwm(
        // system signals 
        input                   sclk                    ,
        input                   s_rst_n                 ,
        // input signals
        input                   enable                  ,       //控制开关
        input                   direct                  ,       //控制方向
        //output signals
        output  [ 1:0]          MA                              //电机控制
);

//============================================================\
// ========= Define Parameter and Internal Signals ==========
//============================================================/ 
parameter               PERIOD  =       'd10_000        ;
parameter               SHIFT   =       'd100_000_000   ;

reg     [29:0]          cnt_spd                         ;
reg     [15:0]          cnt_r                           ;
reg     [15:0]          cntReg                          ;
reg     [15:0]          cnt                             ;
reg                     pulseout                        ;
reg     [ 1:0]          MA_r                            ;
reg     [ 1:0]          spd_sel                         ;       //控制转速
//====================================================================
// ***************      Main    Code    ***************
//====================================================================
assign  MA      =       MA_r;   
      
// speed change
always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                cnt_spd <=      'd0;
        else if(cnt_spd >= SHIFT)
                cnt_spd <=      'd0;
        else
                cnt_spd <=      cnt_spd + 1'b1;
end  

always  @(posedge sclk or negedge s_rst_n) begin
        if (!s_rst_n)
                spd_sel <=      2'b11;
        else if(cnt_spd >= SHIFT)
                spd_sel <=      spd_sel - 1'b1;
end 

// pulse create
always  @( spd_sel ) begin 
        case (spd_sel)
                2'b00 :    cnt_r        <=      PERIOD - 'd3500; 
                2'b01 :    cnt_r        <=      PERIOD - 'd2500; 
                2'b10 :    cnt_r        <=      PERIOD - 'd1750; 
                2'b11 :    cnt_r        <=      PERIOD - 'd1000; 
        endcase 
end 

always  @(posedge sclk or negedge s_rst_n ) begin  
        if (!s_rst_n)
                cntReg  <=      16'b0;
        else if (direct == 1'b1)
                cntReg  <=      cnt_r;
        else if (direct == 1'b0)
                cntReg  <=      PERIOD - cnt_r;
end

always  @(posedge sclk or negedge s_rst_n ) begin  
        if (!s_rst_n)
                cnt     <=      16'b0;
        else if (cnt >= PERIOD)
                cnt     <=      'b0;
        else
                cnt     <=      cnt + 1;
end

always  @(posedge sclk or negedge s_rst_n ) begin  
        if (!s_rst_n)
                pulseout        <=      1'b0;
        else if (cnt >= cntReg)
                pulseout        <=      1'b1;
        else if (cnt >= PERIOD)
                pulseout        <=      1'b0;
end 

always  @(posedge sclk or negedge s_rst_n ) begin  
        if (!s_rst_n)
                MA_r    <=      2'b00;
        else if (enable == 1'b0)
                MA_r    <=      2'b00;
        else       
                MA_r    <=      {~pulseout,pulseout};
end
                
endmodule