function genquiet



end

;---------------------------------------------------------------------->

function genfeature, nblob=nblob,imgsz=imgsz,scale=scale

if not keyword_set(scale) then scale=[50,25]

if not keyword_set(imgsz) then imgsz=[0,300,300]

if not keyword_set(nblob) then nblob=100

farr=fltarr(imgsz[1],imgsz[2])

thisw=randomn(seed1,nblob)*30.
thish=randomn(seed2,nblob)*1000.
thisxy=randomn(seed3,2,nblob)*scale[1]
thisxy[0,0:nblob/2]=thisxy[0,0:nblob/2]-scale[0]
thisxy[0,nblob/2:*]=thisxy[0,nblob/2:*]+scale[0]

for i=0,nblob-1 do begin

	thisg=Gauss_2d(min([imgsz[1],imgsz[2]]), thisw[i], rmax=thish[i])
	
	farr=farr+shift(thisg,thisxy[0,i],thisxy[1,i])

endfor

plot_image,farr

stop

return,farr
end

;---------------------------------------------------------------------->

pro testmodelnoise

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




















end