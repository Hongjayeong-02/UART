; CIW checks after SEALRING / Move Origin / LOGO
cv = dbOpenCellViewByType("UART_MERGE" "uart_chip_top_allpad" "layout")
cv~>bBox                                                    ; ((0.0 0.0) (1912.0 1920.0))
setof(s cv~>shapes s~>layerName == "SEALRING")~>bBox        ; seal ring rectangle
setof(i cv~>instances i~>cellName == "UART_LOGO")~>xy       ; logo instance origin
