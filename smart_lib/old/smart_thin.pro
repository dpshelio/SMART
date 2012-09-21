;This routine uses M_THIN, which creates branches.
;First must ERODE to get down to a few pixels. 
;ERODE structure is bigger than RADIUS of thickness by ~60%

function smart_thin, arr, radius=radius

arr0=arr

if n_elements(radius) lt 1 then radius0=5. else radius0=radius

;radius0=radius0/.63

imgsz=[2,2.*radius0,2.*radius0]
struc=fltarr(imgsz[1],imgsz[2])

;Generate coordinate maps.
xcoord=rot(congrid(transpose(findgen(imgsz[1])),imgsz[1],imgsz[2]),90)
ycoord=rot(xcoord,-90)
rcoord=sqrt((xcoord-imgsz[1]/2.)^2.+(ycoord-imgsz[2]/2.)^2)

struc[where(rcoord le radius0)]=1.

;frac=.63
;struc=fltarr(radius/.63,radius/.63)+1

arrerode=erode(arr0,struc)

thinned=float(m_thin(arrerode))

return,thinned

end