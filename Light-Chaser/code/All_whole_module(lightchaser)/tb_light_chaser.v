module tb_light_chaser;
    // Scale parameters down drastically to make simulation verifiable without waiting millions of ticks
    parameter T_COUNT = 2; 
    parameter N_BITS = 4;

    reg clk_50M, reset_n, hold_n;
    wire [N_BITS-1:0] shift_out;

    reg [N_BITS-1:0] expected_val;
    integer errors = 0;
    integer i;

    light_chaser #(.TOGGLE_COUNT(T_COUNT), .NUM_BITS(N_BITS)) DUT (
        .clk_50M(clk_50M), .reset_n(reset_n), .hold_n(hold_n), .shift_out(shift_out)
    );

    initial begin
        clk_50M = 0;
        forever #5 clk_50M = ~clk_50M;
    end

    initial begin
        // Initialization
        reset_n = 0; hold_n = 1;
        @(negedge clk_50M);
        reset_n = 1;
        expected_val = 4'b1000;

        // Test normal rotation
        for (i = 0; i < 4; i = i + 1) begin
           
            repeat(T_COUNT * 2) @(negedge clk_50M);
            
            expected_val = {expected_val[0], expected_val[N_BITS-1:1]};
            
            if (shift_out !== expected_val) begin
                $display("ERROR: Expected %b, Got %b", expected_val, shift_out);
                errors = errors + 1;
            end else begin
                $display("PASS: shift_out=%b", shift_out);
            end
        end

        // Test hold functionality
        @(negedge clk_50M);
        hold_n = 0;
        
        repeat(T_COUNT * 4) @(negedge clk_50M); 
        if (shift_out !== expected_val) begin
             $display("ERROR: Value shifted while hold_n was active (0).");
             errors = errors + 1;
        end else begin
             $display("PASS: hold_n prevents shifting correctly.");
        end

        if (errors == 0) $display("SUCCESS: Top-level Light Chaser works seamlessly.");
        $stop;
    end
endmodule