module tb_top_system;
    reg clk_50M, rst_n, in_sig;
    wire [6:0] s_r, s_rc, s_f, s_fc, s_t, s_tc;
    integer errors = 0;

    // Instantiate with a toggle count of 2 for extremely fast simulation
    top_edge_system #(.CLK_DIV_TOGGLE(2)) DUT (
        .clk_50M(clk_50M), .rst_n(rst_n), .in_sig(in_sig),
        .seg_r(s_r), .seg_rc(s_rc), .seg_f(s_f), .seg_fc(s_fc), .seg_t(s_t), .seg_tc(s_tc)
    );

    // 50MHz Clock Generation
    initial begin clk_50M = 0; forever #5 clk_50M = ~clk_50M; end

    initial begin
        // Initialize Inputs
        rst_n = 0; 
        in_sig = 0;

        // SCENARIO 1: Check initial Reset (nULL) State

        @(negedge clk_50M); 
        if (s_r !== 7'b0101011 || s_rc !== 7'b1000001 || s_f !== 7'b1000111) begin 
            $display("ERROR [Scen 1]: Top module reset failed to display 'nULL'."); 
            errors = errors + 1; 
        end else begin
            $display("PASS [Scen 1]: Reset state 'nULL' verified.");
        end
        rst_n = 1; // Release reset
        repeat(10) @(posedge clk_50M); // Let the system stabilize

        // SCENARIO 2: Single Pulse

        in_sig = 1; 
        repeat(10) @(posedge clk_50M); 
        in_sig = 0;
        repeat(10) @(posedge clk_50M); 

        // Rise=1 (7'b1111001), Fall=1 (7'b1111001), Total=2 (7'b0100100)
        if (s_rc !== 7'b1111001 || s_fc !== 7'b1111001 || s_tc !== 7'b0100100) begin
            $display("ERROR [Scen 2]: Single pulse counting failed."); 
            errors = errors + 1;
        end else begin
            $display("PASS [Scen 2]: Single pulse counted correctly.");
        end

        // SCENARIO 3: Multiple Rapid Pulses (3 pulses)
  
        repeat(3) begin
            in_sig = 1; repeat(6) @(posedge clk_50M);
            in_sig = 0; repeat(6) @(posedge clk_50M);
        end
        repeat(5) @(posedge clk_50M); // Wait for processing

        // Rise=4 (7'b0011001), Fall=4 (7'b0011001), Total=8 (7'b0000000)
        if (s_rc !== 7'b0011001 || s_fc !== 7'b0011001 || s_tc !== 7'b0000000) begin
            $display("ERROR [Scen 3]: Rapid multi-pulse counting failed."); 
            errors = errors + 1;
        end else begin
            $display("PASS [Scen 3]: Rapid multi-pulse counted correctly (R=4, F=4, T=8).");
        end

 
        // SCENARIO 4: Long Pulse (Testing Level Rejection)

        in_sig = 1; 
        repeat(50) @(posedge clk_50M); // Hold high for a very long time
        in_sig = 0;
        repeat(10) @(posedge clk_50M);

        // Previous counts + 1 more pulse.
        // Rise=5 (7'b0010010), Fall=5 (7'b0010010), Total=10 or Hex 'A' (7'b0001000)
        if (s_rc !== 7'b0010010 || s_tc !== 7'b0001000) begin
            $display("ERROR [Scen 4]: Long pulse edge detection failed. (Possible level-sensitivity issue)."); 
            errors = errors + 1;
        end else begin
            $display("PASS [Scen 4]: Long pulse correctly identified as single edge (R=5, F=5, T=A).");
        end

  
        // SCENARIO 5: Mid-Operation Reset

        rst_n = 0; 
        repeat(2) @(posedge clk_50M);
        if (s_r !== 7'b0101011 || s_rc !== 7'b1000001) begin 
            $display("ERROR [Scen 5]: Mid-operation reset failed to clear outputs."); 
            errors = errors + 1; 
        end else begin
            $display("PASS [Scen 5]: Mid-operation reset cleared system properly.");
        end


        // Final Results

        if(errors == 0) 
            $display("SUCCESS: Entire system passed all test scenarios with 0 errors!");
        else 
            $display("FAILED: System finished with %0d errors.", errors);

        
        $stop;
    end
endmodule