restoreDesign ChipFinish.dat uart_chip_top_allpad
foreach p {VDDIOR VSSIOR VDDPAD25 VSSPAD} { set t [dbGet top.insts.pgInstTerms.name $p -p] ; puts "PG $p n=[llength [dbGet top.insts.pgInstTerms.name $p]] nets=[dbGet $t.net.name -u] cells=[dbGet $t.inst.cell.name -u]" }
foreach p {VDDPAD25 VSSPAD} { set t [dbGet top.insts.instTerms.cellTerm.name $p -p2] ; puts "SIG $p n=[llength $t] nets=[dbGet $t.net.name -u]" }
exit
