/*!\file decode.sv
 * PUC-RS5 VERSION - 1.0.0 - Public Release
 *
 * Distribution:  March 2023
 *
 * Willian Nunes   <willian.nunes@edu.pucrs.br>
 * Marcos Sartori  <marcos.sartori@acad.pucrs.br>
 * Ney calazans    <ney.calazans@pucrs.br>
 *
 * Research group: GAPH-PUCRS  <>
 *
 * \brief
 * Decoder Unit is the second stage of PUC-RS5 processor core.
 *
 * \detailed
 * The decoder unit is the second stage of the PUC-RS5 processor core and 
 * is responsible for identify the instruction operation and based on that 
 * extracts the execution unit for that kind of instruction and
 * also fetches the operands in the register bank, calculate the immediate
 * operand and contains the mechanism of hazard detection, if a hazard is
 * detected (e.g. write after read) a bubble is issued which
 * consists in a NOP (NO Operation) instruction.
 */

module decode 
    import my_pkg::*;
(
    input   logic           clk,
    input   logic           reset,
    input   logic           stall,

    input   logic [31:0]    instruction_i,          // Object code of the instruction_int to extract the immediate operand
    input   logic [31:0]    pc_i,                   // Bypassed to execute unit as an operand
    input   logic [2:0]     tag_i,                  // Instruction tag_o
    input   logic [31:0]    rs1_data_read_i,        // Data read from register bank
    input   logic [31:0]    rs2_data_read_i,        // Data read from register bank

    output  logic [4:0]     rs1_o,                  // Address of the 1st register, conected directly in the register bank
    output  logic [4:0]     rs2_o,                  // Address of the 2nd register, conected directly in the register bank
    output  logic [4:0]     rd_o,                   // Write Address to register bank
    output  logic [31:0]    first_operand_o,        // First operand output register
    output  logic [31:0]    second_operand_o,       // Second operand output register
    output  logic [31:0]    third_operand_o,        // Third operand output register
    output  logic [31:0]    pc_o,                   // PC operand output register
    output  logic [31:0]    instruction_o,          // Instruction Used in exception_os and CSR operations
    output  logic [2:0]     tag_o,                  // Instruction tag_o
    output  iType_e         instruction_operation_o,// Instruction operation
    output  logic           hazard_o,               // Bubble issue indicator (0 active)
    output  logic           exception_o
    );

    logic [31:0] immediate, first_operand_int, second_operand_int, third_operand_int, instruction_int, last_instruction;
    logic last_hazard;
    logic [4:0] locked_registers[2];
    logic [4:0] target_register;
    logic is_store;
    logic locked_memory[2];

    formatType_e instruction_format;
    iType_e instruction_operation;

//////////////////////////////////////////////////////////////////////////////
// Re-Decode isntruction on hazard
//////////////////////////////////////////////////////////////////////////////

    always_ff @(posedge clk ) begin
        last_instruction <= instruction_int;
        last_hazard      <= hazard_o;
    end

    always_comb begin
        if (last_hazard) begin
            instruction_int = last_instruction;
        end
        else begin
            instruction_int = instruction_i;
        end
    end

//////////////////////////////////////////////////////////////////////////////
// Find out the type of the instruction
//////////////////////////////////////////////////////////////////////////////

    iType_e decode_branch;
    iType_e decode_load;
    iType_e decode_store;
    iType_e decode_op_imm;
    iType_e decode_op;
    iType_e decode_misc_mem;
    iType_e decode_system;

    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [6:0] opcode;

    assign opcode = instruction_int[6:0];
    assign funct3 = instruction_int[14:12];
    assign funct7 = instruction_int[31:25];

    always_comb begin
        case (funct3)
            3'b000:     decode_branch = BEQ;
            3'b001:     decode_branch = BNE;
            3'b100:     decode_branch = BLT;
            3'b101:     decode_branch = BGE;
            3'b110:     decode_branch = BLTU;
            3'b111:     decode_branch = BGEU;
            default:    decode_branch = INVALID;
        endcase
    end

    always_comb begin
        case (funct3)
            3'b000:     decode_load = LB;
            3'b001:     decode_load = LH;
            3'b010:     decode_load = LW;
            3'b100:     decode_load = LBU;
            3'b101:     decode_load = LHU;
            default:    decode_load = INVALID;
        endcase
    end

    always_comb begin
        case (funct3)
            3'b000:     decode_store = SB;
            3'b001:     decode_store = SH;
            3'b010:     decode_store = SW;
            default:    decode_store = INVALID;
        endcase
    end

    always_comb begin
        case ({funct7, funct3}) inside
            10'b???????000:     decode_op_imm = ADD;    /* ADDI */
            10'b0000000001:     decode_op_imm = SLL;    /* SLLI */
            10'b???????010:     decode_op_imm = SLT;    /* SLTI */
            10'b???????011:     decode_op_imm = SLTU;   /* SLTIU */
            10'b???????100:     decode_op_imm = XOR;    /* XORI */
            10'b0000000101:     decode_op_imm = SRL;    /* SRLI */
            10'b0100000101:     decode_op_imm = SRA;    /* SRAI */
            10'b???????110:     decode_op_imm = OR;     /* ORI */
            10'b???????111:     decode_op_imm = AND;    /* ANDI */
            default:            decode_op_imm = INVALID;
        endcase
    end

    always_comb begin
        case ({funct7, funct3})
            10'b0000000000:     decode_op = ADD;
            10'b0100000000:     decode_op = SUB;
            10'b0000000001:     decode_op = SLL;
            10'b0000000010:     decode_op = SLT;
            10'b0000000011:     decode_op = SLTU;
            10'b0000000100:     decode_op = XOR;
            10'b0000000101:     decode_op = SRL;
            10'b0100000101:     decode_op = SRA;
            10'b0000000110:     decode_op = OR;
            10'b0000000111:     decode_op = AND;
            default:            decode_op = INVALID;
        endcase
    end

    always_comb begin
        case (funct3)
            3'b000:     decode_misc_mem = NOP;  /* FENCE */
            default:    decode_misc_mem = INVALID;
        endcase
    end

    always_comb begin
        case (instruction_int[31:7]) inside
            25'b0000000000000000000000000:  decode_system = ECALL;
            25'b0000000000010000000000000:  decode_system = EBREAK;
            25'b0001000000100000000000000:  decode_system = SRET;
            25'b0011000000100000000000000:  decode_system = MRET;
            25'b0001000001010000000000000:  decode_system = WFI;
            25'b?????????????????001?????:  decode_system = CSRRW;
            25'b?????????????????010?????:  decode_system = CSRRS;
            25'b?????????????????011?????:  decode_system = CSRRC;
            25'b?????????????????101?????:  decode_system = CSRRWI;
            25'b?????????????????110?????:  decode_system = CSRRSI;
            25'b?????????????????111?????:  decode_system = CSRRCI;
            default:                        decode_system = INVALID;
        endcase
    end

    always_comb begin 
        case (opcode)
            7'b0110111: instruction_operation = LUI;
            7'b0010111: instruction_operation = ADD;                /* AUIPC */
            7'b1101111: instruction_operation = JAL;
            7'b1100111: instruction_operation = JALR;
            7'b1100011: instruction_operation = decode_branch;      /* BRANCH */
            7'b0000011: instruction_operation = decode_load;        /* LOAD */
            7'b0100011: instruction_operation = decode_store;       /* STORE */
            7'b0010011: instruction_operation = decode_op_imm;      /* OP-IMM */
            7'b0110011: instruction_operation = decode_op;          /* OP */
            7'b0001111: instruction_operation = decode_misc_mem;    /* MISC-MEM */
            7'b1110011: instruction_operation = decode_system;      /* SYSTEM */
            default:    instruction_operation = INVALID;
        endcase
    end        

//////////////////////////////////////////////////////////////////////////////
//  Decodes the instruction format
//////////////////////////////////////////////////////////////////////////////

    always_comb begin
        case (opcode)
            7'b0010011, 7'b1100111, 7'b0000011:     instruction_format = I_TYPE;
            7'b0100011:                             instruction_format = S_TYPE;
            7'b1100011:                             instruction_format = B_TYPE;
            7'b0110111, 7'b0010111:                 instruction_format = U_TYPE;
            7'b1101111:                             instruction_format = J_TYPE;
            default:                                instruction_format = R_TYPE;
        endcase
    end

//////////////////////////////////////////////////////////////////////////////
// Extract the immediate based on instruction format
//////////////////////////////////////////////////////////////////////////////

    always_comb begin
        case (instruction_format)
            I_TYPE: begin
                        immediate[31:11] = (!instruction_int[31]) 
                                            ? '0 
                                            : '1;
                        immediate[10:0]  = instruction_int[30:20];
                    end

            S_TYPE: begin
                        immediate[31:11] = (!instruction_int[31]) 
                                            ? '0 
                                            : '1;
                        immediate[10:5]  = instruction_int[30:25];
                        immediate[4:0]   = instruction_int[11:7];
                    end

            B_TYPE: begin
                        immediate[31:12] = (!instruction_int[31]) 
                                            ? '0 
                                            : '1;
                        immediate[11]    = instruction_int[7];
                        immediate[10:5]  = instruction_int[30:25];
                        immediate[4:1]   = instruction_int[11:8];
                        immediate[0]     = 0;
                    end

            U_TYPE: begin
                        immediate[31:12] = instruction_int[31:12];
                        immediate[11:0]  = '0;
                    end

            J_TYPE: begin
                        immediate[31:20] = (!instruction_int[31]) 
                                            ? '0 
                                            : '1;
                        immediate[19:12] = instruction_int[19:12];
                        immediate[11]    = instruction_int[20];
                        immediate[10:5]  = instruction_int[30:25];
                        immediate[4:1]   = instruction_int[24:21];
                        immediate[0]     = 0;
                    end

            default:    immediate        = '0;
        endcase
    end

//////////////////////////////////////////////////////////////////////////////
// Addresses to RegBank
//////////////////////////////////////////////////////////////////////////////

    assign rs1_o = instruction_int[19:15];
    assign rs2_o = instruction_int[24:20];
    assign rd_o  = locked_registers[1];

//////////////////////////////////////////////////////////////////////////////
// Target definitions
//////////////////////////////////////////////////////////////////////////////

    always_comb begin
        if (!hazard_o) begin
            target_register = instruction_int[11:7];
            ///////////////////////////////////
            if (instruction_operation == SB || instruction_operation == SH || instruction_operation == SW) begin
                is_store = 1;
            end
            else begin
                is_store = 0;
            end
        end
        else begin
            target_register = '0;
            is_store        = 0;
        end
    end

//////////////////////////////////////////////////////////////////////////////
// Registe Lock Queue (RLQ)
//////////////////////////////////////////////////////////////////////////////

    always_ff @(posedge clk) begin
        if (reset) begin
            locked_registers[0] <= '0;
            locked_registers[1] <= '0;
            locked_memory[0]    <= '0;
            locked_memory[1]    <= '0;
        end 
        else if (!stall) begin
            locked_registers[0] <= target_register;
            locked_memory[0]    <= is_store;
            locked_registers[1] <= locked_registers[0];
            locked_memory[1]    <= locked_memory[0];
        end
    end

//////////////////////////////////////////////////////////////////////////////
// Hazard signal generation
//////////////////////////////////////////////////////////////////////////////

    always_comb begin
        if ((locked_memory[0] || locked_memory[1]) && (executionUnit_e'(instruction_operation[5:3]) == MEMORY_UNIT)) begin
            hazard_o = 1;
        end
        else if (locked_registers[0] == rs1_o && rs1_o != '0) begin
            hazard_o = 1;
        end
        else if (locked_registers[0] == rs2_o && rs2_o != '0) begin
            hazard_o = 1;
        end
        else begin
            hazard_o = 0;
        end
    end

//////////////////////////////////////////////////////////////////////////////
// Control of the exits based on format
//////////////////////////////////////////////////////////////////////////////

    always_comb begin
        first_operand_int = (instruction_format == U_TYPE || instruction_format==J_TYPE) 
                            ? pc_i  
                            : rs1_data_read_i;

        second_operand_int = (instruction_format == R_TYPE || instruction_format==B_TYPE) 
                            ? rs2_data_read_i 
                            : immediate;

        third_operand_int  = (instruction_format == S_TYPE) 
                            ? rs2_data_read_i 
                            : immediate;
    end

//////////////////////////////////////////////////////////////////////////////
// Outputs
//////////////////////////////////////////////////////////////////////////////

    always_ff @(posedge clk) begin
        if (reset) begin
            first_operand_o  <= '0;
            second_operand_o <= '0;
            third_operand_o  <= '0;
            pc_o             <= '0;
            instruction_o    <= '0;
            instruction_operation_o <= NOP;
            tag_o            <= '0;
            exception_o      <= 0;
        end 
        else if (stall) begin
            first_operand_o   <= first_operand_o;
            second_operand_o  <= second_operand_o;
            third_operand_o   <= third_operand_o;
            pc_o              <= pc_o;
            instruction_o     <= instruction_o;
            instruction_operation_o <= instruction_operation_o;
            tag_o             <= tag_o;
            exception_o       <= exception_o;
        end 
        else if (hazard_o) begin
            first_operand_o  <= '0;
            second_operand_o <= '0;
            third_operand_o  <= '0;
            pc_o             <= '0;
            instruction_o    <= '0;
            instruction_operation_o <= NOP;
            tag_o            <= tag_i;
            exception_o      <= 0;
        end 
        else if (!stall) begin
            first_operand_o  <= first_operand_int;
            second_operand_o <= second_operand_int;
            third_operand_o  <= third_operand_int;
            pc_o             <= pc_i;
            instruction_o    <= instruction_int;
            instruction_operation_o <= instruction_operation;
            tag_o            <= tag_i;
            exception_o      <= (instruction_operation==INVALID) ? 1 : 0;
        end
    end

endmodule
