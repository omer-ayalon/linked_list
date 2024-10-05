/**
 * @file m_counter.v
 * 
 * This module implements an up/down counter that can be configured 
 * with a specified width (N_BITS). The counter can increment or 
 * decrement its value based on the control signals `inc` and `dec`. 
 * It features an active-low reset functionality and uses a flip-flop 
 * module to store the current count value.
 * 
 * @param N_BITS The width of the counter, which determines the number 
 *                of bits used for counting. The counter operates 
 *                within the range of 0 to (2^N_BITS - 1) when 
 *                incrementing and can decrement down to 0.
 * 
 * @input clk   The clock signal, used to synchronize the counter's 
 *               operations.
 * @input rst_n The active-low reset signal. When this signal is 
 *               low, the counter retains its current value until 
 *               the reset is deactivated.
 * @input inc   The increment control signal. When asserted (high), 
 *               the counter increments its value by 1.
 * @input dec   The decrement control signal. When asserted (high), 
 *               the counter decrements its value by 1.
 * 
 * @output cnt  The current value of the counter, which is updated 
 *               on the rising edge of the clock based on the 
 *               increment and decrement signals.
 * 
 * The module includes logic to calculate the next count value based 
 * on the current count and the control signals.
 */
module m_counter #(
parameter N_BITS=4
)(
    input 				    clk,
    input 				    rst_n,
    input				    inc,
    input                   dec,
    output  [N_BITS-1:0]    cnt
);

wire	[N_BITS-1:0]	counter;
wire	[N_BITS-1:0]	data_inc;
wire	[N_BITS-1:0]	data_dec;
reg		[N_BITS-1:0]	next_count;
wire 					enable;

/////////////////////////////////////////////////////////
// Counter inc/dec select
/////////////////////////////////////////////////////////

assign data_inc = counter + 1;
assign data_dec = counter - 1;

// next_count = data_inc / data_dec -> according to inc and dec
always @(*) begin
if (!rst_n) next_count = counter;
else if (inc) next_count = data_inc;
else if (dec) next_count = data_dec;
end

/////////////////////////////////////////////////////////
// Counter flip-flop
/////////////////////////////////////////////////////////

assign enable = (inc | dec);

m_ff #(.RST_N_EN(1'b1),
       .WIDTH(N_BITS),
       .RESET_VAL(0)
) cnt_out (.clk(clk),
          .rst_n(rst_n),
          .enable(enable),
          .data_in(next_count),
          .data_out(counter)
);
 /////////////////////////////////////////////////////////
 // Counter output
 /////////////////////////////////////////////////////////
 
assign cnt = counter;

endmodule