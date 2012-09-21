;time in sec (anytim)

function issi_rot_point, hclonlat,meastim,newtim
	
	meastime=anytim(meastim,/vms)
	newtime=anytim(newtim,/vms)
	dtim=newtim-meastim
	hglonlat=conv_a2h(hclonlat,meastime)
	dlon=diff_rot(dtim/3600./24.,hglonlat[1])
	hglonlat[0]=hglonlat[0]+dlon
	outhclonlat=conv_h2a(hglonlat,newtime)
	
return, outhclonlat

end

;-------------------------------------------------------------->

pro issi_smart_stara_asap, plot=plot, res1tore=res1tore

smartpath='~/science/data/issi_data/sav/'
fsmartsav=file_search(smartpath+'smart_2003*')
ftrunc=strmid(fsmartsav,43,23)
fsmartsav=fsmartsav[where(strmid(ftrunc,10,2) ge 6 and strmid(ftrunc,10,2) le 7)]
restore,fsmartsav[0],/ver

roismid='20030605_0450.mg.06'

datapath='~/science/data/issi_data/issi_smart_stara_asap_20100429/'

plotpath='~/science/data/issi_data/issi_smart_stara_asap_20100429/movie/'

if not keyword_set(res1tore) then begin
	;DO FLARES
	restore,'~/science/data/smart_sf_smart_compare/flare_data_sf.sav',/ver
	smflr2=SMFLRARR[1050:1150]
	smflrx=smflr2.xcen
	smflry=smflr2.ycen
	smflttim=anytim(smflr2.fstart)
	smflttime=anytim(smflr2.fstart,/vms)
	smflrhg=conv_a2h([transpose(smflrx),transpose(smflry)],smflttime)



	;DO ASAP
	fasap='asap_2003.txt'
	readcol,datapath+fasap,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16,x17,x18,x19,x20,x21,x22,x23,x24,x25,DELIMITER=' ',format=['A,A,A,A,A,A,A,A,A,A,A,A,A,A,A,A,A,A,A,A,A,A,A,A,A'],skip=1
	readcol,datapath+fasap,xall,delim='€',format='A',skip=2
	
	asaptime=anytim(x8,/vms)
	asaptim=anytim(x8)
	asaputim=anytim(asaptim[uniq(asaptim)])
	
	nline=n_elements(x7)
	asaphg=fltarr(2,nline)
	for i=0,nline-1 do asaphg[*,i]=reverse(str_sep(x9[i],','))
	asaphc=conv_h2a(asaphg,anytim(asaptime,/vms))
	asapcar=conv_h2c(asaphg,anytim(asaptime,/vms))
	asapxy=(asaphc/mdimap.dx)+512
	
	for j=0,n_elements(xall)-1 do x25[j]=(str_sep(xall[j],' '))[25]
	asaparea=x25 ;in Mm^2
	
	;DO STARA
	;fstaraall='stara_2003.txt'
	;readcol,datapath+fstaraall,y1,y2,y3,y4,y5,y6,y7,y8,y9,y10,y11,delim=' ',format='A,A,A,A,A,A,A,A,A,F,F',skip=2
	;readcol,datapath+fstaraall,yall,delim='€',format='A',skip=2
	
	;for l=0,n_elements(y8)-1 do y8[l]=strjoin(str_sep(strjoin(str_sep(y8[l],'.'),'-'),'_'),'T')
	;staratime=anytim(y8,/vms)
	;staratim=anytim(y8)
	;starautim=staratim[uniq(staratim)]
	;starahglon=y10
	;starahglat=y11
	;starahg=[transpose(y11),transpose(y10)]
	;starahc=conv_h2a(starahg,anytim(staratime,/vms))
	;staracar=conv_h2c(starahg,anytim(staratime,/vms))
	;staraxy=(starahc/mdimap.dx)+512
	;staraarea=float(strmid(yall,strlen(yall)-13,9))
	;nstara=n_elements(staratim)
	;staraarea=fltarr(nstara)
	;for k=0,nstara-1 do staraarea[k]=(str_sep(yall[k],' '))[29]
	
	starapath='~/science/data/issi/algorithm_outputs/stara_spots_2003_sensitive/'
	starafiles=file_search(starapath+'STARA_spot_data_*')
	stara_struct=issi_read_stara(map=mdimap, filelist=starafiles)
	starautim=(stara_struct.tim)[uniq(stara_struct.tim)]
	
	;DO STARA FOR AR
	fstara='stara_2003_1077.txt'
	readcol,datapath+fstara,arstarahours,arstaranfrag,arstarabuns,arstarababs
	arstaratim=anytim('4-jun-2003')+arstarahours*3600.
	arstaratime=anytim(arstaratim,/vms)
	arstarautim=arstaratim[uniq(arstaratim)]

stop
	
	save,asaptime,asaptim,asaputim,asaphg,asapxy,asaparea,asaphc,asapcar, $
		staratime,staratim,starautim,starahglon,starahglat,starahg,starahc,staracar,staraxy, staraarea, $
		arstaratim,arstaratime,arstarautim,arstaranfrag,arstarabuns,arstarababs,file=datapath+'compare_arr.sav'
endif else restore,datapath+'compare_arr.sav'


;DO IMAGE PLOTTING
if keyword_set(plot) then begin
	setplotenv,/xwin
	window,8,xs=700,ys=700
	wset,8
	!p.color=0
	!p.background=255
	!p.multi=0
	plotsym,0,.5,/fill
endif

nsmfile=n_elements(fsmartsav)

fdstarasstim=fltarr(nsmfile)
fdstarassarea=fltarr(nsmfile)
fdstarassnspot=fltarr(nsmfile)
arstarassarea=fltarr(nsmfile)
arstaranspot=fltarr(nsmfile)
;arstarapnarea=fltarr(nsmfile)
;arstaraumarea=fltarr(nsmfile)
fdasapsstim=fltarr(nsmfile)
fdasapssarea=fltarr(nsmfile)
fdasapssnspot=fltarr(nsmfile)
arasapssarea=fltarr(nsmfile)
arasapnspot=fltarr(nsmfile)

for i=48,nsmfile-1 do begin
	restore,fsmartsav[i]
	if keyword_set(plot) then loadct,0,/quiet
	
	maskmap=mdimap
	maskmap.data=armask
	war=(where(arstruct.smid eq roismid))[0]
	
	if war ne -1 then begin
		thisxran=[arstruct[war].hclon-300,arstruct[war].hclon+300]
		thisyran=[arstruct[war].hclat-300,arstruct[war].hclat+300]
		if keyword_set(plot) then plot_map,mdimap,/limb,drange=[-500,500],xran=thisxran,yran=thisyran
		if keyword_set(plot) then plot_map,maskmap,level=.5,c_color=0,/over,xran=thisxran,yran=thisyran
	endif else begin
		if keyword_set(plot) then plot_map,mdimap,/limb,drange=[-500,500]
		if keyword_set(plot) then plot_map,maskmap,level=.5,c_color=0,/over
	endelse
	if keyword_set(plot) then setcolors,/sys,/silent
	
	if war ne -1 then begin
		outmask=maskmap.data
		outmask[where(outmask ne war+1)]=0.
		outmask[where(outmask eq war+1)]=1000.
		maskmap.data=outmask
		if keyword_set(plot) then plot_map,maskmap,level=.5,c_color=!red,/over,xran=thisxran,yran=thisyran
		if keyword_set(plot) then oplot,[arstruct[war].hclon,arstruct[war].hclon],[arstruct[war].hclat,arstruct[war].hclat],ps=4,color=!red
		
	;	stop
		
		
		
		absasapt=abs(asaputim-anytim(mdimap.time))
		wasapubest=where(absasapt eq min(absasapt))
		if wasapubest[0] eq -1 then goto,skipwasap
		wasapbest=where(asaptim eq (asaputim[wasapubest])[0])
		if wasapbest[0] eq -1 then goto,skipwasap
		fdasapsstim[i]=asaputim[wasapubest[0]] ;tim, s
		fdasapssarea[i]=total(float(asaparea[wasapbest])) ;area; Mm^2
	;correct for diff rotation
		asaphcw=asaphc[*,wasapbest]
		for j=0,n_elements(wasapbest)-1 do asaphcw[*,j]=issi_rot_point(asaphcw[*,j],asaputim[wasapubest[0]],anytim(mdimap.time))
		if keyword_set(plot) then oplot,[(asaphcw[0,*]),(asaphcw[0,*])],[(asaphcw[1,*]),(asaphcw[1,*])],ps=4,color=!forest
		if keyword_set(plot) then oplot,[(asaphcw[0,*]),(asaphcw[0,*])],[(asaphcw[1,*]),(asaphcw[1,*])],ps=1,color=!green
	;findspots within AR
		asapxyw=asaphcw/mdimap.dx+512.
		maskasap=outmask
		maskasap[asapxyw[0,*],asapxyw[1,*]]=maskasap[asapxyw[0,*],asapxyw[1,*]]+findgen(n_elements(asapxyw[0,*]))+1
		wasapgt=where(maskasap gt 1000)
		if wasapgt[0] eq -1 then goto,skipwasap
		wasapthisar=maskasap[wasapgt]-1001.
		if wasapthisar[0] ne -1 then arasapssarea[i]=total(float((asaparea[wasapbest])[wasapthisar]))
		if wasapthisar[0] ne -1 then arasapnspot=n_elements(wasapthisar) else arasapnspot=0.
		if keyword_set(plot) then oplot,[(asaphcw[0,*])[wasapthisar],(asaphcw[0,*])[wasapthisar]],[(asaphcw[1,*])[wasapthisar],(asaphcw[1,*])[wasapthisar]],ps=8,color=!red

;if wasapthisar[0] ne -1 then stop

	skipwasap:				
					
		absstarat=abs(starautim-anytim(mdimap.time))
		wstaraubest=where(absstarat eq min(absstarat))
		if wstaraubest[0] eq -1 then goto,skipwstara
		wstarabest=where(staratim eq (starautim[wstaraubest])[0])
		if wstarabest[0] eq -1 then goto,skipwstara
		fdstarasstim[i]=starautim[wstaraubest[0]] ;tim, s
		fdstarassarea[i]=total(float(staraarea[wstarabest])) ;area; Mm^2
	;correct for diff rotation
		starahcw=starahc[*,wstarabest]
		for j=0,n_elements(wstarabest)-1 do starahcw[*,j]=issi_rot_point(starahcw[*,j],starautim[wstaraubest[0]],anytim(mdimap.time))
		if keyword_set(plot) then oplot,[(starahcw[0,*]),(starahcw[0,*])],[(starahcw[1,*]),(starahcw[1,*])],ps=4,color=!cyan
		if keyword_set(plot) then oplot,[(starahcw[0,*]),(starahcw[0,*])],[(starahcw[1,*]),(starahcw[1,*])],ps=1,color=!blue
	;findspots within AR
		staraxyw=starahcw/mdimap.dx+512.
		maskstara=outmask
		maskstara[staraxyw[0,*],staraxyw[1,*]]=maskstara[staraxyw[0,*],staraxyw[1,*]]+findgen(n_elements(staraxyw[0,*]))+1
		wstaragt=where(maskstara gt 1000)
		if wstaragt[0] eq -1 then goto,skipwstara
		wstarathisar=maskstara[wstaragt]-1001.
		if wstarathisar[0] ne -1 then arstarassarea[i]=total(float((staraarea[wstarabest])[wstarathisar]))
		if wstarathisar[0] ne -1 then arstaranspot=n_elements(wstarathisar) else arstaranspot=0.
		if keyword_set(plot) then oplot,[(starahcw[0,*])[wstarathisar],(starahcw[0,*])[wstarathisar]],[(starahcw[1,*])[wstarathisar],(starahcw[1,*])[wstarathisar]],ps=8,color=!red
	
	;stop
	
	skipwstara:

	endif
	if keyword_set(plot) then window_capture,file=plotpath+'image_'+string(i,form='(I04)'),/png
	
endfor

;PLOTTING FOR NOAA 10377 STUDY

arstaranfrag
arstarabuns,arstarababs
arstaratim





stop


stop




















end