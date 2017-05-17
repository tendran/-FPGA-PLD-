`timescale      1ns/1ns

module  tb_state();

reg                     sclk                    ;
reg                     s_rst_n                 ;
reg                     catcher                 ;
reg                     jockey_r                ;
reg                     jockey_l                ;
reg                     key                     ;

wire                    direct                  ;
wire                    enable                  ;

initial begin
        sclk    =       1'b1;
        s_rst_n <=      1'b0;
        catcher <=      1'b1;
        jockey_l<=      1'b1;
        jockey_r<=      1'b1;
        key     <=      1'b0;
        #100
        s_rst_n <=      1'b1;
        #100
        key     <=      1'b1;
        #20
        key     <=      1'b0;
        #100
        catcher <=      1'b0;
        jockey_l<=      1'b0;
        #100
        key     <=      1'b1;
        #20
        key     <=      1'b0;
        
end

always  #10     sclk    =       ~sclk;

state   state_inst(
        .sclk                   (sclk                   ),
        .s_rst_n                (s_rst_n                ),
        .catcher                (catcher                ),
        .jockey_r               (jockey_r               ),
        .jockey_l               (jockey_l               ),
        .key                    (key                    ),
        .direct                 (direct                 ),
        .enable                 (enable                 )
);

endmodule