module tb_generic_decoder;
    parameter N = 3;
    parameter OUT_WIDTH = 1 << N;

    // Testbench signals 
    reg                  en;
    reg  [N-1:0]         in;
    wire [OUT_WIDTH-1:0] out;

    reg  [OUT_WIDTH-1:0] expected_out;
    integer errors = 0;
    integer i;

    generic_decoder #(.N(N)) DUT (
        .en(en), 
        .in(in), 
        .out(out)
    );

    initial begin
        // Initialize
        en = 0; in = 0;
        
        // Test 1: Disabled State
        #10; 
        if (out !== 0) begin
            $display("ERROR: Decoder not 0 when disabled (en=0). Got: %b", out);
            errors = errors + 1;
        end else begin
            $display("PASS: Disabled State -> Output %b", out);
        end

        // Test 2: Iterate through all possible inputs
        en = 1;
        for (i = 0; i < OUT_WIDTH; i = i + 1) begin
            in = i;
            expected_out = 1 << i;
            
            #10; 
            
            if (out !== expected_out) begin
                $display("ERROR: For input %d, expected %b, got %b", in, expected_out, out);
                errors = errors + 1;
            end else begin
                $display("PASS: Input %d -> Output %b", in, out);
            end
        end

        if (errors == 0) $display("SUCCESS: Parameterized Decoder passed all tests.");
        else $display("FAILED with %0d errors.", errors);
        $stop;
    end
endmodule