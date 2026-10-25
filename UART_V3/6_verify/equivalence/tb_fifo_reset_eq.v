`timescale 1ns/1ps
module tb;
reg clk=0, rst_n=0; always #5 clk=~clk;
reg wr=0, rd=0; reg [7:0] wd=0;
wire [7:0] d0,d1; wire f0,f1,e0,e1; wire [4:0] c0,c1;
fifo_orig A(.clk(clk),.rst_n(rst_n),.i_wrEn(wr),.i_wrData(wd),.i_rdEn(rd),.o_rdData(d0),.o_full(f0),.o_empty(e0),.o_count(c0));
fifo_opt  B(.clk(clk),.rst_n(rst_n),.i_wrEn(wr),.i_wrData(wd),.i_rdEn(rd),.o_rdData(d1),.o_full(f1),.o_empty(e1),.o_count(c1));
integer i, err=0, nrst=0, nwr_in_rst=0, nfullrw=0, nemptyrw=0, nrd_after=0, ncase=0;
reg [4:0] since_rst;
always @(negedge clk) begin
  if ({d0,f0,e0,c0}!=={d1,f1,e1,c1}) begin err=err+1; if (err<6) $display("MISMATCH t=%0t rst=%b o:%h %b%b %0d  n:%h %b%b %0d",$time,rst_n,d0,f0,e0,c0,d1,f1,e1,c1); end
end
always @(posedge clk) begin
  if (!rst_n && wr) nwr_in_rst=nwr_in_rst+1;
  if (rst_n && f0 && wr && rd) nfullrw=nfullrw+1;
  if (rst_n && e0 && wr && rd) nemptyrw=nemptyrw+1;
  if (rst_n && since_rst<4 && rd) nrd_after=nrd_after+1;
end
always @(posedge clk or negedge rst_n) if (!rst_n) since_rst<=0; else if (since_rst!=31) since_rst<=since_rst+1;
// ---- directed boundary cases ----
task tick; begin @(negedge clk); end endtask
initial begin
  #23 rst_n=1;
  // D1: write during reset, then read right after release
  tick; wr=1; wd=8'hA5; rst_n=0; tick; tick; rst_n=1; wr=0; rd=1; tick; tick; rd=0; ncase=ncase+1;
  // D2: fill to full, then simultaneous rd+wr at full
  repeat(8) begin wr=1; wd=$random; tick; end wr=0; tick;
  wr=1; rd=1; wd=8'h3C; tick; tick; wr=0; rd=0; tick; ncase=ncase+1;
  // D3: drain to empty, then simultaneous rd+wr at empty
  rd=1; repeat(10) tick; rd=0; tick;
  wr=1; rd=1; wd=8'h7E; tick; wr=0; rd=0; tick; rd=1; tick; rd=0; tick; ncase=ncase+1;
  // D4: reset asserted mid-traffic while full and writing
  repeat(8) begin wr=1; wd=$random; tick; end
  rst_n=0; tick; wd=8'hEE; tick; rst_n=1; tick; wr=0; rd=1; repeat(3) tick; rd=0; ncase=ncase+1;
  // ---- random with random async resets ----
  for (i=0;i<500000;i=i+1) begin
    @(negedge clk);
    if ((i/400)%2==0) begin wr=($random%4)!=0; rd=($random%4)==0; end
    else begin wr=($random%4)==0; rd=($random%4)!=0; end
    wd=$random;
    if (($random%997)==0) begin rst_n=0; nrst=nrst+1; end
    else if (!rst_n && ($random%3)==0) rst_n=1;
  end
  $display("DONE mismatch=%0d directed=%0d random_resets=%0d wr_during_reset=%0d full_rd+wr=%0d empty_rd+wr=%0d reads_within_4clk_after_reset=%0d", err,ncase,nrst,nwr_in_rst,nfullrw,nemptyrw,nrd_after);
  $finish;
end
endmodule
