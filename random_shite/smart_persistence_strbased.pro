;FLARE
;   START_TIME      STRING    ' 2-Sep-1999 03:00:00.000'
;   MAX_TIME        STRING    ' 2-Sep-1999 21:00:00.000'
;   END_TIME        STRING    ' 1-Sep-1999 01:05:00.000'
;   REGION          STRING    ''
;   HGLAT           INT           1000
;   HGLON           INT           1000
;AR
;   ID              STRING    'NF'
;   HGLON           DOUBLE           50.834461
;   HGLAT           DOUBLE           27.314651
;   XPOS            DOUBLE           851.20980
;   YPOS            DOUBLE           766.99828
;   TIME            STRING    ' 2-Feb-1999 19:15:02.131'

;------------------------------------------->
;INPUTS: timerange, filelist
;KEYWORDS: arstr, flare, nostruct
;OUTPUTS: structure, outfiles
function smart_persistence_files, structure, arstr=arstr, flare=flare, $
	timerange=timerange, nostruct=nostruct, filelist=filelist

if not keyword_set(filelist) then begin
	if keyword_set(arstr) then begin
		path='~/science/data/smart_sav/candidates_test/'
		outfiles=file_search(path+'*.sav')
	endif
	
	if keyword_set(flare) then begin
		path='~/science/data/smart_sav/flr_test/'
		outfiles=file_search(path+'*.sav')
		nfile=n_elements(outfiles)
	endif
	
	if keyword_set(timerange) then begin
		ftim=anytim(file2time(outfiles))
		wgood=where(ftim gt timerange[0] and ftim lt timerange[1])
		outfiles=outfiles[wgood]
	endif
endif else outfiles=filelist

nfile=n_elements(filelist)
if not keyword_set(nostruct) then begin
	struct_arr=smart_blanknar(arstr=arstr, flare=flare)
	for i=0l,nfile-1l do begin
		restore,filelist[i]
		if keyword_set(arstr) then struct_arr=[struct_arr,arstruct] $
			else struct_arr=[struct_arr,flrstr]
	endfor
	struct_arr=struct_arr[1l:*]
	structure=struct_arr
endif

return, outfiles

end

;------------------------------------------->

pro smart_persistence_resave, instr, infiles

nfiles=n_elements(infiles)
intim=anytim(instr.time)

for i=0,nfiles-1 do begin
	thisfile=infiles[i]
	restore,thisfile

	filetim=anytim((arstruct.time)[0])
	if filetim eq 0 then goto,skipsave
	
	wtim=where(intim eq filetim)
	arstruct=instr[wtim]
	
	save,mdimap,mapdiff,armask,arstruct,noaastr_daily,file=thisfile
	
	skipsave:
endfor

end

;------------------------------------------->

function smart_persistence_solrot, thisar, tlist, fthis, flist

;Position to look for ARs coming around the limb
rotthresh=-70.

timlist=tlist;anytim(file2time(tlist))

;Find prev solar rotation (span of 5 files)...
thislat=thisar.hglat
thisdate=time2file(thisar.time)
tprevrot=rot_period(thislat) ;days
thislon=thisar.hglon

;Only subtract some of the rotation if the AR less than 70.
if thislon gt rotthresh then begin
	tdegperday=360./tprevrot
	ddat=abs(thislon-rotthresh)/tdegperday
	tprevrot=tprevrot-ddat
endif

smart_calcdate,thisdate,(-1.)*tprevrot,outdate
tprevrot=anytim(outdate)

wprevrot=where(abs(tprevrot-timlist) eq min(abs(tprevrot-timlist)))
fprevrot=flist[((wprevrot-2l) > wprevrot):((wprevrot+2l) < (n_elements(timlist)-1))]
if (where(fprevrot eq fthis))[0] ne -1 then strsolrot='' $
	else dummy=smart_persistence_files(strsolrot, /arstr, filelist=fprevrot)
				
outstr=strsolrot

return, outstr

end

;------------------------------------------->

function smart_persistence_match, instr, str_arr, outmatcharr, flare=flare, arstr=arstr, $
	pixelmatch=pixelmatch, centroidmatch=centroidmatch, previous=previous, next=next
;For matching ARs and flares? or use pixel overlapping...
threshdeg=5. ;deg

thisstr=instr
;thisid=str_sep(thisstr.id,'-')
thisid=thisstr.id

thistim=anytim(thisstr.time)
str_tim=anytim(str_arr.time)
ddays=(thistim-str_tim)/(24.*3600.)

thislat=thisstr.hglat
thislon=thisstr.hglon

str_lon=str_arr.hglon
str_lat=str_arr.hglat

;Do differential rotation to time of region to be matched.
dlon = (DIFF_ROT(ddays,str_lat)) mod 360 ;delta_longitude
str_lonrot=str_lon+dlon

tims=anytim(str_tim[uniq(str_tim)])

for i=0,n_elements(tims)-1 do begin
	;Check all regions in this image...
	wtim=where(str_tim eq tims[i])
	thesestr=str_arr[wtim]
	theselat=str_lat[wtim]
	theselon=str_lon[wtim]
	;Find separations...
	difflat=abs(thislat-theselat)
	difflon=abs(thislon-theselon)
	;Which region matches...
	wmatch=where(difflat lt threshdeg and difflon lt threshdeg)
;	if n_elements(wmatch) gt 1 then $
;		wmatch=where((difflat+difflon) eq min(difflat+difflon))
	
	if wmatch[0] eq -1 then goto,skipmatch
	str_match=thesestr[wmatch]
;	match_id=str_sep(str_match.id,'-')
	match_id=str_match.id
	
;	if keyword_set(previous) then begin
nmatch=n_elements(match_id)
for j=0,nmatch-1 do begin

		;Previous HAS been named. Current has NOT.
		if strlen(match_id[j]) gt 2 and strlen(thisstr.id) lt 3 then thisstr.id=match_id[j]
		
		;NEITHER has been named.
		if strlen(match_id[j]) lt 3 and strlen(thisstr.id) lt 3 then begin
			if stregex(thisstr.id, '[1-9]') ne -1 then thisstr.id=time2file(thisstr.time)+'.'+'ar.'+thisstr.id
			if thisstr.id eq 'PL' then thisstr.id=time2file(thisstr.time)+'.'+'pl.'+thisstr.id			
		endif
		
		;Previous has NOT been named. Current HAS.
		if strlen(match_id[j]) lt 3 and strlen(thisstr.id) gt 2 then begin
			str_match[j].id=thisstr.id
			str_arr[(wtim[wmatch[j]])]=str_match[j]
		endif
endfor
;	endif
	
;	stop
	
	skipmatch:
endfor

outstr=thisstr

outmatcharr=str_arr

;compare hglat lon and time of thisar and the candidate ars

return,outstr

end

;------------------------------------------->

pro smart_persistence_strbased, timerange=intime, rest1ore=rest1ore, plot=plot

;hglatlon_map, hglonmap,hglatmap, dxdy, imgsz, oflb, time=date

;arpath=smart_paths(/savp)
arpath='~/science/data/smart_sav/candidates_test/'

;flrpath=smart_paths(/flarep)
flrpath='~/science/data/smart_sav/flr_test/'

;Choose seed time...
if keyword_set(time) then timerange=intime else timerange=['20-oct-2003','1-dec-2003']
;if keyword_set(time) then timerange=intime else timerange=['1-aug-2006','1-oct-2006']
;if keyword_set(time) then timerange=intime else timerange=['1-oct-2003','1-nov-2006']
timrange=anytim(timerange)

;TEMPORARY!
savstr='~/science/data/smart_sav/cycle_23_distributions.sav'
restore,savstr
all_str=AR_STRUCT_ARR
all_time=all_ar_str.time
all_tim=anytim(all_time)
wgood=where(all_tim ge timrange[0] and all_tim le timrange[1])
all_str=all_str[wgood]
all_time=all_time[wgood]
all_tim=all_tim[wgood]

timlist=all_tim[uniq(all_tim)]
tlist=all_time[uniq(all_tim)]
flist=time2file(tlist)

;Get file list...
flist=smart_persistence_files(dummy, /arstr, time=timrange, /nostruct)
tlist=anytim(file2time(flist))
nlist=n_elements(flist)

;Run though all files
for i=0l,nlist-1l do begin
	
	;Restore files to be compared.
	
	;Previous 5 files...
	rng0=[(i-5l) > 0l,(i-1l) > 0l]
	fprev=flist[rng0[0]:rng0[1]]
	if n_elements(fprev) gt 1 and fprev[0] ne flist[i] then $ 
		dummy=smart_persistence_files(strprev, /arstr, filelist=fprev) $
		else strprev=''
	
	;Flares.
;	fflare=flrpath+'flare_'+time2file(file2time(flist[i]), /date)+'.sav'
;	dummy=smart_persistence_files(flrstr, /flare, filelist=fflare)

	;Next files...
;	rng1=[(i+1l) < (nlist-1l),(i+5l) < (nlist-1l)]
;	fnext=flist[rng1[0]:rng1[1]]
;	if n_elements(fnext) gt 1 and fnext[0] ne flist[i] then $ 
;		dummy=smart_persistence_files(strnext, /arstr, filelist=fnext) $
;		else strnext=''
	
	;Get current file...
	fthis=flist[i]
	restore,fthis

	nar=n_elements(arstruct)
	
	;Name and associate Regions.
	for j=0,nar-1 do begin
		thisar=arstruct[j]
		
		;prev solar rotation (span of 5 files)...
;		thislat=thisar.hglat
;		thisdate=time2file(thisar.time)
;		tprevrot=rot_period(thislat) ;days
;		smart_calcdate,thisdate,tprevrot,outdate
;		tprevrot=anytim(outdate)
;		wprevrot=where(abs(tprevrot-tlist) eq min(abs(tprevrot-tlist)))
;		fprevrot=flist[((wprevrot-2l) < wprevot):((wprevrot+2l) > wprevrot)]
;		if where(fprevrot eq fthis) then strsolrot='' $
;			else dummy=smart_persistence_files(strsolrot, /arstr, filelist=fprevrot)

		strsolrot=smart_persistence_solrot(thisar, tlist, fthis, flist)
				
		if var_type(strsolrot) eq 8 then $
			thisar=smart_persistence_match(thisar, strsolrot, /arstr)

		;Previous 5 files...
		if var_type(strprev) eq 8 then begin
			outthisar=smart_persistence_match(thisar, strprev, outmatch,/arstr,/prev)
			strprev=outmatch
			thisar=outthisar
		endif
		
		arstruct[j]=thisar
	endfor
	
	
	
;	stop
	save,mdimap,mapdiff,armask,arstruct,noaastr_daily,file=fthis
;	save,flrstr,file=fflare
	if var_type(strprev) eq 8 then smart_persistence_resave, strprev, fprev

	if keyword_set(plot) then begin
		loadct,0
		plot_map,mdimap,dran=[-300,300]
		maskmap=mdimap                     
		maskmap.data=armask
		setcolors,/sys
		plot_map,maskmap,level=.5,/over,color=!green
		for k=0,n_elements(arstruct)-1 do xyouts,(arstruct[k].xpos-512.)*mdimap.dx,(arstruct[k].ypos-512.)*mdimap.dy,arstruct[k].id,/data,color=!red
		window_capture,file='~/science/plots/candidates_test/'+time2file(mdimap.time),/png
	endif
	
;	stop

endfor

end
