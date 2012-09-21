pro smart_mdi_cycle23, mdiflxemerge=mdiflxemerge, igramspot=igramspot, rmbad=rmbad

mdip='~/science/data/mdi_cycle23/'
igramp='~/science/data/mdi_igram/'
igramplot='~/science/plots/cycle_23/igrams/'
savp='~/science/data/cycle23_sav/'

;MDI FLUX EMERGENCE------------------------------------------>
if keyword_set(mdiflxemerge) then begin

	filelist=file_search(mdip,'smdi*fits')
	nfile=n_elements(filelist)
	
	;initialize flux emergence map
	;flxemergemap=fltarr(8030,16) ;(4015 days*2 12hr sections) by (16 latitudinal sections -80 -> 80 in sections of 10 deg)
	
	flxwlsg=fltarr(8030)
	flxtot=fltarr(8030)
	flxpos=fltarr(8030)
	flxneg=fltarr(8030)
	flxemerge=fltarr(8030)
	tarr=fltarr(8030)
	
	;window,0
	
	for i=1,nfile-1 do begin
	
		fits2map,filelist[i-1],map1
		fits2map,filelist[i],map2
	
		anytim1=anytim(map1.time)
		anytim2=anytim(map2.time)
		map1=drot_map(map1,anytim2-anytim1,/seconds)
	
		map1.data[where(finite(map1.data) ne 1)]=0
		map2.data[where(finite(map2.data) ne 1)]=0
		
		;should also maskout everything beyond 80 deg in a circle
		
		flxdiff=abs(smooth(map2.data,[5,5]))-abs(smooth(map1.data,[5,5]))
		;flxdiff[where(finite(flxdiff) ne 1)]=0
		flxemerge[i-1]=total(flxdiff)
		tarr[i-1]=anytim(map2.time)
		
	;	if n_elements(tarr) gt 3 then plot,tarr[0:i-1],flxemerge[0:i-1],/xstyle,/ystyle,xtit='anytim',ytit='flxemerge'
	;	print,tarr[i-1],flxemerge[i-1]
	
	endfor
	
	save,tarr,flxemerge,file=savp+'mdi_fd_12hrflxemerge_cycle23.sav'

endif

;IGRAM SUN SPOT CYCLE------------------------------------------>
if keyword_set(igramspot) then begin

	filelist=file_search(igramp,'I*fits*')
	ftimlist=strmid(filelist,41,8)
	;filelist=filelist[uniq(ftimlist)]
	
	nfile=n_elements(filelist)
	
	fdates=datearr(19970101, 20090101)
	fdates=fdates[uniq(fdates)]
	ndates=n_elements(fdates)
	
	;List daily files on BEAUTY server.  
	fbeauty=sock_find('http://beauty.nascom.nasa.gov/arm/mdi_int/','*.fits')
	tbeauty=strmid(fbeauty,51,8)
	
	;initialize flux emergence map
	;flxemergemap=fltarr(8030,16) ;(4015 days*2 12hr sections) by (16 latitudinal sections -80 -> 80 in sections of 10 deg)
	
;	flxemerge=fltarr(8030)
;	tarr=fltarr(8030)
	
	window,1,xs=1000,ys=500
	window,0,xs=1000,ys=500
	!p.multi=[0,2,1]

	mreadfits,filelist[0],index,testdata
	
	;Generate coordinate maps.
	imgsz=size(testdata)
	xcoord=rot(congrid(transpose(findgen(imgsz[1])),imgsz[1],imgsz[2]),90)
	ycoord=rot(xcoord,-90)
	rcoord=sqrt((xcoord-imgsz[1]/2.)^2.+(ycoord-imgsz[2]/2.)^2)
	
	;Get rid of edge pixels
	rthresh=.9
	limbthresh=(index.r_sun)*.9/(imgsz[1]/2.)
	wbad=where(rcoord gt imgsz[1]/2.*limbthresh)
	limbmask=fltarr(imgsz[1],imgsz[2])+1
	limbmask[wbad]=0
	
	;Cosine area correction map
	cosmap=smart_px_area_map(rcoord, limbmask, fract90=rthresh)
	
	;print,'CROPPED DISK AT '+strtrim(cos((1.-rthresh)*!pi)*90.,2)+' HGLON (all the way around)'
	
	numbrapx=0.
	npenumbrapx=0.
	tanytim=0.
	meanigram=0.
	nsunspots=0.
	
	;TEMP
	;	for i=0,nfile-1 do begin
	for i=0,ndates-1 do begin
		print, 'ANALYZING: '+strtrim(fdates[i])
		
		mdibeauty=0
		mdisdd=0
		
		wthisdate=where(ftimlist eq fdates[i])
		if wthisdate[0] eq -1 then begin
			wbeauty=where(tbeauty eq fdates[i])
			if wbeauty[0] eq -1 then goto,gotoskipfile
			locbeauty=(reverse(str_sep(fbeauty[wbeauty],'/')))[0]
			if file_search(igramp,locbeauty) eq '' then begin
				sock_copy,fbeauty[wbeauty]
				spawn,'mv '+locbeauty+' '+igramp
			endif		
			mreadfits,igramp+locbeauty,index,data
			
			mdibeauty=1
		endif else begin
			loclist=filelist[wthisdate]
			
			mreadfits,loclist,indexs
			means=indexs.D_MEAN0
			wbestmean=(where(abs(means-10100.) eq min(abs(means-10100.))))[0]
			mreadfits,loclist[wbestmean],index,data
			
			mdisdd=1
		endelse
		
		;mreadfits,filelist[i],index,data
		
		tanytim=[tanytim,anytim(index.date_obs)]
		
		;CENTER DATA
		data=shift(data,-1.*round(index.xcen),-1.*round(index.ycen))
		
		;CALIBRATION
		if mdisdd eq 1 then begin
			data[where(data eq index.blank)]=0 
			mdi_calib, index, data, odata
			data=odata
		endif else begin
			data[where(finite(data) ne 1)]=0 
		endelse
		
		dataclip=data*limbmask
		
		;Calculate mean.
		thismean=mean(dataclip[where(dataclip gt 0)])
		meanigram=[meanigram,thismean]
		
		
		if thismean lt 6d3 then begin
			flatfudge=smart_fudge_flatfield(data, limbmask)
			dataclip=dataclip*flatfudge
			
			;Re-calculate mean.
			thismean=mean(dataclip[where(dataclip gt 0)])
			meanigram=[meanigram,thismean]
		endif
		
		;REMOVE BAD DATA
		;badmean=5d3
		;if thismean lt 
		
		penthresh=.94*thismean
		umthresh=.7*thismean
		wpen=where(dataclip gt umthresh and dataclip lt penthresh)
		wum=where(dataclip le umthresh and dataclip gt 0)   
		;wpen=where(dataclip gt 6.5d3 and dataclip lt 1.185d4)
		;wum=where(dataclip le 6.5d3 and dataclip gt 0)      
		
		datacont=fltarr(imgsz[1],imgsz[2])+3
		datacont=datacont*limbmask
		if wpen[0] ne -1 then datacont[wpen]=2
		if wum[0] ne -1 then datacont[wum]=1
		
		;Mask out spots of 1 pixel.
		contdata=datacont
		contdata[where(contdata eq 0)]=3
		contour,contdata,findgen(imgsz[1]),findgen(imgsz[2]),level=2.5,path_info=path_info,/path_data_coords,path_xy=path_xy
		
		if n_elements(path_info) gt 0 then begin 
			vectthresh=10
			areathresh=10
			spotthresh=100
			
			;Get rid of noise pixels.
			;pixmask=fltarr(imgsz[1],imgsz[2])
			infos=path_info[where(path_info.n le vectthresh)]
			ninfos=n_elements(infos)
			
			for j=0,ninfos-1 do begin
				info1=infos[j]
				xx=path_xy[0,info1.offset:info1.offset+info1.n-1]
				yy=path_xy[1,info1.offset:info1.offset+info1.n-1]
				poly1=polyfillv(xx,yy,imgsz[1],imgsz[2])
				;if n_elements(poly1) le 1 then pixmask[poly1]=1
				if n_elements(poly1) le areathresh then datacont[reform(path_xy[0,*]+path_xy[1,*]*imgsz[1])]=3
			endfor
			
			;wnoise=where(pixmask eq 1)
			;if wnoise[0] ne -1 then datacont[wnoise]=3
			datacont=datacont*limbmask
	
			wpen=where(datacont eq 2)
			wum=where(datacont eq 1)
			
			;Count sun spots.
			thisnsunspots=0.
			spotinfos=path_info
			for j=0,n_elements(spotinfos)-1 do begin
				info1=spotinfos[j]
				xx=path_xy[0,info1.offset:info1.offset+info1.n-1]
				yy=path_xy[1,info1.offset:info1.offset+info1.n-1]
				poly1=polyfillv(xx,yy,imgsz[1],imgsz[2])
				;if n_elements(poly1) le 1 then pixmask[poly1]=1
				if n_elements(poly1) ge spotthresh then thisnsunspots=thisnsunspots+1.
			endfor
			
		endif else thisnsunspots=0.
		
		;Create masks for umbra and penumbra.
		penmask=fltarr(imgsz[1],imgsz[2])
		ummask=fltarr(imgsz[1],imgsz[2])
		if wpen[0] ne -1 then penmask[wpen]=1
		if wum[0] ne -1 then ummask[wum]=1
		
		;Do area correction
		penmask=penmask/cosmap
		ummask=ummask/cosmap
		
		thispenpx=total(penmask)
		thisumpx=total(ummask)
		numbrapx=[numbrapx,thisumpx]
		npenumbrapx=[npenumbrapx,thispenpx]
		nsunspots=[nsunspots,thisnsunspots]
		
		;PLOT IMAGES
		if i mod 10 eq 0 then begin
		wset,0
		!p.multi=[0,2,1]
		loadct,1
		plot_image,data*limbmask,tit='MDI Intensitygram '+anytim(file2time(filelist[i]),/vms)
		window_capture,file=igramplot+'mdi_igram_'+time2file(file2time(filelist[i]),/date),/png
		loadct,5
		plot_image,datacont,tit='Contoured Umbra and Penumbra '+anytim(file2time(filelist[i]),/vms)
		window_capture,file=igramplot+'mdi_igram_'+time2file(file2time(filelist[i]),/date),/png
		endif
		
		wset,1
		!p.multi=[0,1,2]
		if i gt 4 then begin
		setcolors,/sys
		plot,(tanytim[1:*]-tanytim[1])/(3600.*24.*365.),numbrapx[1:*],/ylog
		oplot,(tanytim[1:*]-tanytim[1])/(3600.*24.*365.),npenumbrapx[1:*],color=!yellow
		oplot,(tanytim[1:*]-tanytim[1])/(3600.*24.*365.),nsunspots[1:*],color=!red
		plot,(tanytim[1:*]-tanytim[1])/(3600.*24.*365.),meanigram[1:*],/ylog
		endif
		
		;CALCULATE HG MAPS
		;dxdy=[map2.dx,map2.dy]
		;hglatlon_map, hglon,hglat, dxdy, imgsz, offlimb,time=time

;If no file for this day then skip...
gotoskipfile:
	
	endfor
	
	tanytim=tanytim[1:*]
	numbrapx=numbrapx[1:*]
	npenumbrapx=npenumbrapx[1:*]
	meanigram=meanigram[1:*]
	save,tanytim,numbrapx,npenumbrapx,meanigram,nsunspots,file=savp+'igram_sunspot_cycle.sav'
	stop
	
	
endif



stop
end