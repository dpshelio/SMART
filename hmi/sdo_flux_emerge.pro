pro sdo_read_data, file, map, mapscl, hmi=hmi, wave=wave, xrange=xrange, yrange=yrange, ref_map=ref_map

	mreadfits, file, ind, dat
	
	index2map, ind, dat, map
	
	if keyword_set(hmi) then begin
		map.data=rot(map.data,-map.roll_angle)
		map.roll_angle=0
		
		sub_map,map,submap,ref_map=ref_map, xrange=xrange, yrange=yrange
		map=submap
		mapscl=map
		datscl=mapscl.data > (-500) < 500
		mapscl.data=datscl		
	endif else begin
		mapscl=map
		datscl=aia_intscale(mapscl.data,exp=mapscl.dur,wave=wave)
		mapscl.data=datscl	
	endelse

end

;-------------------------------------------------------------->

function sdo_roi, map, roimap, magnetogram=magnetogram, continuum=continuum, corona=corona, mapcos=mapcos, click=click, tim0=tim0

;radius to define roi
rasec=50
xyrcoord,size(map.data),xx,yy,rr
w0=where(rr*map.dx gt rasec)
w1=where(rr*map.dx le rasec)
rr[w0]=0 & rr[w1]=1
rr=shift(rr,-1.*(map.xc-click[0])/map.dx,-1.*(map.yc-click[1])/map.dy)
maprr=map & maprr.data=rr

;starting time/ position in asec
tinit=tim0 ;anytim(time0)
posinit=click ;x,y
posinithg=conv_a2h(posinit) ;lon,lat

;diff rot position to current time
dtim=anytim(map.time)-tinit
dlon=diff_rot(dtim/3600./24.,posinithg[1])
thislon=posinithg[0]+dlon
thisposhg=[thislon,posinithg[1]]
thispos=conv_h2a(thisposhg)
dpx=[thispos[0]-posinit[0],thispos[1]-posinit[1]]/map.dx ;x,y
maprr.data=shift(maprr.data,dpx[0],dpx[1])
roimap=maprr

;hmi area weight
if keyword_set(magnetogram) then begin
	sub_map,mapcos,cosmap,ref_map=map
	areamap=cosmap & areamap.data=cosmap.data*maprr.data*smart_hmipxarea(/cmsqppx)
	flux=total(abs(map.data)*cosmap.data*areamap.data)
endif else begin
;do counts or dns /s
	sub_map,mapcos,cosmap,ref_map=map
	imgsz=size(map.data)
	mask=congrid(maprr.data,imgsz[1],imgsz[2])
	if keyword_set(continuum) then flux=total(mask*cosmap*map.data)/map.dur $
		else flux=total(mask*map.data)/map.dur

endelse

return,flux

end

;-------------------------------------------------------------->

pro sdo_plotroi, roimap
	
	loadct,0
	!p.thick=2
	plot_map,roimap,level=.5,color=255,/over
	!p.linestyle=2
	plot_map,roimap,level=.5,color=0,/over
	!p.thick=''
	!p.linestyle=''
	
end

;-------------------------------------------------------------->

pro sdo_flux_emerge,restoreclick=restoreclick, restoremovie=restoremovie

root='/Volumes/IOMEGA HDD/data/sdo/ar_11105/'
;mapcos, mapnorm
restore,'/Volumes/IOMEGA HDD/data/sdo/restore_hmiarea.sav'

pathaia=root+'aia/'
pathhmi=root+'hmi/'
;pathhmi='/Volumes/IOMEGA HDD/data/sdo/sdohmi_test_20100902/'
pathmovie=root+'movie/'

files171=file_search(pathaia+'*171_.fts')
files94=file_search(pathaia+'*94_.fts')
files304=file_search(pathaia+'*304_.fts')
files4500=file_search(pathaia+'*4500_.fts')
files1700=file_search(pathaia+'*1700_.fts')

fileshmi=file_search(pathhmi+'*magnetogram*')

tims171=anytim(file2time(files171))
tims94=anytim(file2time(files94))
tims4500=anytim(file2time(files4500))

;find hmi file times
hmifpos0=strpos(fileshmi[0],'m_45s')
hmiyyyy=strmid(fileshmi,hmifpos0+6,4)
hmimo=strmid(fileshmi,hmifpos0+6+5,2)
hmidd=strmid(fileshmi,hmifpos0+6+5+3,2)
hmihr=strmid(fileshmi,hmifpos0+6+5+3+3,2)
hmimi=strmid(fileshmi,hmifpos0+6+5+3+3+3,2)
hmiss=strmid(fileshmi,hmifpos0+6+5+3+3+3+3,2)
hmitims=anytim(file2time(hmiyyyy+hmimo+hmidd+'_'+hmihr+hmimi+hmiss))

timaia0=tims171[0] ;anytim(file2time(files171[0]))
sdo_read_data, files171[0], ref_map, ref_mapscl, wave=171

fluxhmi=fltarr(n_elements(hmitims))
flux171=fltarr(n_elements(tims171))
flux4500=fltarr(n_elements(tims4500))
flux94=fltarr(n_elements(tims94))

if not keyword_set(restoremovie) then begin
window,xs=800,ys=900
nhmi=n_elements(fileshmi)
for i=0,nhmi-1 do begin
	thistim=hmitims[i] ;anytim(file2time(fileshmi[i]))
	sdo_read_data, fileshmi[i], hmimap, hmimapscl, /hmi, ref_map=ref_map
	;!p.multi=[0,1,2]
	loadct,0

;click to find AR position
	if i eq 0 then begin
		if not keyword_set(restoreclick) then begin
			plot_map,hmimapscl
			cursor,clickx,clicky,3,/data
			erase
			save,clickx,clicky,file=root+'ar11105_click.sav'
		endif else restore,root+'ar11105_click.sav'
		print,'cursor',clickx,clicky
	endif

	plot_map,hmimapscl,grid=10,/noerase,position=[.0,.55,.49937,.95] ;[.1,.5,.661791,.95]
	
	;hmiflux
	fluxhmi[i]=sdo_roi(hmimap,hmiroimap, /magnetogram, mapcos=mapcos, click=[clickx,clicky], tim0=hmitims[0])
	sdo_plotroi,hmiroimap
	
	if timaia0 le thistim then begin
		w94best=where(abs(hmitims-tims94) eq min(abs(hmitims-tims94)))
		w4500best=where(abs(hmitims-tims4500) eq min(abs(hmitims-tims4500)))
		w171best=where(abs(hmitims-tims171) eq min(abs(hmitims-tims171)))
		sdo_read_data, files94[w94best], map94, mapscl94, wave=94
		sdo_read_data, files4500[w4500best], map4500, mapscl4500, wave=4500
		sdo_read_data, files171[w171best], map171, mapscl171, wave=171
	;	!p.multi=[3,2,2]	
		aia_lct,rr,gg,bb,wave=94
		tvlct,rr,gg,bb
		plot_map,mapscl94,grid=10,position=[.0,.05,.49937,.45],/noerase
		sdo_plotroi,hmiroimap
		
	;	!p.multi=[4,2,2]	
		aia_lct,rr,gg,bb,wave=4500
		tvlct,rr,gg,bb
		plot_map,mapscl4500,grid=10,position=[.50063,.05,1,.45],yticknames=strarr(10)+' ',ytit='',/noerase
		sdo_plotroi,hmiroimap
		
	;	!p.multi=[4,2,2]	
		aia_lct,rr,gg,bb,wave=171
		tvlct,rr,gg,bb
		plot_map,mapscl171,grid=10,position=[.50063,.55,1,.95],yticknames=strarr(10)+' ',ytit='',/noerase
		sdo_plotroi,hmiroimap
		
	endif
	
	window_capture,file=pathmovie+'hmi_'+string(i,form='(I05)'),/png
	erase
endfor
save,hmitims,fluxhmi,file=root+'ar_flux_time.sav'
endif else restore,root+'ar_flux_time.sav'

;find coronal counts/s
restore,root+'ar11105_click.sav'
for i=0,n_elements(flux171)-1 do begin
	sdo_read_data, files171[i], map171, wave=171
	flux171[i]=sdo_roi(map171, /corona, mapcos=mapcos, click=[clickx,clicky], tim0=tims171[0])
endfor
for i=0,n_elements(flux94)-1 do begin
	sdo_read_data, files94[i], map94, wave=94
	flux94[i]=sdo_roi(map94, /corona, mapcos=mapcos, click=[clickx,clicky], tim0=tims94[0])
endfor

;find continuum counts/s
for i=0,n_elements(flux4500)-1 do begin
	sdo_read_data, files4500[i], map4500, wave=4500
	flux4500[i]=sdo_roi(map4500, /continuum, mapcos=mapcos, click=[clickx,clicky], tim0=tims4500[0])
endfor

stop

save,hmitims,fluxhmi,tims171,flux171,tims94,flux94,tims4500,flux4500,file=root+'ar_flux_time.sav'

stop

;plot fluxes
!p.multi=[0,1,2]
plot,(hmitims-anytim('1-sep-2010 00:00'))/3600./24.,fluxhmi,xtick_get=xtickvals,xr=[.5,2],/xsty
plot,(tims171-anytim('1-sep-2010 00:00'))/3600./24,flux171,xr=[.5,2],/xsty
!p.multi=[1,1,2]
plot,(tims94-anytim('1-sep-2010 00:00'))/3600./24.,flux94,xr=[.5,2],/xsty,/noerase,color=!red
plot,(tims94-anytim('1-sep-2010 00:00'))/3600./24.,flux94,xr=[.5,2],/xsty,/noerase,/nodata
!p.multi=[1,1,2]
plot,(tims4500-anytim('1-sep-2010 00:00'))/3600./24.,flux4500,xr=[.5,2],/xsty,/noerase,color=!orange
plot,(tims4500-anytim('1-sep-2010 00:00'))/3600./24.,flux4500,xr=[.5,2],/xsty,/noerase,/nodata








end