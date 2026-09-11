module tb_clk_div;
    reg clk, rst_n;
    wire clk_out;
    integer errors = 0;

    // Use small count for fast simulation
    clk_div_100hz #(.TOGGLE_COUNT(4)) DUT (.clk_50M(clk), .rst_n(rst_n), .clk_100Hz(clk_out));

    initial begin clk = 0; forever #5 clk = ~clk; end

    initial begin
        rst_n = 0; @(negedge clk); rst_n = 1;
        
        @(negedge clk_out);
        repeat(4) @(posedge clk);
        @(negedge clk);
        if(clk_out !== 1'b1) begin $display("ERROR: Did not toggle High."); errors = errors + 1; end
        
        repeat(4) @(posedge clk);
        @(negedge clk);
        if(clk_out !== 1'b0) begin $display("ERROR: Did not toggle Low."); errors = errors + 1; end

        if(errors == 0) $display("SUCCESS: Clock Divider works.");
        $stop;
    end
endmodule