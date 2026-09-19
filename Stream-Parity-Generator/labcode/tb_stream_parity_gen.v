module tb_stream_parity_gen;

    reg clk;
    reg reset;
    reg serial_in;
    wire parity_out;
    wire valid;

    integer errors = 0;

    stream_parity_gen DUT (
        .clk(clk),
        .reset(reset),
        .serial_in(serial_in),
        .parity_out(parity_out),
        .valid(valid)
    );

    // 50MHz clock generation (20ns period)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end


    // Exhaustive Testing Task(self checking)

    task run_exhaustive_test;
        integer val;
        integer bit_idx;
        reg [7:0] current_byte;
        reg expected_parity;
        begin
            
            // Outer loop: iterate through all possible 8-bit values (00 to FF)
            for (val = 0; val < 256; val = val + 1) begin
                current_byte = val;
                

                expected_parity = ^current_byte; 

                // Inner loop: Serialize the 8 bits (MSB first)
                for (bit_idx = 7; bit_idx >= 0; bit_idx = bit_idx - 1) begin
                    serial_in = current_byte[bit_idx];
                    @(negedge clk); 
                end
                
                if (parity_out !== expected_parity) begin
                    $display("ERROR: Parity mismatch for data %b. Expected %b, got %b", 
                             current_byte, expected_parity, parity_out);
                    errors = errors + 1;
                end
            end
        end
    endtask

    // Main Simulation Block

    initial begin

        reset = 1;
        serial_in = 0;
        @(negedge clk);
        reset = 0;

        run_exhaustive_test();


        if (errors == 0)
            $display("SUCCESS: All 256 combinations passed successfully.");
        else
            $display("FAILED: System finished with %0d errors.", errors);

        $stop;
    end
endmodule