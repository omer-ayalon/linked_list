/*
 * Author: Omer Ayalon
 */
 
module m_linked_list #(
    parameter LLN = 4,
    parameter WIDTH = 4,
    parameter DEPTH = 16,

    localparam L2_LLN = $clog2(LLN),
    localparam L2_DEPTH = $clog2(DEPTH)
)(
    input       						clk,
    input       						rst_n,
    output [L2_LLN-1:0]   	            pop_vld,
    input                 	            pop_rdy,
    input  [L2_LLN-1:0]                 pop_id,
    output [WIDTH-1:0]  	            pop,
    input                	            push_vld,
    output      						push_rdy,
    input  [L2_LLN-1:0]                 push_id,
    input  [WIDTH-1:0] 	                push
    );



endmodule