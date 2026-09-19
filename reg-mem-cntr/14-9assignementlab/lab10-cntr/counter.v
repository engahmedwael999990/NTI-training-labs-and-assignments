module counter #(
    parameter WIDTH = 5
)(
    input  wire             clk,
    input  wire             rst,
    input  wire             load,
    input  wire             enab,
    input  wire [WIDTH-1:0] cnt_in,
    output reg  [WIDTH-1:0] cnt_out
);

    // Encapsulated combinational logic using a function
    function automatic [WIDTH-1:0] next_count;
        input             f_rst;
        input             f_load;
        input             f_enab;
        input [WIDTH-1:0] f_cnt_in;
        input [WIDTH-1:0] f_cnt_out;
        begin
            if (f_rst) begin
                next_count = {WIDTH{1'b0}};
            end else if (f_load) begin
                next_count = f_cnt_in;
            end else if (f_enab) begin
                next_count = f_cnt_out + 1'b1;
            end else begin
                next_count = f_cnt_out;
            end
        end
    endfunction

    // Sequential procedure
    always @(posedge clk) begin
        cnt_out <= next_count(rst, load, enab, cnt_in, cnt_out);
    end

endmodule