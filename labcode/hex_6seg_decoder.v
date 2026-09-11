module hex_6seg_decoder (
    input  wire rst_n,
    input  wire [3:0] rise_count,
    input  wire [3:0] fall_count,
    input  wire [3:0] total_count,
    output reg  [6:0] seg_r, seg_rc,
    output reg  [6:0] seg_f, seg_fc,
    output reg  [6:0] seg_t, seg_tc
);

    // Internal wires to catch the outputs of the sub-modules
    wire [6:0] out_rc, out_fc, out_tc;

    // Instantiate for the Rise Count
    hex2seg_single u_dec_rise (
        .hex(rise_count),
        .seg(out_rc)
    );

    // Instantiate for the Fall Count
    hex2seg_single u_dec_fall (
        .hex(fall_count),
        .seg(out_fc)
    );

    // Instantiate for the Total Count
    hex2seg_single u_dec_total (
        .hex(total_count),
        .seg(out_tc)
    );

    // Mux Logic: Choose between Reset state or Normal operation
    always @(*) begin
        if (!rst_n) begin
            // "NULL" Reset Condition (Active Low)
            seg_r  = 7'b0101011; 
            seg_rc = 7'b1000001; 
            seg_f  = 7'b1000111;
            seg_fc = 7'b1000111; 
            seg_t  = 7'b1111111; 
            seg_tc = 7'b1111111; 
        end else begin
            // Normal Operational Condition using the sub-module outputs
            seg_r  = 7'b0101111; 
            seg_rc = out_rc;     
            seg_f  = 7'b0001110; 
            seg_fc = out_fc;     
            seg_t  = 7'b0000111;    
            seg_tc = out_tc;     
        end
    end
endmodule