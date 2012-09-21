;Generate SMART figures for ASR

pro smart_arg_plots, pbthresh=pbthresh, pbquietthresh=pbquietthresh, $
	pbactivethresh=pbactivethresh, pbhistthresh=pbhistthresh, pcomparear=pcomparear, $
	palgorithm=palgorithm, pfinalgorithm=pfinalgorithm, pnlsim=pnlsim, $
	restoresav=restoresav, res2toresav=res2toresav

plotp='~/science/plots/smart_paper/'
;smartsavp=smart_paths(/savp)
smartsavp='~/science/data/smart_sav/'

if keyword_set(pbthresh) then begin
;--------------------------------------------------------->
;B threshold, Grad B threshold

	imgsz=[2,1024,1024]
	blank=fltarr(imgsz[1],imgsz[2])
	secpyear=3600.*24.*365.
	
	;contains SSN and SSTIM
	filessn='~/science/data/cycle23_sav/sunspot_monthly_num_sdic.sav'
	
	files=file_search(smart_paths(/mdip),'*.fits')
	
	fmonth=strmid(time2file(file2time(files),/date),0,6)
	
	ufcal=uniq(fmonth)
	nfile=n_elements(ufcal)
	
	multarr=reform(rebin([0,12,36,48,52], 5, nfile, /samp), 5l*nfile)
	
	wfiles=rebin(ufcal,5l*nfile,/samp)-multarr
	wfiles=wfiles[sort(wfiles)]
	
	fcal=files[wfiles]
	
	if not keyword_set(restoresav) then begin
	
	mreadfits, fcal[0], indexstr
	fits2map, fcal[0], testmap
	
	mmppx=smart_mdipxarea(testmap, /mmppx)
	print,'MEGAMETERS PER PIXEL = '+strtrim(mmppx,2)
	
	datastr={imgindex:indexstr, imgtime:'', imgmax:0., maxstd:0., imgmean:0., meanstd:0., imgsigma:0., sigmastd:0., imgkurt:0., kurtstd:0.} ;imgvals:blank, 
	datastr=replicate(datastr,nfile)
	
	gdatastr={imgindex:indexstr, imgtime:'', imgmax:0., maxstd:0., imgmean:0., meanstd:0., imgsigma:0., sigmastd:0., imgkurt:0., kurtstd:0.} ;imgvals:blank, 
	gdatastr=replicate(gdatastr,nfile)
	
	
	for i=0,nfile-1 do begin
		mreadfits, fcal[(i)*5], index, data
		index2map,index,data,thismap
		hglatlon_map, hglon,hglat, [thismap.dx,thismap.dy], imgsz, offlimb,time=thismap.time
		
		maxarr=fltarr(5)
		meanarr=fltarr(5)
		sigmaarr=fltarr(5)
		kurtarr=fltarr(5)
		
		gmaxarr=fltarr(5)
		gmeanarr=fltarr(5)
		gsigmaarr=fltarr(5)
		gkurtarr=fltarr(5)
		
		for k=0,4 do begin
	;Find absolute and signed, smoothed B values on disk, and grad B values for each of 5 images in month.
			mreadfits, fcal[5*i+k], index, data
			index2map,index,data,thismap
			
			imgcal=smart_mdimagprep(data, losmap, nsmooth=5., /nolos, /nonoise);, nosmooth=nosmooth, nonoise=nonoise, nolos=nolos, nofinite=nofinite)
	
	;plot_image,imgcal
	;stop
	
			imggrad=abs(deriv(imgcal))/mmppx ;in Gauss per Mm
	
			imgvals=imgcal[where(offlimb eq 0)]
			absimgvals=abs(imgvals)
			gradvals=imggrad[where(offlimb eq 0)]
	
	;Calculate statistical moments of B values.
			maxarr[k]=max(absimgvals)
			meanarr[k]=mean(absimgvals)
			sigmaarr[k]=stddev(imgvals)
			kurtarr[k]=kurtosis(imgvals)
			
			gmaxarr[k]=max(gradvals)
			gmeanarr[k]=mean(gradvals)
			gsigmaarr[k]=stddev(gradvals)
			gkurtarr[k]=kurtosis(gradvals)
		endfor
	
	;Put values in data structure.
		;datastr[i].imgindex=index
		datastr[i].imgtime=thismap.time
		;datastr[i].imgvals=imgvals
	;Statistical moments.
		datastr[i].imgmax=mean(maxarr) ;uses abs vals
		datastr[i].imgmean=mean(meanarr) ;uses abs vals
		datastr[i].imgsigma=mean(sigmaarr) ;uses signed vals
		datastr[i].imgkurt=mean(kurtarr) ;uses signed vals
	;Error bars for mements.
		datastr[i].maxstd=stddev(maxarr)
		datastr[i].meanstd=stddev(meanarr)
		datastr[i].sigmastd=stddev(sigmaarr)
		datastr[i].kurtstd=stddev(kurtarr)
	
	;Put values in gradient data structure.
		;gdatastr[i].imgindex=index
		gdatastr[i].imgtime=thismap.time
		;gdatastr[i].imgvals=gradvals
	;Statistical moments.
		gdatastr[i].imgmax=mean(gmaxarr) ;uses abs vals
		gdatastr[i].imgmean=mean(gmeanarr) ;uses abs vals
		gdatastr[i].imgsigma=mean(gsigmaarr) ;uses signed vals
		gdatastr[i].imgkurt=mean(gkurtarr) ;uses signed vals
	;Error bars for mements.
		gdatastr[i].maxstd=stddev(gmaxarr)
		gdatastr[i].meanstd=stddev(gmeanarr)
		gdatastr[i].sigmastd=stddev(gsigmaarr)
		gdatastr[i].kurtstd=stddev(gkurtarr)
	
	;plot_image,imgcal
	;stop
	
	endfor
	
	save,datastr,gdatastr,file=smartsavp+'/arg_plots_bvals_'+time2file(systim(/utc))+'.sav'
	endif else begin
		savfile=(reverse(file_search(smartsavp, 'arg_plots_bvals_*.sav', /fully_qualify)))[0]
		restore,savfile,/verb
	endelse
	
	;setplotenv,/ps,file=plotp+'mdi_stddev_vs_cycle.eps',xs=24,ys=24
	setcolors,/sys
	!p.multi=[0,1,2]
	dmax=datastr.imgmax
	dmaxerr=datastr.maxstd
	dsig=datastr.imgsigma
	derr=datastr.sigmastd
	dtim=anytim(datastr.imgtime)
	gmax=gdatastr.imgmax
	gmaxerr=gdatastr.maxstd
	gsig=gdatastr.imgsigma
	gerr=gdatastr.sigmastd
	gtim=anytim(gdatastr.imgtime)
	restore,'~/science/data/cycle23_sav/sunspot_monthly_num_sdic.sav',/verb

	plot,dtim/secpyear-anytim('01-jan-1997')/secpyear,dsig,ps=4, $
		title='STDEV of MDI B values', xtit='Years since 19970101', ytit='STDV [G]'
	oplot,sstim/secpyear-anytim('01-jan-1997')/secpyear,(ssnum)/max(ssnum)*max(dsig), thick=2
	OPLOTERR,dtim/secpyear-anytim('01-jan-1997')/secpyear,dsig,derr,ps=4;,color=!red
	
	plot,gtim/secpyear-anytim('01-jan-1997')/secpyear,gsig,ps=4, $
		title='STDEV of Grad B values', xtit='Years since 19970101', ytit='STDV [G/Mm]'
	oplot,sstim/secpyear-anytim('01-jan-1997')/secpyear,(ssnum)/max(ssnum)*max(gsig), thick=2
	OPLOTERR,gtim/secpyear-anytim('01-jan-1997')/secpyear,gsig,gerr,ps=4;,color=!red
	
	;closeplotenv
	
	stop

	;setplotenv,/ps,file=plotp+'mdi_max_vs_cycle.eps',xs=24,ys=24
	setcolors,/sys

	plot,dtim/secpyear-anytim('01-jan-1997')/secpyear,dmax,ps=4, $
		title='Max of MDI B values', xtit='Years since 19970101', ytit='Max [G]'
	oplot,sstim/secpyear-anytim('01-jan-1997')/secpyear,(ssnum)/max(ssnum)*max(dmax), thick=2
	OPLOTERR,dtim/secpyear-anytim('01-jan-1997')/secpyear,dmax,dmaxerr,ps=4;,color=!red
	
	plot,gtim/secpyear-anytim('01-jan-1997')/secpyear,gmax,ps=4, $
		title='Max of Grad B values', xtit='Years since 19970101', ytit='Max [G/Mm]'
	oplot,sstim/secpyear-anytim('01-jan-1997')/secpyear,(ssnum)/max(ssnum)*max(gmax), thick=2
	OPLOTERR,gtim/secpyear-anytim('01-jan-1997')/secpyear,gmax,gmaxerr,ps=4;,color=!red
	
	;closeplotenv
	
	stop
	
;--------------------------------------------------------->
endif


if keyword_set(pbquietthresh) then begin
;--------------------------------------------------------->
;B threshold, Grad B threshold for quiet sun only.

	secpyear=3600.*24.*365.
	smartsavp='~/science/data/smart_sav/';smart_paths(/savp)
	plotp='~/science/plots/smart_paper/'
	;contains SSN and SSTIM
	filessn='~/science/data/cycle23_sav/sunspot_monthly_num_sdic.sav'
	mdipath='~/science/data/mdi_cycle23/'
	
	files=file_search(mdipath,'*.fits')
	fday=time2file(file2time(files),/date)
	fmonth=strmid(time2file(file2time(files),/date),0,6)
	
	;w5th=where((fday mod 5) eq 0)
	;fcal=files[w5th]
	
	ufcal=uniq(fmonth)
	;nfile=n_elements(fcal)

	fcal=files
	nfile=n_elements(fcal)

	mreadfits, fcal[0], indexstr, data
	fits2map, fcal[0], testmap
	imgsz=size(data)
	
	mmppx=smart_mdipxarea(testmap, /mmppx)
	print,'MEGAMETERS PER PIXEL = '+strtrim(mmppx,2)
	
	index2map,indexstr,data,testmap
	hglatlon_map, hglon,hglat, [testmap.dx,testmap.dy], imgsz, offlimb,time=testmap.time

	if not keyword_set(res2toresav) then begin

	if not keyword_set(restoresav) then begin

	answarr=strarr(nfile)+'n'

	for i=0,nfile-1 do begin
		mreadfits, fcal[i], index, data

		index2map,index,data,thismap
			
;		imgcal=smart_mdimagprep(data, losmap, nsmooth=5., /nolos, /nonoise);, nosmooth=nosmooth, nonoise=nonoise, nolos=nolos, nofinite=nofinite)
		imgcal=smart_mdimagprep(data, losmap, /nolos, /nonoise, /nosmooth);=nosmooth, nonoise=nonoise, nolos=nolos, nofinite=nofinite)

;		plot_image,imgcal > (-300) < 300

	imgsqr=imgcal[450:550,450:550]
	imgmm=abs(minmax(imgsqr))
	print,imgmm
		
;	oplot,[400,400],[-1d6,1d6]
;	oplot,[600,600],[-1d6,1d6]
;	oplot,[-1d6,1d6],[400,400]
;	oplot,[-1d6,1d6],[600,600]

	print,'I = '+strtrim(i,2)
	print,'DAY = '+fday[i]

	if imgmm[0] lt 100 and imgmm[1] lt 100 then begin
		;answ=''
		;read,answ
		if index.MISSVALS eq 0 then answarr[i]='y'
	endif

	endfor
		
	save,fcal,answarr,file=smartsavp+'/arg_plots_quietbvals_'+time2file(systim(/utc))+'.sav'
	
	endif else begin
		savfile=(reverse(file_search(smartsavp, 'arg_plots_quietbvals_*.sav', /fully_qualify)))[0]
		restore,savfile
	endelse

	wfcal=where(answarr eq 'y')
	fcal=files[wfcal]
	nfile=n_elements(fcal)
	
	fmonth=strmid(time2file(file2time(fcal),/date),0,6)
	
	;w5th=where((fday mod 5) eq 0)
	;fcal=files[w5th]
	
	ufmonth=uniq(fmonth)
	nmonth=n_elements(ufmonth)

	datastr={imgindex:indexstr, imgtime:'', imgmax:0., maxstd:0., imgmean:0., meanstd:0., imgsigma:0., sigmastd:0., imgkurt:0., kurtstd:0.} ;imgvals:blank, 
	datastr=replicate(datastr,nmonth)
	
	gdatastr={imgindex:indexstr, imgtime:'', imgmax:0., maxstd:0., imgmean:0., meanstd:0., imgsigma:0., sigmastd:0., imgkurt:0., kurtstd:0.} ;imgvals:blank, 
	gdatastr=replicate(gdatastr,nmonth)	

	for i=0,nmonth-1 do begin

		print,'MONTH = '+strtrim(fmonth[ufmonth[i]],2)
		wmonth=where(fmonth eq fmonth[ufmonth[i]])

		if n_elements(wmonth) ge 2 then begin
			nday=n_elements(wmonth)
			fdaylist=fcal[wmonth]

			maxarr=fltarr(nday)			
			meanarr=fltarr(nday)
			sigmaarr=fltarr(nday)
			kurtarr=fltarr(nday)

			gmaxarr=fltarr(nday)			
			gmeanarr=fltarr(nday)
			gsigmaarr=fltarr(nday)
			gkurtarr=fltarr(nday)		
			
			for k=0,nday-1 do begin
	
				mreadfits, fdaylist[k], index, data
				index2map,index,data,thismap	
;				imgcal=smart_mdimagprep(data, losmap, nsmooth=5., /nolos, /nonoise);, nosmooth=nosmooth, nonoise=nonoise, nolos=nolos, nofinite=nofinite)
				imgcal=smart_mdimagprep(data, losmap, /nolos, /nonoise, /nosmooth);=nosmooth, nonoise=nonoise, nolos=nolos, nofinite=nofinite)

				imgsqr=imgcal[450:550,450:550]
;				gradsqr=abs(deriv(imgsqr))/mmppx ;in Gauss per Mm
	
				absimgsqr=abs(imgsqr)
		
	;Calculate statistical moments of B values.
				maxarr[k]=max(absimgsqr)
				meanarr[k]=mean(absimgsqr)
				sigmaarr[k]=stddev(imgsqr)
;				kurtarr[k]=kurtosis(imgsqr)
				
;				gmaxarr[k]=max(gradsqr)
;				gmeanarr[k]=mean(gradsqr)
;				gsigmaarr[k]=stddev(gradsqr)
;				gkurtarr[k]=kurtosis(gradsqr)
	
			endfor
			
	
			
	;Put values in data structure.
			datastr[i].imgtime=thismap.time
	;Statistical moments.
			datastr[i].imgmax=mean(maxarr) ;uses abs vals
			datastr[i].imgmean=mean(meanarr) ;uses abs vals
			datastr[i].imgsigma=mean(sigmaarr) ;uses signed vals
;			datastr[i].imgkurt=mean(kurtarr) ;uses signed vals
	;Error bars for mements.
			datastr[i].maxstd=stddev(maxarr)
			datastr[i].meanstd=stddev(meanarr)
			datastr[i].sigmastd=stddev(sigmaarr)
;			datastr[i].kurtstd=stddev(kurtarr)
		
	;Put values in gradient data structure.
;			gdatastr[i].imgtime=thismap.time
	;Statistical moments.
;			gdatastr[i].imgmax=mean(gmaxarr)
;			gdatastr[i].imgmean=mean(gmeanarr)
;			gdatastr[i].imgsigma=mean(gsigmaarr)
;			gdatastr[i].imgkurt=mean(gkurtarr)
	;Error bars for mements.
;			gdatastr[i].maxstd=stddev(gmaxarr)
;			gdatastr[i].meanstd=stddev(gmeanarr)
;			gdatastr[i].sigmastd=stddev(gsigmaarr)
;			gdatastr[i].kurtstd=stddev(gkurtarr)

		endif else begin & datastr[i].imgtime=-1 & endelse;gdatastr[i].imgtime=-1 & endelse
		
	endfor
	
	save,datastr,gdatastr,file=smartsavp+'/arg_plots_nosmth_quietstruc_'+time2file(systim(/utc))+'.sav'
	
	endif else begin
		savfile=(reverse(file_search(smartsavp, 'arg_plots_nosmth_quietstruc_*.sav', /fully_qualify)))[0]
		restore,savfile,/verb
	endelse
	
	wgood=where(datastr.imgtime ne -1)
	datastr=datastr[wgood]
;	gdatastr=gdatastr[wgood]
	
	setplotenv,/ps,file=plotp+'mdi_quiet_stddev_maxb_vs_cycle100x100_sm0_bth100.eps',xs=24,ys=24
	
	;setplotenv,/ps,file=plotp+'mdi_quiet_stddev_vs_cycle100x100_sm1_bth100.eps',xs=24,ys=24
	setcolors,/sys
	
	;!p.multi=0;[0,1,2]
	!p.multi=[0,1,2]
	!p.charsize=5
	
	dsig=datastr.imgsigma
	dmax=datastr.imgmax
	dmaxerr=datastr.maxstd
	derr=datastr.sigmastd
	dtim=anytim(datastr.imgtime)
;	gsig=gdatastr.imgsigma
;	gmax=gdatastr.imgmax
;	gmaxerr=gdatastr.maxstd
;	gerr=gdatastr.sigmastd
;	gtim=anytim(gdatastr.imgtime)
	restore,'~/science/data/cycle23_sav/sunspot_monthly_num_sdic.sav',/verb

;	plot,dtim/secpyear-anytim('01-jan-1997')/secpyear,dsig,ps=4, $
;		title='STDEV of MDI B values', xtit='Years since 1-Jan-1997', ytit='STDV [G]'
;	oplot,sstim/secpyear-anytim('01-jan-1997')/secpyear,(ssnum)/max(ssnum)*max(dsig), thick=2
;	OPLOTERR,dtim/secpyear-anytim('01-jan-1997')/secpyear,dsig,derr,ps=4;,color=!red
;	oplot,[-1d6,1d6],[mean(dsig),mean(dsig)], color=!forest
	
;;	plot,gtim/secpyear-anytim('01-jan-1997')/secpyear,gsig,ps=4, $
;;		title='STDEV of Grad B values', xtit='Years since 1-Jan-1997', ytit='STDV [G/Mm]'
;;	oplot,sstim/secpyear-anytim('01-jan-1997')/secpyear,(ssnum)/max(ssnum)*max(gsig), thick=2
;;	OPLOTERR,gtim/secpyear-anytim('01-jan-1997')/secpyear,gsig,gerr,ps=4;,color=!red
;;	oplot,[-1d6,1d6],[mean(gsig),mean(gsig)], color=!forest
	
;	;closeplotenv
	
;	;stop

;	;setplotenv,/ps,file=plotp+'mdi_quiet_max_vs_cycle.eps',xs=24,ys=24
	setcolors,/sys
	
	plot,dtim/secpyear-anytim('01-jan-1997')/secpyear,dmax,ps=4, $
		title='Max of MDI B values', xtit='Years since 1-Jan-1997', ytit='Max [G]'
	oplot,sstim/secpyear-anytim('01-jan-1997')/secpyear,(ssnum)/max(ssnum)*max(dmax), thick=2
	OPLOTERR,dtim/secpyear-anytim('01-jan-1997')/secpyear,dmax,dmaxerr,ps=4;,color=!red
	oplot,[-1d6,1d6],[mean(dmax),mean(dmax)], color=!forest
	
;;	plot,gtim/secpyear-anytim('01-jan-1997')/secpyear,gmax,ps=4, $
;;		title='Max of Grad B values', xtit='Years since 1-Jan-1997', ytit='Max [G/Mm]'
;;	oplot,sstim/secpyear-anytim('01-jan-1997')/secpyear,(ssnum)/max(ssnum)*max(gmax), thick=2
;;	OPLOTERR,gtim/secpyear-anytim('01-jan-1997')/secpyear,gmax,gmaxerr,ps=4;,color=!red
;;	oplot,[-1d6,1d6],[mean(gmax),mean(gmax)], color=!forest
	
;	;closeplotenv
	
	closeplotenv
	
	stop

;--------------------------------------------------------->
endif


if keyword_set(pbactivethresh) then begin
;--------------------------------------------------------->
;B threshold, Grad B threshold for active sun only.

	secpyear=3600.*24.*365.
	smartsavp=smart_paths(/savp)
	plotp='~/science/plots/smart_paper/'
	;contains SSN and SSTIM
	filessn='~/science/data/cycle23_sav/sunspot_monthly_num_sdic.sav'
	
	files=file_search(smart_paths(/mdip),'*.fits')
	fday=time2file(file2time(files),/date)
	fmonth=strmid(time2file(file2time(files),/date),0,6)
	
	ufcal=uniq(fmonth)
	fcal=files
	nfile=n_elements(fcal)

	mreadfits, fcal[0], indexstr, data
	fits2map, fcal[0], testmap
	imgsz=size(data)
	
	mmppx=smart_mdipxarea(testmap, /mmppx)
	print,'MEGAMETERS PER PIXEL = '+strtrim(mmppx,2)
	
	index2map,indexstr,data,testmap
	hglatlon_map, hglon,hglat, [testmap.dx,testmap.dy], imgsz, offlimb,time=testmap.time

	if not keyword_set(res2toresav) then begin

	if not keyword_set(restoresav) then begin

	answarr=strarr(nfile)+'n'

	for i=0,nfile-1 do begin
		mreadfits, fcal[i], index, data

		index2map,index,data,thismap
			
		imgcal=smart_mdimagprep(data, losmap, nsmooth=5., /nolos, /nonoise);, nosmooth=nosmooth, nonoise=nonoise, nolos=nolos, nofinite=nofinite)

	imgsqr=imgcal[550:650,550:650]
	imgmm=abs(minmax(imgsqr))
	print,imgmm
		
	print,'I = '+strtrim(i,2)
	print,'DAY = '+fday[i]

	if imgmm[0] gt 100 and imgmm[1] gt 100 then begin
		if index.MISSVALS eq 0 then answarr[i]='y'
	endif

	endfor
		
	save,fcal,answarr,file=smartsavp+'/arg_plots_activebvals_'+time2file(systim(/utc))+'.sav'
	
	endif else begin
		savfile=(reverse(file_search(smartsavp, 'arg_plots_activebvals_*.sav', /fully_qualify)))[0]
		restore,savfile
	endelse

	wfcal=where(answarr eq 'y')
	fcal=files[wfcal]
	nfile=n_elements(fcal)
	
	fmonth=strmid(time2file(file2time(fcal),/date),0,6)
	
	ufmonth=uniq(fmonth)
	nmonth=n_elements(ufmonth)

	datastr={imgindex:indexstr, imgtime:'', imgmax:0., maxstd:0., imgmean:0., meanstd:0., imgsigma:0., sigmastd:0., imgkurt:0., kurtstd:0.} ;imgvals:blank, 
	datastr=replicate(datastr,nmonth)
	
	gdatastr={imgindex:indexstr, imgtime:'', imgmax:0., maxstd:0., imgmean:0., meanstd:0., imgsigma:0., sigmastd:0., imgkurt:0., kurtstd:0.} ;imgvals:blank, 
	gdatastr=replicate(gdatastr,nmonth)	

	for i=0,nmonth-1 do begin

		print,'MONTH = '+strtrim(fmonth[ufmonth[i]],2)
		wmonth=where(fmonth eq fmonth[ufmonth[i]])

		if n_elements(wmonth) ge 2 then begin
			nday=n_elements(wmonth)
			fdaylist=fcal[wmonth]

			maxarr=fltarr(nday)			
			meanarr=fltarr(nday)
			sigmaarr=fltarr(nday)
			kurtarr=fltarr(nday)

			gmaxarr=fltarr(nday)			
			gmeanarr=fltarr(nday)
			gsigmaarr=fltarr(nday)
			gkurtarr=fltarr(nday)		
			
			for k=0,nday-1 do begin
	
				mreadfits, fdaylist[k], index, data
				index2map,index,data,thismap	
				imgcal=smart_mdimagprep(data, losmap, nsmooth=5., /nolos, /nonoise);, nosmooth=nosmooth, nonoise=nonoise, nolos=nolos, nofinite=nofinite)
	
				imgsqr=imgcal[550:650,550:650]
				gradsqr=abs(deriv(imgsqr))/mmppx ;in Gauss per Mm
	
				absimgsqr=abs(imgsqr)
		
	;Calculate statistical moments of B values.
				maxarr[k]=max(absimgsqr)
				meanarr[k]=mean(absimgsqr)
				sigmaarr[k]=stddev(imgsqr)
				kurtarr[k]=kurtosis(imgsqr)
				
				gmaxarr[k]=max(gradsqr)
				gmeanarr[k]=mean(gradsqr)
				gsigmaarr[k]=stddev(gradsqr)
				gkurtarr[k]=kurtosis(gradsqr)
	
			endfor
			
	
			
	;Put values in data structure.
			datastr[i].imgtime=thismap.time
	;Statistical moments.
			datastr[i].imgmax=mean(maxarr) ;uses abs vals
			datastr[i].imgmean=mean(meanarr) ;uses abs vals
			datastr[i].imgsigma=mean(sigmaarr) ;uses signed vals
			datastr[i].imgkurt=mean(kurtarr) ;uses signed vals
	;Error bars for mements.
			datastr[i].maxstd=stddev(maxarr)
			datastr[i].meanstd=stddev(meanarr)
			datastr[i].sigmastd=stddev(sigmaarr)
			datastr[i].kurtstd=stddev(kurtarr)
		
	;Put values in gradient data structure.
			gdatastr[i].imgtime=thismap.time
	;Statistical moments.
			gdatastr[i].imgmax=mean(gmaxarr)
			gdatastr[i].imgmean=mean(gmeanarr)
			gdatastr[i].imgsigma=mean(gsigmaarr)
			gdatastr[i].imgkurt=mean(gkurtarr)
	;Error bars for mements.
			gdatastr[i].maxstd=stddev(gmaxarr)
			gdatastr[i].meanstd=stddev(gmeanarr)
			gdatastr[i].sigmastd=stddev(gsigmaarr)
			gdatastr[i].kurtstd=stddev(gkurtarr)

		endif else begin & datastr[i].imgtime=-1 & gdatastr[i].imgtime=-1 & endelse
		
	endfor
	
	save,datastr,gdatastr,file=smartsavp+'/arg_plots_activestruc_'+time2file(systim(/utc))+'.sav'
	
	endif else begin
		savfile=(reverse(file_search(smartsavp, 'arg_plots_activestruc_*.sav', /fully_qualify)))[0]
		restore,savfile,/verb
	endelse
	
	wgood=where(datastr.imgtime ne -1)
	datastr=datastr[wgood]
	gdatastr=gdatastr[wgood]
	
	setplotenv,/ps,file=plotp+'mdi_active_stddev_maxb_vs_cycle100x100_sm1_bth100.eps',xs=24,ys=24
	
	;setplotenv,/ps,file=plotp+'mdi_active_stddev_vs_cycle100x100_sm1_bth100.eps',xs=24,ys=24
	setcolors,/sys
	
	;!p.multi=0;[0,1,2]
	!p.multi=[0,1,2]
	
	dsig=datastr.imgsigma
	dmax=datastr.imgmax
	dmaxerr=datastr.maxstd
	derr=datastr.sigmastd
	dtim=anytim(datastr.imgtime)
	gsig=gdatastr.imgsigma
	gmax=gdatastr.imgmax
	gmaxerr=gdatastr.maxstd
	gerr=gdatastr.sigmastd
	gtim=anytim(gdatastr.imgtime)
	restore,'~/science/data/cycle23_sav/sunspot_monthly_num_sdic.sav',/verb

	plot,dtim/secpyear-anytim('01-jan-1997')/secpyear,dsig,ps=4, $
		title='STDEV of MDI B values', xtit='Years since 1-Jan-1997', ytit='STDV [G]'
	oplot,sstim/secpyear-anytim('01-jan-1997')/secpyear,(ssnum)/max(ssnum)*max(dsig), thick=2
	OPLOTERR,dtim/secpyear-anytim('01-jan-1997')/secpyear,dsig,derr,ps=4;,color=!red
	oplot,[-1d6,1d6],[mean(dsig),mean(dsig)], color=!forest
	
;	plot,gtim/secpyear-anytim('01-jan-1997')/secpyear,gsig,ps=4, $
;		title='STDEV of Grad B values', xtit='Years since 1-Jan-1997', ytit='STDV [G/Mm]'
;	oplot,sstim/secpyear-anytim('01-jan-1997')/secpyear,(ssnum)/max(ssnum)*max(gsig), thick=2
;	OPLOTERR,gtim/secpyear-anytim('01-jan-1997')/secpyear,gsig,gerr,ps=4;,color=!red
;	oplot,[-1d6,1d6],[mean(gsig),mean(gsig)], color=!forest
	
	;closeplotenv
	
	;stop

	;setplotenv,/ps,file=plotp+'mdi_active_max_vs_cycle.eps',xs=24,ys=24
	setcolors,/sys
	
	plot,dtim/secpyear-anytim('01-jan-1997')/secpyear,dmax,ps=4, $
		title='Max of MDI B values', xtit='Years since 1-Jan-1997', ytit='Max [G]'
	oplot,sstim/secpyear-anytim('01-jan-1997')/secpyear,(ssnum)/max(ssnum)*max(dmax), thick=2
	OPLOTERR,dtim/secpyear-anytim('01-jan-1997')/secpyear,dmax,dmaxerr,ps=4;,color=!red
	oplot,[-1d6,1d6],[mean(dmax),mean(dmax)], color=!forest
	
;	plot,gtim/secpyear-anytim('01-jan-1997')/secpyear,gmax,ps=4, $
;		title='Max of Grad B values', xtit='Years since 1-Jan-1997', ytit='Max [G/Mm]'
;	oplot,sstim/secpyear-anytim('01-jan-1997')/secpyear,(ssnum)/max(ssnum)*max(gmax), thick=2
;	OPLOTERR,gtim/secpyear-anytim('01-jan-1997')/secpyear,gmax,gmaxerr,ps=4;,color=!red
;	oplot,[-1d6,1d6],[mean(gmax),mean(gmax)], color=!forest
	
	;closeplotenv
	
	closeplotenv
	
	stop

;--------------------------------------------------------->
endif


if keyword_set(pbhistthresh) then begin
;--------------------------------------------------------->
;B threshold, Grad B threshold, OPLOT histograms AR and quiet sun.

ARTYPE = 'BETA'
ARSMOOTH = '1'
bin=5

	x=obj_new('solmon')

if artype eq 'BETA' then begin
;Do Beta Region. 17-sep-1997
	x->set,time='17-sep-1997', inst='mdi', filt='mag'
	data=x->getdata()
	map=x->getmap()
	if arsmooth eq 1 then data=smart_grow(data, /gaus, rad=5)
	plot_image,data < 300 > (-300)
	subar=data[350:550,600:800]
	subqs=data[350:550,200:400]
endif
if artype eq 'PLAGE' then begin
;Do Beta Region. 25-apr-1998
	x->set,time='25-apr-1998', inst='mdi', filt='mag'
	data=x->getdata()
	map=x->getmap()
	if arsmooth eq 1 then data=smart_grow(data, /gaus, rad=5)
	plot_image,data < 300 > (-300)
	subar=data[400:600,250:450]
	subqs=data[350:550,500:700]
endif
if artype eq 'BGDELTA' then begin
;Do Beta Region. 16-mar-1998
	x->set,time='16-mar-1998', inst='mdi', filt='mag'
	data=x->getdata()
	map=x->getmap()
	plot_image,data < 300 > (-300)
	if arsmooth eq 1 then data=smart_grow(data, /gaus, rad=5)
	subar=data[500:700,275:475]
	subqs=data[500:700,450:650]
endif

;stop

	setplotenv,/ps,file=plotp+'mdi_qs_ar'+strlowcase(artype)+'_sm'+strtrim(arsmooth,2)+'.eps',xs=24,ys=24

	!p.multi=[0,2,2]
	!p.thick=10
	!p.charsize=5
	loadct,0
	plot_image,subar < 300 > (-300), title='NOAA AR 8086', xtit='Pixels'
	colorbar,maxr=max(300),minr=min(-300),pos=[.55,.6,.57,.95],/vert, charsize=4.2
	xyouts,.53,.56,'[G]',/norm
	setcolors,/sys
	;contour,abs(subar),level=[stddev(subqs),50],/over,c_color=[!blue,!green], C_LINESTYLE=[3,0]
	contour,abs(subar),level=[stddev(subqs),8.*stddev(subqs)],/over,c_color=[!orange,!green], C_LINESTYLE=[3,0], C_THICK=[10,20]
	loadct,0
	plot_image,subqs < 300 > (-300), title='Quiet '+(str_sep(map.time,' '))[0]
	setcolors,/sys
	;contour,abs(subqs), level=[stddev(subqs),50],/over,c_color=[!blue,!green], C_LINESTYLE=[3,0]
	contour,abs(subqs), level=[stddev(subqs),8.*stddev(subqs)],/over,c_color=[!orange,!green], C_LINESTYLE=[3,0], C_THICK=[10,20]
	;stop

qshist=histogram(subqs,loc=qshistx,bin=bin,min=-1000., max=1000.)
arhist=histogram(subar,loc=arhistx,bin=bin,min=-1000., max=1000.)
diffhist=(arhist-qshist) > 0

;!p.multi=0
;setcolors,/sys
;plot,arhistx, arhist, /ylog, ps=10, xr=[-1000,1000], yr=[.1, 10d3]
;oplot,qshistx, qshist, color=!blue, ps=10, linestyle=1, thick=3
;oplot,arhistx, diffhist, color=!red, thick=3, ps=10

;oplot,[stddev(subqs),stddev(subqs)],[.1,1d6],color=!orange, line=3
;oplot,[50.,50.],[.1,1d6],color=!orange   
;oplot,[0.,0.],[.1,1d6],color=!orange, line=1
;print,stddev(subqs)

;;!p.multi=0
;;plot_hist,subar,/log,xr=[-1000,1000]
;;setcolors,/sys
;;plot_hist,subqs,/log,/oplot,color=!red
;;print,stddev(subqs) 
;;oplot,[stddev(subqs),stddev(subqs)],[.1,1d6],color=!yellow  
;;oplot,[3.*stddev(subqs),3.*stddev(subqs)],[.1,1d6],color=!yellow
;;oplot,[50.,50.],[.1,1d6],color=!orange                          
;;print,3.*stddev(subqs)

;stop

qshist=histogram(abs(subqs),loc=qshistx,bin=bin,min=0., max=1000.)
arhist=histogram(abs(subar),loc=arhistx,bin=bin,min=0., max=1000.)
diffhist=(arhist-qshist) > 0

!p.multi=[1,1,2]
setcolors,/sys
plot,arhistx, arhist, /xlog, /ylog, ps=10, xr=[1,1000], yr=[.1, 10d3], $
title='|B| Value Distribution (AR, QS, AR-QS)', xtit='|B| [G]', ytit='# of Pixels' 
oplot,qshistx, qshist, color=!blue, ps=10, linestyle=3
oplot,arhistx, diffhist, color=!red, ps=10, thick=20

oplot,[stddev(subqs),stddev(subqs)],[.1,1d6],color=!orange, line=3
oplot,[8.*stddev(subqs),8.*stddev(subqs)],[.1,1d6],color=!forest
;oplot,[50.,50.],[.1,1d6],color=!orange   
oplot,[0.,0.],[.1,1d6],color=!orange, line=1
print,stddev(subqs)

;legend,['QS', 'AR', 'AR-QS', '1'+textoidl('\sigma')+'='+strtrim(string(stddev(subqs),format='(F10.1)'),2)+'G', '8'+textoidl('\sigma')], line=[3,0,0,3,0], $
;	color=[!blue, !black, !red, !orange, !forest], thick=[10,10,20,10,10], psym=[10,10,10,10,10]$
;	/top, /right
!p.charsize=3
!p.multi=[3,2,2]
legend,['QS', 'AR', 'AR-QS', '1'+textoidl('\sigma'), '8'+textoidl('\sigma')], line=[3,0,0,3,0], $
	color=[!blue, !black, !red, !orange, !forest], thick=[10,10,20,10,10], $
	/bottom, /left, /clear

closeplotenv

save,arhistx,arhist,qshistx,qshist,diffhist,file='~/science/data/smart_paper_sav/bhistthresh_'+strlowcase(artype)+'_smooth'+strtrim(ARSMOOTH,2)+'.sav'

stop

;--------------------------------------------------------->
endif


if keyword_set(pcomparear) then begin
;--------------------------------------------------------->
;Compare AR distributions

ARSMOOTH=1

if arsmooth eq 0 then begin
	filebe='~/science/data/smart_paper_sav/bhistthresh_beta_smooth0.sav'
	filebg='~/science/data/smart_paper_sav/bhistthresh_bgdelta_smooth0.sav'
	filepl='~/science/data/smart_paper_sav/bhistthresh_plage_smooth0.sav'
endif else begin
	filebe='~/science/data/smart_paper_sav/bhistthresh_beta_smooth1.sav'
	filebg='~/science/data/smart_paper_sav/bhistthresh_bgdelta_smooth1.sav'
	filepl='~/science/data/smart_paper_sav/bhistthresh_plage_smooth1.sav'
endelse


!p.thick=10
!p.multi=[0,1,2]
setcolors,/sys

restore,filepl
pldist=diffhist
plx=arhistx

restore,filebe
bedist=diffhist
bex=arhistx

restore,filebg
bgdist=diffhist
bgx=arhistx

setplotenv,/ps,file=plotp+'mdi_qs_ar_bg-be-pl_sm'+strtrim(arsmooth,2)+'.eps',xs=24,ys=24
setcolors,/sys

plot,bgx,bgdist,ps=10,/ylog,/xlog,xr=[10,1d4],yr=[1,1d3], $
	title='Plage, Beta, and BGD, |B| Distributions', ytit='#',xtit='|B| [G]'
oplot,plx,pldist,ps=10,color=!blue,line=3
oplot,bex,bedist,ps=10,color=!red,thick=20
oplot,bgx,bgdist,ps=10,color=!black
oplot,[50.,50.],[.0001,1d6],color=!orange,line=3

legend,['Plage', 'Beta', 'BGD', '50G'], line=[3,0,0,3], $
	color=[!blue, !red, !black, !orange], thick=[10,20,10,10], $
	/top, /right

plot,bgx,bgdist/float(max(bgdist)),ps=10,/ylog,/xlog,xr=[10,1d4],yr=[.001,2], $
	title='Plage, Beta, and BGD, |B| Distributions', ytit='#',xtit='|B| [G]'
oplot,plx,pldist/float(max(pldist)),ps=10,color=!blue,line=3
oplot,bex,bedist/float(max(bedist)),ps=10,color=!red,thick=20
oplot,bgx,bgdist/float(max(bgdist)),ps=10,color=!black
oplot,[50.,50.],[.00001,1d6],color=!orange,line=3

legend,['Plage', 'Beta', 'BGD', '50G'], line=[3,0,0,3], $
	color=[!blue, !red, !black, !orange], thick=[10,20,10,10], $
	/top, /right

closeplotenv

stop

;--------------------------------------------------------->
endif


if keyword_set(palgorithm) then begin
;--------------------------------------------------------->
;Images of progress through algorithm.

	NOISETHRESH=50 ;Gauss
	GAUSSSMOOTH=5 ;Pixels
	GROWAR=10 ;Pixels
	AREATHRESH=50 ;Pixels
	
	path='~/science/data/mdi_cycle23/'
	;file1='smdi_fd_19970917_1115.fits'
	;file2='smdi_fd_19970917_2359.fits'
	file1='smdi_fd_19990318_0000.fits'
	file2='smdi_fd_19990318_1112.fits'
	
	mreadfits,path+file1,ind1,data1
	mreadfits,path+file2,ind2,data2
	
	index2map,ind1,data1,map1
	index2map,ind2,data2,map2
	
	map1=drot_map(map1,abs(anytim(map2.time)-anytim(map1.time)),/seconds)
	data1=map1.data

	imgsz=size(data1)
	blank=fltarr(imgsz[1],imgsz[2])
	yarc=findgen(imgsz[2])
	xarc=findgen(imgsz[2])
	yarc=(yarc-imgsz[2]/2.)/(max(yarc/2.))*map1.dy
	xarc=(xarc-imgsz[1]/2.)/(max(xarc/2.))*map1.dx

;Do Beta Region. 17-sep-1997
	adata1=smart_mdimagprep(data1, threshnoise=NOISETHRESH, nsmooth=GAUSSSMOOTH)
	adata2=smart_mdimagprep(data2, threshnoise=NOISETHRESH, nsmooth=GAUSSSMOOTH)
	bdata2=smart_mdimagprep(data2, threshnoise=NOISETHRESH, /nosmooth)

	mask01=blank
	mask01[where(adata1 ne 0)]=1
	mask02=blank
	mask02[where(adata2 ne 0)]=1


mask1=mask01
mask2=mask02
mask1=smart_cont_sep(mask01, contlevel=.5, areathresh=AREATHRESH) ;vthresh=10.)
mask2=smart_cont_sep(mask02, contlevel=.5, areathresh=AREATHRESH) ;vthresh=10.)
if (where(mask1 gt 0))[0] ne -1 then mask1[where(mask1 gt 0)]=1 
if (where(mask2 gt 0))[0] ne -1 then mask2[where(mask2 gt 0)]=1   

	;plot_image,mask1
	;plot_image,mask2

;	diff=abs(mask2-mask1)
	diffgr=abs(smart_grow(mask2, rad=growar)-smart_grow(mask1, rad=growar))

;	diffgr01=abs(smart_grow(mask02, rad=growar/2.)-smart_grow(mask01, rad=growar/2.))

;	maskfin=mask2
;	maskfin[where(diff ne 0)]=0
	
	maskfingr=mask2
	maskfingr[where(diffgr ne 0)]=0
	
;	maskfingr01=mask02
;	maskfingr01[where(diffgr01 ne 0)]=0

;Plot Extraction Data
	
;	window,0,xs=1200,ys=800
;setplotenv,/ps,file=plotp+'algorithm_masks_grow0.eps',xs=36,ys=24
;
;	!p.multi=[0,3,2]
;	
;	plot_image, adata2 < 300 > (-300), scale=[map1.dx,map1.dy], tit='Magnetogram 2'
;	
;	plot_image,mask02*(-1), tit='Initial Mask 2'
;	plot_image,mask2, tit='Initial Mask 2 Vthresh=10'
;
;	plot_image,diff*(-1), tit='Diff Mask'
;	
;	plot_image,maskfin,tit='Final Mask (diff)'
;	plot_image,smart_grow(maskfin, rad=growar)*(-1),tit='Grown Final Mask (diff)'
;	
;closeplotenv

;stop

;Plot Extraction Data GR 

;	window,1,xs=1200,ys=800
setplotenv,/ps,file=plotp+'algorithm_masks_grow1.eps',xs=36,ys=24

	!p.multi=[0,3,2]

	plot_image, adata2 < 300 > (-300), scale=[map1.dx,map1.dy], tit='Magnetogram 1'

	plot_image,mask02*(-1), tit='Initial Mask 2'
	plot_image,mask2*(-1), tit='Initial Mask 2 Vthresh=10'
	plot_image,diffgr*(-1), tit='Diff Mask Grow'

	plot_image,maskfingr*(-1), tit='Final Mask'
	plot_image,smart_grow(maskfingr, rad=growar)*(-1),tit='Final Mask (diffgr)'

closeplotenv

;stop

;Plot Extraction Data GR (No differencing)

;	window,1,xs=1200,ys=800
;setplotenv,/ps,file=plotp+'algorithm_masks_nodiff.eps',xs=36,ys=24
;
;	!p.multi=[0,3,2]
;
;	plot_image, adata1 < 300 > (-300), scale=[map1.dx,map1.dy], tit='Magnetogram 1'
;	plot_image, adata2 < 300 > (-300), scale=[map1.dx,map1.dy], tit='Magnetogram 2'
;
;	plot_image,mask01*(-1), tit='Initial Mask 1'
;	plot_image,mask1, tit='Initial Mask 1 vthresh=10'
;	plot_image,mask2, tit='Initial Mask 2 vthresh=10'
;	plot_image,smart_grow(mask2, rad=growar)*(-1),tit='Final Mask (nodiff)'	
;	
;closeplotenv

;stop

;Plot Extraction Data GR 

;	window,1,xs=1200,ys=800
;setplotenv,/ps,file=plotp+'algorithm_masks_simpdiff.eps',xs=36,ys=24
;
;	!p.multi=[0,3,2]

;	plot_image, adata2 < 300 > (-300), scale=[map1.dx,map1.dy], tit='Magnetogram 2'
;
;	plot_image,mask01*(-1), tit='Initial Mask 1'
;
;	plot_image,diffgr01*(-1), tit='Diff Mask Grow 01'
;	plot_image,maskfingr01*(-1), tit='Final Mask01'
;	
;	plot_image,smart_grow(maskfingr01, rad=growar)*(-1),tit='Final Mask gr 01'	
;	
;closeplotenv

finalmask=smart_grow(maskfingr, rad=growar)
save, adata1,adata2,bdata2,map2,finalmask, file=smartsavp+'/ardetectionmask.sav'

stop

;--------------------------------------------------------->
endif


if keyword_set(pfinalgorithm) then begin
;--------------------------------------------------------->
;Final Detections.

FLUXTHRESH=1d5 ;G/Mm^2 = 1*10^5 x 10^16 = 1*10^21 Mx
TPNFRACT=[.1, 10.] ;90% flux imbalance = PLAGE

restore,smartsavp+'/ardetectionmask.sav'

sepcont=smart_cont_sep(finalmask, contlevel=.5)

;window,xs=1000,ys=500

setplotenv,/ps,file=plotp+'algorithm_detections.eps',xs=24,ys=12

!p.multi=[0,2,1]

loadct,0
plot_image,sepcont*(-1),tit='Detection Contours', xtit='Pixels'

plot_image,bdata2 < 300 > (-300), tit=''
setcolors,/sys
contour,finalmask,level=.5,color=!green,/over,thick=10

pixarea=smart_mdipxarea(map2, /mmsqr)
imgsz=size(bdata2)
xyrcoord, imgsz, xcoord, ycoord, rcoord

limbmask=fltarr(imgsz[1],imgsz[2])+1.
limbmask[where(finite(map2.data) ne 1)]=0

cosmap=smart_px_area_map(rcoord, limbmask, fract90=1.)
if (where(finite(cosmap) ne 1))[0] ne -1 then cosmap[where(finite(cosmap) ne 1)]=0

ncont=max(sepcont)
arstr={id:'',xcen:0.,ycen:0.,bpos:0.,bneg:0.}
arstr=replicate(arstr,ncont)

;Finish plotting stuff!!

aridn=0

for i=0,ncont-1 do begin

	thismask=sepcont
	thismask[where(sepcont ne i+1.)]=0.
	thismask[where(sepcont eq i+1.)]=1.
	
;Use LOS corrected B values; COS() correct mask
	thisar=thismask*bdata2*1d ;in Gauss
	thismaskcos=thismask*cosmap*pixarea ;in Mm^2
	;thisdiffar=thismask*mapdiff

	arstr[i].xcen=total(abs(thisar)*thismaskcos*xcoord)/total(abs(thisar)*thismaskcos)
	arstr[i].ycen=total(abs(thisar)*thismaskcos*ycoord)/total(abs(thisar)*thismaskcos)
	
	arstr[i].bpos=total(abs(thisar > 0)*thismaskcos) ;in Gauss Mm^2
	arstr[i].bneg=total(abs(thisar < 0)*thismaskcos) ;in Gauss Mm^2

	thisbflux=arstr[i].bpos+arstr[i].bneg
	thisbfluxfrac=(arstr[i].bpos < abs(arstr[i].bneg))/(arstr[i].bpos > abs(arstr[i].bneg)) ;fraction

	thisid=''
;	if thisbflux lt fluxthresh then thisid='??'

	thisraw=map2.data*thismask
	thiskurt=kurtosis(thisraw[where(thisraw gt 0)])
	
	;if kurt less than 5 its gaussian noise?
	;have to prove using a distribution of kutoses.
	
;Differentiate PLAGE and NETWORK POINT/ PLAGE FRAGMENT
	if thisbfluxfrac lt tpnfract[0] then begin
		if thisbflux ge fluxthresh then thisid='PL' else thisid='NF'
	endif else begin
;Differentiate between FLUX EMERGENCE and potential ACTIVE REGION
		if thisbflux lt fluxthresh then thisid='EF' else begin
			aridn=aridn+1 & thisid=string(aridn, format='(I02)')
		endelse
	endelse
	
	arstr[i].id=thisid
	
	xyouts,arstr[i].xcen,arstr[i].ycen,arstr[i].id, color=!red, charsize=2, charthick=2
endfor

closeplotenv

stop

;--------------------------------------------------------->
endif


if keyword_set(pbfluxthresh) then begin
;--------------------------------------------------------->
;Find blob distribution. What blobs dissappear, and which become ARs?
;Is there a threshold for fluxemergence to develop?


stop

;--------------------------------------------------------->
endif


if keyword_set(pnlsim) then begin
;--------------------------------------------------------->
;NL Simulator

	imgsz=[2,1024,1024]
	blank=fltarr(imgsz[1],imgsz[2])
	;gauss_put(xsz, ysz, value center, xcen, xsig, ycen, ysig, background=0)
	posarr=gauss_put(imgsz[1], imgsz[2], 1000, 450, 50, 450, 50, background=0)
	negarr=gauss_put(imgsz[1], imgsz[2], -1000, 500, 50, 450, 50, background=0)

	img1=posarr+negarr
	grad1=abs(deriv(img1))

	!p.multi=[0,2,1]
	plot_image,img1
	colorbar,maxr=max(img1),minr=min(img1),pos=[.1,.9,.45,.95]
	plot_image,grad1
	colorbar,maxr=max(grad1),minr=min(grad1),pos=[.6,.9,.95,.95]

;smart_nlmagic, inmap, nlvals, nlmask, nlstruct, extractar=extractar, data=data, maskcos=maskcos, maskarea=maskarea, ps=ps, plot=plot

stop

;--------------------------------------------------------->
endif


end