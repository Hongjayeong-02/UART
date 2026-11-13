######################################################################
# tempus_hold_eco.tcl - hold-fix ECO loop (Tempus), uart_chip_top_allpad
# Precondition: design already loaded in this Tempus session
#   (read_design RouteDesign_for_ECO.dat ..., propagated clock, update_timing)
# Usage (inside tempus):  source tempus_hold_eco.tcl
######################################################################
set HOLD_VIEW   [lindex [all_hold_analysis_views] 0]
set SETUP_VIEW  [lindex [all_setup_analysis_views] 0]
set ECO_CELL    CLKBUFX2      ;# CoreSite buffer, NOT BUFX2 (CoreSiteDouble)
set HOLD_TARGET 0.010
set MAX_BUF     8
set MAX_EP      200

set RPT reports/eco
file mkdir $RPT
puts "**INFO: HOLD_VIEW=$HOLD_VIEW SETUP_VIEW=$SETUP_VIEW"

report_timing -early -view $HOLD_VIEW  -max_slack 0 -max_paths 300 -path_type summary > $RPT/00_hold_before.rpt
report_timing -late  -view $SETUP_VIEW -max_paths 20 -path_type summary > $RPT/10_setup_before.rpt

proc worst_hold_slack {pin view} {
    set p [report_timing -early -view $view -to $pin -max_paths 1 -collection]
    if {[sizeof_collection $p] == 0} { return 999 }
    return [get_property $p slack]
}

# 1. violating endpoints
set paths [report_timing -early -view $HOLD_VIEW -max_slack 0 -max_paths $MAX_EP -collection]
set eps {}
foreach_in_collection p $paths {
    set ep [get_object_name [get_property $p capturing_point]]
    if {[lsearch -exact $eps $ep] < 0} { lappend eps $ep }
}
puts "**INFO: hold violating endpoints = [llength $eps]"

# 2. buffer in front of each endpoint until slack >= target
set log [open $RPT/20_eco_log.txt w]
puts $log "endpoint  slack_before  buffers  slack_after"
set total 0
set fail  0
foreach ep $eps {
    set s0 [worst_hold_slack $ep $HOLD_VIEW]
    set n 0
    set s $s0
    while {$s < $HOLD_TARGET && $n < $MAX_BUF} {
        if {[catch {add_repeater -cell $ECO_CELL -term $ep} msg]} {
            puts $log "WARN add_repeater failed: $ep : $msg"
            incr fail
            break
        }
        incr n; incr total
        set s [worst_hold_slack $ep $HOLD_VIEW]
    }
    puts $log [format "%-60s %8.3f  %2d  %8.3f" $ep $s0 $n $s]
}
close $log
puts "**INFO: ECO buffers added = $total , add_repeater failures = $fail"

# 3. after
report_timing -early -view $HOLD_VIEW  -max_slack 0 -max_paths 300 -path_type summary > $RPT/30_hold_after.rpt
report_timing -late  -view $SETUP_VIEW -max_paths 20 -path_type summary > $RPT/40_setup_after.rpt
foreach {tag view mode} [list hold $HOLD_VIEW -early setup $SETUP_VIEW -late] {
    set p [report_timing $mode -view $view -max_paths 1 -collection]
    puts [format "**RESULT (after ECO): %-5s WNS = %s ns" $tag [get_property $p slack]]
}
puts "**INFO: now run:  write_eco -format innovus -output innovus.eco"
