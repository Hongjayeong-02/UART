foreach c (U45 U35 OC OC_U45)
  cd ~/PROJ1/proj1_make/TOP/PNR_1GHZ_$c
  echo "START $c `date`"
  innovus -nowin -log run_all.log < run_all.tcl >& console.log
  echo "END   $c `date`"
end
