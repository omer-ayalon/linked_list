/*
 * Author: Omer Ayalon
 */

module tb;

// IO
localparam  EN = 4;
localparam  L2_EN = $clog2(EN);
localparam  USED_WDT = $clog2(EN+1);

reg		                clk;
reg                     rst_n;
wire                    fl_vld;
reg                     fl_rdy;
reg     [EN-1:0]        fl;
reg                     ret_vld;
wire                    ret_rdy;
wire     [EN-1:0]       ret;
wire    [USED_WDT-1:0]  used;

reg     [USED_WDT-1:0]  fifo_count;
reg                     fifo_full;
reg                     fifo_empty;

/////////////////////////////////////////////////////////
// TEST
/////////////////////////////////////////////////////////

integer rand_const = 0;
always @(*) begin
rand_const = (used==EN ? -15 : rand_const);
end

// random take from free list
integer wait_cycles_fl;
always @(posedge clk) begin
repeat (10)@(posedge clk);

wait_cycles_fl = $random % (5+rand_const);
if (wait_cycles_fl < 0) wait_cycles_fl = -wait_cycles_fl;
repeat (wait_cycles_fl)@(posedge clk);

if (used < EN) begin
t_fl();
end

end


// random return to free list
integer wait_cycles_ret;
always @(posedge clk) begin
repeat (10)@(posedge clk);

wait_cycles_ret = $random % (10+rand_const);
if (wait_cycles_ret < 0) wait_cycles_ret = -wait_cycles_ret;
repeat (wait_cycles_ret)@(posedge clk);

if (used > 0) begin
t_ret();
end
end

// stop test
initial begin
repeat (100)@(posedge clk);
while (1) begin  
if (used == 0) begin
repeat (1)@(posedge clk);
$display("Test completed");
$finish;
end else begin
repeat (1)@(posedge clk);
end
end
end

/////////////////////////////////////////////////////////
// Lap tracker
/////////////////////////////////////////////////////////

initial begin
integer cycle_count = 0; // Initialize the cycle counter

forever begin
    @(posedge clk); // Wait for each positive edge of the clock
    cycle_count = cycle_count + 1;
    
    // Every 100 clock cycles, update the same line
    if (cycle_count % 2000 == 0) begin
        $display("Time: %0t, Cycle Count: %0d", $time, cycle_count);
        $fflush(); // Flush the output buffer to ensure immediate display
    end
end
end

/////////////////////////////////////////////////////////
// TASKS
/////////////////////////////////////////////////////////

task t_fl;
begin
#1;
fl_rdy = 1;
repeat (1)@(posedge clk);
fl_rdy = 0;
#1;
end
endtask

task t_ret;
begin
#1;
ret_vld = 1;
repeat (1)@(posedge clk);
ret_vld = 0;
#1;
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
// FIFO helper
/////////////////////////////////////////////////////////

m_fifo #(.WIDTH(EN),
         .DEPTH(EN),
         .RST_N_EN(1'b1),
         .RESET_VAL(1'b0)
) fifo (.clk(clk),
        .rst_n(rst_n),
        .push_enable(fl_rdy & fl_vld),
        .push_data(fl),
        .pop_enable(ret_vld & ret_rdy),
        .pop_data(ret),
        .item_count(fifo_count),
        .full_flag(fifo_full),
        .empty_flag(fifo_empty)
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