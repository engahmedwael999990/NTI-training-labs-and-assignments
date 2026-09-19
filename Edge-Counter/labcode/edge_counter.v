module edge_counter (
    input  wire clk_100Hz,
    input  wire rst_n,
    input  wire rise_tick,
    input  wire fall_tick,
    input  wire edge_tick,
    output reg  [3:0] rise_count,
    output reg  [3:0] fall_count,
    output reg  [3:0] total_count
);
    always @(posedge clk_100Hz or negedge rst_n) begin
        if (!rst_n) begin
            rise_count  <= 0;
            fall_count  <= 0;
            total_count <= 0;
        end else begin
            if (rise_tick) rise_count  <= rise_count + 1;
            if (fall_tick) fall_count  <= fall_count + 1;
            if (edge_tick) total_count <= total_count + 1;
        end
    end
endmodule