; uart_logo.il : LOGO layer "UART" pixel letters -> cell UART_MERGE/UART_LOGO/layout
; CIW:  load "uart_logo.il"
; pixel 4 um, letter 5x7 pixels (20 x 28 um), gap 1 pixel
let((cv px x0 font rows line y)
  px = 4.0
  font = list(
    list("10001" "10001" "10001" "10001" "10001" "10001" "01110")   ; U
    list("01110" "10001" "10001" "11111" "10001" "10001" "10001")   ; A
    list("11110" "10001" "10001" "11110" "10100" "10010" "10001")   ; R
    list("11111" "00100" "00100" "00100" "00100" "00100" "00100")   ; T
  )
  cv = dbOpenCellViewByType("UART_MERGE" "UART_LOGO" "layout" "maskLayout" "w")
  x0 = 0.0
  foreach(rows font
    for(r 0 6
      line = nth(r rows)
      for(c 0 4
        when(equal(substring(line c+1 1) "1")
          y = (6 - r) * px
          dbCreateRect(cv list("LOGO" "drawing")
                       list(list(x0 + c*px y) list(x0 + (c+1)*px y + px)))
        )
      )
    )
    x0 = x0 + 6*px
  )
  dbSave(cv)
  printf("UART_LOGO bBox = %L\n" cv~>bBox)
  dbClose(cv)
)
