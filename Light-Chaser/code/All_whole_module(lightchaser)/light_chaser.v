module light_chaser #(
    parameter TOGGLE_COUNT = 3125000,
    parameter NUM_BITS     = 10
)(
    input  wire                clk_50M,
    input  wire                reset_n,
    input  wire                hold_n,
    output wire [NUM_BITS-1:0] shift_out
);
    wire clk_8Hz; // Internal divided clock

    // Instantiate Clock Divider
    clk_divider #(
        .TOGGLE_COUNT(TOGGLE_COUNT)
    ) div_inst (
        .clk_in(clk_50M),
        .reset_n(reset_n),
        .clk_out(clk_8Hz)
    );

    // Instantiate Shift Register
    shift_register #(
        .NUM_BITS(NUM_BITS)
    ) sr_inst (
        .clk(clk_8Hz),
        .reset_n(reset_n),
        .hold_n(hold_n),
        .shift_out(shift_out)
    );

endmodule