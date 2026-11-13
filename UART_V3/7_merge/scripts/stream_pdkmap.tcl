# Innovus : design-only GDS with the PDK's Innovus stream map (for Virtuoso merge)
# innovus -log log_stream_pdk.log  ->  source stream_pdkmap.tcl
restoreDesign ChipFinish.dat uart_chip_top_allpad
streamOut outputs/uart_chip_top_allpad_pdkmap.gds \
    -mapFile <PDK>/soce/streamOut.map \
    -libName DesignLib -units 2000 -mode ALL
# no -merge : std / IO cell GDS are merged in Virtuoso (textbook ch13)
