module  top(
        // system signals 
        input                   sclk                    ,  
        input                   s_rst_n                 ,
        // input signals
        input                   key                     ,
        input                   catcher                 ,
        input                   jockey_r                ,
        input                   jockey_l                ,
        // output signals
        output          [ 3:0]  stepdrive               ,
        // output          [ 1:0]  MA    
        output          [ 1:0]  MH                      ,
        output                  GND                     
);

//============================================================\
// ========= Define Parameter and Internal Signals ==========
//============================================================/ 
wire                    pi_flag                         ;
wire                    direct                          ;
wire                    enable                          ;




//====================================================================
// ***************      Main    Code    ***************
//====================================================================
assign  MH      =       {1'b0,1'b1};
assign  GND     =       1'b0;


key     key_inst(
        .sclk                   (sclk                   ),
        .s_rst_n                (s_rst_n                ),
        .key                    (key                    ),
        .po_flag                (pi_flag                )
);

state   state_inst(
        .sclk                   (sclk                   ),
        .s_rst_n                (s_rst_n                ),
        .catcher                (catcher                ),
        .jockey_r               (jockey_r               ),
        .jockey_l               (jockey_l               ),
        .key                    (pi_flag                ),
        .direct                 (direct                 ),
        .enable                 (enable                 )
);

motor   motor_inst(
        .sclk                   (sclk                   ),
        .s_rst_n                (s_rst_n                ),
        .direct                 (direct                 ),
        .stepenable             (enable                 ),
        .stepdrive              (stepdrive              )
);

/* pwm     pwm_inst(
        .sclk                   (sclk                   ),
        .s_rst_n                (s_rst_n                ),
        .enable                 (enable                 ),
        .direct                 (direct                 ),
        .MA                     (MA                     )
);  */       








endmodule