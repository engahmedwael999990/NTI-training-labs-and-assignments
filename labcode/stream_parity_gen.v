module stream_parity_gen (
    input  wire clk,
    input  wire reset,       
    input  wire serial_in,
    output wire parity_out,
    output wire valid
);

    reg [7:0] shift_reg;
    reg [3:0] bit_count;

    function reg calc_even_parity;
        input [7:0] data;
        integer i;
        reg p;
        begin
            p = 1'b0;
            for (i = 0; i < 8; i = i + 1) begin
                p = p ^ data[i]; 
            end
            calc_even_parity = p;
        end
    endfunction

    always @(posedge clk) begin
        if (reset) begin
            shift_reg <= 8'b0;
            bit_count <= 4'b0;
        end else begin
            shift_reg <= {shift_reg[6:0], serial_in};
            
           
            if (bit_count == 4'd7) begin
                bit_count <= 4'd1; 
            end else begin
                bit_count <= bit_count + 1'b1;
            end
        end
    end

    assign valid = (bit_count == 4'd7);
    assign parity_out = calc_even_parity(shift_reg);

endmodule