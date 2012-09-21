function smart_plot_track_flares, arstruct, path=path, rhessi=rhessi, sfreeland=sfreeland

time=arstruct.time








return, flarestr

end

;-------------------------------------------------------------->

pro smart_plot_track_60, extstr, outw60e, outw60w
;FIND 60deg CROSSINGS

dthetae=0.
dthetaw=0.
w60e=-1.
w60w=-1.
abshge=reform(abs((extstr.hglon)[0,*]-60.))
abshgw=reform(abs((extstr.hglon)[1,*]-60.))
while dthetae lt 5 do begin
	wbest=(where(abshge eq min(abshge)))[0]
	dthetae=abshge[wbest]
	if dthetae lt 5 then begin
		w60e=[w60e,wbest]
		abshge[wbest-10 > 0:wbest+10 < n_elements(abshge)-1]=100
	endif
endwhile
if n_elements(w60e) gt 1 then w60e=w60e[1:*]

while dthetaw lt 5 do begin
	wbest=(where(abshgw eq min(abshgw)))[0]
	dthetaw=abshgw[wbest]
	if dthetaw lt 5 then begin
		w60w=[w60w,wbest]
		abshgw[wbest-10 > 0:wbest+10 < n_elements(abshgw)-1]=100
	endif
endwhile
if n_elements(w60w) gt 1 then w60w=w60w[1:*]

outw60e=w60e
outw60w=w60w

end

;-------------------------------------------------------------->

pro smart_plot_track_id, arstruct_arr,extstr=extstr,path=path, xwin=xwin, flares=flares

if not keyword_set(path) then path=smart_paths(/arplots,/no_cal)
;path='~/science/data/issi/tracking_ars/tracked_roi/'

motherid=arstruct_arr[0].smid
if n_elements(extstr) eq 0 then extstruct_arr=arstruct_arr.extstr else extstruct_arr=extstr

;DISTINGUISH AR AND FRAGMENTS
;Extract the fragments
wfr=where(arstruct_arr.smid ne motherid)
if wfr[0] ne -1 then isfr=1 else isfr=0

if isfr then begin
arfr=arstruct_arr[wfr]
if n_elements(extstr) ne 0 then extfr=extstruct_arr[wfr] else extfr=arfr.extstr
timfr=(anytim(arfr.time)-min(anytim(arstruct_arr.time)))/(3600.*24.)
endif

;Extract the mother AR
war=where(arstruct_arr.smid eq motherid)
arstr=arstruct_arr[war]
extstr=extstruct_arr[war]
tim=(anytim(arstr.time)-min(anytim(arstruct_arr.time)))/(3600.*24.)

if n_elements(tim) lt 2 then begin
	print,'LT 2 POINTS TO PLOT!!!'
	return
endif

;FIND 60deg CROSSINGS
smart_plot_track_60, extstr, w60e, w60w
if w60e[0] ne -1 then tvline=tim[w60e] else tvline=-1
if w60w[0] ne -1 then tvline2=tim[w60w] else tvline2=-1

;FIND FLARES
;flarestr=smart_plot_track_flares(arstruct, path=path, /rhessi) ;=rhessi, sfreeland=sfreeland



;OPEN EPS FILE
if not keyword_set(xwin) then setplotenv,file=path+arstruct_arr[0].smid+'.eps',/ps, xs=10,ys=10
	setcolors,/sys,/quiet

;SET SPLOT PARAMETERS
	;plot,tim,ar10488.bflux,/nodata,/noerase,xsty=4,ysty=4
	!x.margin=[15,5]
	!y.minor=1
	!y.ticklen=.01
	blanktick=strarr(10)+' '
	plotsym,0,.5,/fill
	!p.multi=[5,1,5]
	
;CALCULATE PLOT X, Y RANGES
	if isfr then begin
		xrantim=[min([tim,timfr]),max([tim,timfr])] 
		yfluxran=[min([arstr.bflux,arfr.bflux])*1d16,max([arstr.bflux,arfr.bflux])*1d16]
;		ylsgran=[min([arstr.nlstr.lsg,arfr.nlstr.lsg]),max([arstr.nlstr.lsg,arfr.nlstr.lsg])]
		yrran=[min([arstr.nlstr.rval,arfr.nlstr.rval]),max([arstr.nlstr.rval,arfr.nlstr.rval])]
		yemrgran=[min([arstr.bfluxemrg,arfr.bfluxemrg])*1d16,max([arstr.bfluxemrg,arfr.bfluxemrg])*1d16]
		yhglatran=[min([arstr.hglat,arfr.hglat,reform(extstr.hglat,n_elements(extstr.hglat)),reform(extfr.hglat,n_elements(extfr.hglat))]),max([arstr.hglat,arfr.hglat,reform(extstr.hglat,n_elements(extstr.hglat)),reform(extfr.hglat,n_elements(extfr.hglat))])]
		yhglonran=[min([arstr.hglon,arfr.hglon,reform(extstr.hglon,n_elements(extstr.hglon)),reform(extfr.hglon,n_elements(extfr.hglon))]),max([arstr.hglon,arfr.hglon,reform(extstr.hglon,n_elements(extstr.hglon)),reform(extfr.hglon,n_elements(extfr.hglon))])]

		if n_elements(timfr) lt 2 then begin
			timfr=[timfr,timfr]
			arfr=[arfr,arfr]
		endif
		
	endif else begin
		xrantim=[min(tim),max(tim)]
		yfluxran=[min(arstr.bflux)*1d16,max(arstr.bflux)*1d16]
;		ylsgran=[min(arstr.nlstr.lsg),max(arstr.nlstr.lsg)]
		yrran=[min(arstr.nlstr.rval),max(arstr.nlstr.rval)]
		yemrgran=[min(arstr.bfluxemrg)*1d16,max(arstr.bfluxemrg)*1d16]
		yhglatran=[min([arstr.hglat,reform(extstr.hglat,n_elements(extstr.hglat))]),max([arstr.hglat,reform(extstr.hglat,n_elements(extstr.hglat))])]
		yhglonran=[min([arstr.hglon,reform(extstr.hglon,n_elements(extstr.hglon))]),max([arstr.hglon,reform(extstr.hglon,n_elements(extstr.hglon))])]
	endelse
	
;PLOT PROPERTIES VS TIME
	plot,tim,arstr.bflux*1d16,ps=8,/noerase,color=0,/xsty,/ysty,yran=yfluxran,xran=xrantim,xtickname=blanktick,ytickname=blanktick,ymargin=[0,3]
	polyfill,[xrantim[0],xrantim[1],xrantim[1],xrantim[0]],[yfluxran[0],yfluxran[0],yfluxran[1],yfluxran[1]],/data,color=200
	if isfr then begin
		timtimfr=[tim,timfr]
		for i=0,n_elements(timtimfr)-1 do polyfill,[timtimfr[i]-.5,timtimfr[i]+.5,timtimfr[i]+.5,timtimfr[i]-.5],[yfluxran[0],yfluxran[0],yfluxran[1],yfluxran[1]],/data,color=!white
	endif else for i=0,n_elements(tim)-1 do polyfill,[tim[i]-.5,tim[i]+.5,tim[i]+.5,tim[i]-.5],[yfluxran[0],yfluxran[0],yfluxran[1],yfluxran[1]],/data,color=!white
	plot,tim,arstr.bflux*1d16,ps=-8,line=1,/noerase,color=0,/xsty,/ysty,yran=yfluxran,xran=xrantim,xtickname=blanktick,ymargin=[0,3],ytit='Total '+textoidl('\Phi')+' [Mx]',charsize=pchar, tit='SMART '+motherid
	if isfr then oplot,timfr,arfr.bflux*1d16,ps=8,color=!magenta
	if tvline[0] ne -1 then vline,tvline,color=!blue
	if tvline2[0] ne -1 then vline,tvline2,color=!forest
;	vline,imgt,color=0,/log

	!p.multi=[4,1,5]
	plot,tim,arstr.hglon,ps=-8,line=1,/noerase,color=0,/xsty,/ysty,xran=xrantim,yran=yhglonran,xtickname=blanktick,ymargin=[3,0],ytit='HG Lon [deg]',charsize=pchar
	oplot,tim,(extstr.hglon)[0,*],ps=8,color=!blue
	oplot,tim,(extstr.hglon)[1,*],ps=8,color=!forest
	if isfr then oplot,timfr,arfr.hglon,ps=8,color=!magenta
	if isfr then oplot,timfr,(extfr.hglon)[0,*],ps=8,color=!gray
	if isfr then oplot,timfr,(extfr.hglon)[1,*],ps=8,color=!gray
	if tvline[0] ne -1 then vline,tvline,color=!blue
	if tvline2[0] ne -1 then vline,tvline2,color=!forest
	hline,[-60,60],color=!gray

	!p.multi=[3,1,5]
	plot,tim,arstr.hglat,ps=-8,line=1,/noerase,color=0,/xsty,/ysty,xran=xrantim,yran=yhglatran,xtickname=blanktick,ymargin=[6,-3],ytit='HG Lat [deg]',charsize=pchar ;,yrange=[min(arstr.hglat)-10.,max(arstr.hglat)+10.]
	oplot,tim,(extstr.hglat)[0,*],ps=8,color=!blue
	oplot,tim,(extstr.hglat)[1,*],ps=8,color=!forest
	if isfr then oplot,timfr,arfr.hglat,ps=8,color=!magenta
	if isfr then oplot,timfr,(extfr.hglat)[0,*],ps=8,color=!gray
	if isfr then oplot,timfr,(extfr.hglat)[1,*],ps=8,color=!gray
	if tvline[0] ne -1 then vline,tvline,color=!blue
	if tvline2[0] ne -1 then vline,tvline2,color=!forest
	hline,[-60,60],color=!gray

;	!p.multi=[2,1,5]
;	plot,tim,arstr.nlstr.lsg,ps=8,/noerase,color=0,/xsty,/ysty,xran=xrantim,yran=ylsgran,xtickname=blanktick,ymargin=[9,-6],ytit=textoidl('L_{PSL}')+' [Mm]',charsize=pchar;,yran=[1d0,1d3]
;	;oplot,tim,arstr.nlstr.lnl,ps=8,color=!blue
;	if isfr then oplot,timfr,arfr.nlstr.lsg,ps=8,color=!magenta
;	if tvline[0] ne -1 then vline,tvline,color=!blue
;	if tvline2[0] ne -1 then vline,tvline2,color=!forest

	!p.multi=[2,1,5]
	plot,tim,arstr.nlstr.rval,ps=-8,line=1,/noerase,color=0,/xsty,/ysty,xran=xrantim,yran=yrran,xtickname=blanktick,ymargin=[9,-6],ytit='R [Mx]',charsize=pchar;,yran=[1d10,1d14]
	;oplot,tim,arstr.nlstr.r_star,ps=8,color=!blue
	if isfr then oplot,timfr,arfr.nlstr.rval,ps=8,color=!magenta
	if tvline[0] ne -1 then vline,tvline,color=!blue
	if tvline2[0] ne -1 then vline,tvline2,color=!forest
	
	!p.multi=[1,1,5]
	plot,tim,arstr.bfluxemrg*1d16,ps=-8,line=1,/noerase,color=0,/xsty,/ysty,xran=xrantim,yran=yemrgran,ymargin=[12,-9],ytit='Total '+textoidl('d\Phi/dt')+' [Mx/s]',xtit='Days since '+anytim(arstr[0].time,/date,/vms),charsize=pchar;,yran=[1d10,1d14]
	;oplot,tim,arstr.nlstr.r_star,ps=8,color=!blue
	hline,0.,color=!gray
	if isfr then oplot,timfr,arfr.bfluxemrg*1d16,ps=8,color=!magenta
	if tvline[0] ne -1 then vline,tvline,color=!blue
	if tvline2[0] ne -1 then vline,tvline2,color=!forest
	
;PRINT A LEGEND AT THE BOTTOM
	xyouts,.1,.08,'** Mother AR',color=!black,/norm,charsize=1.2
	xyouts,.1,.06,'** Fragments',color=!magenta,/norm,charsize=1.2
	xyouts,.1,.04,'__ 60 Deg Lon Crossing',color=!black,/norm,charsize=1.2
	xyouts,.3,.08,'** North or East Edge',color=!forest,/norm,charsize=1.2
	xyouts,.3,.06,'** South or West Edge',color=!blue,/norm,charsize=1.2
	xyouts,.5,.03,'Paul A. Higgins et al. (ARG/TCD) '+systim(/utc),/norm,charsize=1.
;CLOSE EPS FILE
if not keyword_set(xwin) then closeplotenv

;WRITE PNG FILE
wrpath=strjoin(str_sep(path,' '),'\ ')
if not keyword_set(xwin) then eps2png,wrpath+arstruct_arr[0].smid+'.eps',wrpath+arstruct_arr[0].smid+'.png'


end



