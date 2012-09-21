function smart_hmipxarea, map, mmppx=mmppx, mmsqrppx=mmsqrppx, cmppx=cmppx, cmsqrppx=cmsqrppx, rescale1024=rescale1024

;if keyword_set(rescale1024) then scale=.25 else scale=1.
;vmmppx=0.36911630/scale
rsunmm=695.5
rsunasec=973.159

vmmppx=rsunmm/rsunasec*map.dx ;Mm per Px

if keyword_set(mmppx) then result=vmmppx
if keyword_set(mmsqrppx) then result=vmmppx^2.
if keyword_set(cmppx) then result=vmmppx*1d8
if keyword_set(cmsqppx) then result=(vmmppx*1d8)^2.

return, result

end