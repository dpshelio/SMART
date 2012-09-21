pro testlimb_psl_effects

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
map.data=fltarr(imgsz[1],imgsz[2])



n=32.
hglon=fltarr(n+1)
hglat=fltarr(n+1)
hglonw=fltarr(2,n+1)
area=fltarr(n+1)
cosarea=fltarr(n+1)
cosarealim=fltarr(n+1)
areaerr=fltarr(n+1)
time=fltarr(n+1)

hglatlon_map, hglonmap,hglatmap, [map.dx,map.dy], imgsz,time=map.time

if (where(finite(hglonmap) ne 1))[0] ne -1 then hglonmap[where(finite(hglonmap) ne 1)]=-10000.
if (where(finite(hglatmap) ne 1))[0] ne -1 then hglatmap[where(finite(hglatmap) ne 1)]=-10000.
































end