module tb_encoder_4x2;
    // Testbench signals 
    reg        en;
    reg  [3:0] in;
    wire [1:0] out;

    integer errors = 0;

    encoder_4x2 DUT (
        .en(en), 
        .in(in), 
        .out(out)
    );

    initial begin
        // 1. Test Disabled State
        en = 0; in = 4'b1111;
        #10; 
        
        if (out !== 2'd0) begin
            $display("ERROR: Encoder should output 0 when disabled (en=0). Got: %b", out);
            errors = errors + 1;
        end else begin
            $display("PASS: Disabled State -> out=%b", out);
        end

        // 2. Test Normal 1-Hot Encoding
        en = 1; 
        
        in = 4'b0001; #10;
        if (out !== 2'd0) begin 
            $display("ERROR for input %b, got %d", in, out); errors = errors + 1; 
        end else $display("PASS: Input %b -> Output %d", in, out);

        in = 4'b0010; #10;
        if (out !== 2'd1) begin 
            $display("ERROR for input %b, got %d", in, out); errors = errors + 1; 
        end else $display("PASS: Input %b -> Output %d", in, out);

        in = 4'b0100; #10;
        if (out !== 2'd2) begin 
            $display("ERROR for input %b, got %d", in, out); errors = errors + 1; 
        end else $display("PASS: Input %b -> Output %d", in, out);

        in = 4'b1000; #10;
        if (out !== 2'd3) begin 
            $display("ERROR for input %b, got %d", in, out); errors = errors + 1; 
        end else $display("PASS: Input %b -> Output %d", in, out);

        // 3. Test Priority Logic (Multiple 1s)
        in = 4'b1101; #10; // MSB is 1, should prioritize to output 3
        if (out !== 2'd3) begin 
            $display("ERROR for Priority Input %b, expected 3, got %d", in, out); errors = errors + 1; 
        end else begin
            $display("PASS: Priority Input %b -> Output %d", in, out);
        end

        in = 4'b0111; #10; // Bit 2 is highest, should prioritize to output 2
        if (out !== 2'd2) begin 
            $display("ERROR for Priority Input %b, expected 2, got %d", in, out); errors = errors + 1; 
        end else begin
            $display("PASS: Priority Input %b -> Output %d", in, out);
        end

        if (errors == 0) $display("SUCCESS: Normal 4x2 Encoder passed all tests.");
        else $display("FAILED with %0d errors.", errors);

        $stop;
    end
endmodule