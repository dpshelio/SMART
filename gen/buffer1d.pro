;---------------------------------------------------------------------------->
;+
; Project     : Aurora Research (Summer 2008)
;
; Name        : BUFFER1D
;
; Purpose     : Make an array a standard size by concatenating a
;               buffer array onto the end.
;
; Category    : Array Manipulation
;
; Syntax      : IDL> buffer1d, outarray, new = 10000, $
;               IDL> inarray = array, value = -1
;
; Input       : INARRAY   - The array to buffer.
;
;               NEW       - The desired length of the final array.
;
;               VALUE     - The value of the buffered elements.
;
; Output      : OUTARRAY  - The final buffered array.
;
; Keywords    : None.
;
; Example     : IDL> buffer1d, outarray, new = 10000, $
;               IDL> inarray = fltarr(823), value = -1
;
; History     : Written 8-Jul-2008, Paul Higgins, (SSL/UCB)
;
; Contact     : phiggins@ssl.berkeley.edu
;-
;---------------------------------------------------------------------------->

pro buffer1d, outarray, new = new, inarray = inarray, value = value

nin = n_elements(inarray)

if n_elements(value) lt 1 then value = -10000.
if n_elements(new) lt 1 then new = ceiling(nin/1000.)*1000.

nbuff = new-nin
if nbuff gt 0 then begin
  buffer = fltarr(nbuff)+value
  outarray = [inarray, buffer]
endif else outarray = inarray

end

;---------------------------------------------------------------------------->
