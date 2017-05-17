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
parameter               SHIFT   =       'd25_000_000    ;

reg     [29:0]          cnt_spd                         ;
reg     [15:0]          cnt_r                           ;
reg     [15:0]          cntReg                          ;
reg     [15:0]          cnt                             ;
reg                     pulseout                        ;
reg     [ 1:0]          MA_r                            ;
reg     [ 2:0]          spd_sel                         ;       //控制转速
//====================================================================
// ***************      Main    Code    ***************
//====================================================================
assign  MA      =       MA_r;   
      
// speed change
always  @(posedge sclk or negedge s_rst_n) begin
        if(!s_rst_n)
                cnt_spd <=      'd0;
        else if(!enable)
                cnt_spd <=      'd0;
        else if(cnt_spd >= SHIFT)
                cnt_spd <=      'd0;
        else
                cnt_spd <=      cnt_spd + 1'b1;
end  

always  @(posedge sclk or negedge s_rst_n) begin
        if (!s_rst_n)
                spd_sel <=      3'b111;
        else if(!enable)
                spd_sel <=      3'b111;
        else if(cnt_spd >= SHIFT)
                spd_sel <=      spd_sel - 1'b1;
end 

// pulse create
always  @(posedge sclk or negedge s_rst_n ) begin 
        case (spd_sel)
                3'b000:    cnt_r        <=      PERIOD - 'd8000;        // L8
                3'b001:    cnt_r        <=      PERIOD - 'd7000; 
                3'b010:    cnt_r        <=      PERIOD - 'd6000; 
                3'b011:    cnt_r        <=      PERIOD - 'd5000;               
                3'b100:    cnt_r        <=      PERIOD - 'd4000;
                3'b101:    cnt_r        <=      PERIOD - 'd3000; 
                3'b110:    cnt_r        <=      PERIOD - 'd2000; 
                3'b111:    cnt_r        <=      PERIOD - 'd1000;        // L1
        endcase 
end 

// 脉宽
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
                pulseout        <=      1'bz;
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