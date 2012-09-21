;Calculate the area of an MDI pixel.

function smart_mdipxarea, map, mmsqr=mmsqr, cmsqr=cmsqr, mmppx=mmppx, cmppx=cmppx, asecppx=asecppx, rsunasec=rsunasec

if n_elements(map) lt 1 then map={dx:1.98394,dy:1.98394,rsun:975.147}

;Calculate the area of a pixel in Mm^2
rsunmm=6.955d2 ;Mm
mmperarcsec=rsunmm/map.rsun ;Mm/arcsec
pixarea=((map.dx*mmperarcsec)*(map.dy*mmperarcsec)) ;Mm^2

if keyword_Set(cmsqr) then pixarea=pixarea*1D16

;Length of a side of a pixel.
arcppx=map.dx
arcpsun=map.rsun
mmpsun=6.955*1D8/1D6
retmmppx=(arcppx/arcpsun)*mmpsun ;in Mm/px

if keyword_set(mmppx) then return, retmmppx

if keyword_set(cmppx) then return, retmmppx*1d8

if keyword_set(asecppx) then return, map.dx

if keyword_set(rsunasec) then return, map.rsun

return, pixarea

end