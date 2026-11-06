
module control_unit (
    input [3:0] opcode,

    output reg reg_write,
    output reg alu_src,
    output reg mem_read,
    output reg mem_write,
    output reg mem_to_reg,
    output reg branch,
    output reg [2:0] alu_control
);

always @(*) begin

    reg_write   = 0;
    alu_src     = 0;
    mem_read    = 0;
    mem_write   = 0;
    mem_to_reg  = 0;
    branch      = 0;
    alu_control = 3'b000;

    case (opcode)

        4'b0000: begin // ADD
            reg_write = 1;
            alu_control = 3'b000;
        end

        4'b0001: begin // SUB
            reg_write = 1;
            alu_control = 3'b001;
        end

        4'b0010: begin // AND
            reg_write = 1;
            alu_control = 3'b010;
        end

        4'b0011: begin // OR
            reg_write = 1;
            alu_control = 3'b011;
        end

        4'b0100: begin // ADDI
            reg_write = 1;
            alu_src = 1;
            alu_control = 3'b000;
        end

        4'b0101: begin // LW
            reg_write = 1;
            alu_src = 1;
            mem_read = 1;
            mem_to_reg = 1;
            alu_control = 3'b000;
        end

        4'b0110: begin // SW
            alu_src = 1;
            mem_write = 1;
            alu_control = 3'b000;
        end

        4'b0111: begin // BEQ
            branch = 1;
            alu_control = 3'b001;
        end

        default: begin
            // All controls remain zero
        end

    endcase

end

endmodule
