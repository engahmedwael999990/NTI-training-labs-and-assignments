module top_gray2seg (
    input  wire [3:0] in_gray,
    output wire [6:0] seg_out
);
    // Internal wire connecting the two sub-modules
    wire [3:0] out_binary;

    gray2bin #(.N(4)) u_gray2bin (
        .gray(in_gray),
        .bin(out_binary)
    );

    bin2seg u_bin2seg (
        .bin(out_binary),
        .seg(seg_out)
    );

endmodule