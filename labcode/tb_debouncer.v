module tb_debouncer;

    // 50MHz clock -> 20ns period
    reg clk;
    reg rst_n;
    reg sw;
    wire db;

    integer errors = 0;

    debouncer_fsm #(
        .TICK_CYCLES(5)
    ) DUT (
        .clk(clk),
        .rst_n(rst_n),
        .sw(sw),
        .db(db)
    );

    // Clock generation (20ns period)
    initial begin
        clk = 0;
        forever #10 clk = ~clk; 
    end

    // Stimulus and Self-Checking Logic
    initial begin
        rst_n = 0; 
        sw = 0;
        @(negedge clk); 
        rst_n = 1;
        repeat(5) @(negedge clk); 


        //Switch Bounce / Glitch Rejection (0 to 1)

        sw = 1;
        // Hold for 12 cycles (240ns).
        repeat(12) @(negedge clk); 
        sw = 0; 
        
   
        repeat(5) @(negedge clk);
        
        if (db !== 1'b0) begin
            $display("ERROR [Scen 1]: FSM failed to reject a high glitch. db should be 0, got %b", db);
            errors = errors + 1;
        end else begin
            $display("PASS [Scen 1]: High glitch successfully rejected.");
        end


        //Stable Press (0 to 1)

        sw = 1;
        // Hold for 20 cycles (400ns).
        repeat(20) @(negedge clk); 
        
        if (db !== 1'b1) begin
            $display("ERROR [Scen 2]: FSM failed to register a stable press. db should be 1, got %b", db);
            errors = errors + 1;
        end else begin
            $display("PASS [Scen 2]: Stable press successfully registered.");
        end

        //Switch Bounce / Glitch Rejection (1 to 0)
        sw = 0;
        // Hold for 12 cycles (240ns).
        repeat(12) @(negedge clk); 
        sw = 1; 
        
        repeat(5) @(negedge clk);
        
        if (db !== 1'b1) begin
            $display("ERROR [Scen 3]: FSM failed to reject a low glitch. db should remain 1, got %b", db);
            errors = errors + 1;
        end else begin
            $display("PASS [Scen 3]: Low glitch successfully rejected.");
        end


        // Stable Release (1 to 0)

        sw = 0;

        repeat(20) @(negedge clk); 
        
        if (db !== 1'b0) begin
            $display("ERROR [Scen 4]: FSM failed to register a stable release. db should be 0, got %b", db);
            errors = errors + 1;
        end else begin
            $display("PASS [Scen 4]: Stable release successfully registered.");
        end

        if (errors == 0)
            $display("SUCCESS: All debouncer scenarios passed.");
        else
            $display("FAILED: System finished with %0d errors.", errors);
        $stop;
    end
endmodule