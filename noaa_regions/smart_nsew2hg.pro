pro smart_nsew2hg, locstr, hglat, hglon

nloc=n_elements(locstr)
hglat=fltarr(nloc)
hglon=fltarr(nloc)

for i=0,nloc-1 do begin

	if strtrim(locstr[i],2) eq '////' or strtrim(locstr[i],2) eq '' then begin
		hglat[i]=1000
		hglon[i]=1000
		return
	endif
	
	if strmid(locstr[i],0,1) eq 'S' then mlat=-1 else mlat=1
	if strmid(locstr[i],1,2) eq '**' then hglat[i]=1000 else hglat[i]=fix(strmid(locstr[i],1,2))*mlat
	if strmid(locstr[i],3,1) eq 'E' then mlon=-1 else mlon=1
	if strmid(locstr[i],4,2) eq '**' then hglon[i]=1000 else hglon[i]=fix(strmid(locstr[i],4,2))*mlon

	hglat[i]=fix(hglat[i])
	hglon[i]=fix(hglon[i])
endfor


end