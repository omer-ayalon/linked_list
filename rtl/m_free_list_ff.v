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

reg     [EN-1:0]    first_set;

// m_ff #(.RST_N_EN(1'b1),
//        .WIDTH(EN),
//        .RESET_VAL(1'b1)
// ) set_one_hot (.clk(clk),
//                .rst_n(rst_n),
//                .enable(),
//                .data_in(),
//                .data_out()
// );

reg                 fl_strb;
reg                 ret_strb;
reg                 fl_vld;
reg                 ret_rdy;

assign fl_strb  = fl_rdy  && fl_vld;
assign ret_strb = ret_rdy && ret_vld;

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
first_set = {EN{1'b1}};
end

always @(posedge clk)
if (fl_strb) first_set <= first_set & ~fl;

always @(posedge clk)
if (ret_strb) first_set <= first_set | ret;


endmodule