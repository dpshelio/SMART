;Create cosine correction map for pixel areas. Multiply an 2D array of pixel areas by 
;this map to weight them. Pixels near limb will be weighted higher as we see less of their true area.

;RCOORD = radial coordinates from disk center in pixels
;LIMBMASK = 1 for disk pixels, 0 for off disk (must extend to edge of Rsun otherwise cos corr will be wrong.)
;FRACT90 = the fraction of 90 heliographic degrees to create the map for [.9 -> .1] 

function smart_px_area_map, coscor=coscor, surfcor=surfcor, savmaps=savmaps, res1tore=res1tore;, rcoord, limbmask, fract90=fract90

; TODO: Choose which approach to take.
; From smart_hek
;restore,smart_paths(/resmap)+'mdi_loscor_map.sav'
;return,losmap



if not keyword_set(res1tore) then begin

	;Radius of sun in Pixels
	;rsunpx=484.455
	rsunpx=(smart_mdipxarea(/rsunasec))/(smart_mdipxarea(/asecppx))
	
	;Radius of sun in Mm
	rsunmm=695.5
	
	;rmask=rcoord*limbmask
	;rsunpx=ceil(max(rmask))
	;degmap=asin(rmask/max(rmask));*fract90*!pi/2.
	
	restore, '~/science/data/restore_maps/mdi_limbmask_map.sav'
	restore, '~/science/data/restore_maps/mdi_rorsun_map.sav'
	
	;pi/2 at limb, 0 in center
	degmap=asin(rorsun) ;radians
	
	;rorsun px resolution across disk = 1./rsun in px
	drorsun=1./rsunpx ;per px
	
	;degree resolution map. good at sun center, bad at limb. yields position uncertainty in radians
	dtheta=1./(1.-(rorsun^2.))^(.5)*drorsun*limbmask ;rad
	if (where(finite(dtheta) ne 1))[0] ne -1 then dtheta[where(finite(dtheta) ne 1)]=0
	;Mm resolution map. position (dist) uncertainty in Mm.
	dmm=dtheta*(rsunmm) ;Mm. radial arc length covered by each pixel in Mm.

	;dmmsq=dmm*1./rsunpx ;Mm^2.	
	drmm=rsunmm/rsunpx
	dmmsq=dmm*drmm ;Mm^2. multiply by the non forshortened pixel width.
	
	if keyword_set(savmaps) then save, dtheta, dmm, dmmsq, file='~/science/data/restore_maps/mdi_uncertainty_maps.sav'
	
	;Cosine weighting map assuming tilted rectangular area under each pixel, 
	;w/ normal vector at theta to the observer.
	cosmap=1./cos(degmap)
	
	if keyword_set(savmaps) then save, cosmap,file='~/science/data/restore_maps/mdi_px_area_map.sav'

goto,feckinthing	
	;Estimate spherical surface section under each pixel. 1 at disk center >>1 near limb.
	imgsz=[2,1024,1024]
	mmppx=smart_mdipxarea(/mmppx)
	xyrcoord,imgsz,xx0,yy0,rr
	xx0=xx0[0:511,0:511]*1.
	yy0=yy0[0:511,0:511]*1.
	xx1=xx0+1.
	yy1=yy0+1.
	;xx1=shift(xx0,-1,0)*1.
	;yy1=shift(yy0,0,-1)*1.
	rr=(shift(rr,512,512))[0:511,0:511]
	rsunpx=(smart_mdipxarea(/rsunasec))/(smart_mdipxarea(/asecppx))
	theta1=asin(yy1/sqrt(xx0^2.+yy1^2.))
	theta0=asin(yy0/sqrt(xx1^2.+yy0^2.))
	phi1=acos(sqrt(rsunpx^2.-xx1^2.-yy1^2.)/rsunpx)
	phi0=acos(sqrt(rsunpx^2.-xx0^2.-yy0^2.)/rsunpx)
	rphi=rsunpx
	rtheta=(xx1*yy1-xx0*yy0)/2.
	surfmap=abs(abs(theta1)-abs(theta0))*abs(abs(phi1)-abs(phi0))*rphi*rtheta
	surfmap[where(rr ge rsunpx)]=1.
	surfmap[where(finite(surfmap) ne 1)]=1.
feckinthing:

;stop

	surfmap=dtheta*rsunpx
	if keyword_set(savmaps) then save, surfmap,file='~/science/data/restore_maps/mdi_px_surfarea_map.sav'
	
	;IT TURNS OUT THAT THE LOS CORRECTION, COS AREA CORRECTION AND AREA SURF 
	;CORRECTION ARE EXACTLY THE SAME....

endif else begin
	restore,'~/science/data/restore_maps/mdi_px_area_map.sav'
	restore,'~/science/data/restore_maps/mdi_px_surfarea_map.sav'
endelse

if keyword_set(surfcor) then return,surfmap $
	else return,cosmap

end
