
module register_file (
    input clk,
    input reset,

    input [2:0] read_addr1,
    input [2:0] read_addr2,
    input [2:0] read_addr3,

    input [2:0] write_addr,
    input [15:0] write_data,
    input reg_write,

    output [15:0] read_data1,
    output [15:0] read_data2,
    output [15:0] read_data3
);

reg [15:0] registers [0:7];
integer i;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        for (i = 0; i < 8; i = i + 1)
            registers[i] <= 16'b0;
    end
    else if (reg_write && write_addr != 3'b000) begin
        registers[write_addr] <= write_data;
    end
end

assign read_data1 = registers[read_addr1];
assign read_data2 = registers[read_addr2];
assign read_data3 = registers[read_addr3];

endmodule
