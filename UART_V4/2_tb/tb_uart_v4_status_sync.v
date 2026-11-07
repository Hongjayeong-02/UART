`timescale 1ns/1ps
// Self-checking TB for uart_v4_sync_level + uart_v4_event_sync.
//   L1 level held long enough is seen in the destination within 3 dst cycles, and stays
//   E1 one event                 -> exactly 1 destination pulse
//   E2 two events back-to-back   -> 2 pulses (2nd waits as "pending", not lost)
//   E3 burst of 5 events         -> 1..3 pulses (merged while in flight, never zero;
//                                    exact count depends on the round-trip vs clock ratio)
//   E4 random events             -> every event covered by a send at or after it,
//                                    sends == pulses, last pulse after last event
// Options: +SHALF=<ns> +DHALF=<ns> +SEED=<n>
module tb_uart_v4_status_sync;

reg     r_sclk, r_dclk, r_srst_n, r_drst_n;
reg     r_level, r_event, r_rnd;
wire    w_level, w_pulse, w_busy;

integer r_errCnt, r_seed, r_seed0, r_events, r_sends, r_pulses, r_i, r_p0;
real    r_sHalf, r_dHalf, r_tChange, r_tLastEvt, r_tLastPulse;
reg     r_unc;
real    r_tUnc;

uart_v4_sync_level u_lvl (.i_clk(r_dclk), .i_rst_n(r_drst_n), .i_level(r_level), .o_level(w_level));
uart_v4_event_sync u_evt (.i_sclk(r_sclk), .i_srst_n(r_srst_n), .i_event(r_event), .o_busy(w_busy),
                          .i_dclk(r_dclk), .i_drst_n(r_drst_n), .o_pulse(w_pulse));

initial begin
        r_sHalf = 5.0; r_dHalf = 13.1; r_seed = 1;
        if ($value$plusargs("SHALF=%f", r_sHalf)) ;
        if ($value$plusargs("DHALF=%f", r_dHalf)) ;
        if ($value$plusargs("SEED=%d",  r_seed))  ;
        r_seed0 = r_seed;
end
initial begin r_sclk = 1'b0; #0.1;  forever #(r_sHalf) r_sclk = ~r_sclk; end
initial begin r_dclk = 1'b0; #0.61; forever #(r_dHalf) r_dclk = ~r_dclk; end

task check;
        input cond;
        input [8*60-1:0] msg;
        begin
                if (cond) $display("PASS: %0s", msg);
                else begin $display("FAIL: %0s", msg); r_errCnt = r_errCnt + 1; end
        end
endtask

// ---------------- level checker ----------------
always @(negedge r_dclk) if (r_drst_n) begin
        if ($realtime - r_tChange > 6.0 * r_dHalf + 2.0 * r_sHalf + 1.0 && w_level !== r_level) begin
                $display("FAIL: level not followed at %0t", $time); r_errCnt = r_errCnt + 1;
        end
end

// ---------------- event checkers ----------------
always @(posedge r_sclk) if (r_srst_n) begin
        if (r_event) begin r_events = r_events + 1; r_tLastEvt = $realtime; end
        if (u_evt.w_send) begin
                r_sends = r_sends + 1;
                r_unc   = 1'b0;                 // this send carries every earlier event
        end else if (r_event && !r_unc) begin
                r_unc  = 1'b1; r_tUnc = $realtime;
        end
        if (r_unc && ($realtime - r_tUnc) > 40.0 * (r_sHalf + r_dHalf)) begin
                $display("FAIL: event at %0t never sent", r_tUnc); r_errCnt = r_errCnt + 1; r_unc = 1'b0;
        end
end
always @(posedge r_dclk) if (r_drst_n && w_pulse) begin
        r_pulses = r_pulses + 1; r_tLastPulse = $realtime;
end

// ---------------- drivers ----------------
task evt;                               // one-cycle event in the source domain
        begin
                @(negedge r_sclk); r_event = 1'b1;
                @(negedge r_sclk); r_event = 1'b0;
        end
endtask

task quiet;                             // wait until nothing is in flight
        begin
                repeat (2) @(posedge r_sclk);
                while (w_busy || u_evt.r_pend) @(posedge r_sclk);
                repeat (8) @(posedge r_dclk);
        end
endtask

always @(negedge r_sclk) if (r_rnd) begin
        r_event = ($random(r_seed) % 7 == 0);
        if ($random(r_seed) % 23 == 0) begin r_level = ~r_level; r_tChange = $realtime; end
end

initial begin
        r_errCnt = 0; r_events = 0; r_sends = 0; r_pulses = 0; r_unc = 0;
        r_level = 0; r_event = 0; r_rnd = 0; r_tChange = 0; r_tLastEvt = 0; r_tLastPulse = 0;
        r_srst_n = 0; r_drst_n = 0;
        #60 r_srst_n = 1; #11 r_drst_n = 1;
        repeat (4) @(posedge r_dclk);

        // L1
        @(negedge r_sclk); r_level = 1'b1; r_tChange = $realtime;
        repeat (3) @(posedge r_dclk); #0.01;
        check(w_level === 1'b1, "L1 level 0->1 seen within 3 dst cycles");
        @(negedge r_sclk); r_level = 1'b0; r_tChange = $realtime;
        repeat (3) @(posedge r_dclk); #0.01;
        check(w_level === 1'b0, "L1 level 1->0 seen within 3 dst cycles");

        // E1
        r_p0 = r_pulses; evt; quiet;
        check(r_pulses - r_p0 == 1, "E1 one event -> exactly 1 pulse");

        // E2
        r_p0 = r_pulses;
        @(negedge r_sclk); r_event = 1'b1;
        @(negedge r_sclk); r_event = 1'b1;
        @(negedge r_sclk); r_event = 1'b0;
        quiet;
        check(r_pulses - r_p0 == 2, "E2 two back-to-back events -> 2 pulses");

        // E3
        r_p0 = r_pulses;
        @(negedge r_sclk); r_event = 1'b1;
        repeat (5) @(negedge r_sclk);
        r_event = 1'b0;
        quiet;
        $display("INFO: E3 burst of 5 gave %0d pulses", r_pulses - r_p0);
        check(r_pulses - r_p0 >= 1 && r_pulses - r_p0 <= 3, "E3 burst of 5 -> 1..3 pulses (merged, not lost)");

        // E4
        r_rnd = 1;
        repeat (3000) @(posedge r_sclk);
        r_rnd = 0; @(negedge r_sclk); r_event = 1'b0;
        quiet;
        check(r_sends == r_pulses,              "E4 sends == destination pulses");
        check(r_tLastPulse > r_tLastEvt,        "E4 last pulse after last event");
        check(r_pulses <= r_events && !r_unc,   "E4 every event covered, pulses <= events");

        if (r_errCnt == 0)
                $display("STATUS_SYNC ALL PASS  events=%0d pulses=%0d sHalf=%0.2f dHalf=%0.2f seed=%0d",
                         r_events, r_pulses, r_sHalf, r_dHalf, r_seed0);
        else
                $display("STATUS_SYNC FAIL  errors=%0d", r_errCnt);
        $finish;
end

initial begin #50_000_000; $display("STATUS_SYNC FAIL  timeout"); $finish; end

endmodule
