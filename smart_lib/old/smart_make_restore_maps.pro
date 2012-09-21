pro smart_make_restore_maps, map

imgsz=size(map.data)
xyrcoord,imgsz,xxx,yyy,rrr

;mask for on-disk pixels
limbmask=fltarr(imgsz[1],imgsz[2])+1.
limbmask[where(rrr gt (map1.rsun/map1.dx))]=0.  

limbmaskcrop=fltarr(imgsz[1],imgsz[2])+1.
limbmaskcrop[where(rrr gt .99*(map1.rsun/map1.dx))]=0.  


;cosine correction
;degmap=acos(rrr/(map.rsun/map.dx))
degmap=asin(rrr*limbmask/max(rrr*limbmask))
;losmap=1./cos(!pi/2.0001*degmap*limbmask/max(degmap*limbmask))
losmap=1./cos(degmap)*limbmask








end
