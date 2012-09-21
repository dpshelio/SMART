pro smart_write_docalib,calib=calib, grianlive=grianlive, localmdi=localmdi, psplot=psplot, winnum=winnum

if keyword_set(calib) then calib=1 else calib=0
if keyword_set(grianlive) then grianlive=1 else grianlive=0
if keyword_set(localmdi) then localmdi=1 else localmdi=0
if keyword_set(psplot) then psplot=1 else psplot=0
if keyword_set(winnum) then winnum=winnum else winnum=0
save,calib,grianlive,localmdi,psplot,winnum,file=smart_paths(/calibp)

end