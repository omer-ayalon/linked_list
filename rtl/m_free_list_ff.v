/*
 * Author: Omer Ayalon
 */

module m_free_list_ff #(
    parameter   EN = 64,        // Number of entries in the free list

    localparam  L2_EN = $clog2(EN),
	localparam  USED_WDT = $clog2(EN+1)
)(
    input       						clk,
    input       						rst_n,
    input       						flush,
    output                	            fl_vld,
    input                 	            fl_rdy,
    output [EN-1:0]       	            fl_data,
    input                	            ret_vld,
    output      						ret_rdy,
    input  [EN-1:0]  	                ret,
    output [USED_WDT-1:0]              	used
);

/////////////////////////////////////////////////////////
// wire declaration
/////////////////////////////////////////////////////////

wire    [EN-1:0]    fl_array;
wire    [EN-1:0]    fl_data;
wire    [EN-1:0]    fl_set;
wire    [EN-1:0]    fl_reset;
wire    [EN-1:0]    fl_en;
wire    [EN-1:0]    fl_next;
wire                fl_strb;
wire                ret_strb;

/////////////////////////////////////////////////////////
// *_strb 
/////////////////////////////////////////////////////////

assign fl_strb  = fl_rdy  & fl_vld;
assign ret_strb = ret_rdy & ret_vld;

/////////////////////////////////////////////////////////
// Create Free List
/////////////////////////////////////////////////////////


generate
for (genvar i0=0; i0<EN; i0=i0+1) begin : create_free_list
assign fl_set[i0]   = (ret_strb & ret[i0]);                 // If returning item
assign fl_reset[i0] = (fl_strb  & fl_data[i0]);  // If getting item
assign fl_en[i0]    = fl_set[i0] | fl_reset[i0];
assign fl_next[i0]  = (fl_set[i0] ? 1'b1 : 1'b0);           // If returning item, set to 1'b1

m_ff #(.RST_N_EN(1),
       .WIDTH(1),
       .RESET_VAL(1'b1)
) m_ff_fl_array (.clk(clk),
               .rst_n(rst_n),
               .enable(fl_en[i0]),
               .data_in(fl_next[i0]),
               .data_out(fl_array[i0])
);
end
endgenerate

/////////////////////////////////////////////////////////
// Used Counter
/////////////////////////////////////////////////////////

m_counter #(.N_BITS(USED_WDT)
) m_counter_used (
    .clk(clk),
    .rst_n(rst_n),
    .inc(fl_strb),
    .dec(ret_strb),
    .cnt(used)
);

/////////////////////////////////////////////////////////
// ret_rdy, fl_vld 
/////////////////////////////////////////////////////////

assign ret_rdy = (used != '0);
assign fl_vld  = (used != EN);

/////////////////////////////////////////////////////////
// First Set
/////////////////////////////////////////////////////////

m_first_set #(.EN(EN)
) m_first_set_fl_array (
    .set_in(fl_array),
    .set_out(fl_data)
);

/////////////////////////////////////////////////////////
// Asserts
/////////////////////////////////////////////////////////

// synopsys translate_off
m_assert #(.MESSAGE("free list full & fifo counter not zero")
) full_assert (
    .clk(clk),
    .rst_n(rst_n),
    .expr((fl_array == {EN{1'b1}}) & (used != '0))
);

m_assert #(.MESSAGE("returing value that is already in free list")
) double_ret_assert (
    .clk(clk),
    .rst_n(rst_n),
    .expr(((fl_array & ret) & ret_strb) != '0)
);

m_assert #(.MESSAGE("tried to get item on empty list")
) fl_assert (
    .clk(clk),
    .rst_n(rst_n),
    .expr(fl_strb & (used == EN))
);

m_assert #(.MESSAGE("returning on full list")
) ret_assert (
    .clk(clk),
    .rst_n(rst_n),
    .expr(ret_strb & (used == 0))
);
// synopsys translate_on

endmodule