
;	no_prevrot=Don't search for files from previous rotation of first 
;		file/time in input. Otherwise looks for files of previous 40 days to see if it can match ARs to previous rotation.
;	Enter a timerange or filelist of files to be run 

;
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
;KEYWORDS: 	arstr, flare, nostruct
;OUTPUTS: structure, outfiles
function smart_persistence_files, structure, arstr=arstr, flare=flare, $
	timerange=intime, nostruct=nostruct, filelist=filelist, pathsav=pathsav, error_status=error_status

if n_elements(intime) gt 0 then timerange=anytim(intime)

if n_elements(filelist) lt 1 then begin
	if keyword_set(arstr) then begin
		if n_elements(pathsav) ne 1 then path=smart_paths(/resavetrackp,/no_cal) $ ;'~/science/data/smart_sav_10488/candidates/'
			else path=pathsav
		outfiles=file_search(path+'smart*.sav*')
	endif
	
	if keyword_set(flare) then begin
		path='~/science/data/smart_sav/flr_test/'
		outfiles=file_search(path+'*.sav*')
	endif
	
	if keyword_set(timerange) then begin
		ftim=anytim(file2time(outfiles))
		wgood=where(ftim ge timerange[0] and ftim le timerange[1])
	        ;!!!Test for files to track!!!-----	
                if wgood[0] eq -1 then begin
                   error_status=5
                   return,''
                endif

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

;stop

for i=0,nfiles-1 do begin
	thisfile=infiles[i]

	if (reverse(str_sep(thisfile,'.')))[0] eq 'gz' then begin
			spawn,'gunzip -f '+thisfile
			restore,strjoin((str_sep(thisfile,'.'))[0:n_elements(str_sep(thisfile,'.'))-2],'.')
			spawn,'gzip -f '+strjoin((str_sep(thisfile,'.'))[0:n_elements(str_sep(thisfile,'.'))-2],'.')
	endif else restore,thisfile

	filetim=anytim((arstruct.time)[0])
	if filetim eq 0 then goto,skipsave
	
	wtim=where(intim eq filetim)
	if wtim[0] eq -1 then goto,skipsave
	
	arstruct=instr[wtim]
	
	save,arstruct, noaastr_daily, extentstr, file=thisfile;,mdimap,mapdiff,armask
	
	skipsave:
endfor

end

;------------------------------------------->

function smart_persistence_solrot, thisar, tlist, fthis, flist

;Position to look for ARs coming around the limb
rotthresh=70.

timlist=tlist;anytim(file2time(tlist))

;Find prev solar rotation (span of 5 files)...
thislat=thisar.hglat
tsolrot=rot_period(thislat)*3600.*24. ;seconds
thislon=thisar.hglon

;Only subtract some of the rotation if the AR less than -70.
;Matches the time to when the region should be at ROTTHRESH, 70 deg.
dtdtheta=tsolrot/360.
deltatheta=abs(rotthresh-thislon)

thistim=anytim(thisar.time)
prevrottim=thistim-tsolrot+(dtdtheta*deltatheta)

;Find best match for prev rot sav file. 
;Must match to within 2 days, to avoid getting first file in series that is no where near prev sol rotation.
wprevrot=where(abs(prevrottim-timlist) eq min(abs(prevrottim-timlist)))
if min(abs(prevrottim-timlist)) gt (3600.*24.)*2. then return,''

fprevrot=flist[((wprevrot-2l) > wprevrot):((wprevrot+2l) < (n_elements(timlist)-1))]
if (where(fprevrot eq fthis))[0] ne -1 then strsolrot='' $
	else dummy=smart_persistence_files(strsolrot, /arstr, filelist=fprevrot)
				
outstr=strsolrot

return, outstr

end

;------------------------------------------->

function smart_persistence_match, instr, str_arr, outmatcharr, flare=flare, arstr=arstr, $
	pixelmatch=pixelmatch, centroidmatch=centroidmatch, previous=previous, next=next, solrot=solrot

thisstr=instr

;!!TEMPPPP------------->
;if thisstr.smid eq '' then thisstr.smid=thisstr.id
;for j=0,n_elements(str_arr)-1 do $
;	if str_arr[j].smid eq '' then str_arr[j].smid=str_arr[j].id
;!!TEMPPPP------------->

;thisid=str_sep(thisstr.id,'-')
thisid=thisstr.smid
thiscl=thisstr.class

thistim=anytim(thisstr.time)
str_tim=anytim(str_arr.time)
ddays=(thistim-str_tim)/(24.*3600.)

thislat=thisstr.carlat
thislon=thisstr.carlon

;For matching ARs and flares? or use pixel overlapping...
;Dynamic thresholding. At disk center-> 2 deg matching threshold.
threshlat=5./cos(!dtor*abs(thisstr.hglon)) < 10. ;deg
threshlon=5./cos(!dtor*abs(thisstr.hglon)) < 10.

;Tighten threshold for doing previous rotation stuff...
if keyword_set(solrot) then begin
	threshlat=10
	threshlon=10
endif

str_lon=str_arr.carlon
str_lat=str_arr.carlat

;how many sav files included in the massive struct arr... (each image has multiple struct elements)
tims=reverse(anytim(str_tim[uniq(str_tim)]))

;if thisid eq '12' then stop

;loop through sav files
for i=0,n_elements(tims)-1 do begin
	;Check all regions in this current sav...
	wtim=where(str_tim eq tims[i])
	thesestr=str_arr[wtim]
	theselat=str_lat[wtim]
	theselon=str_lon[wtim]
	
	;Find separations...
	;Check for negative Carrington Lons
	;See if matching are on either sides of carrington long. break near 0 or 360. Add or subtract 360.
	if thislon lt 0 then thislon=thislon+360.
	if (where(theselon lt 0))[0] ne -1 then theselon[where(theselon lt 0)]=theselon[where(theselon lt 0)]+360
	if thislon lt 15 and max(theselon) gt 345 then theselon[where(theselon gt 345)]=theselon[where(theselon gt 345)]-360.
	if thislon gt 345 and min(theselon) lt 15 then theselon[where(theselon lt 15)]=theselon[where(theselon lt 15)]+360.
	difflat=abs(thislat-theselat)
	difflon=abs(thislon-theselon)
	
	;Which region matches...
	wmatch=where(difflat lt threshlat and difflon lt threshlon)

	if wmatch[0] eq -1 then goto,skipmatch
	difflat=difflat[wmatch]
	difflon=difflon[wmatch]
	wbestmatch=(where(sqrt(difflat^2.+difflon^2.) eq min(sqrt(difflat^2.+difflon^2.))))[0]
	
	str_match=thesestr[wmatch]
	match_id=str_match.smid
	match_cl=str_match.class
	
nmatch=n_elements(match_id)

		;Previous HAS been named. Current has NOT.
		;name this one as the best match which has been named. and then if nothing matches well enough, then it names as new catalog name.
		if strlen(match_id[wbestmatch]) gt 2 and strlen(thisstr.smid) lt 3 then thisstr.smid=match_id[wbestmatch]
		
		;NEITHER has been named.
		if strlen(match_id[wbestmatch]) lt 3 and strlen(thisstr.smid) lt 3 then begin
			if thisstr.class eq 'PL' or thisstr.class eq 'AR' then thisstr.smid=time2file(thisstr.time)+'.mg.'+thisstr.id
		endif
		
		;Previous has NOT been named. Current HAS.
		if strlen(match_id[wbestmatch]) lt 3 and strlen(thisstr.smid) gt 2 then begin
			str_match[wbestmatch].smid=thisstr.smid
			str_arr[(wtim[wbestmatch])]=str_match[wbestmatch]
		endif

	skipmatch:

endfor

;Don't want to name new regions if no match when running w/ SOLROT.
;Not sure whether to match unnamed (small) regions in prev rot with 
;developed regions in new rot, when match occurs..
if keyword_set(solrot) then return,thisstr

;Check for new regions that dont match anything else. 
if wmatch[0] eq -1 and strlen(thisstr.smid) lt 3 then begin
	if thisstr.class eq 'PL' or thisstr.class eq 'AR' then thisstr.smid=time2file(thisstr.time)+'.mg.'+thisstr.id
endif

outstr=thisstr

outmatcharr=str_arr

return,outstr

end

;------------------------------------------->

pro smart_persistence3, filelist=filelist, timerange=intime, rest1ore=rest1ore, plot=plot, no_prevrot=no_prevrot, pathsav=pathsav, error_status=error_status

error_status=0

;if keyword_set(plot) then begin & window,0,xs=800,ys=800 & wset,0 & endif

smart_write_docalib,/calib,/local

if n_elements(pathsav) ne 1 then arpath=smart_paths(/savp) else arpath=pathsav
plotpath=smart_paths(/plotp)

if n_elements(filelist) gt 1 then begin & flist=filelist & goto,skip_getfiles & endif

;Choose seed time...
if n_elements(intime) gt 0 then timerange=intime else timerange=['1-apr-2005','1-jun-2005']
timrange=anytim(timerange)

;Get file list...
flist=smart_persistence_files(dummy, /arstr, time=timrange, /nostruct, pathsav=pathsav, error_status=error_status)
if error_status[0] ne 0 then return

skip_getfiles:
if not keyword_set(no_prevrot) then $
	flistall=smart_persistence_files(dummy, /arstr, time=[anytim(anytim(file2time(flist[0]))-(40.*3600.*24.),/vms),anytim(file2time((reverse(flist))[0]),/vms)], /nostruct, pathsav=pathsav) else $
	flistall=flist

tlist=anytim(file2time(flist))
tlistall=anytim(file2time(flistall))
nlist=n_elements(flist)

;Run though all files
for i=0l,nlist-1l do begin
	if keyword_set(rest1ore) then goto,gotojump1
	;Restore files to be compared.
	
	;Previous 5 files...
	rng0=[(i-5l) > 0l,(i-1l) > 0l]
	fprev=flist[rng0[0]:rng0[1]]
	if n_elements(fprev) ge 1 and fprev[0] ne flist[i] then $ 
		dummy=smart_persistence_files(strprev, /arstr, filelist=fprev, pathsav=pathsav) $
		else strprev=''
	
gotojump1:
	;Get current file...
	fthis=flist[i]
	if keyword_set(rest1ore) then goto,gotojump2

	if (reverse(str_sep(fthis,'.')))[0] eq 'gz' then begin
		spawn,'gunzip -f '+fthis
		restore,strjoin((str_sep(fthis,'.'))[0:n_elements(str_sep(fthis,'.'))-2],'.')
		spawn,'gzip -f '+strjoin((str_sep(fthis,'.'))[0:n_elements(str_sep(fthis,'.'))-2],'.')
	endif else restore,fthis

	nar=n_elements(arstruct)

	;Name and associate Regions.
	for j=0,nar-1 do begin
		thisar=arstruct[j]
		
		;Do not track stuff before -70 deg
		if thisar.hglon gt -70 then begin
			;prev solar rotation (span of 5 files)...
			;Only do prev solrot if in left hemisphere (east?)...
			if thisar.hglon le -60 then begin
				strsolrot=smart_persistence_solrot(thisar, tlistall, fthis, flistall)		
				if var_type(strsolrot) eq 8 then $
					thisar=smart_persistence_match(thisar, strsolrot, /arstr,/solrot)
			endif
	
			;Previous 5 files...
			if var_type(strprev) ne 8 then strprev0=smart_blanknar(/arstr) else strprev0=strprev
			outthisar=smart_persistence_match(thisar, strprev0, outmatch,/arstr,/prev)
			strprev0=outmatch
			thisar=outthisar
			arstruct[j]=thisar
			
			;Check for double named regions.
			if n_elements(where(arstruct.smid eq arstruct[j].smid)) gt 1 then begin
				;wsame=where(strmid(arstruct.smid,0,strlen(arstruct[j].smid)) eq arstruct[j].smid)
				;armatchname=arstruct[wsame]
				;letter=string(byte(strmid(armatchname.smid,strlen(arstruct[j].smid)-1.,1))+1)
				;arstruct[j].smid=arstruct[j].smid+strtrim(letter,2)
				
				arstruct[j].smid=arstruct[j].smid+strtrim(string(byte(97+j)),2)
			endif
		endif
	endfor
	
	save,arstruct, noaastr_daily, extentstr, file=fthis;,mdimap,mapdiff,armask


	if var_type(strprev) eq 8 then begin
		strprev=strprev0
		smart_persistence_resave, strprev, fprev
	endif

gotojump2:
	if keyword_set(plot) then begin
		setplot,'z'
		device, set_resolution = [1500,1500]
		!p.background=255
		!p.color=0
		!p.charsize=1.8
		!p.thick=3
		!x.thick=3
		!y.thick=3
	
		smart_plot_detections,arpath+'smart_'+time2file(file2time(fthis))+'.sav',/catalog,position=[ 0.07, 0.05, 0.99, 0.97 ], grid=10
	
;		loadct,0
;		plot_map,mdimap,dran=[-300,300], thick=3,charsize=1.4, charthick=2
;		maskmap=mdimap                     
;		maskmap.data=armask
;		setcolors,/sys
;		plot_map,maskmap,level=.5,/over,color=!green, c_thick=2
;		for k=0,n_elements(arstruct)-1 do begin
;			if strlen(arstruct[k].smid) lt 3 then thisplotid=arstruct[k].smid else $
;				thisplotid=strmid(arstruct[k].smid,4,4)+'.'+strmid(arstruct[k].smid,9,4)+'.'+(str_sep(arstruct[k].smid,'.'))[2]
;		xyouts,(arstruct[k].xpos-512.)*mdimap.dx,(arstruct[k].ypos-512.)*mdimap.dy,thisplotid,/data,color=!blue, charsize=1.2, charthick=3
;		xyouts,(arstruct[k].xpos-512.)*mdimap.dx,(arstruct[k].ypos-512.)*mdimap.dy,thisplotid,/data,color=!white, charsize=1.2, charthick=1
;		endfor
;		;window_capture,file=smart_paths(/plot,/no_calib)+'track_'+time2file(mdimap.time),/jpeg

		zb_plot = tvrd()
		wr_png, plotpath+'smart_'+time2file(file2time(fthis))+'.png', zb_plot
		setplot,'x'
		;wr_png, smart_paths(/plot,/no_calib)+'track_'+time2file(mdimap.time)+'.png', zb_plot
	endif
	
endfor

end
