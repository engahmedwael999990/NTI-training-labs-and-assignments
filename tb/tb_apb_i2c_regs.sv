// -----------------------------------------------------------------------------
// Testbench for apb_i2c_regs.sv
// -----------------------------------------------------------------------------
// Tests:
//   1. Reset values
//   2. Write/read CTRL
//   3. Write/read SLAVE_ADDR
//   4. Write/read TX_DATA
//   5. Write/read CLK_DIV
//   6. START one-cycle pulse
//   7. START ignored while master is busy
//   8. Master DONE / RX_DATA / status capture
//   9. ACK_ERROR capture
//  10. BUS_ERROR and I2C_BUS_BUSY status
//  11. Invalid APB address -> PSLVERR
//  12. VERSION read
//
// This is a register-block testbench. The I2C master itself is modeled by
// driving the status inputs of the register block.
// -----------------------------------------------------------------------------

module tb_apb_i2c_regs;

    // -------------------------------------------------------------------------
    // Clock / reset
    // -------------------------------------------------------------------------
    reg        PCLK;
    reg        PRESETn;

    // -------------------------------------------------------------------------
    // APB signals
    // -------------------------------------------------------------------------
    reg [11:0] PADDR;
    reg        PSEL;
    reg        PENABLE;
    reg        PWRITE;
    reg [31:0] PWDATA;

    wire [31:0] PRDATA;
    wire        PREADY;
    wire        PSLVERR;

    // -------------------------------------------------------------------------
    // I2C master control outputs from DUT
    // -------------------------------------------------------------------------
    wire        master_start;
    wire        master_rw;
    wire [6:0]  master_slave_addr;
    wire [7:0]  master_tx_data;
    wire [31:0] master_clk_div;

    // -------------------------------------------------------------------------
    // I2C master/status inputs to DUT
    // -------------------------------------------------------------------------
    reg        master_busy;
    reg        master_done;
    reg        master_ack_error;
    reg        master_bus_error;
    reg        i2c_bus_busy;
    reg [7:0]  master_rx_data;

    integer errors;

    // -------------------------------------------------------------------------
    // DUT
    // -------------------------------------------------------------------------
    apb_i2c_regs #(
        .CLK_DIV_DEFAULT(32'd250),
        .VERSION_VALUE(32'h0001_0000)
    ) dut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PADDR(PADDR),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .PSLVERR(PSLVERR),

        .master_start(master_start),
        .master_rw(master_rw),
        .master_slave_addr(master_slave_addr),
        .master_tx_data(master_tx_data),
        .master_clk_div(master_clk_div),

        .master_busy(master_busy),
        .master_done(master_done),
        .master_ack_error(master_ack_error),
        .master_bus_error(master_bus_error),
        .i2c_bus_busy(i2c_bus_busy),
        .master_rx_data(master_rx_data)
    );

    // -------------------------------------------------------------------------
    // 50 MHz clock
    // Period = 20 ns
    // -------------------------------------------------------------------------
    initial begin
        PCLK = 1'b0;
        forever #10 PCLK = ~PCLK;
    end

    // -------------------------------------------------------------------------
    // Helper: check a value
    // -------------------------------------------------------------------------
    task check_value;
        input [31:0] actual;
        input [31:0] expected;
        input [255:0] name;
        begin
            if (actual !== expected) begin
                $display("FAIL: %s | expected = 0x%08h, actual = 0x%08h",
                         name, expected, actual);
                errors = errors + 1;
            end
            else begin
                $display("PASS: %s | value = 0x%08h", name, actual);
            end
        end
    endtask

    // -------------------------------------------------------------------------
    // APB write task
    //
    // APB transfer:
    //   Setup  : PSEL=1, PENABLE=0
    //   Access : PSEL=1, PENABLE=1
    // -------------------------------------------------------------------------
    task apb_write;
        input [11:0] addr;
        input [31:0] data;
        begin
            @(negedge PCLK);

            PADDR   = addr;
            PWDATA  = data;
            PWRITE  = 1'b1;
            PSEL    = 1'b1;
            PENABLE = 1'b0;

            @(negedge PCLK);

            PENABLE = 1'b1;

            @(posedge PCLK);

            #1;

            if (!PREADY) begin
                $display("FAIL: APB write not ready, addr=0x%03h", addr);
                errors = errors + 1;
            end

            @(negedge PCLK);

            PSEL    = 1'b0;
            PENABLE = 1'b0;
            PWRITE  = 1'b0;
            PADDR   = 12'h000;
            PWDATA  = 32'h0000_0000;
        end
    endtask

    // -------------------------------------------------------------------------
    // APB read task
    // -------------------------------------------------------------------------
    task apb_read;
        input  [11:0] addr;
        output [31:0] data;
        begin
            @(negedge PCLK);

            PADDR   = addr;
            PWDATA  = 32'h0000_0000;
            PWRITE  = 1'b0;
            PSEL    = 1'b1;
            PENABLE = 1'b0;

            @(negedge PCLK);

            PENABLE = 1'b1;

            @(posedge PCLK);

            #1;

            if (!PREADY) begin
                $display("FAIL: APB read not ready, addr=0x%03h", addr);
                errors = errors + 1;
            end

            data = PRDATA;

            @(negedge PCLK);

            PSEL    = 1'b0;
            PENABLE = 1'b0;
            PADDR   = 12'h000;
        end
    endtask

    // -------------------------------------------------------------------------
    // Main test sequence
    // -------------------------------------------------------------------------
    reg [31:0] read_data;

    initial begin
        errors = 0;

        // Initial APB values
        PADDR          = 12'h000;
        PSEL           = 1'b0;
        PENABLE        = 1'b0;
        PWRITE         = 1'b0;
        PWDATA         = 32'h0000_0000;

        // Initial I2C status values
        master_busy      = 1'b0;
        master_done      = 1'b0;
        master_ack_error = 1'b0;
        master_bus_error = 1'b0;
        i2c_bus_busy     = 1'b0;
        master_rx_data   = 8'h00;

        // ---------------------------------------------------------------------
        // TEST 1: RESET
        // ---------------------------------------------------------------------
        $display("");
        $display("==========================================");
        $display("TEST 1: RESET");
        $display("==========================================");

        PRESETn = 1'b0;

        repeat (3) @(posedge PCLK);

        #1;

        check_value({31'h0, master_start}, 32'h0000_0000,
                    "master_start after reset");
        check_value({31'h0, master_rw}, 32'h0000_0000,
                    "master_rw after reset");
        check_value({25'h0, master_slave_addr}, 32'h0000_0000,
                    "slave address after reset");
        check_value({24'h0, master_tx_data}, 32'h0000_0000,
                    "TX data after reset");
        check_value(master_clk_div, 32'd250,
                    "CLK_DIV after reset");

        PRESETn = 1'b1;

        // ---------------------------------------------------------------------
        // TEST 2: CTRL
        // ---------------------------------------------------------------------
        $display("");
        $display("==========================================");
        $display("TEST 2: CTRL REGISTER");
        $display("==========================================");

        apb_write(12'h000, 32'h0000_0002);

        apb_read(12'h000, read_data);

        // CTRL[1] is RW. CTRL[0] is a command pulse and reads back as zero.
        check_value(read_data, 32'h0000_0002,
                    "CTRL RW bit");

        // ---------------------------------------------------------------------
        // TEST 3: SLAVE_ADDR
        // ---------------------------------------------------------------------
        $display("");
        $display("==========================================");
        $display("TEST 3: SLAVE ADDRESS");
        $display("==========================================");

        apb_write(12'h008, 32'h0000_0050);

        check_value({25'h0, master_slave_addr}, 32'h0000_0050,
                    "SLAVE_ADDR output");

        apb_read(12'h008, read_data);

        check_value(read_data, 32'h0000_0050,
                    "SLAVE_ADDR readback");

        // ---------------------------------------------------------------------
        // TEST 4: TX_DATA
        // ---------------------------------------------------------------------
        $display("");
        $display("==========================================");
        $display("TEST 4: TX DATA");
        $display("==========================================");

        apb_write(12'h00C, 32'h0000_00A5);

        check_value({24'h0, master_tx_data}, 32'h0000_00A5,
                    "TX_DATA output");

        apb_read(12'h00C, read_data);

        check_value(read_data, 32'h0000_00A5,
                    "TX_DATA readback");

        // ---------------------------------------------------------------------
        // TEST 5: CLK_DIV
        // ---------------------------------------------------------------------
        $display("");
        $display("==========================================");
        $display("TEST 5: CLOCK DIVIDER");
        $display("==========================================");

        apb_write(12'h014, 32'd125);

        check_value(master_clk_div, 32'd125,
                    "CLK_DIV output");

        apb_read(12'h014, read_data);

        check_value(read_data, 32'd125,
                    "CLK_DIV readback");

        // ---------------------------------------------------------------------
        // TEST 6: START pulse
        // ---------------------------------------------------------------------
        $display("");
        $display("==========================================");
        $display("TEST 6: START COMMAND");
        $display("==========================================");

        // Select WRITE operation and START.
        apb_write(12'h000, 32'h0000_0001);

        // master_start is asserted for the PCLK cycle generated by the write.
        // It must return low afterwards.
        @(posedge PCLK);
        #1;

        if (master_start !== 1'b0) begin
            $display("FAIL: master_start did not return low");
            errors = errors + 1;
        end
        else begin
            $display("PASS: master_start returned low after one cycle");
        end

        // ---------------------------------------------------------------------
        // TEST 7: START while BUSY must be ignored
        // ---------------------------------------------------------------------
        $display("");
        $display("==========================================");
        $display("TEST 7: START WHILE BUSY");
        $display("==========================================");

        master_busy = 1'b1;

        apb_write(12'h000, 32'h0000_0001);

        if (master_start !== 1'b0) begin
            $display("FAIL: START was accepted while master_busy=1");
            errors = errors + 1;
        end
        else begin
            $display("PASS: START ignored while master_busy=1");
        end

        master_busy = 1'b0;

        // ---------------------------------------------------------------------
        // TEST 8: DONE + RX_DATA + successful completion
        // ---------------------------------------------------------------------
        $display("");
        $display("==========================================");
        $display("TEST 8: MASTER DONE / RX DATA");
        $display("==========================================");

        master_rx_data   = 8'hA5;
        master_ack_error = 1'b0;
        master_bus_error = 1'b0;
        master_done      = 1'b1;

        @(posedge PCLK);
        #1;

        master_done = 1'b0;

        apb_read(12'h010, read_data);
        check_value(read_data, 32'h0000_00A5,
                    "RX_DATA");

        apb_read(12'h004, read_data);
        check_value(read_data[4:0], 5'b00010,
                    "STATUS after successful DONE");

        // STATUS expected:
        // [0] BUSY       = 0
        // [1] DONE       = 1
        // [2] ACK_ERROR  = 0
        // [3] BUS_ERROR  = 0
        // [4] BUS_BUSY   = 0

        // ---------------------------------------------------------------------
        // TEST 9: ACK_ERROR
        // ---------------------------------------------------------------------
        $display("");
        $display("==========================================");
        $display("TEST 9: ACK ERROR");
        $display("==========================================");

        master_ack_error = 1'b1;
        master_done      = 1'b1;

        @(posedge PCLK);
        #1;

        master_done      = 1'b0;
        master_ack_error = 1'b0;

        apb_read(12'h004, read_data);

        check_value(read_data[4:0], 5'b00110,
                    "STATUS after ACK error");

        // ---------------------------------------------------------------------
        // TEST 10: BUS_ERROR / I2C_BUS_BUSY
        // ---------------------------------------------------------------------
        $display("");
        $display("==========================================");
        $display("TEST 10: BUS STATUS");
        $display("==========================================");

        master_bus_error = 1'b1;
        i2c_bus_busy     = 1'b1;
        master_busy      = 1'b1;

        apb_read(12'h004, read_data);

        check_value(read_data[4:0], 5'b11111,
                    "STATUS bus fields");

        master_bus_error = 1'b0;
        i2c_bus_busy     = 1'b0;
        master_busy      = 1'b0;

        // ---------------------------------------------------------------------
        // TEST 11: Invalid address
        // ---------------------------------------------------------------------
        $display("");
        $display("==========================================");
        $display("TEST 11: INVALID ADDRESS");
        $display("==========================================");

        // Setup phase first.
        @(negedge PCLK);

        PADDR   = 12'h100;
        PWRITE  = 1'b0;
        PSEL    = 1'b1;
        PENABLE = 1'b0;

        @(negedge PCLK);

        // Access phase.
        PENABLE = 1'b1;

        @(posedge PCLK);
        #1;

        if (PSLVERR !== 1'b1) begin
            $display("FAIL: PSLVERR was not asserted for invalid address");
            errors = errors + 1;
        end
        else begin
            $display("PASS: PSLVERR asserted for invalid address");
        end

        if (PRDATA !== 32'h0000_0000) begin
            $display("FAIL: Invalid address PRDATA expected 0, got 0x%08h",
                     PRDATA);
            errors = errors + 1;
        end
        else begin
            $display("PASS: Invalid address returned zero PRDATA");
        end

        @(negedge PCLK);

        PSEL    = 1'b0;
        PENABLE = 1'b0;

        // ---------------------------------------------------------------------
        // TEST 12: VERSION
        // ---------------------------------------------------------------------
        $display("");
        $display("==========================================");
        $display("TEST 12: VERSION");
        $display("==========================================");

        apb_read(12'h01C, read_data);

        check_value(read_data, 32'h0001_0000,
                    "VERSION");

        // ---------------------------------------------------------------------
        // Final result
        // ---------------------------------------------------------------------
        $display("");
        $display("==========================================");
        $display("APB-I2C REGISTER BLOCK VERIFICATION");
        $display("==========================================");

        if (errors == 0) begin
            $display("TOTAL FAILURES : 0");
            $display("RESULT         : PASS");
        end
        else begin
            $display("TOTAL FAILURES : %0d", errors);
            $display("RESULT         : FAIL");
            $fatal(1);
        end

        $display("==========================================");

        #100;
        $finish;
    end

endmodule
