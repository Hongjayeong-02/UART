source 0_InitDesign.tcl

checkDesign -all -outdir checkDesign
checkFPlan -outFile checkFPlan.rpt
timeDesign -prePlace -outDir reports/prePlace -prefix prePlace

set fp [open initio_summary.txt w]
puts $fp "DIE  : [dbGet top.fPlan.box]"
puts $fp "CORE : [dbGet top.fPlan.coreBox]"
foreach c {PADDI PADDO PADVDD PADVSS PADVDDIOR PADVSSIOR padIORINGCORNER} {
    set p [dbGet -p2 top.insts.cell.name $c]
    if {$p eq "0x0"} { set n 0 } else { set n [llength $p] }
    puts $fp [format "%-16s %d" $c $n]
}
set f [dbGet -p top.insts.name IOFILL*]
if {$f eq "0x0"} { set nf 0 } else { set nf [llength $f] }
puts $fp [format "%-16s %d" IOFILL $nf]
close $fp

fit
dumpToGIF initio_full.gif
zoomBox 0 1560 420 1900
dumpToGIF initio_corner_TL.gif
fit
