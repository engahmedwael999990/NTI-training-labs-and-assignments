module tb_stream_parity_gen;

    reg clk;
    reg reset;
    reg serial_in;
    wire parity_out;
    wire valid;

    integer i;
    reg [7:0] test_data;

    stream_parity_gen DUT (
        .clk(clk),
        .reset(reset),
        .serial_in(serial_in),
        .parity_out(parity_out),
        .valid(valid)
    );

    // 50MHz clock generation (20ns period)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin

        reset = 1;
        serial_in = 0;
        @(negedge clk);
        reset = 0;


        test_data = 8'b1011_0010; 
        
        for (i = 7; i >= 0; i = i - 1) begin
            serial_in = test_data[i];
            @(negedge clk);
        end


        @(negedge clk);

        
        test_data = 8'b1111_0010;
        for (i = 7; i >= 0; i = i - 1) begin
            serial_in = test_data[i];
            @(negedge clk);
        end

        
        @(negedge clk);
        
        $display("Simulation Complete.");
        $stop;
    end
endmodule