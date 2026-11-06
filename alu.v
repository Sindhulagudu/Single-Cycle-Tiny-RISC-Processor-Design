
module alu (
    input  [15:0] A,
    input  [15:0] B,
    input  [2:0] alu_control,

    output reg [15:0] result,
    output reg zero,
    output reg carry,
    output reg overflow
);

reg [16:0] temp;

always @(*) begin

    result   = 16'b0;
    carry    = 1'b0;
    overflow = 1'b0;
    temp     = 17'b0;

    case (alu_control)

        // ADD
        3'b000: begin
            temp = {1'b0, A} + {1'b0, B};
            result = temp[15:0];
            carry = temp[16];
            overflow = (~(A[15] ^ B[15])) &
                       (result[15] ^ A[15]);
        end

        // SUB
        3'b001: begin
            temp = {1'b0, A} + {1'b0, ~B} + 17'd1;
            result = temp[15:0];
            carry = temp[16];
            overflow = (A[15] ^ B[15]) &
                       (result[15] ^ A[15]);
        end

        // AND
        3'b010:
            result = A & B;

        // OR
        3'b011:
            result = A | B;

        // XOR
        3'b100:
            result = A ^ B;

        // NOT
        3'b101:
            result = ~A;

        // Shift left
        3'b110:
            result = A << B[3:0];

        // Shift right
        3'b111:
            result = A >> B[3:0];

        default:
            result = 16'b0;

    endcase

    zero = (result == 16'b0);

end

endmodule
