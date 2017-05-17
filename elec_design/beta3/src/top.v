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
        // output          [ 3:0]  stepdrive
        output          [ 1:0]  MA                      ,
        output          [ 1:0]  MH                      
);

//============================================================\
// ========= Define Parameter and Internal Signals ==========
//============================================================/ 
wire                    pi_flag                         ;
wire                    direct                          ;
wire                    enable                          ;
wire                    flag                            ;
wire    [ 2:0]          cnt                             ;


//====================================================================
// ***************      Main    Code    ***************
//====================================================================
assign  MH      =       {1'b0,1'b1};

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
        .flag                   (flag                   ),
        .direct                 (direct                 ),
        .enable                 (enable                 ),
        .cnt                    (cnt                    )
);

/* motor   motor_inst(
        .sclk                   (sclk                   ),
        .s_rst_n                (s_rst_n                ),
        .direct                 (direct                 ),
        .stepenable             (stepenable             ),
        .stepdrive              (stepdrive              )
); */

pwm     pwm_inst(
        .sclk                   (sclk                   ),
        .s_rst_n                (s_rst_n                ),
        .enable                 (enable                 ),
        .direct                 (direct                 ),
        .cnt                    (cnt                    ),
        .flag                   (flag                   ),
        .MA                     (MA                     )
);        








endmodule