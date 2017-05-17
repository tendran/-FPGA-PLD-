module  state(
        // system signals
        input                   sclk                    ,
        input                   s_rst_n                 ,
        // input signals
        input                   catcher                 ,
        input                   jockey_r                ,
        input                   jockey_l                ,
        input                   key                     ,
  //      input                   flag                    ,
        // output signals
        output  reg             direct                  ,
        output  reg             enable                  ,
        output  reg     [ 2:0]  cnt                     
);

//============================================================\
// ========= Define Parameter and Internal Signals ==========
//============================================================/ 
parameter       ROUND   =       'd6                             ;
parameter       PERIOD  =       'd100_000_000                   ;

localparam      IDLE    =       6'b000001                       ,
                BALANCE =       6'b000010                       ,
                WAIT    =       6'b000100                       ,
                AUTOR   =       6'b001000                       ,       // 轨道右倾，主轴顺时针
                AUTOL   =       6'b010000                       ,       // 轨道左倾，主轴逆时针
                AJUST   =       6'b100000                       ;       // 做周期递减的往复运动
                

reg     [ 5:0]          status                          ;
reg                     flag_state                      ;       // 标志改变使能的状态跳转
reg                     direct_a                        ;       // 以下四个寄存器，处理最后调平衡过程
reg                     chg_flag                        ;
reg     [26:0]          chg_cnt                         ;
reg     [26:0]          rounds                          ;
//====================================================================
// ***************      Main    Code    ***************
//====================================================================

always  @(posedge sclk or negedge s_rst_n) begin
        if(!s_rst_n)
                cnt     <=      'd1;
        else if(cnt > ROUND)
                cnt     <=      'd1;
        else if (!jockey_l && status == AUTOL ||
                !jockey_r && status == AUTOR)
                cnt     <=      cnt + 1'b1;
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(!s_rst_n)
                status  <=      IDLE;
        else case(status)
                IDLE:
                        if(key)
                                status  <=      BALANCE;
                        else
                                status  <=      IDLE;
                BALANCE:
                        if(!catcher)
                                status  <=      WAIT;
                        else
                                status  <=      BALANCE;
                WAIT:
                        if(key)
                                status  <=      AUTOR;
                        else
                                status  <=      WAIT;
                AUTOR:
                        if(!jockey_r)
                                status  <=      AUTOL;
                        else
                                status  <=      AUTOR;
                AUTOL:
                        if(cnt == ROUND)
                                status  <=      AJUST;
                        else if(!jockey_l)
                                status  <=      AUTOR;
                        else
                                status  <=      AUTOL;
                AJUST:
                        if(rounds >= PERIOD - 10)
                                status  <=      IDLE;
                        else
                                status  <=      AJUST;
                default:;
        endcase
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(!s_rst_n)
                flag_state      <=      1'b0;
        else if(status == IDLE && key || status == WAIT && key || status == AUTOL && cnt == ROUND
                || status == AUTOL && !jockey_l || status == AUTOR && !jockey_r)
                flag_state      <=      1'b1;
        else
                flag_state      <=      1'b0;
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(!s_rst_n)
                enable  <=      1'b0;
/*         else if(flag)
                enable  <=      1'b0; */
        else if(flag_state || status == BALANCE || status == AJUST)
                enable  <=      1'b1;
        else if(status == WAIT)
                enable  <=      1'b0;
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(!s_rst_n)
                direct  <=      1'bz;
        else case(status)
                AUTOR:
                        direct  <=      1'b1;
                AUTOL,BALANCE:
                        direct  <=      1'b0;
                AJUST:
                        direct  <=      direct_a;
                default:
                        direct  <=      1'bz;
        endcase
end


// AJUST
always  @(posedge sclk or negedge s_rst_n) begin
        if(!s_rst_n)
                direct_a        <=      1'b0;
        else if(chg_flag)
                direct_a        <=      ~direct_a;
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(!s_rst_n)
                chg_flag        <=      1'b0;
        else if(chg_cnt >= PERIOD - rounds)
                chg_flag        <=      1'b1;
        else
                chg_flag        <=      1'b0;
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(!s_rst_n)
                chg_cnt <=      27'b0;
        else if(chg_cnt >= PERIOD - rounds)
                chg_cnt <=      27'b0;
        else if(status == AJUST)
                chg_cnt <=      chg_cnt + 1'b1;
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(!s_rst_n)
                rounds  <=      27'b0;
        else if(chg_cnt >= PERIOD - rounds)
                rounds  <=      rounds + (PERIOD - rounds)/10;
end





endmodule