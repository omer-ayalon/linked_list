/**
 * @file m_ff.v
 * 
 * This module implements a parameterized flip-flop that can be configured 
 * to support an active-low reset or normal operation. It stores a WIDTH-bit 
 * value and updates the stored value on the rising edge of the clock 
 * signal if the enable signal is asserted. The module includes an assertion 
 * mechanism to check for illegal states of the enable signal.
 * 
 * @param RST_N_EN A parameter to enable or disable the active-low reset 
 *                  functionality. If set to 1, the flip-flop will reset 
 *                  its output to RESET_VAL when the reset signal is low.
 * 
 * @param WIDTH    The width of the data stored in the flip-flop. This 
 *                 parameter defines the number of bits the flip-flop will 
 *                 hold.
 * 
 * @param RESET_VAL The value to which the flip-flop output will be reset 
 *                  when the reset signal is low. This parameter can be 
 *                  set to any value based on design requirements.
 * 
 * @input clk     The clock signal, used to synchronize the operation of 
 *                 the flip-flop.
 * @input rst_n   The active-low reset signal. When this signal is low, 
 *                 the flip-flop resets to RESET_VAL.
 * @input enable  The enable signal that controls whether the flip-flop 
 *                 updates its output with the input data. The output 
 *                 will only be updated if this signal is high.
 * @input data_in The input data to be stored in the flip-flop when 
 *                 enabled.
 * 
 * @output data_out The current value stored in the flip-flop. This value 
 *                   is updated on the rising edge of the clock when 
 *                   enabled.
 * 
 * The module includes an assertion check to verify that the enable signal 
 * is not in an invalid state (x or z). If the assertion fails, an error 
 * message is displayed, and the simulation terminates.
 */
module m_ff #(
    parameter RST_N_EN=1,
    parameter WIDTH=4,
    parameter RESET_VAL=0) 
(
    input                   clk,
    input                   rst_n,
    input                   enable,
    input      [WIDTH-1:0]  data_in,
    output reg [WIDTH-1:0]  data_out
);

/////////////////////////////////////////////////////////
// enable assertion checking
/////////////////////////////////////////////////////////

// synopsys translate_off
wire expr = ((enable === 1'bx) | (enable === 1'bz));

m_assert #(.MESSAGE("m_ff enable is x/z")
) m_ff_enable_assert (
    .clk(clk),
    .rst_n(rst_n),
    .expr(expr)
);
// synopsys translate_on

/////////////////////////////////////////////////////////
// Flip flop
/////////////////////////////////////////////////////////

generate
if (RST_N_EN) begin
always @(posedge clk or negedge rst_n)
if (~rst_n) data_out = RESET_VAL;
else if (enable) data_out <= data_in;
end

else begin
always @(posedge clk)
if (enable) data_out <= data_in;
end
endgenerate

endmodule