;Find the best file available, closest to

pro get_mag_repop, date, filename, err

err=''
date0=strtrim(date,2)

url='soi.stanford.edu'
nping=0
pingagain1:
sock_ping,url,status 
if status ne 1 then begin
	print,'can not connect to server'
	wait,30
	nping=nping+1
;	if nping gt 5 then begin
;		print,'Giving up on STANFORD server...'
;		err=-1
;		return
;	endif
	goto,pingagain1
endif

smart_allfiles, flist,daylist,timerange=[date0,date0]

if flist[0] eq '' then begin & err=-1 & filename='' & return & endif

for i=0,n_elements(flist)-1 do sock_copy,flist[i]
flistloc=strmid(flist,58,27)
mreadfits,flistloc,index
wgood=where(index.datamean lt 10. and index.missvals eq 0)
if wgood[0] eq -1 then begin 
	wgood=where(index.datamean lt 10.)
	if wgood[0] eq '' then begin & err=-1 & filename='' & return & endif
	flist=flist[wgood]
	index=index[wgood]
	wgood=where(index.missvals eq min(index.missvals))
	flist=flist[wgood]
	index=index[wgood]
endif else begin
	flist=flist[wgood]
	index=index[wgood]
endelse
for i=0,n_elements(flistloc)-1 do spawn,'rm '+flistloc[i]

tims=anytim(index.date_obs)
thistim=anytim(anytim(file2time(date0),/date,/vms)+' 12:00:00')
wbest=where(abs(tims-thistim) eq min(abs(tims-thistim)))
thisfile=flist[wbest]
thisindex=index[wbest]

sock_copy,thisfile

filename=(reverse(str_sep(thisfile,'/')))[0]

end