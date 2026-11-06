
module pc (
    input clk,
    input reset,
    input [15:0] next_pc,
    output reg [15:0] current_pc
);

always @(posedge clk or posedge reset) begin

    if (reset)
        current_pc <= 16'b0;

    else
        current_pc <= next_pc;

end

endmodule
