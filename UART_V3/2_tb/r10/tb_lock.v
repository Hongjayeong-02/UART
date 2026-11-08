`timescale 1ns/1ps
module tb_lock;
reg clk=0, rst_n=0; always #5 clk=~clk;
reg psel=0, pen=0, pwr=0; reg [7:0] paddr=0; reg [31:0] pwdata=0;
reg rx=1;
wire [31:0] rd_a, rd_b; wire rdy_a, rdy_b, err_a, err_b, tx_a, tx_b, irq_a, irq_b;
uart_apb     A(.clk(clk),.rst_n(rst_n),.i_psel(psel),.i_penable(pen),.i_pwrite(pwr),.i_paddr(paddr),.i_pwdata(pwdata),
               .o_prdata(rd_a),.o_pready(rdy_a),.o_pslverr(err_a),.i_uartRx(rx),.o_uartTx(tx_a),.o_irq(irq_a));
uart_apb_r10 B(.clk(clk),.rst_n(rst_n),.i_psel(psel),.i_penable(pen),.i_pwrite(pwr),.i_paddr(paddr),.i_pwdata(pwdata),
               .o_prdata(rd_b),.o_pready(rdy_b),.o_pslverr(err_b),.i_uartRx(rx),.o_uartTx(tx_b),.o_irq(irq_b));
reg [31:0] lastrd; integer dirok=0, dirfail=0;
integer push=0, pushbad=0;
integer rxv=0, rxrd=0, d8=0;
integer cyc=0, mism=0, frames=0, seed, mode;
reg en=0; reg prev_tx=1;
always @(posedge clk) if (rst_n) begin
  cyc=cyc+1;
  if ({rd_a,rdy_a,err_a,tx_a,irq_a} !== {rd_b,rdy_b,err_b,tx_b,irq_b}) begin
    mism=mism+1;
    if (mism<10) $display("MISMATCH cyc=%0d prdata %h/%h rdy %b/%b err %b/%b tx %b/%b irq %b/%b",
       cyc,rd_a,rd_b,rdy_a,rdy_b,err_a,err_b,tx_a,tx_b,irq_a,irq_b);
  end
  // step 10-E premise: when the TX push reaches the core, CTRL enables are still set
  if (A.r_txPush) begin push=push+1; if (!(A.r_uartEn && A.r_txEn)) begin pushbad=pushbad+1;
      if (pushbad<5) $display("PREMISE FAIL cyc=%0d push with uartEn=%b txEn=%b", cyc, A.r_uartEn, A.r_txEn); end end
  if (A.uut_uart_core.o_rxValid) begin rxv=rxv+1; if (!A.r_data7) d8=d8+1; end
  if (psel && pen && rdy_a && !pwr && paddr==8'h04 && rd_a[7:0]!=0) rxrd=rxrd+1;
  if (prev_tx && !tx_a) frames=frames+1; prev_tx=tx_a;
end
// RX stimulus: mostly external loopback of A's TX, sometimes random line activity
always @(posedge clk) begin
  if (mode==0) rx <= tx_a;
  else if (($random(seed) & 63)==0) rx <= $random(seed);
end
task apb(input w, input [7:0] a, input [31:0] d);
begin
  @(negedge clk); psel=1; pen=0; pwr=w; paddr=a; pwdata=d;
  @(negedge clk); pen=1; #1;
  while (!rdy_a) @(negedge clk);
  lastrd = rd_a;
  @(negedge clk); psel=0; pen=0;
end endtask
integer i, k, r; reg [7:0] addr;
initial begin
  if (!$value$plusargs("seed=%d", seed)) seed=1;
  mode=0;
  repeat(5) @(negedge clk); rst_n=1;
  // back-to-back phase: TX_DATA write immediately followed by CTRL disable / re-enable
  apb(1,8'h0C,0); apb(1,8'h10,1); apb(1,8'h0C,8'h07);
  for (k=0;k<200;k=k+1) begin
    apb(1,8'h00,$random(seed));
    case ($random(seed) & 3)
      0: apb(1,8'h0C,8'h00);          // uart off right after the write
      1: apb(1,8'h0C,8'h05);          // tx off
      2: apb(1,8'h0C,8'h07);
      3: ;
    endcase
    apb(1,8'h0C,8'h07);
    repeat($random(seed) & 7) @(negedge clk);
  end
  // drain: let TX finish, then empty the RX FIFO
  apb(1,8'h0C,8'h07); repeat(30000) @(negedge clk);
  for (k=0;k<20;k=k+1) apb(0,8'h04,0);
  // directed phase: internal loopback, every format, BAUDDIV 0..2, self-check RX data
  for (k=0;k<36;k=k+1) begin : dir
    reg [7:0] cfg, dat, exp; integer j, t;
    cfg = 8'h87 | ((k%3)<<3) | (((k/3)%2)<<5) | (((k/6)%2)<<6);   // loopback|parity|stop2|data7|en
    apb(1,8'h0C,0); apb(1,8'h10,(k/12)+1); apb(1,8'h0C,cfg);
    for (j=0;j<4;j=j+1) begin
      dat = $random(seed);
      exp = cfg[6] ? {1'b0,dat[6:0]} : dat;
      apb(1,8'h00,dat);
      t=0; while (A.uut_uart_core.o_rxFifoEmpty && t<20000) begin @(negedge clk); t=t+1; end
      apb(0,8'h04,0);
      if (tb_lock.lastrd[7:0] !== exp || tb_lock.lastrd[9:8] !== 2'b00) begin
        dirfail=dirfail+1; $display("DIRECT FAIL k=%0d cfg=%h sent=%h got=%h", k, cfg, dat, tb_lock.lastrd);
      end else dirok=dirok+1;
    end
  end
  for (i=0;i<6000;i=i+1) begin
    r = $random(seed) & 255;
    if (i%500==0) begin
      // reconfigure: disable, change BAUDDIV (static while enabled), enable with random format
      apb(1,8'h0C,32'h0);
      apb(1,8'h10,($random(seed)&3));        // BAUDDIV 0..3 (0 = no tick)
      apb(1,8'h0C,{24'h0,($random(seed)&8'hF8)} | 32'h7); // uart/tx/rx en + random parity/stop/data7/loopback
      apb(1,8'h14,$random(seed)&32'hF);
      mode = ($random(seed) & 3)==0;
    end
    else if (r < 70)  apb(1,8'h00,$random(seed));
    else if (r < 140) apb(0,8'h04,0);
    else if (r < 200) begin addr = ($random(seed)&7)<<2; apb(0,addr,0); end
    else if (r < 215) apb(1,8'h18,$random(seed));
    else if (r < 220) apb(1,8'h0C,{24'h0,($random(seed)&8'hFF)});  // CTRL change while running (BAUDDIV unchanged)
    else repeat(($random(seed)&255)) @(negedge clk);
  end
  repeat(2000) @(negedge clk);
  $display("LOCKSTEP seed=%0d cycles=%0d tx_frames=%0d mismatches=%0d rx_valid=%0d (8bit %0d) rxdata_reads_nonzero=%0d direct_ok=%0d direct_fail=%0d push=%0d premise_fail=%0d => %s", seed, cyc, frames, mism, rxv, d8, rxrd, dirok, dirfail, push, pushbad, (mism==0 && dirfail==0 && pushbad==0)?"PASS":"FAIL");
  $finish;
end
endmodule
