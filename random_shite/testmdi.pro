;read in some MDI data

pro testmdi

path='~/science/data/mdi_calibration/'

file='fd_M_96m_01d.6032.0014.fits'

mreadfits,path+file,index,data

index2map,index,data,map

loadct,0
window,0
plot_map,map,/limb

;Calculate MDI pixel specs...
print,[[' '],['MDI PIXELS:']]
print,strtrim(smart_mdipxarea(map, /mmsqr),2)+' Mm^2'
print,strtrim(smart_mdipxarea(map, /cmsqr),2)+' cm^2'
print,strtrim(smart_mdipxarea(map, /mmppx),2)+' Mm'
print,strtrim(smart_mdipxarea(map, /cmppx),2)+' cm'

imgsz=size(data)
xyrcoord, imgsz, xcoord, ycoord, rcoord

;Create limb mask...
hglatlon_map, hglonmap,hglatmap, dxdy, imgsz, oflb, time=systim(/utc),/mdi
;limbmask[where(finite(data) eq 1)]=1
limbmask=fltarr(imgsz[1],imgsz[2])
wsun=where(oflb eq 0)
limbmask[wsun]=1.

save,limbmask,file='~/science/data/restore_maps/mdi_limbmask_map.sav'

stop

;Create R/Rsun map...
rorsun=rcoord*limbmask
rorsun=rorsun/max(rorsun)

save,rorsun,file='~/science/data/restore_maps/mdi_rorsun_map.sav'

;Create cosine area correction map...
areacor=1./cos(asin(rorsun))
wbad=where(finite(areacor) ne 1)
if wbad[0] ne -1 then areacor[wbad]=1
areamap=smart_mdipxarea(map, /cmsqr)*areacor

;Create los b correction map...
loscor=1./sin(acos(rorsun))
wbad=where(finite(areacor) ne 1)
if wbad[0] ne -1 then loscor[wbad]=1

save,loscor,file='~/science/data/restore_maps/mdi_loscor_map.sav'

setcolors,/sys
window,1
plot,areacor[*,imgsz[1]/2.],tit='w=area, r=loscor'
oplot,loscor[*,imgsz[1]/2.],color=!red

stop

end