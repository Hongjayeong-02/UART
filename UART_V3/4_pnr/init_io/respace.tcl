# left/right IO pads : integer gaps so that 1um IO fillers can fill every gap
set dieH [lindex [dbGet top.fPlan.box] 0 3]
foreach side {L R} {
  set lst {}
  foreach i [dbGet top.insts] {
    set cn [dbGet $i.cell.name]
    if {![string match -nocase pad* $cn] || [string match -nocase *CORNER* $cn]} continue
    set b [lindex [dbGet $i.box] 0]
    if {$side eq "L" && [lindex $b 2] > 300} continue
    if {$side eq "R" && [lindex $b 0] < 1500} continue
    if {[lindex $b 1] < 239 || [lindex $b 3] > $dieH - 239} continue
    lappend lst [list [lindex $b 1] $i [expr {[lindex $b 3] - [lindex $b 1]}]]
  }
  set lst [lsort -real -index 0 $lst]
  set n [llength $lst]
  set used 0.0
  foreach e $lst { set used [expr {$used + [lindex $e 2]}] }
  set spare [expr {round($dieH - 480 - $used)}]
  set base  [expr {$spare / ($n + 1)}]
  set extra [expr {$spare % ($n + 1)}]
  set y 240.0
  set k 0
  foreach e $lst {
    set g $base
    if {$k < $extra} { incr g }
    set y [expr {$y + $g}]
    set i [lindex $e 1]
    dbSet $i.pt_y [expr {[dbGet $i.pt_y] + $y - [lindex $e 0]}]
    set y [expr {$y + [lindex $e 2]}]
    incr k
  }
  puts "RESPACE $side n=$n spare=$spare base=$base extra=$extra last_end=$y"
}
