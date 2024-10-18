/**
 * @file m_fifo.v
 * 
 * This module implements a parameterized FIFO buffer capable of 
 * storing a specified number of data elements (DEPTH) with a 
 * specified bit-width (WIDTH). The FIFO supports push and pop 
 * operations, allowing data to be written to and read from the 
 * buffer in a first-in-first-out manner. The module includes 
 * indicators for full and empty states, as well as item count 
 * tracking.
 * 
 * @param WIDTH The bit-width of each data element in the FIFO. 
 *               This parameter defines how many bits are used to 
 *               represent each piece of data stored in the FIFO.
 * @param DEPTH The maximum number of data elements that the FIFO 
 *               can hold. The FIFO can store up to `DEPTH` items.
 * 
 * @localparam L2_DEPTH_P1 The ceiling of the logarithm base 2 of 
 *               (DEPTH + 1), used to determine the number of bits 
 *               required to represent the item count.
 * @localparam L2_DEPTH    The logarithm base 2 of DEPTH, used for 
 *               addressing the read and write pointers.
 * 
 * @input clk            The clock signal, used to synchronize 
 *                       operations within the FIFO.
 * @input rst_n         The active-low reset signal. When asserted 
 *                       (low), the FIFO is reset to its initial 
 *                       state.
 * @input push_enable    The control signal to enable writing data 
 *                       into the FIFO. When asserted (high), data 
 *                       from `push_data` is pushed onto the FIFO.
 * @input push_data      The data input that is pushed into the FIFO 
 *                       when `push_enable` is high.
 * @input pop_enable     The control signal to enable reading data 
 *                       from the FIFO. When asserted (high), the 
 *                       FIFO outputs data from the front of the FIFO.
 * 
 * @output pop_data      The data output that is read from the FIFO 
 *                       when `pop_enable` is high.
 * @output item_count    The current number of items in the FIFO, 
 *                       represented in binary.
 * @output full_flag     A flag indicating whether the FIFO is full. 
 *                       When high, no more data can be pushed onto 
 *                       the FIFO.
 * @output empty_flag    A flag indicating whether the FIFO is empty. 
 *                       When high, no data is available for popping.
 * 
 * The module features internal counters for read and write 
 * operations, and it generates assertions to check for illegal 
 * operations such as pushing data onto a full FIFO or popping 
 * data from an empty FIFO. The FIFO memory is implemented using 
 * a series of flip-flops to store each data element.
 */
module m_fifo #(
parameter   WIDTH=4,
parameter   DEPTH=2,
parameter	RST_N_EN=0,
parameter	RESET_VAL=0,

localparam L2_DEPTH_P1 	= $clog2(DEPTH+1),
localparam L2_DEPTH 	= $clog2(DEPTH)
)(
	input 						clk,
	input 						rst_n,
	input 						push_enable,
	input 	[WIDTH-1:0]			push_data,
	input						pop_enable,
	output  [WIDTH-1:0]			pop_data,
    output  [L2_DEPTH_P1-1:0]   item_count,
	output						full_flag,
	output						empty_flag
);

wire    [DEPTH-1:0][WIDTH-1:0]	fifo_mem;
wire    [L2_DEPTH-1:0] 			rd_ptr;
wire    [L2_DEPTH-1:0] 			wr_ptr;
wire    [DEPTH-1:0]	            mem_en;

/////////////////////////////////////////////////////////
// Counters
/////////////////////////////////////////////////////////

m_counter #(
	.N_BITS(L2_DEPTH)
) write_counter (
	.clk(clk),
	.rst_n(rst_n),
	.inc(push_enable),
    .dec(1'b0),
	.cnt(wr_ptr));
	
m_counter #(
	.N_BITS(L2_DEPTH)
) read_counter (
	.clk(clk),
	.rst_n(rst_n),
	.inc(pop_enable),
    .dec(1'b0),
	.cnt(rd_ptr));

m_counter #(
	.N_BITS(L2_DEPTH_P1)
) full_counter (
	.clk(clk),
	.rst_n(rst_n),
	.inc(push_enable),
    .dec(pop_enable),
	.cnt(item_count));

/////////////////////////////////////////////////////////
// FIFO
/////////////////////////////////////////////////////////

generate
for (genvar i0=0; i0<DEPTH; i0++) begin : i0_fifo

assign mem_en[i0] = push_enable & wr_ptr==i0;

m_ff #(.WIDTH(WIDTH),
	   .RST_N_EN(RST_N_EN),
	   .RESET_VAL(RESET_VAL)
) mem(
	.clk(clk),
	.rst_n(rst_n),
	.enable(mem_en[i0]),
	.data_in(push_data),
	.data_out(fifo_mem[i0])
);
end
endgenerate

// Read Data
assign pop_data = fifo_mem[rd_ptr];

// Full And Empty Flags
assign full_flag = (item_count==DEPTH[L2_DEPTH_P1-1:0]);
assign empty_flag = (item_count=={L2_DEPTH_P1{1'b0}});

/////////////////////////////////////////////////////////
// Assertions
/////////////////////////////////////////////////////////

// synopsys translate_off
wire    pop_on_empty;
wire    push_on_full;

assign pop_on_empty = (empty_flag & pop_enable);
assign push_on_full = (full_flag & push_enable);

m_assert #(.MESSAGE("PUSH ON FULL")
) assert_push_full (
	.clk(clk),
    .rst_n(rst_n),
	.expr(push_on_full));

m_assert #(.MESSAGE("POP ON EMPTY")
) assert_pop_empty (
	.clk(clk),
    .rst_n(rst_n),
	.expr(pop_on_empty));
// synopsys translate_on

endmodule