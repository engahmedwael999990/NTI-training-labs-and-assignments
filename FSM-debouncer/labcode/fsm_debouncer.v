module debouncer_fsm#(
    parameter TICK_CYCLES = 5 
)(
    input  wire clk,
    input  wire rst_n,
    input  wire sw,
    output reg  db
);
    reg [$clog2(TICK_CYCLES)-1:0] counter;
    reg m_tick;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            m_tick  <= 1'b0;
        end else begin
            if (counter == TICK_CYCLES - 1) begin
                counter <= 0;
                m_tick  <= 1'b1;
            end else begin
                counter <= counter + 1;
                m_tick  <= 1'b0; 
            end
        end
    end
    
    localparam S_ZERO    = 3'b000;
    localparam S_WAIT1_1 = 3'b001;
    localparam S_WAIT1_2 = 3'b010;
    localparam S_WAIT1_3 = 3'b011;
    localparam S_ONE     = 3'b100;
    localparam S_WAIT0_1 = 3'b101;
    localparam S_WAIT0_2 = 3'b110;
    localparam S_WAIT0_3 = 3'b111;

    reg [2:0] cs, ns;

    // Next State Logic (Combinational)
    always @(*) begin
        case(cs)
            S_ZERO: 
                if (sw) ns = S_WAIT1_1;
                else    ns = S_ZERO;

            S_WAIT1_1: 
                if (!sw)        ns = S_ZERO;
                else if(m_tick) ns = S_WAIT1_2;
                else            ns = S_WAIT1_1;

            S_WAIT1_2: 
                if (!sw)        ns = S_ZERO;
                else if(m_tick) ns = S_WAIT1_3;
                else            ns = S_WAIT1_2;

            S_WAIT1_3: 
                if (!sw)        ns = S_ZERO;
                else if(m_tick) ns = S_ONE;
                else            ns = S_WAIT1_3;

            S_ONE: 
                if (!sw) ns = S_WAIT0_1;
                else     ns = S_ONE;

            S_WAIT0_1: 
                if (sw)         ns = S_ONE;
                else if(m_tick) ns = S_WAIT0_2;
                else            ns = S_WAIT0_1;

            S_WAIT0_2: 
                if (sw)         ns = S_ONE;
                else if(m_tick) ns = S_WAIT0_3;
                else            ns = S_WAIT0_2;

            S_WAIT0_3: 
                if (sw)         ns = S_ONE;
                else if(m_tick) ns = S_ZERO;
                else            ns = S_WAIT0_3;
                
            default: ns = S_ZERO;
        endcase
    end

    // State Memory (Sequential)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) cs <= S_ZERO;
        else        cs <= ns;
    end

    // Output Logic (Combinational - Moore FSM)
    always @(*) begin
        if (cs == S_ONE || cs == S_WAIT0_1 || cs == S_WAIT0_2 || cs == S_WAIT0_3) 
            db = 1'b1;
        else 
            db = 1'b0;
    end
endmodule