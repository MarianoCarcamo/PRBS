module feedback_cell
#(
    parameter K              = 5, //Factor de paralelismo
    parameter MAX_PRBS_ORDER = 1
)(
    output                                 o_bit,
    input [MAX_PRBS_ORDER * K**2 - 1  : 0] i_fb_signal, //Señales de feedback que ingresan al bloque
    input [MAX_PRBS_ORDER * K    - 1  : 0] i_PRBS_poly, //Polinomio de la PRBS. Ejemplo -> [00011] = "x^3 + x^2 + 1" ; El término independiente se lo ignora
    input [((K>1)? $clog2(K) - 1 : 0) : 0] i_sel       //Entrada de seleccion del mux
);

reg  [MAX_PRBS_ORDER * K - 1 : 0] r_fb_mux;
wire                              w_andxor;

// feedback Mux
integer i;
always @(*) begin
    r_fb_mux = {MAX_PRBS_ORDER*K{1'b0}};
    for(i = 0 ; i < K ; i = i + 1) begin
        if(i == i_sel) r_fb_mux = i_fb_signal[MAX_PRBS_ORDER*K*i +: MAX_PRBS_ORDER*K];
    end
end

assign o_bit = ^(r_fb_mux & i_PRBS_poly);

endmodule