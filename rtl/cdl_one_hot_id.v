//=============================================================================
// Module:       cdl_one_hot_id
// Author:       Gilad Ayalon
// Description:  
//   This module identifies the position of the first set bit in a vector, 
//   assuming the vector is onehot (where only a single bit is 1 at a time).
//
// Parameters:
//   WIDTH     	- Integer: Width of the input vector (default is 8 bits)
//   LG2_WIDTH  - Local parameter: Logarithm base 2 of WIDTH (rounded up)
//
// Ports:
//   input  [WIDTH-1:0]    	in    - Input vector of bits
//   output [LG2_WIDTH-1:0] out   - Position of the first set bit
//=============================================================================

module cdl_one_hot_id #(
    parameter WIDTH = 8,                    				// Width of input vector
    localparam LG2_WIDTH = (WIDTH == 1) ? 1 : $clog2(WIDTH) // Log2 of WIDTH 
)(
    input  [WIDTH-1:0]    in,	// Input vector of bits
    output [LG2_WIDTH-1:0] out	// Position of the first set bit
);

localparam WIDTH_P2 = 2 ** LG2_WIDTH;	// Power of 2 value derived from WIDTH

wire   [WIDTH_P2-1:0] in_pad = (WIDTH_P2)'(in);

generate
	for (genvar i0=0; i0<LG2_WIDTH; i0=i0+1)	begin : gid
		localparam P = 1 << i0+1;
		assign out[i0] = |(in_pad & {WIDTH_P2/P{{P/2{1'b1}}, {P/2{1'b0}}}});
	end
endgenerate

endmodule 
