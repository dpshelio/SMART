pro smart_plot_tracking_review, res1tore=res1tore

path='~/science/papers/active_regions_1/review/'

if not keyword_set(res1tore) then begin
	filename=[file_search(smart_paths(/resavetrackp,/no_cal)+'smart_200310*'),file_search(smart_paths(/resavetrackp,/no_cal)+'smart_200311*'),file_search(smart_paths(/resavetrackp,/no_cal)+'smart_200312*')]
	
	smart_persistence3, filelist=filename
	
	stop
	
	arstruct_arr=smart_blanknar(/ars)
	extstruct_arr=smart_blanknar(/ext)
	
	nfile=n_elements(filename)
	for j=0,nfile-1 do begin
	
		if (reverse(str_sep(filename[j],'.')))[0] eq 'gz' then begin
			spawn,'gunzip -f '+filename[j]
			restore,strjoin((str_sep(filename[j],'.'))[0:n_elements(str_sep(filename[j],'.'))-2],'.')
			spawn,'gzip -f '+strjoin((str_sep(filename[j],'.'))[0:n_elements(str_sep(filename[j],'.'))-2],'.')
		endif else restore,filename[j]
	
		arstruct_arr=[arstruct_arr,arstruct]
		extstruct_arr=[extstruct_arr,extentstr]
	
	endfor
	arstruct_arr=arstruct_arr[1:*]
	extstruct_arr=extstruct_arr[1:*]
	
	save,arstruct_arr,extstruct_arr,file=path+'smart_plot_tracking_review.sav'
	
	stop
endif else restore,path+'smart_plot_tracking_review.sav',/verb

war=where(arstruct_arr.smid eq '20031026_1423.mg.11')
ar10488=arstruct_arr[war]
ext10488=extstruct_arr[war]
tim=(anytim(ar10488.time)-min(anytim(ar10488.time)))/(3600.*24.)

save,ar10488,ext10488,tim,file=path+'tracking_10488.sav'

wfr=where(strmid(arstruct_arr.smid,0,19) eq '20031026_1423.mg.11' and arstruct_arr.smid ne '20031026_1423.mg.11')
arfr=arstruct_arr[wfr]
extfr=extstruct_arr[wfr]
timfr=(anytim(arfr.time)-min(anytim(arfr.time)))/(3600.*24.)

setplotenv,file=path+'tracking_10488_solrot.eps',/ps, xs=15,ys=20
	
	xychar=1.4
	pchar=3
	
	setcolors,/sys
	
	!p.multi=[0,3,5]
	
	;smart_plot_detections,smart_paths(/resav,/no_cal)+'smart_20031029_1251.sav', id='20031026_1423.mg.11',xmargin=[0,0],ymargin=[0,0]
	!x.margin=[-10,-10]
	!y.margin=[1,1]
	restore,smart_paths(/resav,/no_cal)+'smart_20031029_1251.sav'
	dd=smart_crop_ar(mdimap.data, armask, '03', arstruct=arstruct,/plot,color=0,xmargin=[5,5],ymargin=[2,2],/mm,/cont,subtitle='',title='',/iso,/standard,charsize=pchar)
	xyouts,-190,175,mdimap.time,/data,color=0,charsize=xychar
	
	restore,smart_paths(/resav,/no_cal)+'smart_20031125_1251.sav'
	dd=smart_crop_ar(mdimap.data, armask, '02', arstruct=arstruct,/plot,color=0,xmargin=[5,5],ymargin=[2,2],/mm,/cont,subtitle='',title='',/iso,/standard,charsize=pchar,ytit='')
	xyouts,-190,175,mdimap.time,/data,color=0,charsize=xychar
	
	restore,smart_paths(/resav,/no_cal)+'smart_20031222_1251.sav'
	dd=smart_crop_ar(mdimap.data, armask, '01', arstruct=arstruct,/plot,color=0,xmargin=[5,5],ymargin=[2,2],/mm,/cont,subtitle='',title='',/iso,/standard,charsize=pchar,ytit='')
	xyouts,-190,175,mdimap.time,/data,color=0,charsize=xychar
	
	imgt=(anytim(file2time(['20031029_1251','20031125_1251','20031222_1251']))-min(anytim(ar10488.time)))/(3600.*24.)
	
	setcolors,/sys,/quiet
	;plot,tim,ar10488.bflux,/nodata,/noerase,xsty=4,ysty=4
	!x.margin=[15,5]
	!y.minor=1
	!y.ticklen=.01
	blanktick=strarr(10)+' '
	plotsym,0,.5,/fill
	
	hgabs=reform(abs(abs((ext10488.hglon)[1,*])-60))
	w601=(where(hgabs eq min(hgabs)))[0]
	hgabs[w601-5:w601+5]=1d6
	w602=(where(hgabs eq min(hgabs)))[0]
	hgabs[w602-5:w602+5]=1d6
	w603=(where(hgabs eq min(hgabs)))[0]
	hgabs[w603-5:w603+5]=1d6
	w604=(where(hgabs eq min(hgabs)))[0]
	hgabs[w604-5:w604+5]=1d6
	w605=(where(hgabs eq min(hgabs)))[0]
	tvline=tim[[w601,w602,w603,w604,w605]]
	
	hgabs2=reform(abs(abs((ext10488.hglon)[0,*])-60))
	w601=(where(hgabs2 eq min(hgabs2)))[0]
	hgabs2[w601-5:w601+5]=1d6
	w602=(where(hgabs2 eq min(hgabs2)))[0]
	hgabs2[w602-5:w602+5]=1d6
	w603=(where(hgabs2 eq min(hgabs2)))[0]
	hgabs2[w603-5:w603+5]=1d6
	w604=(where(hgabs2 eq min(hgabs2)))[0]
	hgabs2[w604-5:w604+5]=1d6
	w605=(where(hgabs2 eq min(hgabs2)))[0]
	tvline2=tim[[w601,w602,w603,w604,w605]]
	
	!p.multi=[4,1,5]
	plot,tim,ar10488.bflux*1d16,ps=4,/ylog,/noerase,color=0,/xsty,xtickname=blanktick,ymargin=[0,5],ytit='Total '+textoidl('\Phi')+' [Mx]',charsize=pchar
	oplot,timfr,arfr.bflux*1d16,ps=4,color=!blue
	vline,tvline,color=!forest,/log
	vline,tvline2,color=!blue,/log
	vline,imgt,color=0,/log
	!p.multi=[3,1,5]
	plot,tim,ar10488.hglon,ps=4,/noerase,color=0,/xsty,xtickname=blanktick,ymargin=[5,0],ytit='HG Longitude [deg]',charsize=pchar
	oplot,tim,(ext10488.hglon)[0,*],ps=8,color=!blue
	oplot,tim,(ext10488.hglon)[1,*],ps=8,color=!forest
	vline,tvline,color=!forest
	vline,tvline2,color=!blue
	!p.multi=[2,1,5]
	plot,tim,ar10488.nlstr.lsg,ps=4,/ylog,/noerase,color=0,/xsty,xtickname=blanktick,ymargin=[10,-5],ytit=textoidl('L_{PSL}')+' [Mx]',charsize=pchar,yran=[1d0,1d3]
	oplot,tim,ar10488.nlstr.lnl,ps=4,color=!blue
	vline,tvline,color=!forest,/log
	vline,tvline2,color=!blue,/log
	!p.multi=[1,1,5]
	plot,tim,ar10488.nlstr.rval,ps=4,/ylog,/noerase,color=0,/xsty,ymargin=[15,-10],ytit='R [Mx]',xtit='Days since '+anytim(ar10488[0].time,/date,/vms),charsize=pchar,yran=[1d10,1d14]
	oplot,tim,ar10488.nlstr.r_star,ps=4,color=!blue
	vline,tvline,color=!forest,/log
	vline,tvline2,color=!blue,/log
	
closeplotenv
eps2png,path+'tracking_10488_solrot.eps',path+'tracking_10488_solrot.png'

stop
end