`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// uart_v4_event_sync
//   One-cycle EVENT crossing with a toggle req/ack handshake
//   (e.g. RX overflow in UART_CLK -> sticky IRQ status in PCLK).
//   Guarantee: every source event produces AT LEAST ONE destination pulse.
//   Events that arrive while one is still in flight are merged into it
//   (fine for sticky status flags; not a counter).
//   Why not a bare toggle synchronizer: two events closer than the
//   destination sampling time toggle twice and cancel -> zero pulses.
// -----------------------------------------------------------------------------
module uart_v4_event_sync (
        // source domain
        input   wire    i_sclk,
        input   wire    i_srst_n,
        input   wire    i_event,
        output  wire    o_busy,         // an event is in flight (status/debug)

        // destination domain
        input   wire    i_dclk,
        input   wire    i_drst_n,
        output  reg     o_pulse
);

// source
reg     r_reqTog;
reg     r_ackSync1;
reg     r_ackSync2;
reg     r_pend;                 // event seen while in flight -> send again

// destination
reg     r_reqSync1;
reg     r_reqSync2;
reg     r_reqSync3;             // previous value for edge detect = ack toggle

wire    w_idle;
wire    w_send;

assign o_busy = (r_reqTog != r_ackSync2);
assign w_idle = !o_busy;
assign w_send = w_idle && (i_event || r_pend);

always @(posedge i_sclk or negedge i_srst_n) begin
        if (!i_srst_n) begin
                r_reqTog   <= 1'b0;
                r_ackSync1 <= 1'b0;
                r_ackSync2 <= 1'b0;
                r_pend     <= 1'b0;
        end else begin
                r_ackSync1 <= r_reqSync3;
                r_ackSync2 <= r_ackSync1;

                if (w_send)
                        r_reqTog <= ~r_reqTog;

                // an event during flight is remembered (merged into one more send)
                if (w_send)
                        r_pend <= 1'b0;
                else if (i_event && o_busy)
                        r_pend <= 1'b1;
        end
end

always @(posedge i_dclk or negedge i_drst_n) begin
        if (!i_drst_n) begin
                r_reqSync1 <= 1'b0;
                r_reqSync2 <= 1'b0;
                r_reqSync3 <= 1'b0;
                o_pulse    <= 1'b0;
        end else begin
                r_reqSync1 <= r_reqTog;
                r_reqSync2 <= r_reqSync1;
                r_reqSync3 <= r_reqSync2;
                o_pulse    <= (r_reqSync2 != r_reqSync3);
        end
end

endmodule
