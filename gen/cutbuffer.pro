;---------------------------------------------------------------------------->
;+
; Project     : Aurora Research (Summer 2008)
;
; Name        : CUTBUFFER
;
; Purpose     : Clip the buffer from an array.
;
; Category    : Array Manipulation
;
; Syntax      : IDL> outarray = cutbuffer(inarray=inarray, value=value)
;
; Input       : INARRAY        - The buffered array.
;
;               VALUE          - The value of the buffer elements.
;
; Output      : Returned Value - The new clipped array.
;
; Keywords    : None.
;
; Example     : IDL> outarray = cutbuffer(inarray=[0,2,4,-1,-1,-1],value=-1)
;
; History     : Written 9-Jul-2008, Paul Higgins, (SSL/UCB)
;
; Contact     : phiggins@ssl.berkeley.edu
;-
;---------------------------------------------------------------------------->

function cutbuffer, inarray = inarray, value = value

if n_elements(value) lt 1 then value = -10000
value = value[0]

wgood = where(inarray ne value)
if wgood[0] eq -1 then outarray=[value] else $
	outarray = inarray[wgood]

return, outarray

end

;---------------------------------------------------------------------------->
