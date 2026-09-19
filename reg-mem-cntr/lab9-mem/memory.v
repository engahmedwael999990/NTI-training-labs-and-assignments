module memory #(
    parameter AWIDTH = 5,
    parameter DWIDTH = 8
)(
    input  wire              clk,
    input  wire              wr,
    input  wire              rd,
    input  wire [AWIDTH-1:0] addr,
    inout  wire [DWIDTH-1:0] data
);

    // Memory array declaration
    reg [DWIDTH-1:0] mem [0:(1<<AWIDTH)-1];

    // Procedural assignment for write operation
    always @(posedge clk) begin
        if (wr) begin
            mem[addr] <= data;
        end
    end

    // Continuous assignment for read operation (tri-state buffer)
    assign data = (rd && !wr) ? mem[addr] : {DWIDTH{1'bz}};

endmodule