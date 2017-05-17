module  state(
        // system signals
        input                   sclk                    ,
        input                   s_rst_n                 ,
        // input signals
        input                   catcher                 ,
        input                   jockey_r                ,
        input                   jockey_l                ,
        input                   key                     ,
        // output signals
        output  reg             direct                  ,
        output  reg             enable
);

//============================================================\
// ========= Define Parameter and Internal Signals ==========
//============================================================/ 
parameter       ROUND   =       3'd5                            ;

localparam      IDLE    =       6'b000001                       ,
                BALANCE =       6'b000010                       ,
                WAIT    =       6'b000100                       ,
                AUTOR   =       6'b001000                       , // 轨道右倾，主轴顺时针
                AUTOL   =       6'b010000                       , // 轨道左倾，主轴逆时针
                AJUST   =       6'b100000                       ;
                
reg     [ 2:0]          cnt                             ;
reg     [ 5:0]          status                          ;
//====================================================================
// ***************      Main    Code    ***************
//====================================================================

always  @(posedge sclk or negedge s_rst_n) begin
        if(!s_rst_n)
                cnt     <=      'd0;
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
                        if(!catcher)
                                status  <=      IDLE;
                        else
                                status  <=      AJUST;
                default:;
        endcase
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(!s_rst_n)
                enable  <=      1'b0;
        else if(status == BALANCE || status == AUTOR || status == AUTOL || status == AJUST)
                enable  <=      1'b1;
        else
                enable  <=      1'b0;
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(!s_rst_n)
                direct  <=      1'bz;
        else case(status)
                AUTOR:
                        direct  <=      1'b1;
                AUTOL,BALANCE,AJUST:
                        direct  <=      1'b0;
                default:
                        direct  <=      1'bz;
        endcase
end



endmodule