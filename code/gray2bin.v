module gray2bin #(
    parameter N = 4
)(
    input  wire [N-1:0] gray,
    output wire [N-1:0] bin
);
    genvar i;

    assign bin[N-1] = gray[N-1];
    
    generate
        for (i = N-2; i >= 0; i = i - 1) begin : gen_gray_conv
            assign bin[i] = bin[i+1] ^ gray[i];
        end
    endgenerate   
endmodule