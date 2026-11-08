`timescale 1ns/1ps
// step 10-F: upper-byte borrow path. Static periods for BAUDDIV across byte
// boundaries, then live changes between large values (period / first tick).
module tb_baud_big;
reg clk=0, rst_n=0, en=0; reg [15:0] div=1; always #5 clk=~clk;
wire t9, t10; wire t10r = t10;
baud9  A(.clk(clk),.rst_n(rst_n),.i_enable(en),.i_baudDiv(div),.o_tick16(t9));
baud10 B(.clk(clk),.rst_n(rst_n),.i_enable(en),.i_baudDiv(div),.o_tick16(t10));
integer err=0, n=0, k, p, p9, i, first, c, seed=11, dold, dnew, mis=0;
reg [15:0] vals [0:15];
always @(posedge clk) if (t10 !== t10r) mis=mis+1;
task per10(output integer cyc); begin cyc=0; @(negedge clk); cyc=1; while(!t10 && cyc<200000) begin @(negedge clk); cyc=cyc+1; end end endtask
task per9 (output integer cyc); begin cyc=0; @(negedge clk); cyc=1; while(!t9  && cyc<200000) begin @(negedge clk); cyc=cyc+1; end end endtask
initial begin
  vals[0]=255; vals[1]=256; vals[2]=257; vals[3]=325; vals[4]=511; vals[5]=512; vals[6]=513; vals[7]=1000;
  vals[8]=4095; vals[9]=4096; vals[10]=4097; vals[11]=16'h1234; vals[12]=767; vals[13]=768; vals[14]=1; vals[15]=2;
  repeat(3) @(negedge clk); rst_n=1;
  for (i=0;i<16;i=i+1) begin
    en=0; div=vals[i]; repeat(5) @(negedge clk); en=1;
    // first tick after enable must match step 9 exactly (cycle count)
    fork per9(p9); per10(p); join
    if (p!=p9) begin err=err+1; $display("FAIL first-after-enable div=%0d step9=%0d step10=%0d", div, p9, p); end
    for (k=0;k<3;k=k+1) begin per10(p); n=n+1;
      if (p != div+1) begin err=err+1; $display("FAIL static div=%0d period=%0d", div, p); end end
  end
  for (i=0;i<60;i=i+1) begin
    dold = 200 + ($random(seed) & 1023); dnew = 200 + ($random(seed) & 1023); if (dnew==dold) dnew=dold+1;
    en=0; div=dold; repeat(5) @(negedge clk); en=1; per10(p); per10(p);
    repeat(($random(seed) & 32'h7fffffff) % dold) @(negedge clk);
    div=dnew; c=0; first=0;
    while(!first && c<200000) begin @(negedge clk); c=c+1; if (t10 && c>2) first=c; end
    n=n+1; if (first > dnew+4) begin err=err+1; $display("FAIL live %0d->%0d first=%0d", dold, dnew, first); end
    for (k=0;k<2;k=k+1) begin per10(p); if (p != dnew+1) begin err=err+1; $display("FAIL live %0d->%0d period=%0d", dold, dnew, p); end end
  end
  $display("BAUD BIG TB: checks=%0d errors=%0d tx!=rx=%0d => %s", n, err, mis, (err==0 && mis==0)?"PASS":"FAIL");
  $finish;
end
endmodule
