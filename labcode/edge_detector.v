module edge_detector (
    input  wire clk_100Hz,
    input  wire rst_n,
    input  wire in_sig,
    output reg  rise_tick,
    output reg  fall_tick,
    output reg  edge_tick
);
    parameter S_ZERO = 2'b00;
    parameter S_RISE = 2'b01;
    parameter S_ONE  = 2'b10;
    parameter S_FALL = 2'b11;

    reg [1:0] cs, ns;

    // Next State Logic
    always @(*) begin
        case(cs)
            S_ZERO: ns = in_sig ? S_RISE : S_ZERO;
            S_RISE: ns = in_sig ? S_ONE  : S_FALL;
            S_ONE:  ns = in_sig ? S_ONE  : S_FALL;
            S_FALL: ns = in_sig ? S_RISE : S_ZERO;
            default: ns = S_ZERO;
        endcase
    end

    // State Memory (Async Active-Low Reset)
    always @(posedge clk_100Hz or negedge rst_n) begin
        if (!rst_n) cs <= S_ZERO;
        else        cs <= ns;
    end

    // Moore Output Logic
    always @(*) begin
        rise_tick = (cs == S_RISE) ? 1'b1 : 1'b0;
        fall_tick = (cs == S_FALL) ? 1'b1 : 1'b0;
        edge_tick = (cs == S_RISE || cs == S_FALL) ? 1'b1 : 1'b0;
    end
endmodule