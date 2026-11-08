`timescale 1ns/1ps
// Self-checking TB for uart_baud_gen (step 10)
//  T1 static : period == BAUDDIV + 1 for BAUDDIV 1..40, no tick for BAUDDIV 0
//  T2 live   : BAUDDIV changed while enabled, at every count phase, random old/new
//              ticks within 2 cycles of the write may still come from the old setting
//              (change detect latency); after that the first tick is <= new + 4 cycles
//              after the write, then period == new + 1
//  Reference : step 9 run on the same stimulus, 65536-cycle stalls counted
module tb_baud_live;
reg clk=0, rst_n=0, en=0; reg [15:0] div=8; always #5 clk=~clk;
wire t9, t10;
baud9  A(.clk(clk),.rst_n(rst_n),.i_enable(en),.i_baudDiv(div),.o_tick16(t9));
baud10 B(.clk(clk),.rst_n(rst_n),.i_enable(en),.i_baudDiv(div),.o_tick16(t10));
integer seed=7, err=0, n=0, stall9=0, c, d, k, ph, dold, dnew, first, p, last, tries;
task wait_tick(output integer cyc); begin cyc=0; @(negedge clk); cyc=1; while(!t10 && cyc<70000) begin @(negedge clk); cyc=cyc+1; end end endtask
initial begin
  repeat(3) @(negedge clk); rst_n=1;
  // T1
  for (d=0; d<=40; d=d+1) begin
    en=0; div=d; repeat(5) @(negedge clk); en=1;
    if (d==0) begin
      c=0; repeat(200) begin @(negedge clk); if (t10) c=c+1; end
      if (c) begin err=err+1; $display("FAIL T1 div=0 ticks=%0d", c); end
    end else begin
      wait_tick(p);
      for (k=0;k<3;k=k+1) begin wait_tick(p); n=n+1;
        if (p != d+1) begin err=err+1; $display("FAIL T1 div=%0d period=%0d", d, p); end end
    end
  end
  // T2
  for (tries=0; tries<400; tries=tries+1) begin
    dold = 1 + ($random(seed) & 31); dnew = 1 + ($random(seed) & 31);
    if (dnew==dold) dnew = dold + 1;
    en=0; div=dold; repeat(5) @(negedge clk); en=1;
    wait_tick(p); wait_tick(p);
    ph = $random(seed) % (dold+1); if (ph<0) ph=-ph;
    repeat(ph) @(negedge clk);
    div = dnew;                                  // live write
    first=0; c=0;
    while (c<70000 && !first) begin @(negedge clk); c=c+1; if (t9 && c>2) first=c; end
    if (first==0 || first > dnew+1) stall9=stall9+1;
    // re-measure step 10 from scratch in a clean run (first tick + periods)
    en=0; div=dold; repeat(5) @(negedge clk); en=1; wait_tick(p); wait_tick(p);
    repeat(ph) @(negedge clk); div=dnew;
    c=0; first=0;
    while (!first && c<70000) begin @(negedge clk); c=c+1; if (t10 && c>2) first=c; end
    n=n+1;
    if (first > dnew+4) begin err=err+1; $display("FAIL T2 %0d->%0d phase=%0d first=%0d", dold, dnew, ph, first); end
    for (k=0;k<3;k=k+1) begin wait_tick(p);
      if (p != dnew+1) begin err=err+1; $display("FAIL T2 %0d->%0d phase=%0d period=%0d", dold, dnew, ph, p); end end
  end
  $display("BAUD LIVE TB: checks=%0d errors=%0d | step9 late/stalled first tick (> new+1 or none)=%0d / 400 => %s", n, err, stall9, err==0?"PASS":"FAIL");
  $finish;
end
endmodule
