`timescale 1ns/1ps
// V3 (uart_apb_v3, combinational read) vs padall_read_opt (uart_apb):
// same APB transaction list, each DUT driven by its own back-to-back
// master (no idle cycle between transfers, honors PREADY).
// The V3 master idles one cycle wherever read_opt adds a wait state, so
// both DUTs see each SETUP on the same clock edge (no time drift).
// Checks: every read returns the same value, PSLVERR same,
//         write = 0 wait in both, read = +1 wait in read_opt (RX_DATA same).
module tb_read_opt_diff;
reg clk = 0; always #5 clk = ~clk;
reg rst_n = 0;

reg        a_psel, a_pen, a_pwr; reg [7:0] a_addr; reg [31:0] a_wd;
reg        b_psel, b_pen, b_pwr; reg [7:0] b_addr; reg [31:0] b_wd;
wire [31:0] a_rd, b_rd; wire a_rdy, b_rdy, a_err, b_err;
wire a_tx, b_tx, a_irq, b_irq;

uart_apb_v3 u_a (.clk(clk), .rst_n(rst_n), .i_psel(a_psel), .i_penable(a_pen),
    .i_pwrite(a_pwr), .i_paddr(a_addr), .i_pwdata(a_wd), .o_prdata(a_rd),
    .o_pready(a_rdy), .o_pslverr(a_err), .i_uartRx(a_tx), .o_uartTx(a_tx), .o_irq(a_irq));
uart_apb    u_b (.clk(clk), .rst_n(rst_n), .i_psel(b_psel), .i_penable(b_pen),
    .i_pwrite(b_pwr), .i_paddr(b_addr), .i_pwdata(b_wd), .o_prdata(b_rd),
    .o_pready(b_rdy), .o_pslverr(b_err), .i_uartRx(b_tx), .o_uartTx(b_tx), .o_irq(b_irq));

localparam N = 400;
reg        t_wr  [0:N-1];
reg [7:0]  t_adr [0:N-1];
reg [31:0] t_dat [0:N-1];
reg [31:0] ra [0:N-1], rb [0:N-1];
reg        ea [0:N-1], eb [0:N-1];
integer    wa [0:N-1], wb [0:N-1];
reg done_a = 0, done_b = 0;
integer i, err = 0, seed = 7, rdn = 0;

// back-to-back APB master (SETUP at posedge k, ACCESS from k+1)
task automatic run_a; integer k, w; reg [31:0] smp_rd; reg smp_err, smp_rdy; begin
  for (k = 0; k < N; k = k + 1) begin
    @(negedge clk); a_psel=1; a_pen=0; a_pwr=t_wr[k]; a_addr=t_adr[k]; a_wd=t_dat[k];
    @(negedge clk); a_pen=1; w=0;
    // APB: PRDATA/PSLVERR are sampled at the edge where PREADY=1, so take
    // them 1 ns BEFORE that edge (not after it, where a combinational
    // PRDATA would already show the next-cycle state)
    #4 smp_rd = a_rd; smp_err = a_err; smp_rdy = a_rdy;
    while (!smp_rdy) begin
      w=w+1; @(posedge clk); #9 smp_rd = a_rd; smp_err = a_err; smp_rdy = a_rdy;
    end
    @(posedge clk);
    ra[k]=smp_rd; ea[k]=smp_err; wa[k]=w;
    // keep both DUTs cycle-aligned: read_opt spends one more ACCESS cycle
    // on this read, so the V3 master idles one cycle (psel=0) instead
    if (!t_wr[k] && !(t_adr[k] == 8'h04 && w == 1)) begin
      @(negedge clk); a_psel=0; a_pen=0;
    end
  end
  @(negedge clk); a_psel=0; a_pen=0; done_a=1; end endtask
task automatic run_b; integer k, w; reg [31:0] smp_rd; reg smp_err, smp_rdy; begin
  for (k = 0; k < N; k = k + 1) begin
    @(negedge clk); b_psel=1; b_pen=0; b_pwr=t_wr[k]; b_addr=t_adr[k]; b_wd=t_dat[k];
    @(negedge clk); b_pen=1; w=0;
    // APB: PRDATA/PSLVERR are sampled at the edge where PREADY=1, so take
    // them 1 ns BEFORE that edge (not after it, where a combinational
    // PRDATA would already show the next-cycle state)
    #4 smp_rd = b_rd; smp_err = b_err; smp_rdy = b_rdy;
    while (!smp_rdy) begin
      w=w+1; @(posedge clk); #9 smp_rd = b_rd; smp_err = b_err; smp_rdy = b_rdy;
    end
    @(posedge clk);
    rb[k]=smp_rd; eb[k]=smp_err; wb[k]=w;
  end
  @(negedge clk); b_psel=0; b_pen=0; done_b=1; end endtask

initial begin
  a_psel=0; a_pen=0; a_pwr=0; a_addr=0; a_wd=0;
  b_psel=0; b_pen=0; b_pwr=0; b_addr=0; b_wd=0;
  // transaction list: config, TX writes immediately followed by STATUS /
  // FIFO_LEVEL reads (TX push visibility), loopback RX reads, random rest
  for (i = 0; i < N; i = i + 1) begin
    t_wr[i]  = $random(seed);
    t_adr[i] = {$random(seed)} % 9 * 4;          // 0x00..0x20 (0x20 = invalid)
    t_dat[i] = $random(seed);
    if (t_adr[i] == 8'h0C) t_dat[i] = {t_dat[i][31:8], 1'b1, t_dat[i][6:3], 3'b111}; // loopback, en
    if (t_adr[i] == 8'h10) t_dat[i] = 32'd2;      // fast baud so RX data arrives
  end
  t_wr[0]=1; t_adr[0]=8'h10; t_dat[0]=32'd2;
  t_wr[1]=1; t_adr[1]=8'h0C; t_dat[1]=32'h87;     // en, tx, rx, loopback
  t_wr[2]=1; t_adr[2]=8'h00; t_dat[2]=32'h5A;
  t_wr[3]=0; t_adr[3]=8'h1C;                       // FIFO_LEVEL right after TX write
  t_wr[4]=1; t_adr[4]=8'h00; t_dat[4]=32'hA5;
  t_wr[5]=0; t_adr[5]=8'h08;                       // STATUS right after TX write
  repeat (5) @(negedge clk); rst_n = 1; repeat (5) @(negedge clk);
  fork run_a; run_b; join
  for (i = 0; i < N; i = i + 1) if (!t_wr[i]) begin
    rdn = rdn + 1;
    if (ra[i] !== rb[i] || ea[i] !== eb[i]) begin
      err = err + 1;
      if (err < 10) $display("MISMATCH k=%0d addr=%02h v3=%08h opt=%08h err %b/%b", i, t_adr[i], ra[i], rb[i], ea[i], eb[i]);
    end
    if (wb[i] != ((t_adr[i]==8'h04 && wa[i]==1) ? 1 : wa[i] + 1)) begin
      err = err + 1; $display("WAIT k=%0d addr=%02h v3=%0d opt=%0d", i, t_adr[i], wa[i], wb[i]);
    end
  end else if (wa[i] != 0 || wb[i] != 0 || ea[i] !== eb[i]) begin
    err = err + 1; $display("WRITE k=%0d wait %0d/%0d err %b/%b", i, wa[i], wb[i], ea[i], eb[i]);
  end
  $display("READ_OPT_DIFF reads=%0d writes=%0d mismatch=%0d -> %s", rdn, N-rdn, err, err ? "FAIL" : "PASS");
  $finish;
end
endmodule
