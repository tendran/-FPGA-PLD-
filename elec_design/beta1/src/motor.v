module  motor(
        // system signals 
        input                   sclk                    ,  
        input                   s_rst_n                 ,
        // input signals
        input                   direct                  , // 主轴转向
        input                   stepenable              , // 电机使能
        //output signals
        output  reg     [ 3:0]  stepdrive
);
//============================================================\
// ========= Define Parameter and Internal Signals ==========
//============================================================/ 
//parameter       STEPLOCKOUT     =       32'd200_000             ; //250HZ
//parameter       STEPLOCKOUT     =       32'd20_000              ; //25HZ
parameter       STEPLOCKOUT     =       32'd40_000             ;

reg     [ 2:0]          state                           ; 
reg     [31:0]          stepcounter                     ; // 转速计数

//====================================================================
// ***************      Main    Code    ***************
//====================================================================

always @(posedge sclk or negedge s_rst_n) begin 
        if(!s_rst_n)
                stepcounter     <=      32'b0;
        else if(stepcounter >= STEPLOCKOUT)
                stepcounter     <=      32'b0; 
        else if(stepenable == 1'b1)
                stepcounter     <=      stepcounter + 31'b1;                
end

always @(posedge sclk or negedge s_rst_n) begin 
        if(!s_rst_n)
                state   <=      3'b0;
        else if(direct == 1'b1 && stepcounter >= STEPLOCKOUT)
                state   <=      state + 3'b001; 
        else if(direct == 1'b0 && stepcounter >= STEPLOCKOUT)
                state   <=      state - 3'b001; 
end

always @(posedge sclk or negedge s_rst_n) begin 
        if(!s_rst_n) 
                stepdrive       <=      4'b0;
        else case(state)
                3'b000: stepdrive       <=      4'b0001; 
                3'b001: stepdrive       <=      4'b0011; 
                3'b010: stepdrive       <=      4'b0010; 
                3'b011: stepdrive       <=      4'b0110; 
                3'b100: stepdrive       <=      4'b0100; 
                3'b101: stepdrive       <=      4'b1100; 
                3'b110: stepdrive       <=      4'b1000; 
                3'b111: stepdrive       <=      4'b1001; 
        endcase        
end

endmodule