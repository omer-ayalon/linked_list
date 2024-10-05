module m_linked_list #(
    parameter WIDTH = 4,
    parameter DEPTH = 16,

    localparam L2_DEPTH = $clog2(DEPTH)
)(
    input       						clk,
    input       						rst_n,
    output                	            pop_vld,
    input                 	            pop_rdy,
    output [WIDTH-1:0]  	            pop,
    input                	            push_vld,
    output      						push_rdy,
    input  [WIDTH-1:0] 	                push
);



endmodule