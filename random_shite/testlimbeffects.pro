pro testlimbeffects, psplot=psplot, res1tore=res1tore

;restore cosmap
restore,'~/science/data/restore_maps/mdi_px_area_map.sav'
cosmaplim=cosmap < 1./cos(86.31*!dtor)
	
;restore area error map: dtheta, dmm, dmmsq
restore,'~/science/data/restore_maps/mdi_uncertainty_maps.sav',/verb
	
;restore rorsun
restore,'~/science/data/restore_maps/mdi_rorsun_map.sav',/verb

;Mm pixel area at limb center
mdipixelarea=smart_mdipxarea(/mmsqr);2.0990357; Mm^2

;restore error map, est. error


mreadfits,'~/science/data/mdi_10488/smdi_fd_20031019_2359.fits',index,data

imgsz=size(data)

blank=fltarr(imgsz[1],imgsz[2])

limbmask=blank
wnan=where(finite(data) eq 1)

limbmask[wnan]=1

xyrcoord, imgsz, xcoord, ycoord, rcoord

wcirc=where(rcoord lt 50)

limbmask[wcirc]=2

index2map,index,data,map

map.time='7-jun-2009'
map.data=limbmask

n=32.
hglon=fltarr(n+1)
hglat=fltarr(n+1)
area=fltarr(n+1)
cosarea=fltarr(n+1)
cosarealim=fltarr(n+1)
areaerr=fltarr(n+1)
time=fltarr(n+1)

hglatlon_map, hglonmap,hglatmap, [map.dx,map.dy], imgsz,time=map.time
;hglonmap=hglonmap*limbmask
;hglatmap=hglatmap*limbmask
if (where(finite(hglonmap) ne 1))[0] ne -1 then hglonmap[where(finite(hglonmap) ne 1)]=-10000.
if (where(finite(hglatmap) ne 1))[0] ne -1 then hglatmap[where(finite(hglatmap) ne 1)]=-10000.

data=map.data
data=(data-1.) > 0.
datahg=data
datahg[where(datahg eq 0)]=-10000.
datahg[where(datahg lt 1)]=0
hglatmap=hglatmap*data+datahg
hglonmap=hglonmap*data+datahg
	
area[0]=total(data)
cosarea[0]=total(data*cosmap)
cosarealim[0]=total(data*cosmaplim)
areaerr[0]=total(data*dmmsq)
time[0]=anytim(map.time)
hglon[0]=mean((hglonmap)[where(hglonmap gt -1000.)])
hglat[0]=mean((hglatmap)[where(hglatmap gt -1000.)])

if not keyword_set(res1tore) then begin
	!p.multi=[0,2,1]
	window,0,xs=1000,ys=500
	
	for i=0,n-1 do begin

		map2=drot_map(map,i/4.+.25,/day,/keep_center)
		
if keyword_set(psplot) then setplotenv,/ps,xs=20,ys=10,file='~/science/data/testlimbeffects/rot_compare'+string((i+1.),format='(I03)')+'.eps'
		plot_map,map,dran=[0,2],title='Disk Center'
		plot_map,map2,dran=[0,2],title='Rotate by '+strmid(strtrim(i/4.+.25,2),0,5)+' Days'
if keyword_set(psplot) then closeplotenv
		map2tim=anytim(map.time)+(i/4.+.25)*24.*3600.
		map2time=anytim(map2tim,/vms)
		
		hglatlon_map, hglonmap,hglatmap, [map2.dx,map2.dy], imgsz,time=map2time
		;hglonmap=hglonmap*limbmask
		;hglatmap=hglatmap*limbmask
		if (where(finite(hglonmap) ne 1))[0] ne -1 then hglonmap[where(finite(hglonmap) ne 1)]=-10000.
		if (where(finite(hglatmap) ne 1))[0] ne -1 then hglatmap[where(finite(hglatmap) ne 1)]=-10000.
	
		data2=map2.data
		data2=(data2-1.) > 0.
		datahg=data2
		datahg[where(datahg lt 1)]=-10000.
		if (where(datahg eq 1))[0] ne -1 then datahg[where(datahg eq 1)]=0
		hglatmap=hglatmap*data2+datahg
		hglonmap=hglonmap*data2+datahg
		
		area[i+1]=total(data2)	
		cosarea[i+1]=total(data2*cosmap)
		cosarealim[i+1]=total(data2*cosmaplim)
		areaerr[i+1]=total(data2*dmmsq)
		time[i+1]=map2tim
		if (where(hglonmap gt -1000.))[0] ne -1 then hglon[i+1]=mean((hglonmap)[where(hglonmap gt -1000.)]) else hglon[i+1]=90.
		if (where(hglatmap gt -1000.))[0] ne -1 then hglat[i+1]=mean((hglatmap)[where(hglatmap gt -1000.)]) else hglat[i+1]=90.
		
		window_capture,file='~/science/data/testlimbeffects/rot_compare'+string((i+1.),format='(I03)'),/png
		;if i eq 8 then window_capture,file='~/science/data/testlimbeffects/rot_compare',/png
		
		;wspot=where(map2.data eq 2)
		;if wspot[0] eq -1. then area[i]=0. else area[i]=n_elements(wspot)
	endfor
	
	area=area*mdipixelarea
	cosarea=cosarea*mdipixelarea
	cosarealim=cosarealim*mdipixelarea
	
	save,area,cosarea,cosarealim,areaerr,time,hglon,hglat,map,file='~/science/data/testlimbeffects/test_limb_effects.sav'

endif else restore,'~/science/data/testlimbeffects/test_limb_effects.sav'

;PLOTTING
if keyword_set(psplot) then begin pthick=10 & pchar=2.2 & endif else begin pthick=2 & pchar=2 & endelse

;Plot corrected area

if keyword_set(psplot) then setplotenv,/ps,xs=15,ys=10,file='~/science/data/testlimbeffects/plot_area_w_correction_vs_hglon.eps' else begin
	window,1,xs=700,ys=500
	wset,1
endelse

loadct,0
setcolors,/sys
!p.multi=0
days=(time-min(time))/3600./24.
plot,hglon,area,yr=[0,area[0]*2.],xtit='HG Longitude',ytit='Apparent Area [Mm]',thick=pthick,ps=-4, charsize=pchar
;ploterror,(time-min(time))/3600./24.,area,fltarr(n),areaerr, thick=pthick
oplot,hglon,cosarea,color=!red,line=1, thick=pthick,ps=-4
oplot,hglon,cosarealim,color=!forest, thick=pthick,ps=-4
hline,area[0],linesty=1, thick=pthick
legend,['Area','COS Correct','COS Cor. Limit'],color=[!black,!red,!forest],line=[0,1,0],psym=[-4,-4,-4],thick=[pthick,pthick,pthick], charsize=pchar

if keyword_set(psplot) then closeplotenv else window_capture,file='~/science/data/testlimbeffects/plot_area_w_correction_vs_hglon',/png

;Plot error

if keyword_set(psplot) then setplotenv,/ps,xs=15,ys=10,file='~/science/data/testlimbeffects/plot_area_error.eps' else begin
	window,1,xs=700,ys=500
	wset,1
endelse

loadct,0
setcolors,/sys
!p.multi=0

areaerror=(cosarealim-area[0])/area[0]*100.

plot,hglon,areaerror,yr=[0,60.],xtit='HG Longitude',ytit='% Difference Between Corrected and True Area',thick=pthick,ps=-4, charsize=pchar
;ploterror,(time-min(time))/3600./24.,area,fltarr(n),areaerr, thick=pthick


if keyword_set(psplot) then closeplotenv else window_capture,file='~/science/data/testlimbeffects/plot_area_error',/png

thetaarr=findgen(1000)/999.*!pi/2.
coscorrarr=1./cos(thetaarr)
coscorrarr=coscorrarr[0:998]
thetaarr=thetaarr[0:998]
coscorrlim=coscorrarr < 31.133

!p.multi=0
setplotenv,/ps,xs=15,ys=10,file='~/science/data/testlimbeffects/cosine_factor.eps',/eps
setcolors,/sys
;plot,(rcoord/484.455)[512:*,512],cosmap[512:*,512], charsize=2.2,thick=10,xtit='R/Rsun',ytit='Cosine Correction Factor',/xsty
plot,thetaarr/!dtor,coscorrarr, charsize=2.6,thick=15,xtit='Angle to Line-of-sight',ytit='Cosine Correction Factor',/xsty,/ylog
oplot,thetaarr/!dtor,coscorrarr,color=!black,line=0,thick=15
oplot,thetaarr/!dtor,coscorrlim,color=!red,thick=15
hline,31.133,line=1,color=!red,thick=15
legend,['Correction Factor', 'Corr. Factor Limited'],color=[!black,!red],line=[0,0],thick=[15,15]
closeplotenv

stop














end