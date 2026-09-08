module tb_top_gray2seg;
    // Testbench signals 
    reg  [3:0] in_gray;
    wire [6:0] seg_out;

    // Self-checking variables
    integer i;
    integer errors = 0;
    reg [3:0] expected_bin;
    reg [6:0] expected_seg;

    // Instantiate Top Module
    top_gray2seg DUT (
        .in_gray(in_gray),
        .seg_out(seg_out)
    );

    // Helper function to return expected active-low 7-seg values
    function [6:0] get_expected_seg;
        input [3:0] bin_val;
        begin
            case (bin_val)
                4'h0: get_expected_seg = 7'b1000000;
                4'h1: get_expected_seg = 7'b1111001;
                4'h2: get_expected_seg = 7'b0100100;
                4'h3: get_expected_seg = 7'b0110000;
                4'h4: get_expected_seg = 7'b0011001;
                4'h5: get_expected_seg = 7'b0010010;
                4'h6: get_expected_seg = 7'b0000010;
                4'h7: get_expected_seg = 7'b1111000;
                4'h8: get_expected_seg = 7'b0000000;
                4'h9: get_expected_seg = 7'b0010000;
                4'hA: get_expected_seg = 7'b0001000;
                4'hB: get_expected_seg = 7'b0000011;
                4'hC: get_expected_seg = 7'b1000110;
                4'hD: get_expected_seg = 7'b0100001;
                4'hE: get_expected_seg = 7'b0000110;
                4'hF: get_expected_seg = 7'b0001110;
                default: get_expected_seg = 7'b1111111;
            endcase
        end
    endfunction

    initial begin

        
        // Initialize
        in_gray = 4'b0000;
        #10;

        // Exhaustive test: Loop through all 16 binary numbers
        for (i = 0; i < 16; i = i + 1) begin
            expected_bin = i;
            
            // Calculate the Gray Code stimulus dynamically: G = (B >> 1) ^ B
            in_gray = (expected_bin >> 1) ^ expected_bin;
            
            // Get the expected 7-segment output based on the binary value
            expected_seg = get_expected_seg(expected_bin);

            // Wait 10 time units for combinational logic to settle
            #10;

            // Verify output
            if (seg_out !== expected_seg) begin
                $display("ERROR: Gray Input %b (Bin %h) | Expected Seg: %b, Got: %b",
                         in_gray, expected_bin, expected_seg, seg_out);
                errors = errors + 1;
            end else begin
                $display("PASS: Gray Input %b -> Internal Bin %h -> Seg Out %b", 
                         in_gray, expected_bin, seg_out);
            end
        end


        if (errors == 0) 
            $display("SUCCESS: Top Level Module passed all 16 tests!");
        else 
            $display("FAILED with %0d errors.", errors);
        $stop;
    end
endmodule