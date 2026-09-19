module tb_edge_detector;
    reg clk, rst_n, in_sig;
    wire rise_tick, fall_tick, edge_tick;
    integer errors = 0;

    edge_detector DUT (.clk_100Hz(clk), .rst_n(rst_n), .in_sig(in_sig), 
                       .rise_tick(rise_tick), .fall_tick(fall_tick), .edge_tick(edge_tick));

    initial begin clk = 0; forever #5 clk = ~clk; end

    initial begin
        rst_n = 0; in_sig = 0;
        @(negedge clk); rst_n = 1; @(negedge clk);

        // Test Rising Edge
        in_sig = 1; @(negedge clk);
        if (!rise_tick || !edge_tick || fall_tick) begin $display("ERROR: Rise Tick failed."); errors = errors+1; end
        
        @(negedge clk); // S_ONE state
        if (rise_tick || edge_tick) begin $display("ERROR: Tick lasted too long."); errors = errors+1; end

        // Test Falling Edge
        in_sig = 0; @(negedge clk);
        if (!fall_tick || !edge_tick || rise_tick) begin $display("ERROR: Fall Tick failed."); errors = errors+1; end

        if(errors == 0) $display("SUCCESS: Edge Detector works perfectly.");
        $stop;
    end
endmodule