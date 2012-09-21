;+
; SMART_READMAGNETOGRAM
;
;
;
; History:   Created by P.A. Higgins (TCD) - smart_readmdi procedure
;            Modified by D. Perez-Suarez (TCD-HELIO) - 23 July 2012 -
;                                                      modified as function
;
;-

function smart_readmagnetogram, file, carmap=carmap

; TODO: to review all this!!  How to read the file in a smart way to 
; choose mdi, hmi, ....???

print,'SMART_READMDI'

restore,smart_paths(/calibp)

;if calib eq 0 then mreadfits, file, index
read_sdo, file, index, data
;fits2map, file, map
index2map,index,data,map

;RPT - ugly code to use T_OBS instead of DATE-OBS and move it to same format
timestr=repstr(index.t_obs,'_TAI','')
timestr=repstr(timestr,'_','T')
timestr=repstr(timestr,'.','-')
map.time=anytim(timestr,/vms)



;Shift image to center.
map.data=shift(map.data,((-1.)*map.yc/map.dy),((-1.)*map.xc/map.dx))
map.xc=0
map.yc=0


;Rotate image.
roll=map.roll_angle
;if calib eq 0 then roll=(-1.)*index.crot else roll=map.roll_angle
map.data=rot(map.data,(-1.)*roll)
map.roll_angle=0.

;Crop image to 0.98 Rsun
;restore,smart_paths(/resmap,/no_cal)+'mdi_limbmask_map_crop.sav'
imgsz=size(map.data)
xyrcoord,imgsz,xxx,yyy,rrr
limbmaskcrop=fltarr(imgsz[1],imgsz[2])+1.
limbmaskcrop[where(rrr gt .98*(map.rsun/map.dx))]=0.  
map.data=map.data*limbmaskcrop

;Resize data from 4k to 1k *** should this be done before SMART runs?
add_prop,map,data=rebin(map.data,1024,1024),/replace
map.dx=map.dx*4.
map.dy=map.dy*4.

add_prop,map,data=float(map.data),/replace

;Do a fudge calibration if using planning data.
if calib eq 0 then begin
	inplan=map.data
	smart_mdiplan2cal,inplan,outcal
	map.data=outcal
endif






  return, smart_map
end
