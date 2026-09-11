module clk_div_100hz #( 
    parameter TOGGLE_COUNT = 250000 
)(
    input  wire clk_50M,
    input  wire rst_n,
    output reg  clk_100Hz
);
    reg [$clog2(TOGGLE_COUNT)-1:0] counter;

    always @(posedge clk_50M or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            clk_100Hz <= 1'b0;
        end else begin
            if (counter == TOGGLE_COUNT - 1) begin
                counter <= 0;
                clk_100Hz <= ~clk_100Hz;
            end else begin
                counter <= counter + 1;
            end
        end
    end
endmodule