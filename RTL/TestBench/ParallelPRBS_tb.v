`timescale 1ns/100ps
`include "./RTL/Defines.v"

module parallel_prbs_tb;

    // Parameters
    localparam  K = `PARALLEL;
    localparam  MAX_PRBS = `MAX_PRBS;
    
    //Ports
    wire [K - 1 : 0] o_bits;

    reg  [MAX_PRBS * K - 1 : 0] i_PRBS_poly;
    reg  [MAX_PRBS * K - 1 : 0] i_PRBS_order;
    reg  [MAX_PRBS * K - 1 : 0] i_PRBS_seed;
    reg                         i_enb;
    reg                         i_clk;
    reg                         i_rst;
    
    //Variables
    wire [K - 1 : 0] file_bits;
    wire [K - 1 : 0] check_bits;

    integer fid, r, j;
    integer b[K-1 : 0];

    initial begin
    
        $dumpfile(`VCD_FILE);
        $dumpvars(0, parallel_prbs_tb);
    
        // Abre el archivo con los estímulos
        fid = $fopen("./vector_files/prbs_vector.out", "r");
        
        if (fid == 0) begin
            $display("Error: No se pudo abrir el archivo.");
            $finish;
        end
        
        i_clk = 1'b1;
        i_rst = 1'b0;
        i_enb = 1'b0;

        i_PRBS_poly  = `POLY;
        i_PRBS_order = `ORDER;
        i_PRBS_seed  = `SEED;
        
        #50 i_rst = 1'b1;
        #10 i_enb = 1'b1;
    
        while (!$feof(fid)) begin
            for(j = 0 ; j < K ; j = j + 1)begin
                r = $fscanf(fid, "%d", b[j]);
            end
            #10;
        end
    
        $fclose(fid);
        $finish;
    end

    always #5  i_clk =  ~i_clk ;

    genvar i;
    generate
        for(i = 0 ; i < K ; i = i + 1)begin
            assign file_bits[i] = b[i];
        end
    endgenerate

    assign check_bits = file_bits ^ o_bits;

    parallel_prbs # (
        .K(K),
        .MAX_PRBS(MAX_PRBS)
    )
    parallel_inst (
        .o_bits(o_bits),
        .i_PRBS_poly(i_PRBS_poly),
        .i_PRBS_order(i_PRBS_order),
        .i_PRBS_seed(i_PRBS_seed),
        .i_enb(i_enb),
        .i_clk(i_clk),
        .i_rst(i_rst)
    );

endmodule