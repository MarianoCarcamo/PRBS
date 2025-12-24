module register_cell(
    output o_bit,
    input i_bit,
    input i_seed_bit,
    input i_mux,
    input i_enb,
    input i_clk,
    input i_rst
);

reg r_bit;

always @(posedge i_clk) begin
    if(!i_rst) begin
        r_bit <= i_seed_bit;
    end else begin
        if(i_enb) begin
            r_bit <= i_bit;
        end else begin
            r_bit <= r_bit;
        end
    end
end

assign o_bit = !i_mux? i_bit : r_bit;


endmodule