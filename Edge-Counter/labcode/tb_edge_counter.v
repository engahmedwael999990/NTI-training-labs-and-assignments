module tb_edge_counter;
    reg clk, rst_n, r_tick, f_tick, e_tick;
    wire [3:0] rc, fc, tc;
    integer errors = 0;

    edge_counter DUT (.clk_100Hz(clk), .rst_n(rst_n), .rise_tick(r_tick), .fall_tick(f_tick), 
                      .edge_tick(e_tick), .rise_count(rc), .fall_count(fc), .total_count(tc));

    initial begin clk = 0; forever #5 clk = ~clk; end

    initial begin
        rst_n = 0; r_tick = 0; f_tick = 0; e_tick = 0;
        @(negedge clk); rst_n = 1; @(negedge clk);

        r_tick = 1; e_tick = 1; @(negedge clk); // Pulse
        r_tick = 0; e_tick = 0; @(negedge clk); // Clear

        if (rc !== 1 || tc !== 1 || fc !== 0) begin $display("ERROR on Rise Count."); errors = errors+1; end

        f_tick = 1; e_tick = 1; @(negedge clk);
        f_tick = 0; e_tick = 0; @(negedge clk);

        if (fc !== 1 || tc !== 2 || rc !== 1) begin $display("ERROR on Fall Count."); errors = errors+1; end

        if(errors == 0) $display("SUCCESS: Edge Counter works.");
        $stop;
    end
endmodule