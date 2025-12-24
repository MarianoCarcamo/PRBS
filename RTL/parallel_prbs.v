module parallel_prbs
#( 
    parameter K        = 1, // Factor de paralelismo
    parameter MAX_PRBS = 5  //Como factor entero positivo de K. Se permite implementar hasta PRBS[MAX_PRBS * K]
)
(
    output reg [K - 1 : 0]            o_bits,
    input      [MAX_PRBS * K - 1 : 0] i_PRBS_poly,
    input      [MAX_PRBS * K - 1 : 0] i_PRBS_order,
    input      [MAX_PRBS * K - 1 : 0] i_PRBS_seed,
    input                             i_enb,
    input                             i_clk,
    input                             i_rst
);

localparam CELLS_PER_LINE = MAX_PRBS + 1; //A las celdas por fila dadas por MAX_PRBS le sumo la celda de feedback
localparam SEL_BITS = (K>1) ? $clog2(K) : 1;

wire [CELLS_PER_LINE * K - 1 : 0] w_fb_bits;
wire [MAX_PRBS * K**2 - 1    : 0] w_fb_bus;

reg [SEL_BITS * K - 1 : 0] r_sel_matrix;
reg [SEL_BITS * K - 1 : 0] r_sel_matrix_rotated;

integer q;
initial begin
    for(q = 0 ; q < K ; q = q + 1)begin
        r_sel_matrix[SEL_BITS*q +: SEL_BITS] = q;
    end
end

always @(posedge i_clk) begin
    if(!i_rst)begin
        o_bits <= {K{1'b0}};
    end else begin
        o_bits <= w_fb_bits[MAX_PRBS * K - 1 : 0];
    end
end

always @(*) begin
    r_sel_matrix_rotated = r_sel_matrix;
    for(q = 0 ; q < MAX_PRBS * K ; q = q + 1)begin
        if(i_PRBS_order[q])begin
            r_sel_matrix_rotated = r_sel_matrix_rotated << SEL_BITS | r_sel_matrix_rotated >> ((K-1)*SEL_BITS); //Wrapped left shift
        end
    end
end

genvar i,j;
generate
    for(i = 0 ; i < CELLS_PER_LINE ; i = i + 1)begin
        if(i == CELLS_PER_LINE - 1)begin
            for(j = 0 ; j < K ; j = j + 1)begin
                feedback_cell 
                    #(
                        .K              (K),
                        .MAX_PRBS_ORDER (MAX_PRBS)
                    ) inst_fb_cell(
                        .o_bit(w_fb_bits[(i*K) + j]),
                        .i_fb_signal(w_fb_bus),
                        .i_PRBS_poly(i_PRBS_poly),
                        .i_sel(r_sel_matrix_rotated[j*SEL_BITS +: SEL_BITS])
                    );
            end
        end else begin
            for(j = 0 ; j < K ; j = j + 1)begin
                register_cell
                    inst_reg_cell(
                        .o_bit(w_fb_bits[(i*K) + j]),
                        .i_bit(w_fb_bits[((i+1)*K) + j]),
                        .i_seed_bit(i_PRBS_seed[(i*K) + j]),
                        .i_mux(i_PRBS_order[(i*K) + j]),
                        .i_enb(i_enb),
                        .i_clk(i_clk),
                        .i_rst(i_rst)
                    );
            end
        end
    end

    for(i = 0 ; i < K ; i = i + 1) begin
        assign w_fb_bus[i*MAX_PRBS*K +: MAX_PRBS*K] = w_fb_bits[i +: MAX_PRBS*K];
    end
endgenerate

endmodule