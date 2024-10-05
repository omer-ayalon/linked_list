module tb;

// IO
localparam EN = 7;
localparam L2_EN = $clog2(EN);
localparam USED_WDT = $clog2(EN+1);

reg		                clk;
reg                     rst_n;
wire                    fl_vld;
reg                     fl_rdy;
reg     [EN-1:0]        fl;
reg                     ret_vld;
wire                    ret_rdy;
reg     [EN-1:0]        ret;
wire    [USED_WDT-1:0]  used;    

/////////////////////////////////////////////////////////
// TEST
/////////////////////////////////////////////////////////
initial begin
repeat (10) @(posedge clk);

t_fl();
t_fl();
t_ret(7'b0000001);
t_fl();


repeat (5) @(negedge clk);
$display("Test completed");
$finish;
end

/////////////////////////////////////////////////////////
// TASKS
/////////////////////////////////////////////////////////
task t_fl;
begin
#1;
fl_rdy = 1;
repeat (1)@(posedge clk);
#1;
fl_rdy = 0;
end
endtask

task t_ret;
input   [EN-1:0]    ret_data;
begin
#1
ret = ret_data;
ret_vld = 1;
repeat (1)@(posedge clk);
#1;
ret_vld = 0;
end
endtask

/////////////////////////////////////////////////////////
// DUT
/////////////////////////////////////////////////////////
m_free_list_ff #(
    .EN(EN)
) dut (
    .clk(clk),
    .rst_n(rst_n),
    .flush(1'b0),
    .fl_vld(fl_vld),
    .fl_rdy(fl_rdy),
    .fl(fl),
    .ret_vld(ret_vld),
    .ret_rdy(ret_rdy),
    .ret(ret),
    .used(used)
);

/////////////////////////////////////////////////////////
// INIT
/////////////////////////////////////////////////////////

initial begin
clk = 0;
rst_n = 1;

fl_rdy = 0;
ret_vld = 0;
end

/////////////////////////////////////////////////////////
// RST_N
/////////////////////////////////////////////////////////

initial begin
repeat (1) @ (posedge clk);
rst_n=0;
repeat (1) @ (posedge clk);
rst_n=1;
end

/////////////////////////////////////////////////////////
// WAVES
/////////////////////////////////////////////////////////

initial begin
$dumpfile("tb.vcd");
$dumpvars(0, tb);
end

/////////////////////////////////////////////////////////
// clk
/////////////////////////////////////////////////////////

always #5 clk = ~clk;

endmodule