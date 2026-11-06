
module immediate_generator (
    input [5:0] immediate,
    output [15:0] extended_immediate
);

assign extended_immediate =
    {{10{immediate[5]}}, immediate};

endmodule
