;   EVENTNUM        LONG              5250
;   START_TIME      STRING    ' 2-Sep-1999 03:00:00.000'
;   MAX_TIME        STRING    ' 2-Sep-1999 21:00:00.000'
;   END_TIME        STRING    ' 1-Sep-1999 01:05:00.000'
;   SATELLITE       STRING    'GO8'
;   Q               STRING    '5'
;   TYPE            STRING    'XRA'
;   FREQ            STRING    '1-8A'
;   FCLASS          STRING    'C2.7'
;   FBASE           FLOAT           0.00000
;   FLUX            FLOAT           2700.00
;   P1              FLOAT           0.00000
;   REGION          STRING    ''
;   HGLAT           INT           1000
;   HGLON           INT           1000

;   ID              STRING    'NF'
;   HGLON           DOUBLE           50.834461
;   HGLAT           DOUBLE           27.314651
;   XPOS            DOUBLE           851.20980
;   YPOS            DOUBLE           766.99828
;   MEANVAL         DOUBLE           23.308640
;   STDDV           DOUBLE           41.813919
;   KURT            DOUBLE           5.2147396
;   NARPX           DOUBLE           1000.0000
;   BFLUX           DOUBLE           12874.825
;   BFLUXPOS        DOUBLE           12874.825
;   BFLUXNEG        DOUBLE           0.0000000
;   BLFUXEMRG       DOUBLE        0.0076238948
;   TIME            STRING    ' 2-Feb-1999 19:15:02.131'
;   NOAA            STRUCT    -> <Anonymous> Array[1]
;   AREA            DOUBLE           411.02759
;   BMIN            DOUBLE           0.0000000
;   BMAX            DOUBLE           483.00662
;   SCHRIJVER_R     DOUBLE           0.0000000
;   WLSG            DOUBLE           0.0000000
;   NL_LENGTH       DOUBLE           0.0000000     

;Plot statistics of extraction code WRT flares and size/ property distributions.

pro smart_plot_distributions, res1tore=res1tore

savp='~/science/data/smart_sav/candidates_test/'
flrp='~/science/data/smart_sav/flr_test/'
plotp='~/science/plots/smart_paper/test_year/'
if not keyword_set(res1tore) then begin

flist=file_search(savp,'*.sav')
tlist=long(anytim(file2time(flist)))

;flrlist=file_search(flrp,'*.sav')
;tflrlist=anytim(file2time(flist))

arstrarr=smart_blanknar(/arstr)
flrstrarr=smart_blanknar(/flare)

narfile=n_elements(tlist)
for k=0,narfile-2 do begin
	thistim=[tlist[k],tlist[k+1]]
	thisfile=flist[k]
	thisfnm=(reverse(str_sep(thisfile,'/')))[0]
	thisflrfile=flrp+'flare_'+strmid(thisfnm,6,8)+'.sav'
	restore,thisfile
	restore,thisflrfile
	
	flrloc=flrstr.hglat
	flrtims=flrstr.max_time
	
	;stop
	
	wflr=where(flrloc ne 1000 and anytim(flrtims) lt thistim[1] and anytim(flrtims) ge thistim[0])
	if wflr[0] eq -1 then nflr=0 else nflr=n_elements(wflr)
	if nflr lt 1 then goto,skipar

	;{eventnum:0L, start_time:'', max_time:'', end_time:'', satellite:'', q:'', type:'', freq:'', fclass:'', fbase:0., flux:0., p1:0., region:'', hglat:0, hglon:0}

	;cantim=anytim(file2time(daylist))
	
	for i=0,nflr-1 do begin
		thisflare=flrstr[wflr[i]]
		tflare=thisflare.max_time
		flaretim=anytim(tflare)
		hglatlon=[thisflare.hglat,thisflare.hglon]
	
		;canfile=thisfile;daylist[where(abs(cantim-flaretim) eq min(abs(cantim-flaretim)))]
		;restore,canfile;[0]
		
		arids=arstruct.id
		
		;dxdy=[mdimap.dx,mdimap.dy]
		dxdy=[1.97735,1.97735]
		imgsz=size(mdimap.data)
		arcxy=conv_h2a([hglatlon[1],hglatlon[0]], anytim(flaretim,/vms)) ;, behind=bhdlmb,arcmin=arcmin
		pxy=[(arcxy[0]/dxdy[0])+imgsz[1]/2.,(arcxy[1]/dxdy[1])+imgsz[2]/2.]
		
		
		warid=armask[pxy[0],pxy[1]]-1
		
		if warid ge 0 then begin
			flrid=arids[warid]
			thisflare.region=string(1d3*k+warid,format='(I09)')+'_'+flrid
			flrstrarr=[flrstrarr,thisflare]
			arstrarr=[arstrarr,arstruct[warid]]
		endif else begin
			thisflare.region='none'
			flrstrarr=[flrstrarr,thisflare]
			arstrarr=[arstrarr,smart_blanknar(/arstr)]
		endelse
		
		;flrstr[wflr[i]]=thisflare
	
	endfor
	
	skipar:

;print,'nflare = '+strtrim(nflr,2)
;help,arstrarr,flrstrarr
print,k,narfile

endfor

save,flrstrarr,arstrarr,file='~/science/data/smart_sav/test_distributions_'+time2file(systim(/utc))+'.sav'

endif

latestsav=(reverse(file_search('~/science/data/smart_sav/test_distributions_*.sav')))[0]
restore, latestsav


arstack=arstrarr[uniq(flrstrarr.region)]

stop


stop

end

