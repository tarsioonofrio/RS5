/*!\file RS5_pkg.sv
 * RS5 VERSION - 1.1.0 - Pipeline Simplified and Core Renamed
 *
 * Distribution:  July 2023
 *
 * Willian Nunes   <willian.nunes@edu.pucrs.br>
 * Marcos Sartori  <marcos.sartori@acad.pucrs.br>
 * Ney calazans    <ney.calazans@pucrs.br>
 *
 * Research group: GAPH-PUCRS  <>
 *
 * \brief
 * RS5 Package definition.
 *
 * \detailed
 * Defines the package used in the processor units, it defines some types
 * for instruction formats, instruction types, operation, exceptions and
 * interrupts causes and CSR addresses.
 */

`ifndef RS5_PKG
`define RS5_PKG

package RS5_pkg;

    typedef enum integer {
        ASIC    = 0,
        FPGA    = 1
    } environment_e;

    typedef enum integer {
        RV32I       = 0,
        RV32M       = 1,
        RV32ZMMUL   = 2
    } rv32_e;

    typedef enum logic[5:0] {
        R_TYPE = 6'b000001,
        I_TYPE = 6'b000010,
        S_TYPE = 6'b000100,
        B_TYPE = 6'b001000,
        U_TYPE = 6'b010000,
        J_TYPE = 6'b100000
    } formatType_e;

    typedef enum logic[51:0] {
        NOP       = 52'b0000000000000000000000000000000000000000000000000000,
        LUI       = 52'b0000000000000000000000000000000000000000000000000001,
        SRET      = 52'b0000000000000000000000000000000000000000000000000010,
        MRET      = 52'b0000000000000000000000000000000000000000000000000100,
        WFI       = 52'b0000000000000000000000000000000000000000000000001000,
        ECALL     = 52'b0000000000000000000000000000000000000000000000010000,
        EBREAK    = 52'b0000000000000000000000000000000000000000000000100000,
        INVALID   = 52'b0000000000000000000000000000000000000000000001000000,
        ADD       = 52'b0000000000000000000000000000000000000000000010000000,
        SUB       = 52'b0000000000000000000000000000000000000000000100000000,
        SLTU      = 52'b0000000000000000000000000000000000000000001000000000,
        SLT       = 52'b0000000000000000000000000000000000000000010000000000,
        XOR       = 52'b0000000000000000000000000000000000000000100000000000,
        OR        = 52'b0000000000000000000000000000000000000001000000000000,
        AND       = 52'b0000000000000000000000000000000000000010000000000000,
        SLL       = 52'b0000000000000000000000000000000000000100000000000000,
        SRL       = 52'b0000000000000000000000000000000000001000000000000000,
        SRA       = 52'b0000000000000000000000000000000000010000000000000000,
        BEQ       = 52'b0000000000000000000000000000000000100000000000000000,
        BNE       = 52'b0000000000000000000000000000000001000000000000000000,
        BLT       = 52'b0000000000000000000000000000000010000000000000000000,
        BLTU      = 52'b0000000000000000000000000000000100000000000000000000,
        BGE       = 52'b0000000000000000000000000000001000000000000000000000,
        BGEU      = 52'b0000000000000000000000000000010000000000000000000000,
        JAL       = 52'b0000000000000000000000000000100000000000000000000000,
        JALR      = 52'b0000000000000000000000000001000000000000000000000000,
        LB        = 52'b0000000000000000000000000010000000000000000000000000,
        LBU       = 52'b0000000000000000000000000100000000000000000000000000,
        LH        = 52'b0000000000000000000000001000000000000000000000000000,
        LHU       = 52'b0000000000000000000000010000000000000000000000000000,
        LW        = 52'b0000000000000000000000100000000000000000000000000000,
        SB        = 52'b0000000000000000000001000000000000000000000000000000,
        SH        = 52'b0000000000000000000010000000000000000000000000000000,
        SW        = 52'b0000000000000000000100000000000000000000000000000000,
        CSRRW     = 52'b0000000000000000001000000000000000000000000000000000,
        CSRRS     = 52'b0000000000000000010000000000000000000000000000000000,
        CSRRC     = 52'b0000000000000000100000000000000000000000000000000000,
        CSRRWI    = 52'b0000000000000001000000000000000000000000000000000000,
        CSRRSI    = 52'b0000000000000010000000000000000000000000000000000000,
        CSRRCI    = 52'b0000000000000100000000000000000000000000000000000000,
        MUL       = 52'b0000000000001000000000000000000000000000000000000000,
        MULH      = 52'b0000000000010000000000000000000000000000000000000000,
        MULHSU    = 52'b0000000000100000000000000000000000000000000000000000,
        MULHU     = 52'b0000000001000000000000000000000000000000000000000000,
        DIV       = 52'b0000000010000000000000000000000000000000000000000000,
        DIVU      = 52'b0000000100000000000000000000000000000000000000000000,
        REM       = 52'b0000001000000000000000000000000000000000000000000000,
        REMU      = 52'b0000010000000000000000000000000000000000000000000000,
        AES32ESMI = 52'b0000100000000000000000000000000000000000000000000000,
        AES32ESI  = 52'b0001000000000000000000000000000000000000000000000000,
        VLOAD     = 52'b0010000000000000000000000000000000000000000000000000,
        VSTORE    = 52'b0100000000000000000000000000000000000000000000000000,
        VECTOR    = 52'b1000000000000000000000000000000000000000000000000000
    } iType_e;

    typedef enum logic[1:0] {
        USER, SUPERVISOR, HYPERVISOR, MACHINE = 3
    } privilegeLevel_e;

    typedef enum logic[1:0] {
        NONE, WRITE, SET, CLEAR
    } csrOperation_e;

    typedef enum logic {
        M_IDLE, M_CALC
    } mult_states_e;

    typedef enum logic [1:0] {
        D_IDLE, D_INIT, D_CALC, D_SIGN
    } div_states_e;

    typedef enum logic [1:0] {
        V_IDLE, V_EXEC, V_END
    } vector_states_e;

    typedef enum logic [1:0] {
        VLSU_IDLE, VLSU_FIRST_CYCLE, VLSU_EXEC, VLSU_LAST_CYCLE
    } vector_lsu_states_e;

    typedef enum  logic[1:0] {DIRECT, VECTORED} trapMode_e;

    typedef enum  logic[11:0] {
        VSTART = 12'h008,
        MVENDORID = 12'hF11, MARCHID, MIMPID, MHARTID, MCONFIGPTR,
        MSTATUS = 12'h300, MISA, MEDELEG, MIDELEG, MIE, MTVEC, MCOUNTEREN, MSTATUSH = 12'h310,
        MSCRATCH = 12'h340, MEPC, MCAUSE, MTVAL, MIP, MTINST = 12'h34A, MTVAL2,
        MVMDO = 12'h7C0, MVMDS, MVMIO, MVMIS, MVMCTL, MVMDM, MVMIM,
        MCYCLE = 12'hB00, MINSTRET = 12'hB02, MHPMCOUNTER3 = 12'hB03, MHPMCOUNTER4 = 12'hB04, MHPMCOUNTER5 = 12'hB05, MHPMCOUNTER6  = 12'hB06,
        MHPMCOUNTER7  = 12'hB07, MHPMCOUNTER8  = 12'hB08, MHPMCOUNTER9  = 12'hB09, MHPMCOUNTER10 = 12'hB0A, MHPMCOUNTER11 = 12'hB0B,
        MHPMCOUNTER12 = 12'hB0C, MHPMCOUNTER13 = 12'hB0D, MHPMCOUNTER14 = 12'hB0E, MHPMCOUNTER15 = 12'hB0F, MHPMCOUNTER16 = 12'hB10,
        MHPMCOUNTER17 = 12'hB11, MHPMCOUNTER18 = 12'hB12, MHPMCOUNTER19 = 12'hB13, MHPMCOUNTER20 = 12'hB14, MHPMCOUNTER21 = 12'hB15,
        MHPMCOUNTER22 = 12'hB16, MHPMCOUNTER23 = 12'hB17, MHPMCOUNTER24 = 12'hB18, MHPMCOUNTER25 = 12'hB19, MHPMCOUNTER26 = 12'hB1A,
        MHPMCOUNTER27 = 12'hB1B, MHPMCOUNTER28 = 12'hB1C, MHPMCOUNTER29 = 12'hB1D, MHPMCOUNTER30 = 12'hB1E, MHPMCOUNTER31 = 12'hB1F,
        MCYCLEH = 12'hB80, MINSTRETH = 12'hB82,
        CYCLE = 12'hC00, TIME, INSTRET, CYCLEH=12'hC80, TIMEH, INSTRETH,
        VL = 12'hC20, VTYPE, VLENBYTES
    } CSRs;

    typedef enum  logic[4:0] {
        INSTRUCTION_ADDRESS_MISALIGNED, INSTRUCTION_ACCESS_FAULT, ILLEGAL_INSTRUCTION,
        BREAKPOINT, LOAD_ADDRESS_MISALIGNED, LOAD_ACCESS_FAULT, STORE_AMO_ADDRESS_MISALIGNED,
        STORE_AMO_ACCESS_FAULT, ECALL_FROM_UMODE, ECALL_FROM_SMODE, ECALL_FROM_MMODE = 11,
        INSTRUCTION_PAGE_FAULT, LOAD_PAGE_FAULT, STORE_AMO_PAGE_FAULT = 15, NE
    } exceptionCode_e;

    typedef enum  logic[4:0] {
        S_SW_INT = 1, M_SW_INT = 3, S_TIM_INT = 5, M_TIM_INT = 7, S_EXT_INT = 9,
        M_EXT_INT = 11
    } interruptionCode_e;

// Element width
    typedef enum logic [2:0] {
        EW8    = 3'b000,
        EW16   = 3'b001,
        EW32   = 3'b010,
        EW64   = 3'b011,
        EW128  = 3'b100,
        EW256  = 3'b101,
        EW512  = 3'b110,
        EW1024 = 3'b111
    } vew_e;

  // Length multiplier
    typedef enum logic [2:0] {
        LMUL_1    = 3'b000,
        LMUL_2    = 3'b001,
        LMUL_4    = 3'b010,
        LMUL_8    = 3'b011,
        LMUL_RSVD = 3'b100,
        LMUL_1_8  = 3'b101,
        LMUL_1_4  = 3'b110,
        LMUL_1_2  = 3'b111
    } vlmul_e;

    typedef enum  logic[7:0] {
        VNOP,
        VSETVL,
        VSETVLI,
        VSETIVLI,
        VADD,
        VSUB,
        VRSUB,
        VAND,
        VOR,
        VXOR,
        VSLL,
        VSRL,
        VSRA,
        VMSEQ,
        VMSNE,
        VMSLTU,
        VMSLT,
        VMSLEU,
        VMSLE,
        VMSGTU,
        VMSGT,
        VMINU,
        VMIN,
        VMAXU,
        VMAX,
        VMUL,
        VMULH,
        VMULHU,
        VMULHSU,
        VWMUL,
        VWMULU,
        VWMULSU,
        VDIVU,
        VDIV,
        VREMU,
        VREM,
        VMACC,
        VNMSAC,
        VMADD,
        VNMSUB,
        VREDSUM,
        VREDMAXU,
        VREDMAX,
        VREDMINU,
        VREDMIN,
        VREDAND,
        VREDOR,
        VREDXOR,
        VMV,
        VMVR,
        VMVSX,
        VMVXS
    } iTypeVector_e;

    typedef enum  logic[2:0] {
        OPIVV = 3'b000,
        OPFVV = 3'b001,
        OPMVV = 3'b010,
        OPIVI = 3'b011,
        OPIVX = 3'b100,
        OPFVF = 3'b101,
        OPMVX = 3'b110,
        OPCFG = 3'b111
    } opCat_e;

    typedef enum logic[1:0] {
        UNIT_STRIDED,
        INDEXED_UNORDERED,
        STRIDED,
        INDEXED_ORDERED
    } addrModes_e;

endpackage

`endif
