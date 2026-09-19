module controller (
    input  wire [2:0] opcode,
    input  wire [2:0] phase,
    input  wire       zero,
    output reg        sel,
    output reg        rd,
    output reg        ld_ir,
    output reg        inc_pc,
    output reg        halt,
    output reg        ld_pc,
    output reg        data_e,
    output reg        ld_ac,
    output reg        wr
);

    // Instruction Opcodes
    localparam HLT = 3'b000;
    localparam SKZ = 3'b001;
    localparam ADD = 3'b010;
    localparam AND = 3'b011;
    localparam XOR = 3'b100;
    localparam LDA = 3'b101;
    localparam STO = 3'b110;
    localparam JMP = 3'b111;

    // Phase Names
    localparam INST_ADDR  = 3'b000;
    localparam INST_FETCH = 3'b001;
    localparam INST_LOAD  = 3'b010;
    localparam IDLE       = 3'b011;
    localparam OP_ADDR    = 3'b100;
    localparam OP_FETCH   = 3'b101;
    localparam ALU_OP     = 3'b110;
    localparam STORE      = 3'b111;

    
    always @(*) begin
        
        sel    = 1'b0;
        rd     = 1'b0;
        ld_ir  = 1'b0;
        inc_pc = 1'b0;
        halt   = 1'b0;
        ld_pc  = 1'b0;
        data_e = 1'b0;
        ld_ac  = 1'b0;
        wr     = 1'b0;

        case (phase)
            INST_ADDR: begin
                sel = 1'b1;
            end
            
            INST_FETCH: begin
                sel = 1'b1;
                rd  = 1'b1;
            end
            
            INST_LOAD: begin
                sel   = 1'b1;
                rd    = 1'b1;
                ld_ir = 1'b1;
            end
            
            IDLE: begin
                sel   = 1'b1;
                rd    = 1'b1;
                ld_ir = 1'b1;
            end
            
            OP_ADDR: begin
                inc_pc = 1'b1;
                if (opcode == HLT) begin
                    halt = 1'b1;
                end
            end
            
            OP_FETCH: begin
                if (opcode == ADD || opcode == AND || opcode == XOR || opcode == LDA) begin
                    rd = 1'b1;
                end
            end
            
            ALU_OP: begin
                if (opcode == ADD || opcode == AND || opcode == XOR || opcode == LDA) begin
                    rd = 1'b1;
                end
                if (opcode == SKZ && zero == 1'b1) begin
                    inc_pc = 1'b1;
                end
                if (opcode == JMP) begin
                    ld_pc = 1'b1;
                end
                if (opcode == STO) begin
                    data_e = 1'b1;
                end
            end
            
            STORE: begin
                if (opcode == ADD || opcode == AND || opcode == XOR || opcode == LDA) begin
                    rd    = 1'b1;
                    ld_ac = 1'b1;
                end
                if (opcode == JMP) begin
                    ld_pc = 1'b1;
                end
                if (opcode == STO) begin
                    data_e = 1'b1;
                    wr     = 1'b1;
                end
            end

            default: begin
                sel    = 1'b0;
                rd     = 1'b0;
                ld_ir  = 1'b0;
                inc_pc = 1'b0;
                halt   = 1'b0;
                ld_pc  = 1'b0;
                data_e = 1'b0;
                ld_ac  = 1'b0;
                wr     = 1'b0;
            end
        endcase
    end

endmodule