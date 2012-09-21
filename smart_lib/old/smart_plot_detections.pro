;Plot cataloged (or not) detections from smart for a specified smart IDL SAV file.

pro smart_plot_detections, file, outfile=outfile, noaa=noaa, ps=ps, pdf=pdf, png=png, $
	grayscale=grayscale, nocontour=nocontour, c_bar=c_bar, c_range=c_range, catalog=catalog, $
	grid=grid, idplot=idplot,position=position, $;,windownum=windownum
	arstruct=arstruct, datamap=datamap, mask=mask


;if keyword_set(windownum) then winnum=windownum else winnum=0
if not keyword_set(grid) then grid=0

if keyword_set(idplot) then catalog=1

if n_elements(file) gt 0 then begin
	restore,file[0]
	maskmap=mdimap
	maskmap.data=armask
endif else begin
	if n_elements(arstruct) gt 0 and n_elements(datamap) gt 0 and n_elements(mask) gt 0 then begin
		mdimap=datamap[0]
		maskmap=datamap
		maskmap.data=mask
	endif else begin
		print, 'No filename variable or data/arstruct/mask keywords input!!'
		return
	endelse
endelse

if not keyword_set(outfile) then outfile='./smart_'+time2file(mdimap.time)+'.eps'

if not keyword_set(c_range) then begin
	if keyword_set(uncalibrated) then drange=[-100,100] else drange=[-1000,1000]
endif else drange=c_range

;Set up PS device
if keyword_set(ps) then setplotenv,/ps,xs=15,ys=15, file=outfile

noregions=0
titlereg=''
;Make a plot of the AR candidate positions in the image.
loadct,0
setcolors,/sys
if keyword_set(gray) then begin
	!red=244
	!green=0
	!blue=0
	!white=244
endif

imgsz=size(mdimap.data)
arxarr=(arstruct.xpos)*(mdimap.dx)-imgsz[1]*(mdimap.dx)/2.
aryarr=(arstruct.ypos)*(mdimap.dy)-imgsz[2]*(mdimap.dy)/2.
if keyword_set(catalog) then idarr=arstruct.smid else idarr=arstruct.class
if (where(strlen(idarr) gt 1))[0] eq -1 then begin
	noregions=1
	titlereg=' - NONE FOUND'
endif

oldthick=!p.thick
oldchar=!p.charsize
oldbg=!p.background
oldcolor=!p.color
oldcthick=!p.charthick
if keyword_set(ps) then begin
	!p.thick=7
	c_thick=10
	charsize=2.4
	!p.charsize=2.4
	!p.background=254
	!p.color=0
endif else begin
	!p.background=255
	!p.color=0
	!x.thick=3
	!y.thick=3
	!p.thick=3
	c_thick=3
	!p.charsize=1.8
	charsize=1.8
	!p.charthick=3
	xycharsize=2.0
endelse
if keyword_set(png) then begin
   setplot,'z'
   device, set_resolution = [1500,1500]
   !p.background=255
   !p.color=0
   !p.charsize=1.8
   !p.thick=3
   !x.thick=3
   !y.thick=3
endif

;if not keyword_set(ps) then wset,winnum

;plot_image,mdimap.data > drange[0] < drange[1], title='Magnetic Structure Detections '+mdimap.time+titlereg
if keyword_set(ps) then plottit='SMART Magnetic Feature Detections '+anytim(mdimap.time,/date,/vms)+titlereg else plottit='SMART Magnetic Feature Detections '+mdimap.time+titlereg
if total(mdimap.data) eq 0 then mdimap.data=mdimap.data+.001

plot_map,mdimap, dmin=drange[0], dmax=drange[1], title=plottit, /limb, grid=grid,lc=0,position=position

;if not keyword_set(ps) then wset,winnum

if not keyword_set(nocontour) then begin

	if noregions eq 1 then return
	;contour,armask,/over,levels=.5,color=!green
	plot_map,maskmap, level=.5, /over,color=!green,c_thick=c_thick,position=position 
	contz=n_elements(idarr)
	
	if n_elements(idplot) gt 0 then begin
		wid=where(idarr ne idplot)
		idarr[wid]=''
	endif
	
	for j=0,contz-1 do begin
		plotid=idarr[j]
		if strlen(idarr[j]) gt 2 then begin
			plotid=strmid(plotid,4,strlen(plotid)-4)
			plotid=strmid(plotid,0,4)+'.'+strmid(plotid,5,4)+'.'+(str_sep(plotid,'.'))[2]
		endif
		
	;!! TEMPORARYYYYY!	
		;if plotid ne 'NF' and plotid ne 'EF' then plotid='AR' 
		if arxarr[j] lt 0 then negshiftx=-1. else negshiftx=1.
		if aryarr[j] lt 0 then negshifty=-1. else negshifty=1.
		xyouts,arxarr[j]+.07*arxarr[j]*negshiftx,aryarr[j]+.07*aryarr[j]*negshifty,plotid,color=!blue,charsize=xycharsize,charthick=10
		xyouts,arxarr[j]+.07*arxarr[j]*negshiftx,aryarr[j]+.07*aryarr[j]*negshifty,plotid,color=!white,charsize=xycharsize,charthick=5
	endfor

endif

if keyword_set(noaa) then begin
;noaastr=arstruct.noaa
noaastr=strnoaa
noaaid=noaastr.noaa

dxdy=[mdimap.dx,mdimap.dy]
imgsz=size(mdimap.data)
halfw=[dxdy[0]*imgsz[1]/2.,dxdy[1]*imgsz[2]/2.]
wnoaa=where(noaaid ne 0)
if wnoaa[0] eq -1 then return
noaastr=noaastr[wnoaa]
for i=0,n_elements(wnoaa)-1 do begin
	noaaloc=(noaastr[i]).location
	noaaid=strtrim((noaastr[i]).noaa)
	artime=(arstruct[0]).time
;rotate position into the current time
	dtimedays=(anytim(artime)-anytim(anytim(artime,/date,/vms)+' 24:00'))/(3600.*24.) ;Time diff in days btwn NOAA and SMART sav. 
	dlons=DIFF_ROT(dtimedays,noaaloc[0]) ;IS THIS FOR HG OR HC?
	noaaloc[0]=noaaloc[0]+dlons	

;Find position in px coords
;	xy=((hel2arcmin(noaaloc[1],noaaloc[0],soho=0,date=artime)*60.)+halfw)/float(dxdy)
	xy=hel2arcmin(noaaloc[1],noaaloc[0],soho=0,date=artime)*60.

;if not keyword_set(ps) then wset,winnum

;oPlot position of noaa
	oplot,[xy[0],xy[0]],[xy[1],xy[1]],ps=1,color=!blue
	xyouts,xy[0],xy[1],noaaid,color=!blue,align=1,charsize=xycharsize
endfor
endif

if keyword_set(c_bar) then begin
	loadct,0
	colorbar,range=drange,/vertical, position=[0.88, 0.15, 0.92, 0.85], /right, xtit='[G]',charsize=charsize
endif

if keyword_set(ps) then closeplotenv

if keyword_set(ps) and keyword_set(pdf) then spawn,'ps2pdf '+outfile

if keyword_set(png) then begin
   zb_plot = tvrd()
   wr_png, outfile, zb_plot
   setplot,'x'
endif

!p.thick=oldthick
!p.charsize=oldchar
!p.background=oldbg
!p.color=oldcolor
!p.charthick=oldcthick


return

end
