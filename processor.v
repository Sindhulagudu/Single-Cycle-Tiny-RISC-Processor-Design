
module processor (
    input clk,
    input reset
);

// ------------------------------------------------
// 1. Program Counter
// ------------------------------------------------

wire [15:0] pc;
reg  [15:0] next_pc;

// ------------------------------------------------
// 2. Instruction
// ------------------------------------------------

wire [15:0] instruction;

wire [3:0] opcode;
wire [2:0] rd, rs1, rs2;
wire [5:0] immediate;

// ------------------------------------------------
// 3. Control signals
// ------------------------------------------------

wire reg_write;
wire alu_src;
wire mem_read;
wire mem_write;
wire mem_to_reg;
wire branch;
wire [2:0] alu_control;

// ------------------------------------------------
// 4. Register File
// ------------------------------------------------

wire [15:0] read_data1;
wire [15:0] read_data2;
wire [15:0] store_data;

wire [15:0] write_back_data;

// ------------------------------------------------
// 5. Immediate Generator
// ------------------------------------------------

wire [15:0] extended_immediate;

// ------------------------------------------------
// 6. ALU
// ------------------------------------------------

wire [15:0] alu_input2;
wire [15:0] alu_result;

wire zero;
wire carry;
wire overflow;

// ------------------------------------------------
// 7. Data Memory
// ------------------------------------------------

wire [15:0] memory_data;

// ------------------------------------------------
// Instruction decoding
// ------------------------------------------------

assign opcode = instruction[15:12];

assign rd  = instruction[11:9];
assign rs1 = instruction[8:6];
assign rs2 = instruction[5:3];

assign immediate = instruction[5:0];

// ------------------------------------------------
// Program Counter
// ------------------------------------------------

pc PC (
    .clk(clk),
    .reset(reset),
    .next_pc(next_pc),
    .current_pc(pc)
);

// ------------------------------------------------
// Instruction Memory
// ------------------------------------------------

instruction_memory IM (
    .address(pc),
    .instruction(instruction)
);

// ------------------------------------------------
// Control Unit
// ------------------------------------------------

control_unit CU (
    .opcode(opcode),
    .reg_write(reg_write),
    .alu_src(alu_src),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_to_reg(mem_to_reg),
    .branch(branch),
    .alu_control(alu_control)
);

// ------------------------------------------------
// Register File
// ------------------------------------------------

// Register fields are selected according to
// the instruction type.

wire [2:0] read_addr1;
wire [2:0] read_addr2;
wire [2:0] read_addr3;

assign read_addr1 =
    (opcode == 4'b0111) ? rd : rs1;

assign read_addr2 =
    (opcode == 4'b0111) ? rs1 : rs2;

assign read_addr3 = rd;

register_file RF (
    .clk(clk),
    .reset(reset),

    .read_addr1(read_addr1),
    .read_addr2(read_addr2),
    .read_addr3(read_addr3),

    .write_addr(rd),
    .write_data(write_back_data),
    .reg_write(reg_write),

    .read_data1(read_data1),
    .read_data2(read_data2),
    .read_data3(store_data)
);

// ------------------------------------------------
// Immediate Generator
// ------------------------------------------------

immediate_generator IG (
    .immediate(immediate),
    .extended_immediate(extended_immediate)
);

// ------------------------------------------------
// ALU input selection
// ------------------------------------------------

assign alu_input2 =
    alu_src ? extended_immediate : read_data2;

// ------------------------------------------------
// ALU
// ------------------------------------------------

alu ALU (
    .A(read_data1),
    .B(alu_input2),
    .alu_control(alu_control),

    .result(alu_result),
    .zero(zero),
    .carry(carry),
    .overflow(overflow)
);

// ------------------------------------------------
// Data Memory
// ------------------------------------------------

data_memory DM (
    .clk(clk),
    .mem_read(mem_read),
    .mem_write(mem_write),

    .address(alu_result[7:0]),
    .write_data(store_data),
    .read_data(memory_data)
);

// ------------------------------------------------
// Write-back MUX
// ------------------------------------------------

assign write_back_data =
    mem_to_reg ? memory_data : alu_result;

// ------------------------------------------------
// Next PC logic
// ------------------------------------------------

always @(*) begin

    next_pc = pc + 16'd1;

    if (branch && zero)
        next_pc = pc + 16'd1 +
                  extended_immediate;

end

endmodule
