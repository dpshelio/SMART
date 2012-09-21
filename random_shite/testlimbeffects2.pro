function circ_proj, map, mask, NEAREST_NEIGHBOR=NEAREST_NEIGHBOR, quintic=quintic
dd=mask*map.data

imgsz=size(dd)
dxdy=[map.dx,map.dy]
xyrcoord,imgsz,xx,yy,rr
hglatlon_map, hglonmap,hglatmap, dxdy, imgsz, time=map.time, /mdi

centall=[total(mask*abs(dd)*xx)/total(mask*abs(dd)),total(mask*abs(dd)*yy)/total(mask*abs(dd))]

hc_lb=[(((centall[0]-100) > 0)-imgsz[1]/2.)*dxdy[0],(((centall[1]-100) > 0)-imgsz[2]/2.)*dxdy[1]]
hc_rt=[(((centall[0]+100) < 1023)-imgsz[1]/2.)*dxdy[0],(((centall[1]+100 < 1023))-imgsz[2]/2.)*dxdy[1]]

hg_lb=conv_a2h(hc_lb,map.time)
hg_rt=conv_a2h(hc_rt,map.time)

;use projection to flat surface to find angles
;;projres=180./(!pi*map.rsun*2./(map.dx)) so pix are same size as unprojected image...
;projres: smart_mdipxarea(/mmppx)/(!pi*6.955d2/2./90.)
projres=.116568465 ;degrees/px
;range=[hglon1,hglon2,hglat1,hglat2]

print,'PROJECTING...'
arproj=wcspixproj(dd, hglonmap, hglatmap, resolution=projres, /hg_coord,range=[hg_lb[0],hg_rt[0],hg_lb[1],hg_rt[1]], fill=0, $
	NEAREST_NEIGHBOR=NEAREST_NEIGHBOR, quintic=quintic)

return,arproj

end

;--------------------------------------------------------------------->

pro testlimbeffects2, psplot=psplot, res1tore=res1tore

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


;mreadfits,'~/science/data/mdi_10488/smdi_fd_20031019_2359.fits',index,data
mreadfits,'~/science/data/mdi_96/smdi_fd_20010831_013530.fits.gz',index,data

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
hglonw=fltarr(2,n+1)
area=fltarr(n+1)
cosarea=fltarr(n+1)
cosarealim=fltarr(n+1)
areaerr=fltarr(n+1)
time=fltarr(n+1)
areawarp=fltarr(n+1)
areaquin=fltarr(n+1)
;areanear=fltarr(n+1)

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
hglonw[*,0]=[min((hglonmap)[where(hglonmap gt -1000.)]), max((hglonmap)[where(hglonmap gt -1000.)])]

projres=.116568465 ;deg/px for conservation of px size

if not keyword_set(res1tore) then begin

;	mapw=map
;	mapw.data=data
	;arnear=round(circ_proj(mapw, data, /NEAREST_NEIGHBOR))
;	arwarp=round(circ_proj(mapw, data))
;	arquin=round(circ_proj(mapw, data, /quintic))

	;areanear[0]=total(arnear)
;	areawarp[0]=total(arwarp)
;	areaquin[0]=total(arquin)

	!p.multi=[0,2,1]
	window,0,xs=1000,ys=500
	
	for i=0,n-1 do begin

		map2=drot_map(map,i/4.+.25,/day,/keep_center)
		
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
		if (where(hglatmap gt -1000.))[0] ne -1 then hglonw[*,i+1]=[min((hglonmap)[where(hglonmap gt -1000.)]), max((hglonmap)[where(hglonmap gt -1000.)])]
		
;		mapw=map2
;		mapw.data=data2
		;arnear=round(circ_proj(mapw, data2, /NEAREST_NEIGHBOR))
;		arwarp=round(circ_proj(mapw, data2))
;		arquin=round(circ_proj(mapw, data2, /quintic))

		;areanear[i+1]=total(arnear)
;		areawarp[i+1]=total(arwarp)
;		areaquin[i+1]=total(arquin)
		
	;PLOTTING---------------------------------->
		if keyword_set(psplot) then setplotenv,/ps,xs=20,ys=20,file='~/science/data/testlimbeffects2/noproj_rot_compare'+string((i+1.),format='(I03)')+'.eps'
		plot_map,map,dran=[0,2],title='Disk Center', grid=10
		xyouts,.15,.15,'Area = '+string(area[0],form='(E1.3)'),/norm
		plot_map,map2,dran=[0,2],title='Rotate by '+strmid(strtrim(i/4.+.25,2),0,5)+' Days', grid=10
		xyouts,.65,.25,'Area = '+string(area[i],form='(E1.3)'),/norm
		xyouts,.65,.15,'Corr = '+string(cosarealim[i],form='(E1.3)'),/norm
;		plot_image,arwarp,xtit='Triangulate',scale=projres,origin=[0,0]
;		hline,[10,20,30],color=150,line=1,thick=3
;		vline,[10,20,30],color=150,line=1,thick=3
;		plot_image,arquin,xtit='Smooth Quintic',scale=projres,origin=[0,0]
;		hline,[10,20,30],color=150,line=1,thick=3
;		vline,[10,20,30],color=150,line=1,thick=3
		if keyword_set(psplot) then closeplotenv
		spawn,'convert ~/science/data/testlimbeffects2/noproj_rot_compare'+string((i+1.),format='(I03)')+'.eps ~/science/data/testlimbeffects2/noproj_rot_compare'+string((i+1.),format='(I03)')+'_eps.png'
		plot_map,map,dran=[0,2],title='Disk Center', grid=10
		xyouts,.07,.1,'Area = '+strtrim(string(area[0],form='(E13.2)'),2),/norm
		plot_map,map2,dran=[0,2],title='Rotate by '+strmid(strtrim(i/4.+.25,2),0,5)+' Days', grid=10
		xyouts,.57,.15,'Area = '+strtrim(string(area[i],form='(E13.2)'),2),/norm
		xyouts,.57,.1,'Corr = '+strtrim(string(cosarealim[i],form='(E13.2)'),2),/norm
;		plot_image,arwarp,xtit='Triangulate',scale=projres,origin=[0,0]
;		hline,[10,20,30],color=150,line=1
;		vline,[10,20,30],color=150,line=1
;		plot_image,arquin,xtit='Smooth Quintic',scale=projres,origin=[0,0]
;		hline,[10,20,30],color=150,line=1
;		vline,[10,20,30],color=150,line=1
		
		window_capture,file='~/science/data/testlimbeffects2/noproj_rot_compare'+string((i+1.),format='(I03)'),/png
		;if i eq 8 then window_capture,file='~/science/data/testlimbeffects2/noproj_rot_compare',/png
	;------------------------------------------>
	
		;wspot=where(map2.data eq 2)
		;if wspot[0] eq -1. then area[i]=0. else area[i]=n_elements(wspot)
	endfor

stop
	
	area=area*mdipixelarea
	cosarea=cosarea*mdipixelarea
	cosarealim=cosarealim*mdipixelarea
	areawarp=areawarp*mdipixelarea
	areaquin=areaquin*mdipixelarea

	save,area,cosarea,cosarealim,areaerr,time,hglon,hglat,hglonw,map,areawarp,areaquin,file='~/science/data/testlimbeffects2/test_limb_effects.sav'

endif else restore,'~/science/data/testlimbeffects2/test_limb_effects.sav'

;PLOTTING
if keyword_set(psplot) then begin pthick=10 & pchar=2.2 & endif else begin pthick=2 & pchar=2 & endelse

;Plot correction factors

if keyword_set(psplot) then setplotenv,/ps,xs=15,ys=10,file='~/science/data/testlimbeffects2/plot_correction_factor.eps' else begin
	window,1,xs=700,ys=500
	wset,1
endelse
loadct,0
setcolors,/sys
!p.multi=0
ror=rorsun[511:*,511]
ror[where(ror eq 0)]=1
plot,ror,cosmap[511:*,511],color=0, ytit='Correction Factor', xtit='R/'+textoidl('R_{Sun}'),thick=15
oplot,ror,cosmaplim[511:*,511],color=!red,thick=15
hline,1./cos(86.31*!dtor),lines=1,color=!red,thick=10
legend,['Corr. Factor','Corr. Limited'],line=[0,0],color=[!black,!red],thick=[15,15], charsize=pchar,outline=0
if keyword_set(psplot) then begin
	closeplotenv 
	eps2png,'~/science/data/testlimbeffects2/plot_correction_factor.eps','~/science/data/testlimbeffects2/plot_correction_factor_eps.png'
endif else window_capture,file='~/science/data/testlimbeffects2/plot_correction_factor',/png


;Plot corrected area

if keyword_set(psplot) then setplotenv,/ps,xs=15,ys=10,file='~/science/data/testlimbeffects2/plot_area_w_correction_vs_hglon.eps' else begin
	window,1,xs=700,ys=500
	wset,1
endelse

loadct,0
setcolors,/sys
!p.multi=0
days=(time-min(time))/3600./24.
plot,hglon,area,yr=[0,2d4],xtit='HG Longitude',ytit='Apparent Area [Mm'+textoidl('^2')+']',thick=pthick,ps=-4, charsize=pchar,color=0
;ploterror,(time-min(time))/3600./24.,area,fltarr(n),areaerr, thick=pthick
oplot,hglon,cosarea,color=!red,line=1, thick=pthick,ps=-4
oplot,hglon,cosarealim,color=!forest, thick=pthick,ps=-4
hline,area[0],linesty=1, thick=pthick,color=0
legend,['Area','COS Correct','COS Cor. Limit'],color=[!black,!red,!forest],line=[0,1,0],psym=[-4,-4,-4],thick=[pthick,pthick,pthick], charsize=pchar,outline=0

if keyword_set(psplot) then begin
	closeplotenv 
	eps2png,'~/science/data/testlimbeffects2/plot_area_w_correction_vs_hglon.eps','~/science/data/testlimbeffects2/plot_area_w_correction_vs_hglon_eps.png'
endif else window_capture,file='~/science/data/testlimbeffects2/plot_area_w_correction_vs_hglon',/png

stop

;Plot error

if keyword_set(psplot) then setplotenv,/ps,xs=15,ys=10,file='~/science/data/testlimbeffects2/plot_area_error.eps' else begin
	window,1,xs=700,ys=500
	wset,1
endelse

loadct,0
setcolors,/sys
!p.multi=0

areaerror=abs(cosarealim-cosarealim[0])/cosarealim[0]*100.

plot,hglon,areaerror,yrange=[-2,2],xtit='HG Longitude',ytit='% Difference Between Corrected and True Area',thick=pthick,ps=-4, charsize=pchar
;ploterror,(time-min(time))/3600./24.,area,fltarr(n),areaerr, thick=pthick

if keyword_set(psplot) then begin
	closeplotenv 
	eps2png,'~/science/data/testlimbeffects2/plot_area_error.eps','~/science/data/testlimbeffects2/plot_area_error_eps.png'
endif else window_capture,file='~/science/data/testlimbeffects2/plot_area_error',/png

stop

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