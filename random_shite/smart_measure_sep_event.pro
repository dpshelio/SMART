pro smart_measure_sep_event, res1tor=res1tor

path='~/science/data/sep_mdi_ace/'

print,anytim2doy(['28-oct-2003','29-oct-2003'])
;DOY = 301, 302

if not keyword_set(res1tor) then begin

ff=file_Search(smart_paths(/mdi,/no_cal)+'*20031026*')
ff2=file_Search(smart_paths(/mdi,/no_cal)+'*20031027*')
ff3=file_Search(smart_paths(/mdi,/no_cal)+'*20031028*')
ff4=file_Search(smart_paths(/mdi,/no_cal)+'*20031029*')
ff5=file_Search(smart_paths(/mdi,/no_cal)+'*20031030*')
ff6=file_Search(smart_paths(/mdi,/no_cal)+'*20031031*')

ff=[ff,ff2,ff3,ff4,ff5,ff6]

window,xs=800,ys=800
loadct,0,/silent
;!p.multi=[0,1,2]

nfile=n_elements(ff)

iarr=fltarr(nfile)
narr=iarr
farr=iarr
tarr=iarr
timarr=iarr

for i=0,nfile-1 do begin
	;mreadfits,ff[i],ind,dat,/silent
	fits2map,ff[i],map,/silent
	dat=map.data
	tim=(anytim(map.time)-anytim('26-oct-2003'))/(3600.*24.)
	timarr[i]=tim
	
	dd=abs(dat[400:800,650:800])

loadct,0,/silent
;	!p.multi=[0,1,2]
	plot_image,dd > 100,/noerase, position=[.1,.6,.9,.9],xtickname=strarr(10)+' ',tit='days since 26 oct 2003'
;	!p.multi=[1,1,2]
	plot_image,dat[400:800,650:800] > (-200) < 200,/noerase, position=[.1,.3,.9,.6]
	
	narr[i]=n_elements(where(dd gt 100))
	iarr[i]=i
	farr[i]=total(dd[where(dd gt 100)])
	tarr[i]=total(dd)
	
	
	plot,timarr,narr,/xstyle,/ystyle,yran=[1d2,1d7],xran=[0,7],/ylog,/noerase,position=[.1,.05,.9,.3]
	setcolors,/sys,/quiet
	oplot,timarr,farr,color=!red
	oplot,timarr,tarr,color=!green
	
	window_capture,file=path+'pngs/sep_'+string(i,form='(I03)'),/png
	
	;wait,.1

endfor

save,timarr,tarr,farr,narr,file=path+'smart_measure_sep_event.sav'

endif else restore,path+'smart_measure_sep_event.sav',/verb

;year day hr proton_density proton_temp He4toprotons proton_speed
readcol,path+'ace_hrly_276_302.txt',x1,x2,x3,x4,x5,x6,x7,skip=31
readcol,path+'ace_hrly_303_329.txt',y1,y2,y3,y4,y5,y6,y7,skip=31

x1=[x1,y1]
x2=[x2,y2]
x3=[x3,y3]
x4=[x4,y4]
x5=[x5,y5]
x6=[x6,y6]
x7=[x7,y7]

window
!p.multi=0

acetim4=fltarr(n_elements(x1))
for j=0,n_elements(x1)-1 do acetim4[j]=((doytodate(x1[j],x2[j])+(x3[j]*3600.))-anytim('26-oct-2003'))/(3600.*24.)

acetim5=acetim4
acetim7=acetim4

wgood4=where(x4 ne '-9.9999e+03')
acetim4=acetim4[wgood4] & x4=x4[wgood4]
wgood5=where(x5 ne '-9.9999e+03')
acetim5=acetim5[wgood5] & x5=x5[wgood5]
wgood7=where(x7 ne '-9.9999e+03')
acetim7=acetim7[wgood7] & x7=x7[wgood7]

plot,timarr,(farr-min(farr))/max(farr),/xstyle,/ystyle,yran=[0,1.2],xran=[0,7],/noerase,xtit='days since 26 oct 2003',ytit='normalized units',charsize=1.4;,position=[.1,.05,.9,.3]
setcolors,/sys,/quiet
oplot,timarr,farr,color=!red
oplot,timarr,tarr,color=!green
;oplot,acetim4,(x4-min(x4))/max(x4),color=!red
;oplot,acetim5,(x5-min(x5))/max(x5),color=!green
;oplot,acetim7,(x7-min(x7))/max(x7),color=!cyan

;save,omtim,yr,dday,hr,bmagavg,magavgb,iont,ionp,ionv,file=path+'omni_plot.sav'
restore,path+'omni_plot.sav',/verb

nom=n_elements(dday)
omtim=fltarr(nom)
firstd=anytim('26-oct-2003')
for k=0,nom-1 do omtim[k]=((doytodate(yr[k],dday[k])+hr[k]*3600.)-firstd)/(3600.*24.)

wgood=where(dday gt 298 and dday lt 306)
ionp=ionp[wgood]
iont=iont[wgood]
ionv=ionv[wgood]
omtim=omtim[wgood]
dday=dday[wgood]

wp=where(ionp ne '999.900')
ionp=ionp[wp] & pomtim=omtim[wp] & pdday=dday[wp]
;wt=where(iont ne '9999.00')
iont=iont & tomtim=omtim & tdday=dday
wv=where(ionv ne '9999.00')
ionv=ionv[wv] & vomtim=omtim[wv] & vdday=dday[wv]

oplot,pomtim,(ionp-min(ionp))/max(ionp),color=!red
oplot,tomtim,(iont-min(iont))/max(iont),color=!green
oplot,vomtim,(ionv-min(ionv))/max(ionv),color=!cyan

legend,['ion p','ion T','ion v'],color=[!red,!green,!cyan],psym=[-4,-4,-4],charsize=1.2

window_capture,file=path+'omni_vs_mdi_20031026',/png

stop

end