module  key(
        input                   sclk                    ,
        input                   s_rst_n                 ,
        input                   key                     ,
        output  reg             po_flag
);
//===================================================================\
// ========= Define Parameter and Internal Signals ==========
//===================================================================/
parameter       DELAY_10MS      =       499999                  ;

reg                             key_r1                          ;
reg                             key_r2                          ;
reg                             key_r3                          ;
reg                             key_chg                         ;
// reg                     key_neg                 ;
// reg                     key_pos                 ;
reg                             flag_cnt                        ;
// reg                     flag_pre                ;
// reg                     flag_for                ;
reg     [18:0]                  cnt_10ms                        ;
// reg             [ 8:0]  cnt_pre                 ;
// reg             [ 8:0]  cnt_for                 ;

//===========================================================================
// **************     Main     Code    **************
//===========================================================================
always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0) begin
                key_r1  <=      1'b1;
                key_r2  <=      1'b1;
                key_r3  <=      1'b1;
        end
        else begin
                key_r1  <=      key;
                key_r2  <=      key_r1;
                key_r3  <=      key_r2;
        end
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                key_chg <=      1'b0;
        else if((key_r2 == 1'b0 && key_r3 == 1'b1)||
                (key_r2 == 1'b1 && key_r3 == 1'b0))
                key_chg <=      1'b1;
        else
                key_chg <=      1'b0;
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                flag_cnt        <=      1'b0;
        else if(key_chg == 1'b1)
                flag_cnt        <=      1'b1;
        else if(cnt_10ms >= DELAY_10MS)
                flag_cnt        <=      1'b0;
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                cnt_10ms        <=      'd0;
        else if(cnt_10ms >= DELAY_10MS)
                cnt_10ms        <=      'd0;
        else if(flag_cnt == 1'b1)
                cnt_10ms        <=      cnt_10ms + 1'b1;
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                po_flag <=      1'b0;
        else if(cnt_10ms == 'd1)
                po_flag <=      1'b1;
        else
                po_flag <=      1'b0;
end

endmodule