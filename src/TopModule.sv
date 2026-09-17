// Top Module should be exposed to the main pins of the APB and the I2C's
// bus. and the rest should be internal to the module. and defined in the
// instantiation of the their respective modules.

module Top_Module 
(
    input  PCLK, 
    input  PRESETn,         // APB clock Active Low
    input  [11:0] PADDR,    // APB address bus 
    input  PSEL,            // APB select signal
    input  PENABLE,         // APB enable signal
    input  PWRITE,          // APB write signal  
    input  [31:0] PWDATA,   // APB write data bus
    output [31:0] PRDATA,   // APB read data bus    
    output PREADY,          // APB ready signal
    output PSLVERR,         // APB slave error signal
    inout  SDA,             // I2C SDA bus
    inout  SCL              // I2C SCL bus
); 
wire rst = !PRESETn;          // this way it can be active high
wire master_start;            // wire to start the I2C master transaction
wire master_rw;               // wire to indicate read or write operation for the I2C master
wire [6:0] master_slave_addr; // wire to hold the slave address for the I2C master
wire [7:0] master_tx_data;    // wire to hold the data to be transmitted by the I2C master
wire [31:0] master_clk_div;   // wire to hold the clock divider value for the I2C master
wire master_busy;             // wire to indicate if the I2C master is busy
wire master_done;             // wire to indicate if the I2C master has completed a transaction
wire master_ack_error;        // wire to indicate if the I2C master has received an ACK error
wire master_bus_error;        // wire to indicate if the I2C master has a bus error


wire i2c_bus_busy;   // MUST CHECK WHEN I2C MASTER IS RECEIVED            // wire to indicate if the I2C bus is busy



wire [7:0] slave_rx_data;     // wire to hold the data received by the I2C slave    
wire [7:0] master_rx_data;    // wire to hold the data received by the I2C master
wire slave_sda_drive_low;     // wire to indicate if the I2C slave is driving the SDA line low
wire master_sda_drive_low;    // wire to indicate if the I2C master is driving the SDA line low
wire scl_drive_low;           // wire to indicate if the I2C master is driving the SCL line low

// Open Drain connections
assign SDA = (master_sda_drive_low || slave_sda_drive_low) ? 1'b0 : 1'bz;
assign SCL = scl_drive_low ? 1'b0 : 1'bz;


// -------------------------------------------------------------------------
// APB to I2C register bridge
// -------------------------------------------------------------------------
apb_i2c_regs Bridge (
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
// I2C Slave and Master instantiation
// -------------------------------------------------------------------------
i2c_slave i2c_slave
#( .SLAVE_ADDRESS(7'h50))
(
    .sda_in(SDA),
    .scl_in(SCL),
    .sda_drive_low(slave_sda_drive_low),
    .clk(PCLK),
    .rst(rst),
    .rx_data(slave_rx_data)
);



// -------------------------------------------------------------------------
// I2C Master instantiation
// -------------------------------------------------------------------------
i2c_master i2c_master
(
    .clk(PCLK),
    .rst(rst),
    .start(master_start),
    .rw(master_rw),
    .slave_addr(master_slave_addr),
    .tx_data(master_tx_data),
    .rx_data(master_rx_data),
    .busy(master_busy),
    .done(master_done),
    .ack_error(master_ack_error),
    .bus_error(master_bus_error),
    .i2c_bus_busy(i2c_bus_busy),
    .sda_in(SDA),
    .scl_in(SCL),
    .clk_div(master_clk_div),
    .sda_drive_low(master_sda_drive_low),
    .scl_drive_low(scl_drive_low)
);

endmodule