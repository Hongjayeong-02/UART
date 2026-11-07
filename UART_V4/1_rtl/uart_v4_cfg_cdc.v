`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// uart_v4_cfg_cdc
//   Configuration crossing PCLK -> UART_CLK for UART V4 (spec D3, D4, D7, D8).
//
//   PCLK side
//     - i_cfgWr is a one-cycle request carrying the complete new config word.
//     - Accepted only when o_cfgBusy == 0. Then r_swCfg is updated and the
//       request toggle flips. Refused writes raise o_cfgWrErr (-> PSLVERR).
//     - While busy, writes are refused, so r_swCfg is stable for the whole
//       transfer. It therefore also serves as the snapshot register.
//     - o_cfgBusy = request toggle != synchronized acknowledge toggle.
//
//   UART_CLK side
//     - Request toggle -> 2-FF synchronizer -> "pending" when it differs from
//       the last handled toggle.
//     - A pending config is applied only while i_uIdle == 1 (no frame in
//       progress). On apply: o_activeCfg <= r_swCfg, ack toggle follows request.
//     - o_cfgCommit is the apply strobe itself (combinational, UART_CLK domain).
//       Logic that must change together with the config (baud counter clear)
//       samples it on the SAME edge that loads o_activeCfg.
//     - o_applyPulse is the registered copy, one cycle later (status / debug).
//     - Ack toggle -> 2-FF synchronizer back to PCLK clears o_cfgBusy.
//
//   Reset: both domain resets are asserted together (spec D12).
//   CDC constraint for implementation: r_swCfg -> o_activeCfg is a
//   multi-bit crossing qualified by the synchronized request; it needs a
//   max-delay constraint, not a plain false path.
//   Integration note: o_cfgWrErr depends on i_cfgWr in the same cycle
//   (zero-wait write + PSLVERR), i.e. it is an input-to-output path at the
//   APB boundary.
// -----------------------------------------------------------------------------
module uart_v4_cfg_cdc #(
        parameter                       CW      = 24,
        parameter       [CW-1:0]        CFG_RST = {CW{1'b0}}
)(
        // PCLK domain
        input   wire                    i_pclk,
        input   wire                    i_prst_n,
        input   wire                    i_cfgWr,
        input   wire    [CW-1:0]        i_cfgWrData,
        output  wire                    o_cfgBusy,
        output  wire                    o_cfgWrErr,
        output  wire    [CW-1:0]        o_swCfg,

        // UART_CLK domain
        input   wire                    i_uclk,
        input   wire                    i_urst_n,
        input   wire                    i_uIdle,
        output  reg     [CW-1:0]        o_activeCfg,
        output  wire                    o_cfgCommit,
        output  reg                     o_applyPulse
);

// ---------------- PCLK domain ----------------
reg     [CW-1:0]        r_swCfg;
reg                     r_reqTog;
reg                     r_ackSync1;
reg                     r_ackSync2;

// ---------------- UART_CLK domain ----------------
reg                     r_reqSync1;
reg                     r_reqSync2;
reg                     r_ackTog;       // = last handled request toggle

wire                    w_cfgAccept;
wire                    w_pending;
wire                    w_apply;

assign o_cfgBusy   = (r_reqTog != r_ackSync2);
assign w_cfgAccept = i_cfgWr && !o_cfgBusy;
assign o_cfgWrErr  = i_cfgWr &&  o_cfgBusy;
assign o_swCfg     = r_swCfg;

always @(posedge i_pclk or negedge i_prst_n) begin
        if (!i_prst_n) begin
                r_swCfg    <= CFG_RST;
                r_reqTog   <= 1'b0;
                r_ackSync1 <= 1'b0;
                r_ackSync2 <= 1'b0;
        end else begin
                r_ackSync1 <= r_ackTog;
                r_ackSync2 <= r_ackSync1;

                if (w_cfgAccept) begin
                        r_swCfg  <= i_cfgWrData;
                        r_reqTog <= ~r_reqTog;
                end
        end
end

assign w_pending = (r_reqSync2 != r_ackTog);
assign w_apply   = w_pending && i_uIdle;
assign o_cfgCommit = w_apply;

always @(posedge i_uclk or negedge i_urst_n) begin
        if (!i_urst_n) begin
                r_reqSync1   <= 1'b0;
                r_reqSync2   <= 1'b0;
                r_ackTog     <= 1'b0;
                o_activeCfg  <= CFG_RST;
                o_applyPulse <= 1'b0;
        end else begin
                r_reqSync1   <= r_reqTog;
                r_reqSync2   <= r_reqSync1;
                o_applyPulse <= w_apply;

                if (w_apply) begin
                        o_activeCfg <= r_swCfg;
                        r_ackTog    <= r_reqSync2;
                end
        end
end

endmodule
