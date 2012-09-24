;Image must be centered and complete. Ie. SIZE is used to convert to ARCSEC. 
;Data is shifted by imgsz/2 and multiplied by DX, DY

function smart_arextent, indata, rsundeg=rsundeg, dx=dx,dy=dy, date=date, plot=plot

data=indata

imgsz=size(data)

extentstr=smart_blanknar(/extent)
if total(data) eq 0 then return,extentstr

if n_elements(rsundeg) lt 1 then begin
	restore,smart_paths(/resmap,/no_calib)+'mdi_rorsun_map.sav'
	rsundeg=asin(rorsun)/!dtor
endif

;===== Finding Bounding box

xcut=abs(total(data,2))
nxcut=n_elements(xcut)
wxn0=where(xcut ne 0)
xmean=mean(xcut[wxn0])
wxbnd=[min(wxn0),max(wxn0)]

xmeanpos=total(xcut*findgen(nxcut))/total(xcut)

ycut=abs(total(data,1))
nycut=n_elements(ycut)
wyn0=where(ycut ne 0)
ymean=mean(ycut[wyn0])
wybnd=[min(wyn0),max(wyn0)]

ymeanpos=total(ycut*findgen(nycut))/total(ycut)

;===== Finding Bounding box of the higher threshold
wxn10=where(xcut gt .1*xmean)
wxbnd10=[min(wxn10),max(wxn10)]

wyn10=where(ycut gt .1*ymean)
wybnd10=[min(wyn10),max(wyn10)]


;===== Convert the BB px coordinates to Solar Radii of higher threshold
londegsunc=[rsundeg[wxbnd10[0],ymeanpos],rsundeg[wxbnd10[1],ymeanpos]] ;!!!Be careful with this!!!
latdegsunc=[rsundeg[xmeanpos,wybnd10[0]],rsundeg[xmeanpos,wybnd10[1]]] ; it may give larger BB because it uses [xy]meanpos

;===== Convert the BB px coordinates to Heliocentric of higher threshold
hcxmean=(xmeanpos-imgsz[1]/2.)*dx
hcymean=(ymeanpos-imgsz[2]/2.)*dy
hcxbnd10=(wxbnd10-imgsz[1]/2.)*dx
hcybnd10=(wybnd10-imgsz[2]/2.)*dy
;hglon=[(conv_a2h([hcxbnd10[0],hcymean]))[0], (conv_a2h([hcxbnd10[1],hcymean]))[0]] ;!!!Be careful with this!!!  Missing date!!
;hglat=[(conv_a2h([hcxmean,hcybnd10[0]]))[1], (conv_a2h([hcxmean,hcybnd10[1]]))[1]] ; it may give larger BB because it uses [xy]meanpos
;changed to use the total bounding box and added the date
   x=(wxbnd - imgsz[1]/2.)*dx
   Y=(wybnd - imgsz[2]/2.)*dy
   ll=arcmin2hel(x[0]/60.,Y[0]/60.,date=date)
   ur=arcmin2hel(X[1]/60.,Y[1]/60.,date=date)
   HGLON=[ll[1],ur[1]]
   HGLAT=[ll[0],ur[0]]
;TODO: Do we need to change this to the 4 corners??

extentstr.xylon=wxbnd   ; Px values
extentstr.xylat=wybnd
extentstr.hclon=x       ; Arcsec values
extentstr.hclat=y
extentstr.rdeglon=londegsunc  ; Solar radii??
extentstr.rdeglat=latdegsunc
extentstr.hglon=hglon   ; Heliographic in degrees
extentstr.hglat=hglat
extentstr.xymean10lon=wxbnd10
extentstr.xymean10lat=wybnd10
extentstr.hglonwidth=abs(hglon[1]-hglon[0])
extentstr.hglatwidth=abs(hglat[1]-hglat[0])

if keyword_Set(plot) then begin
	loadct,0
	plot_image,data
	setcolors,/sys
	oplot,[xmeanpos,xmeanpos],wybnd10,ps=4,color=!red
	oplot,wxbnd10,[ymeanpos,ymeanpos],ps=4,color=!red
	oplot,[xmeanpos,xmeanpos],wybnd,ps=4,color=!green
	oplot,wxbnd,[ymeanpos,ymeanpos],ps=4,color=!green
	help,extentstr,/str
endif

return,extentstr

end
