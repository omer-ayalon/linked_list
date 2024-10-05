/**
 * @file m_assert.v
 * @brief Assertion Module
 * 
 * This module provides a simple assertion mechanism that can be used in 
 * digital designs to check for specific conditions during simulation. 
 * When the specified condition (expression) evaluates to true, and the 
 * reset signal is not asserted (active low), a message is displayed, 
 * and the simulation is terminated.
 * 
 * @param MESSAGE A string parameter that allows customization of the 
 *                assertion message displayed during simulation. By 
 *                default, it is set to "[ASSERT]".
 * 
 * @input clk   The clock signal, used to synchronize the assertion 
 *               checking process.
 * @input rst_n The active-low reset signal. The assertion is checked 
 *               only if this signal is high (not asserted).
 * @input expr  The expression to evaluate for the assertion. If this 
 *               expression is true (non-zero), the assertion will be 
 *               triggered.
 * 
 * When the conditions are met (expr is true and rst_n is high), the 
 * module will display the message defined in the MESSAGE parameter and 
 * terminate the simulation using $finish().
 */
module m_assert #(
    parameter MESSAGE = "[ASSERT]") 
(
    input   clk,
    input   rst_n,
    input   expr
);

always @(posedge clk)
if (expr & rst_n) begin
$display("[Assert] %s", MESSAGE);
$finish();
end

endmodule