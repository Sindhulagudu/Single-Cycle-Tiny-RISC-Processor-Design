
module instruction_memory (
    input  [15:0] address,
    output reg [15:0] instruction
);

reg [15:0] memory [0:255];

integer i;

initial begin

    for (i = 0; i < 256; i = i + 1)
        memory[i] = 16'b0;

    // ADD R1, R2, R3
    memory[0] = {4'b0000, 3'd1, 3'd2, 3'd3, 3'b000};

    // SUB R4, R1, R2
    memory[1] = {4'b0001, 3'd4, 3'd1, 3'd2, 3'b000};

    // AND R5, R2, R3
    memory[2] = {4'b0010, 3'd5, 3'd2, 3'd3, 3'b000};

    // OR R6, R1, R3
    memory[3] = {4'b0011, 3'd6, 3'd1, 3'd3, 3'b000};

    // ADDI R7, R2, 5
    memory[4] = {4'b0100, 3'd7, 3'd2, 6'd5};

   
    // SW R1, 4(R2)
    memory[5] = {4'b0110, 3'd1, 3'd2, 6'd4};

    // LW R3, 4(R2)
    memory[6] = {4'b0101, 3'd3, 3'd2, 6'd4};

    // BEQ R1, R2, offset 2 (not taken)
    memory[7] = {4'b0111, 3'd1, 3'd2, 6'd2};

    // BEQ R1, R1, offset 2 (taken)
    memory[8] = {4'b0111, 3'd1, 3'd1, 6'd2};

end

always @(*) begin
    instruction = memory[address[7:0]];
end

endmodule
