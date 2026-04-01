//===-- RISCVInstrInfoXRegs1024.td - XRegs1024 instructions -*- tablegen -*-===//
//
// 64-bit instruction definitions for the XRegs1024 vendor extension.
// These use 10-bit register fields and Size=8 encoding.
//
//===----------------------------------------------------------------------===//

let Predicates = [HasVendorXRegs1024] in {

//===----------------------------------------------------------------------===//
// Instruction Class Templates (64-bit)
//===----------------------------------------------------------------------===//

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class ALU_rr_64<bits<7> funct7, bits<3> funct3, string opcodestr,
                bit Commutable = 0>
    : RVInstR64X<funct7, funct3, OPC_OP, (outs GPR:$rd),
                 (ins GPR:$rs1, GPR:$rs2), opcodestr, "$rd, $rs1, $rs2"> {
  let isCommutable = Commutable;
}

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class ALU_ri_64<bits<3> funct3, string opcodestr>
    : RVInstI64X<funct3, OPC_OP_IMM, (outs GPR:$rd),
                 (ins GPR:$rs1, simm12_lo:$imm12), opcodestr,
                 "$rd, $rs1, $imm12">,
      Sched<[WriteIALU, ReadIALU]>;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class Shift_ri_64<bits<5> imm11_7, bits<3> funct3, string opcodestr>
    : RVInstIShift64X<imm11_7, funct3, OPC_OP_IMM, (outs GPR:$rd),
                      (ins GPR:$rs1, uimmlog2xlen:$shamt), opcodestr,
                      "$rd, $rs1, $shamt">;

let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in
class Load_ri_64<bits<3> funct3, string opcodestr>
    : RVInstI64X<funct3, OPC_LOAD, (outs GPR:$rd),
                 (ins GPRMem:$rs1, simm12_lo:$imm12), opcodestr,
                 "$rd, ${imm12}(${rs1})">;

let hasSideEffects = 0, mayLoad = 0, mayStore = 1 in
class Store_rri_64<bits<3> funct3, string opcodestr>
    : RVInstS64X<funct3, OPC_STORE, (outs),
                 (ins GPR:$rs2, GPRMem:$rs1, simm12_lo:$imm12),
                 opcodestr, "$rs2, ${imm12}(${rs1})">;

class BranchCC_rri_64<bits<3> funct3, string opcodestr>
    : RVInstB64X<funct3, OPC_BRANCH, (outs),
                 (ins GPR:$rs1, GPR:$rs2, bare_simm13_lsb0:$imm12),
                 opcodestr, "$rs1, $rs2, $imm12">,
      Sched<[WriteJmp, ReadJmp, ReadJmp]> {
  let isBranch = 1;
  let isTerminator = 1;
  let hasSideEffects = 0;
  let mayLoad = 0;
  let mayStore = 0;
}

//===----------------------------------------------------------------------===//
// 64-bit Instruction Definitions
//===----------------------------------------------------------------------===//

// U-type
let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
let isReMaterializable = 1, isAsCheapAsAMove = 1, IsSignExtendingOpW = 1 in
def LUI_X : RVInstU64X<OPC_LUI, (outs GPR:$rd), (ins uimm20_lui:$imm20),
                        "lui", "$rd, $imm20">, Sched<[WriteIALU]>;

def AUIPC_X : RVInstU64X<OPC_AUIPC, (outs GPR:$rd),
                          (ins uimm20_auipc:$imm20),
                          "auipc", "$rd, $imm20">, Sched<[WriteIALU]>;

// J-type
def JAL_X : RVInstJ64X<OPC_JAL, (outs GPR:$rd),
                        (ins simm21_lsb0_jal:$imm20),
                        "jal", "$rd, $imm20">, Sched<[WriteJal]>;

// I-type (JALR)
def JALR_X : RVInstI64X<0b000, OPC_JALR, (outs GPR:$rd),
                         (ins GPR:$rs1, simm12_lo:$imm12),
                         "jalr", "$rd, ${imm12}(${rs1})">,
             Sched<[WriteJalr, ReadJalr]>;
} // hasSideEffects = 0, mayLoad = 0, mayStore = 0

// B-type (branches)
def BEQ_X  : BranchCC_rri_64<0b000, "beq">;
def BNE_X  : BranchCC_rri_64<0b001, "bne">;
def BLT_X  : BranchCC_rri_64<0b100, "blt">;
def BGE_X  : BranchCC_rri_64<0b101, "bge">;
def BLTU_X : BranchCC_rri_64<0b110, "bltu">;
def BGEU_X : BranchCC_rri_64<0b111, "bgeu">;

// Loads
let IsSignExtendingOpW = 1, canFoldAsLoad = 1, isReMaterializable = 1 in {
def LB_X  : Load_ri_64<0b000, "lb">, Sched<[WriteLDB, ReadMemBase]>;
def LH_X  : Load_ri_64<0b001, "lh">, Sched<[WriteLDH, ReadMemBase]>;
def LW_X  : Load_ri_64<0b010, "lw">, Sched<[WriteLDW, ReadMemBase]>;
def LBU_X : Load_ri_64<0b100, "lbu">, Sched<[WriteLDB, ReadMemBase]>;
def LHU_X : Load_ri_64<0b101, "lhu">, Sched<[WriteLDH, ReadMemBase]>;
}

// Stores
def SB_X : Store_rri_64<0b000, "sb">, Sched<[WriteSTB, ReadStoreData, ReadMemBase]>;
def SH_X : Store_rri_64<0b001, "sh">, Sched<[WriteSTH, ReadStoreData, ReadMemBase]>;
def SW_X : Store_rri_64<0b010, "sw">, Sched<[WriteSTW, ReadStoreData, ReadMemBase]>;

// I-type ALU
let isReMaterializable = 1, isAsCheapAsAMove = 1 in
def ADDI_X : ALU_ri_64<0b000, "addi">;

let IsSignExtendingOpW = 1 in {
def SLTI_X  : ALU_ri_64<0b010, "slti">;
def SLTIU_X : ALU_ri_64<0b011, "sltiu">;
}

let isReMaterializable = 1, isAsCheapAsAMove = 1 in {
def XORI_X : ALU_ri_64<0b100, "xori">;
def ORI_X  : ALU_ri_64<0b110, "ori">;
}

def ANDI_X : ALU_ri_64<0b111, "andi">;

// Shifts
def SLLI_X : Shift_ri_64<0b00000, 0b001, "slli">,
             Sched<[WriteShiftImm, ReadShiftImm]>;
def SRLI_X : Shift_ri_64<0b00000, 0b101, "srli">,
             Sched<[WriteShiftImm, ReadShiftImm]>;
def SRAI_X : Shift_ri_64<0b01000, 0b101, "srai">,
             Sched<[WriteShiftImm, ReadShiftImm]>;

// R-type ALU
def ADD_X  : ALU_rr_64<0b0000000, 0b000, "add", Commutable=1>,
             Sched<[WriteIALU, ReadIALU, ReadIALU]>;
def SUB_X  : ALU_rr_64<0b0100000, 0b000, "sub">,
             Sched<[WriteIALU, ReadIALU, ReadIALU]>;
def SLL_X  : ALU_rr_64<0b0000000, 0b001, "sll">,
             Sched<[WriteShiftReg, ReadShiftReg, ReadShiftReg]>;
let IsSignExtendingOpW = 1 in {
def SLT_X  : ALU_rr_64<0b0000000, 0b010, "slt">,
             Sched<[WriteIALU, ReadIALU, ReadIALU]>;
def SLTU_X : ALU_rr_64<0b0000000, 0b011, "sltu">,
             Sched<[WriteIALU, ReadIALU, ReadIALU]>;
}
def XOR_X  : ALU_rr_64<0b0000000, 0b100, "xor", Commutable=1>,
             Sched<[WriteIALU, ReadIALU, ReadIALU]>;
def SRL_X  : ALU_rr_64<0b0000000, 0b101, "srl">,
             Sched<[WriteShiftReg, ReadShiftReg, ReadShiftReg]>;
def SRA_X  : ALU_rr_64<0b0100000, 0b101, "sra">,
             Sched<[WriteShiftReg, ReadShiftReg, ReadShiftReg]>;
def OR_X   : ALU_rr_64<0b0000000, 0b110, "or", Commutable=1>,
             Sched<[WriteIALU, ReadIALU, ReadIALU]>;
def AND_X  : ALU_rr_64<0b0000000, 0b111, "and", Commutable=1>,
             Sched<[WriteIALU, ReadIALU, ReadIALU]>;

// System instructions (no register operands, keep as-is with 64-bit encoding)
let hasSideEffects = 1, mayLoad = 0, mayStore = 0 in {
def ECALL_X : RVInstI64X<0b000, OPC_SYSTEM, (outs), (ins), "ecall", "">,
              Sched<[WriteJmp]> {
  let rs1 = 0;
  let rd = 0;
  let imm12 = 0;
}

let isTrap = 1 in
def EBREAK_X : RVInstI64X<0b000, OPC_SYSTEM, (outs), (ins), "ebreak", "">,
               Sched<[]> {
  let rs1 = 0;
  let rd = 0;
  let imm12 = 1;
}
} // hasSideEffects = 1

// RV32M multiply/divide (64-bit encoding)
let Predicates = [HasVendorXRegs1024, HasStdExtZmmul] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
def MUL_X    : ALU_rr_64<0b0000001, 0b000, "mul", Commutable=1>,
               Sched<[WriteIMul, ReadIMul, ReadIMul]>;
def MULH_X   : ALU_rr_64<0b0000001, 0b001, "mulh", Commutable=1>,
               Sched<[WriteIMul, ReadIMul, ReadIMul]>;
def MULHSU_X : ALU_rr_64<0b0000001, 0b010, "mulhsu">,
               Sched<[WriteIMul, ReadIMul, ReadIMul]>;
def MULHU_X  : ALU_rr_64<0b0000001, 0b011, "mulhu", Commutable=1>,
               Sched<[WriteIMul, ReadIMul, ReadIMul]>;
}
} // Predicates = [HasVendorXRegs1024, HasStdExtZmmul]

let Predicates = [HasVendorXRegs1024, HasStdExtM] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
def DIV_X    : ALU_rr_64<0b0000001, 0b100, "div">,
               Sched<[WriteIDiv, ReadIDiv, ReadIDiv]>;
def DIVU_X   : ALU_rr_64<0b0000001, 0b101, "divu">,
               Sched<[WriteIDiv, ReadIDiv, ReadIDiv]>;
def REM_X    : ALU_rr_64<0b0000001, 0b110, "rem">,
               Sched<[WriteIDiv, ReadIDiv, ReadIDiv]>;
def REMU_X   : ALU_rr_64<0b0000001, 0b111, "remu">,
               Sched<[WriteIDiv, ReadIDiv, ReadIDiv]>;
}
} // Predicates = [HasVendorXRegs1024, HasStdExtM]

} // Predicates = [HasVendorXRegs1024]
