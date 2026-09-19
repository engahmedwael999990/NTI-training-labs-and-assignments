module tb_shift_register;
    parameter N_BITS = 10;
    
    reg clk, reset_n, hold_n;
    wire [N_BITS-1:0] shift_out;

    reg [N_BITS-1:0] expected_val;
    integer errors = 0;
    integer i;
    reg rand_hold;

    shift_register #(.NUM_BITS(N_BITS)) DUT (
        .clk(clk), .reset_n(reset_n), .hold_n(hold_n), .shift_out(shift_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Initialization
        reset_n = 0; hold_n = 1;
        @(negedge clk);
        reset_n = 1;
        
        expected_val = {1'b1, {(N_BITS-1){1'b0}}};

        // Self-Checking Loop with Random Stimulus
        for (i = 0; i < 20; i = i + 1) begin
            // Generate random 1-bit hold_n constraint at negedge
            rand_hold = $random % 2; 
            hold_n = rand_hold;
            
            @(negedge clk); // Step forward one full clock cycle (past the posedge)
            
            // Update expected value if hold_n was inactive (1)
            if (rand_hold == 1'b1) begin
                expected_val = {expected_val[0], expected_val[N_BITS-1:1]};
            end
            
            // Validate
            if (shift_out !== expected_val) begin
                $display("ERROR at iteration %0d: Expected %b, Got %b (hold_n=%b)", 
                         i, expected_val, shift_out, hold_n);
                errors = errors + 1;
            end else begin
                $display("PASS: hold_n=%b | shift_out=%b", hold_n, shift_out);
            end
        end

        if (errors == 0) $display("SUCCESS: Shift Register passed random stimulus checks.");
        $stop;
    end
endmodule