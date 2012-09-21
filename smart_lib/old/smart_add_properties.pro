pro smart_add_properties, infilelist, nl_prop=nl_prop, extent_prop=extent_prop, fractal_prop=fractal_prop, $
	turbulence_prop=turbulence_prop, noaa_prop=noaa_prop, rotation_prop=rotation_prop, ising_prop=ising_prop, $
	_extra=_extra, use_fits=use_fits, remove_maps=remove_maps
	
filelist=infilelist
pathfits=smart_paths(/fits,/no_cal)

if keyword_set(extent_prop) then begin
	restore,smart_paths(/resmap,/no_calib)+'mdi_rorsun_map.sav'
	rsundeg=asin(rorsun)/!dtor
endif

nfile=n_elements(filelist)
for i=0l,nfile-1l do begin

;thistim=anytim(systim(/utc))

	;spawn,'gunzip -f '+filelist[i]
	;restore,filelist[i];strjoin((str_sep(filelist[i],'.'))[0l:1l],'.')
	thisfile=filelist[i]
	thisfdate=time2file(file2time(thisfile))
	if keyword_set(use_fits) then begin
		mreadfits,pathfits+'smart_mask_'+thisfdate+'.fits.gz',ind,armask
		fits2map,pathfits+'smart_mdimag_'+thisfdate+'.fits.gz',mdimap
	endif
	restore,thisfile

print,thisfdate

	if keyword_set(extent_prop) then begin
	;Do extent stuff for each AR
		extentstr=smart_blanknar(/extentstr)
		extentstr=replicate(extentstr,n_elements(arstruct))
	endif
	
	if keyword_set(rotation_prop) then begin
		rotstr=smart_blanknar(/rotstr)
		rotstr=replicate(rotstr,n_elements(arstruct))
	endif

	if keyword_set(ising_prop) then begin
		;isingstr=smart_blanknar(/isingstr)
		;isingstr=replicate(isingstr,n_elements(arstruct))
		ising_image, is_dummy0, is_dummy1, filelist=thisfile, struct=isingstr, $
			/zerother, /no_output_image, /noascii
		help,isingstr,/str
		save,arstruct,isingstr,file='/Volumes/LaCie/data/smart2/issi_ising/ising_'+thisfdate+'.sav'
		continue
	endif
	
	for j=0l,n_elements(arstruct)-1l do begin
	
		if keyword_set(nl_prop) then begin
		;Do nl stuff for each AR
			thisar=arstruct[j]
			
		if (thisar.type)[0] ne 'M' or (thisar.type)[1] ne 'B' then goto,skipar
			data=mdimap.data
			data[where(armask ne j+1)]=0
			nltime=mdimap.time
			nlid=thisar.id
			datacr=smart_crop_ar(mdimap.data, armask, nlid,/zero);, arstruct=arstrflr[i]
			smart_nlmagic, nlstr, data=datacr, $
				id=nlid, time=nltime, _extra=_extra; plot=plot, png=png, ps=ps, plot=plot, pathplot=pathplot,
		
			thisar.nlstr=nlstr
			arstruct[j]=thisar
		skipar:
		endif
		
		if keyword_set(extent_prop) then begin
		;Do extent stuff for each AR
			thisar=arstruct[j]
			nlid=thisar.id
			data=mdimap.data
			data[where(armask ne j+1)]=0
			thisextstr=smart_arextent(data, rsundeg=rsundeg, dx=mdimap.dx,dy=mdimap.dy)
			;thisar.extstr=thisextstr
			;arstruct[j]=thisar
			extentstr[j]=thisextstr
			thisar.extstr=thisextstr
			arstruct[j]=thisar
		endif
		
		if keyword_set(entropy_prop) then begin
		;Do information entropy stuff for each AR
		
			;use entropy_func
			;crop ar
			;divide by 100 and 1000 and round() and fix()
			;call entropy_func
		
		endif
		
		if keyword_set(rotation_prop) then begin
		;Do rotation stuff for each region
			thisar=arstruct[j]
		
		if (thisar.type)[0] ne 'M' or (thisar.type)[1] ne 'B' then goto,skipar2
			nlid=thisar.id
			data=mdimap.data
			data[where(armask ne j+1)]=0
			thisrotar=smart_rotmagic(data, rsundeg=rsundeg, dx=mdimap.dx,dy=mdimap.dy, time=mdimap.time, map=mdimap, arid=nlid) ;,/plot
			rotstr[j]=thisrotar
		skipar2:
		endif
		
		;Do fractal stuff
			
		;Do turbulence stuff
		
		;Do coronal temperature stuff?
		
		;Do sunspot area and number and such stuff?
	
	endfor

;print,(anytim(systim(/utc))-thistim)/60.

	if keyword_set(noaa_prop) then begin
	;DO NOAA Regions
		;noaastr_daily=smart_blanknar()
		noaatime=mdimap.time
		indate=time2file(noaatime,/date)
		noaastr=smart_rdnar(indate)
		noaastr_daily=noaastr
	endif

if n_elements(EXTENTSTR) ne n_elements(arstruct) then begin
	print,'WTFFFFF!!!'
	help,EXTENTSTR,arstruct
	stop
endif

if keyword_set(remove_maps) then begin
	save,arstruct,rotstr,noaastr_daily,file=filelist[i]
;	if keyword_set(rotation_prop) then save,arstruct,rotstr,noaastr_daily,file=filelist[i] else $;, mdimap, mapdiff, armask ;strjoin((str_sep(filelist[i],'.'))[0l:1l],'.') ;filelist[i]
;		save,arstruct,noaastr_daily,file=filelist[i]
endif else begin
	save,arstruct,MDIMAP,MAPDIFF,ARMASK,rotstr,NOAASTR_DAILY,file=filelist[i],/compress
;	save,arstruct,rotstr,noaastr_daily,EXTENTSTR,MDIMAP,MAPDIFF,ARMASK,file=filelist[i],/compress
;	if keyword_set(rotation_prop) then save,arstruct,rotstr,noaastr_daily,EXTENTSTR,MDIMAP,MAPDIFF,ARMASK,file=filelist[i],/compress else $;, mdimap, mapdiff, armask ;strjoin((str_sep(filelist[i],'.'))[0l:1l],'.') ;filelist[i]
;		save,arstruct,noaastr_daily,EXTENTSTR,MDIMAP,MAPDIFF,ARMASK,file=filelist[i],/compress
endelse

;	spawn,'gzip -f '+strjoin((str_sep(filelist[i],'.'))[0l:1l],'.')

endfor



end