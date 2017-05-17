`timescale      1ns/1ns

module  tb_pwm();

reg                     sclk                    ;
reg                     s_rst_n                 ;
reg                     direct                  ;
reg                     enable                  ;

wire    [ 1:0]          MA                      ; 

initial begin
        sclk    =       1'b1;
        s_rst_n <=      1'b0;
        direct  <=      1'b1;
        enable  <=      1'b0;
        #100
        s_rst_n <=      1'b1;
        enable  <=      1'b1;
end

always  #10     sclk    =       ~sclk;

pwm     pwm_inst(
        .sclk                   (sclk                   ),
        .s_rst_n                (s_rst_n                ),
        .enable                 (enable                 ),
        .direct                 (direct                 ),
        .MA                     (MA                     )
); 

endmodule