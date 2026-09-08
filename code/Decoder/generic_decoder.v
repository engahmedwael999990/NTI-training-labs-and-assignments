module generic_decoder #(
    parameter N = 3 // N inputs, 2^N outputs
)(
    input  wire                 en,
    input  wire [N-1:0]         in,
    output reg  [(1<<N)-1:0]    out
);

    always @(*) begin
        if (en) begin
            out = 1 << in; 
        end else begin
            out = 0;
        end
    end
endmodule