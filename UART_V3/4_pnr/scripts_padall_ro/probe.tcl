source 0_InitDesign.tcl
foreach h {1900 1901 1902 1903 1904 1905 1906 1907 1908 1909 1910 1911 1912 1913 1914 1915 1916 1917 1918 1919 1920} { floorPlan -site CoreSite -d 1892 $h 30 30 30 30 ; puts "PROBE h=$h die=[dbGet top.fPlan.box] core=[dbGet top.fPlan.coreBox]" }
exit
