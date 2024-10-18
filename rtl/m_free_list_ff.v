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
    output [EN-1:0]       	            fl,
    input                	            ret_vld,
    output      						ret_rdy,
    input  [EN-1:0]  	                ret,
    output [USED_WDT-1:0]              	used
);

wire     [EN-1:0]   first_set;
reg      [EN-1:0]   fl;

reg                 fl_strb;
reg                 ret_strb;
reg                 fl_vld;
reg                 ret_rdy;

wire    [EN-1:0]    ret;
wire                fl_rdy;
wire                ret_vld;   

assign fl_strb  = fl_rdy  & fl_vld;
assign ret_strb = ret_rdy & ret_vld;

generate
for (genvar i0=0; i0<EN; i0=i0+1) begin : create_free_set
m_ff #(.RST_N_EN(1),
       .WIDTH(1),
       .RESET_VAL(1'b1)
) set_one_hot (.clk(clk),
               .rst_n(rst_n & ~(ret_strb & ret[i0])),
               .enable(fl[i0] & fl_strb),
               .data_in(1'b0),
               .data_out(first_set[i0])
);
end
endgenerate

m_counter #(.N_BITS(USED_WDT)
) used_cnt (
    .clk(clk),
    .rst_n(rst_n),
    .inc(fl_strb),
    .dec(ret_strb),
    .cnt(used)
);

m_first_set #(.EN(EN)
) set (
    .set_in(first_set),
    .set_out(fl)
);

always @(posedge clk or negedge rst_n)
if (~rst_n) begin
fl_vld = 0;
ret_rdy = 1;
fl_vld = 1;
end

endmodule