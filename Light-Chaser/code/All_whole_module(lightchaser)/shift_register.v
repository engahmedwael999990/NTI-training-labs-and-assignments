module shift_register #(
    parameter NUM_BITS = 10
)(
    input  wire                clk,
    input  wire                reset_n,
    input  wire                hold_n,
    output reg  [NUM_BITS-1:0] shift_out
);
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // Initialize with 1 at the MSB, and 0s elsewhere
            shift_out <= {1'b1, {(NUM_BITS-1){1'b0}}};
        end else begin
            // Active low hold_n means it shifts when hold_n == 1
            if (hold_n == 1'b1) begin
                // Rotate right (Light chaser effect)
                shift_out <= {shift_out[0], shift_out[NUM_BITS-1:1]};
            end
        end
    end
endmodule