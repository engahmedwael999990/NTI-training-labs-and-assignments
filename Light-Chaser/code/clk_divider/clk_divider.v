module clk_divider #( 
    parameter TOGGLE_COUNT = 3125000 
)(//each 3125000 cycles of clk_in, clk_out toggles once ,so 8 cycles of clk_out = 6250000 cycles of clk_in, so 50,000,000 / 6250000 = 8Hz
    input  wire clk_in,
    input  wire reset_n,
    output reg  clk_out
);
    reg [$clog2(TOGGLE_COUNT)-1:0] counter;

    always @(posedge clk_in or negedge reset_n) begin
        if (!reset_n) begin
            counter <= 0;
            clk_out <= 1'b0;
        end else begin
            if (counter == TOGGLE_COUNT - 1) begin
                counter <= 0;
                clk_out <= ~clk_out;
            end else begin
                counter <= counter + 1;
            end
        end
    end
endmodule