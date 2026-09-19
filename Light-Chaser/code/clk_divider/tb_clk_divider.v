module tb_clk_divider;
    reg  clk_in, reset_n;
    wire clk_out;

    // Use a small TOGGLE_COUNT (e.g., 4) for quick simulation
    parameter T_COUNT = 4;
    integer errors = 0;
    integer i;

    clk_divider #(.TOGGLE_COUNT(T_COUNT)) DUT (
        .clk_in(clk_in), .reset_n(reset_n), .clk_out(clk_out)
    );

    initial begin
        clk_in = 0;
        forever #5 clk_in = ~clk_in;
    end

    initial begin
        reset_n = 0;
        @(negedge clk_in);
        reset_n = 1;

        // Synchronize to the first negative edge of the output clock
        @(negedge clk_out);
        
        // Self-Checking Loop
        for (i = 0; i < 3; i = i + 1) begin
            // Wait for exactly T_COUNT rising edges (when the RTL counter increments)
            repeat(T_COUNT) @(posedge clk_in);
            
            // Wait half a cycle for the negedge to safely sample the updated value
            @(negedge clk_in); 
            
            // The output clock should have toggled to HIGH
            if (clk_out !== 1'b1) begin
                $display("ERROR: clk_out did not toggle HIGH after %0d cycles.", T_COUNT);
                errors = errors + 1;
            end

            // Wait for another T_COUNT rising edges
            repeat(T_COUNT) @(posedge clk_in);
            
            // Wait half a cycle for the negedge to safely sample
            @(negedge clk_in); 
            
            // The output clock should have toggled to LOW
            if (clk_out !== 1'b0) begin
                $display("ERROR: clk_out did not toggle LOW after %0d cycles.", T_COUNT);
                errors = errors + 1;
            end
        end

        if (errors == 0) $display("SUCCESS: Clock Divider works perfectly.");
        $stop;
    end
endmodule