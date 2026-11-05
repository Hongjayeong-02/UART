source 0_InitDesign.tcl
source 1_PowerPlan.tcl
verifyConnectivity -type all -error 1000 -warning 50 -report pp_all.rpt
exit
