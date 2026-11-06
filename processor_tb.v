
`timescale 1ns/1ps

module processor_tb;

reg clk;
reg reset;

integer errors;
integer cycles;

processor DUT (
    .clk(clk),
    .reset(reset)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Check register contents
task check_register;
    input [2:0] reg_num;
    input [15:0] expected;

    begin
        if (DUT.RF.registers[reg_num] !== expected) begin
            $display(
                "FAIL: R%0d Expected=%0d Actual=%0d",
                reg_num,
                expected,
                DUT.RF.registers[reg_num]
            );
            errors = errors + 1;
        end
        else begin
            $display(
                "PASS: R%0d = %0d",
                reg_num,
                DUT.RF.registers[reg_num]
            );
        end
    end
endtask

// Execute one instruction
task execute_instruction;
    begin
        @(posedge clk);
        #1;
        cycles = cycles + 1;

        $display(
            "Cycle=%0d PC=%0d Instruction=%h",
            cycles,
            DUT.pc,
            DUT.instruction
        );
    end
endtask

initial begin

    errors = 0;
    cycles = 0;

    $dumpfile("tinyrisc.vcd");
    $dumpvars(0, processor_tb);

    reset = 1;

    repeat (2) @(posedge clk);

    #1;
    reset = 0;

    // Initialize test operands
    DUT.RF.registers[2] = 16'd10;
    DUT.RF.registers[3] = 16'd3;

    // Instruction 0: ADD R1,R2,R3
    execute_instruction;
    check_register(1, 16'd13);

    // Instruction 1: SUB R4,R1,R2
    execute_instruction;
    check_register(4, 16'd3);

    // Instruction 2: AND R5,R2,R3
    execute_instruction;
    check_register(5, 16'd2);

    // Instruction 3: OR R6,R1,R3
    execute_instruction;
    check_register(6, 16'd15);

    // Instruction 4: ADDI R7,R2,5
    execute_instruction;
    check_register(7, 16'd15);

    // Instruction 5: SW R1,4(R2)
    execute_instruction;

    if (DUT.DM.memory[14] !== 16'd13) begin
        $display("FAIL: Store operation");
        errors = errors + 1;
    end
    else
        $display("PASS: Store operation");

    // Instruction 6: LW R3,4(R2)
    execute_instruction;
    check_register(3, 16'd13);

    // Instruction 7: BEQ R1,R2 (not taken)
    execute_instruction;

    if (DUT.pc !== 16'd8) begin
        $display("FAIL: Branch not-taken PC");
        errors = errors + 1;
    end
    else
        $display("PASS: Branch not taken");

    // Instruction 8: BEQ R1,R1 (taken)
    execute_instruction;

    if (DUT.pc !== 16'd11) begin
        $display("FAIL: Branch taken PC");
        errors = errors + 1;
    end
    else
        $display("PASS: Branch taken");

    // R0 must remain zero
    check_register(0, 16'd0);

    $display("--------------------------------");
    $display("TOTAL CHECKS COMPLETED");
    $display("TOTAL ERRORS = %0d", errors);

    if (errors == 0)
        $display("ALL TESTS PASSED");
    else
        $display("VERIFICATION FAILED");

    $display("--------------------------------");

    $finish;

end

endmodule
