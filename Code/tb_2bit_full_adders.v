module tb_2bit_full_adders;

    // Testbench signals
    reg [1:0] tb_a;
    reg [1:0] tb_b;
    reg tb_cin;

    // Outputs from DUTs
    wire [1:0] gate_sum, struct_sum, behav_sum;
    wire gate_cout, struct_cout, behav_cout;

    // Self-checking variables
    reg [1:0] exp_sum;
    reg exp_cout;
    integer error_count = 0;
    integer i;

    // Instantiate the Gate-Level 2-Bit FA
    fa_2bit_gate DUT_GATE (
        .a(tb_a), .b(tb_b), .cin(tb_cin),
        .sum(gate_sum), .cout(gate_cout)
    );

    // Instantiate the Structural 2-Bit FA
    full_adder_2bit DUT_STRUCT (
        .a(tb_a), .b(tb_b), .cin(tb_cin),
        .sum(struct_sum), .cout(struct_cout)
    );

    // Instantiate the Behavioral 2-Bit FA
    fa_2bit_behavioral DUT_BEHAV (
        .a(tb_a), .b(tb_b), .cin(tb_cin),
        .sum(behav_sum), .cout(behav_cout)
    );

    // Stimulus and Self-Checking Task
    task check_results;
        begin
            // Calculate the expected true mathematical sum
            {exp_cout, exp_sum} = tb_a + tb_b + tb_cin;
            
            // Check Gate Level
            if ({gate_cout, gate_sum} !== {exp_cout, exp_sum}) begin
                $display("ERROR (Gate): A=%b, B=%b, Cin=%b | Expected={%b,%b}, Got={%b,%b}", 
                         tb_a, tb_b, tb_cin, exp_cout, exp_sum, gate_cout, gate_sum);
                error_count = error_count + 1;
            end

            // Check Structural Level
            if ({struct_cout, struct_sum} !== {exp_cout, exp_sum}) begin
                $display("ERROR (Struct): A=%b, B=%b, Cin=%b | Expected={%b,%b}, Got={%b,%b}", 
                         tb_a, tb_b, tb_cin, exp_cout, exp_sum, struct_cout, struct_sum);
                error_count = error_count + 1;
            end

            // Check Behavioral Level
            if ({behav_cout, behav_sum} !== {exp_cout, exp_sum}) begin
                $display("ERROR (Behav): A=%b, B=%b, Cin=%b | Expected={%b,%b}, Got={%b,%b}", 
                         tb_a, tb_b, tb_cin, exp_cout, exp_sum, behav_cout, behav_sum);
                error_count = error_count + 1;
            end
        end
    endtask

    
    initial begin
        $display("Starting 2-Bit Full Adder Tests...");
        
        // Loop through all 32 possible combinations of A(2), B(2), and Cin(1)
        for (i = 0; i < 32; i = i + 1) begin
            {tb_a, tb_b, tb_cin} = i;
            #10;               // Wait for combinational logic to settle
            check_results();   // Call the self-checking validation
        end

        // Final Report

        if (error_count == 0)
            $display("SUCCESS: All 3 modules passed 32/32 tests with 0 errors!");
        else
            $display("FAILED: Testbench completed with %0d total errors.", error_count);
        
        $stop;
    end

endmodule