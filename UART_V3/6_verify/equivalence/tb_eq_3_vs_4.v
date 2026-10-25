`timescale 1ns/1ps
module tb_eq;
reg clk=0, rst_n=0; always #5 clk=~clk;
// FIFO
reg wr,rd; reg [7:0] wd;
wire [7:0] d0,d1; wire f0,f1,e0,e1; wire [4:0] c0,c1;
uart_fifo_old A(.clk(clk),.rst_n(rst_n),.i_wrEn(wr),.i_wrData(wd),.i_rdEn(rd),.o_rdData(d0),.o_full(f0),.o_empty(e0),.o_count(c0));
uart_fifo     B(.clk(clk),.rst_n(rst_n),.i_wrEn(wr),.i_wrData(wd),.i_rdEn(rd),.o_rdData(d1),.o_full(f1),.o_empty(e1),.o_count(c1));
// TX
reg tick, tv, d7, s2; reg [1:0] pm; reg [7:0] td;
wire [3:0] t0,t1;
uart_tx_old TA(.clk(clk),.rst_n(rst_n),.i_tick16(tick),.i_txValid(tv),.i_txData(td),.i_data7(d7),.i_parityMode(pm),.i_stop2(s2),.o_txReady(t0[0]),.o_txBusy(t0[1]),.o_txDone(t0[2]),.o_uartTx(t0[3]));
uart_tx     TB(.clk(clk),.rst_n(rst_n),.i_tick16(tick),.i_txValid(tv),.i_txData(td),.i_data7(d7),.i_parityMode(pm),.i_stop2(s2),.o_txReady(t1[0]),.o_txBusy(t1[1]),.o_txDone(t1[2]),.o_uartTx(t1[3]));
integer i, err=0, frames=0;
always @(negedge clk) if (rst_n) begin
  if ({d0,f0,e0,c0}!=={d1,f1,e1,c1}) begin err=err+1; if(err<5) $display("FIFO MISMATCH t=%0t",$time); end
  if (t0!==t1) begin err=err+1; if(err<5) $display("TX MISMATCH t=%0t %b %b",$time,t0,t1); end
end
integer nf=0, ne=0, pf=0; always @(posedge clk) begin if (t0[2]) frames=frames+1; if (f0) nf=nf+1; if (e0) ne=ne+1; if (TA.r_state==4 && TA.r_parityMode==3) pf=pf+1; end
initial begin
  wr=0;rd=0;wd=0;tick=0;tv=0;d7=0;pm=0;s2=0;td=0;
  #23 rst_n=1;
  for (i=0;i<400000;i=i+1) begin
    @(negedge clk);
    // bias phases: fill-heavy / drain-heavy
    if ((i/500)%2==0) begin wr=($random%4)!=0; rd=($random%4)==0; end
    else begin wr=($random%4)==0; rd=($random%4)!=0; end
    wd=$random;
    tick=($random%3)==0; tv=$random; td=$random; d7=$random; pm=$random; s2=$random;
  end
  $display("DONE err=%0d tx_frames=%0d full_cyc=%0d empty_cyc=%0d reserved_parity_cyc=%0d", err, frames, nf, ne, pf);
  $finish;
end
endmodule
