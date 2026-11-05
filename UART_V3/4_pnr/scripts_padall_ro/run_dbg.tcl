source 0_InitDesign.tcl
foreach i [dbGet top.insts] { set cn [dbGet $i.cell.name]; set b [lindex [dbGet $i.box] 0]; if {[string match -nocase pad* $cn] && [lindex $b 0] < 300 && [lindex $b 1] > 780 && [lindex $b 1] < 1120} { puts "LEFT [format %9.3f [lindex $b 1]] [format %9.3f [lindex $b 3]] $cn [dbGet $i.name]" } }
exit
