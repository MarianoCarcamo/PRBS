`include "./RTL/Defines.v"

module prbs
    (
        output reg [`PARALLEL - 1 : 0] o_bits,
        input                          i_enb,
        input                          i_clk,
        input                          i_rst
    );

    localparam K        = `PARALLEL;
    localparam MAX_PRBS = `MAX_PRBS;
    localparam POLY     = `POLY;
    localparam ORDER    = `ORDER;
    localparam SEED     = `SEED;

    reg [MAX_PRBS * K - 1 : 0] r_poly;
    reg [MAX_PRBS * K - 1 : 0] r_order;
    reg [MAX_PRBS * K - 1 : 0] r_seed;

    initial begin
        r_poly  = POLY;
        r_order = ORDER;
        r_seed  = SEED;
    end

    parallel_prbs
        #( 
            .K        (K),
            .MAX_PRBS (MAX_PRBS)
        )
        u_parallel_prbs(
            .o_bits(o_bits),
            .i_PRBS_poly(r_poly),
            .i_PRBS_order(r_order),
            .i_PRBS_seed(r_seed),
            .i_enb(i_enb),
            .i_clk(i_clk),
            .i_rst(i_rst)
        );

endmodule
