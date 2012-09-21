pro smart_compare_noaa, res1tore=res1tore

;smart props for ea. day
;N groups (regions of ea. type)
;avg B for all & ea. type
;tot flux for ea. type

;noaa regions
;N ars
;avg N of spots for ea.
;avg area of regions
;tot. area of spots

;arstr_arr
;restore,'~/science/data/smart_eventcat/sav/arstr_arr_1pday.sav',/verb

;Smart AR=multipolar,big

smartarr={nar:-1.,nbig:-1.,nsmall:-1.,nall:-1.,avgbar:-1.,avgbbig:-1.,avgbsmall:-1.,avgball:-1.,totfluxar:-1.,totfluxbig:-1.,totfluxsmall:-1.,totfluxall:-1.,avgareaar:-1.,avgareabig:-1.,avgareasmall:-1.,avgareaall:-1.,totareaar:-1.,totareabig:-1.,totareasmall:-1.,totareaall:-1.}

noaaarr={nar:-1.,nspotavg:-1.,avgarea:-1.,totarea:-1.}

filelist=''

arstrarr=smart_blanknar(/arstr)
noaastrarr=smart_blanknar()

;save,arstrarr,noaastrarr,smartarr,noaaarr,file='~/science/papers/active_regions_1/review/smart_compare_noaa_str.sav'

datearray=datearr('19970101','20081201')
ndate=n_elements(datearray)

print,ndate

if not keyword_set(res1tore) then begin

	for j=0,ndate-1 do begin
		i=datearray[j]
		
		file=(file_search(smart_paths(/sav,/no_cal)+'smart_'+strtrim(i,2)+'*'))[0]
		if file ne '' then begin 
		
			filelist=[filelist,file]
			
			if (reverse(str_sep(file,'.')))[0] eq 'gz' then begin
				spawn,'gunzip -f '+file
				restore,strjoin((str_sep(file,'.'))[0:n_elements(str_sep(file,'.'))-2],'.')
				spawn,'gzip -f '+strjoin((str_sep(file,'.'))[0:n_elements(str_sep(file,'.'))-2],'.')
			endif else restore,file
			
			arstrarr=[arstrarr,arstruct]
		
		endif
		
		noaastr=smart_rdnar(strtrim(i,2),err=err)
		if err eq '' then begin
			noaastrarr=[noaastrarr,noaastr]
		endif
	
	endfor
	
	print,'DONE!!! now save the arrays!'
	stop
	
	noaastrarr=noaastrarr[1:*]
	arstrarr=arstrarr[1:*]
	
	save,arstrarr,noaastrarr,file='~/science/papers/active_regions_1/review/smart_compare_noaa_str.sav'

endif else restore,'~/science/papers/active_regions_1/review/smart_compare_noaa_str.sav',/verb

noaaarr=replicate(noaaarr,ndate)
smartarr=replicate(smartarr,ndate)

artimarr=anytim(arstrarr.time,/date)

for k=0,ndate-1 do begin

	i=datearray[k]

	thisnoaa=noaaarr[k]
	thissmart=smartarr[k]

;	smartarr={nar:0,nbig:0.,nsmall:0.,nall:0.,avgbar:0.,avgbbig:0.,avgbsmall:0.,avgball:0.,totfluxar:0.,totfluxbig:0.,totfluxsmall:0.,totfluxall:0.,avgareaar:0.,avgareabig:0.,avgareasmall:0.,avgareaall:0.,totareaar:0.,totareabig:0.,totareasmall:0.,totareaall:0.}
;	noaaarr={nar:0.,nspotavg:0.,avgarea:0.,totarea:0.}

stop

	wnoaatoday=where(noaastrarr.day eq (anytim(file2time(i))/(3600.*24.)))
	if wnoaatoday[0] ne -1 then begin

	endif
	
	wsmarttoday=where(artimarr eq anytim(file2time(i)))
	if wsmarttoday[0] ne -1 then begin
		thesear=arstrarr[wsmarttoday]
		war=where(strjoin((thesear.type)[0:1,*],'') eq 'MB')
		wbig=where((thesear.type)[1,*] eq 'B')
		wsmall=where((thesear.type)[1,*] eq 'S')
		wall=where(thesear.id ne 0)
		
		if war[0] eq -1 then begin
			smartarr.nar=0.
			smartarr.avgbar=0.
			smartarr.totfluxar=0.
			smartarr.avgareaar=0.
			smartarr.totareaar=0.
		endif else begin
			smartarr.nar=n_elements(war)
			smartarr.avgbar=mean(thesear[war].bflux/thesear[war].area) ;in gauss
			smartarr.totfluxar=total(thesear[war].bflux)*1d16 ;in Mx
			smartarr.avgareaar=mean(thesear[war].area) ;in Mm^2
			smartarr.totareaar=total(thesear[war].area) ;in Mm^2
		endelse
		if wbig[0] eq -1 then begin
			smartarr.nbig=0
			smartarr.avgbbig=0
		endif else begin
			smartarr.nbig=n_elements(wbig)
		endelse
		if wsmall[0] eq -1 then begin
			smartarr.nsmall=0
			smartarr.avgbsmall=0
		endif else begin
			smartarr.nsmall=n_elements(wsmall)
		endelse
		if wall[0] eq -1 then begin
			smartarr.nall=0
			smartarr.avgball=0
		endif else begin
			smartarr.nall=n_elements(wall)
		endelse

	endif
	
	
	
	
	stop



endfor




end