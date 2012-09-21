pro smart_paper_plot_tracking,rest1ore=rest1ore,ps=ps

filepath='~/science/data/smart_sav_10488/candidates/'

if not keyword_Set(rest1ore) then begin
	
	files=file_search(filepath+'*.sav*')
	
	timlist=anytim(file2time(files))
	
	timrange=anytim(['1-oct-2003','1-dec-2003'])
	
	files=files[where(timlist gt timrange[0] and timlist lt timrange[1])]
	
	str_arr=smart_blanknar(/ars)
	
	for i=0,n_elements(files)-1 do begin
		restore,files[i]
		str_arr=[str_arr,arstruct]
	endfor
	
	str_arr=str_arr[1:*]

	save,str_arr,files,file='smart_paper_plot_tracking.sav'
endif else restore,'smart_paper_plot_tracking.sav'

;w1=where(str_arr.id eq '19990204_0003.pl.PL')

;w2=where(str_arr.id eq '19990204.1115.ar.02')

;w1=where((str_arr.id) eq '19990702_1115.ar.06')

regname='20031028_1247.ar.05'
regname2='20031120_1115.ar.03'
w1=[where((str_arr.id) eq regname),where((str_arr.id) eq regname2)]

;wfiles=[w1[0],w1[n_elements(w1)/2],w1[n_elements(w1)-1]]
timlist=anytim(file2time(files))
timrng=anytim([str_arr[0].time,str_arr[n_elements(str_arr)/2].time,str_arr[n_elements(str_arr)-1].time])
wfiles=where(timlist ge timrng[0] and timlist le timrng[2])
wfiles=wfiles[[0,wfiles[n_elements(wfiles)/2],wfiles[n_elements(wfiles)-1]]]

wfiles=[5,7,30]

erase

;if keyword_set(ps) then setplotenv,file='~/science/plots/smart_paper_plot_tracking.eps',/ps,xs=16,ys=16
if keyword_set(ps) then setplotenv,file='~/science/plots/smart_paper_plot_tracking.eps',/ps,xs=16,ys=16

!y.margin=[-5,3]
xmargin=!x.margin

;pmulti=[0,5,6]
!p.multi=[0,3,5]

blanktick=strarr(10)+' '

wpictim=[0,0,0]

this_str=str_arr[w1]
thistim=anytim(this_str.time)
timplot=(thistim-thistim[0])/(3600.*24.)

for j=0,2 do begin
	if j eq 0 then !x.margin=[10,0]
	if j eq 1 then !x.margin=[9,1]
	if j eq 2 then !x.margin=[7,3]

	;!p.multi=[j,3,6]
	restore,files[wfiles[j]]
	
	wpictim[j]=where(abs(thistim-anytim(file2time(files[wfiles[j]]))) eq min(abs(thistim-anytim(file2time(files[wfiles[j]])))))	
	
	loadct,0
	plot_map,mdimap,dran=[-300,300],/noerase,/square,tit='',ytit='',xtit='',xtickname=blanktick,ytickname=blanktick,/limb
	maskmap=mdimap                     
	maskmap.data=armask
	setcolors,/sys
	plot_map,maskmap,level=.5,/over,color=!green,/limb
	k=where(arstruct.id eq regname or regname2)
	xyouts,(this_str[wpictim[j]].xpos-512.)*mdimap.dx,(this_str[wpictim[j]].ypos-512.)*mdimap.dy,'20031028.AR.05',/data,charsize=2,color=255;!red;arstruct[k].id,/data,color=!red,charsize=2
;	for k=0,n_elements(arstruct)-1 do xyouts,(arstruct[k].xpos-512.)*mdimap.dx,(arstruct[k].ypos-512.)*mdimap.dy,arstruct[k].id,/data,color=!red
endfor

!y.margin=[0,0]
!p.charsize=3
!x.margin=xmargin
!p.thick=10

!y.margin=[2,0]
;!y.margin=[0,0]
!p.multi=[1,1,6]
plot,timplot,this_str.hglon,/noerase,xtickname=blanktick,ytit='HGlon [deg]',/xsty,ps=-4
plot_vline, timplot[wpictim[0]], linestyle=1
plot_vline, timplot[wpictim[1]], linestyle=1
plot_vline, timplot[wpictim[2]], linestyle=1
!p.multi=[2,1,6]
plot,timplot,this_str.BLFUXEMRG*1d16,/noerase,ytit=textoidl('d\Phi /dt')+' [Mx/s]',/xsty,ps=-4
plot_vline, timplot[wpictim[0]], linestyle=1
plot_vline, timplot[wpictim[1]], linestyle=1
plot_vline, timplot[wpictim[2]], linestyle=1
!p.multi=[3,1,6]
plot,timplot,this_str.bflux*1d16,/noerase,xtickname=blanktick,ytit=textoidl('Phi')+' [Mx]',/xsty,ps=-4
plot_vline, timplot[wpictim[0]], linestyle=1
plot_vline, timplot[wpictim[1]], linestyle=1
plot_vline, timplot[wpictim[2]], linestyle=1
!p.multi=[4,1,6]
plot,timplot,abs(this_str.BFLUXPOS-this_str.BFLUXneg)/this_str.bflux,/noerase,xtickname=blanktick,ytit='Flux Imbalance [%]',/xsty,ps=-4
plot_vline, timplot[wpictim[0]], linestyle=1
plot_vline, timplot[wpictim[1]], linestyle=1
plot_vline, timplot[wpictim[2]], linestyle=1


;oplot,[],abs(this_str.BFLUXPOS-this_str.BFLUXneg)/this_str.bflux/2.
;oplot,[timplot[wpictim[0]],timplot[wpictim[0]]],[0,.3],lin=1
;oplot,[timplot[wpictim[1]],timplot[wpictim[1]]],[-1d30,1d30],lin=1
;oplot,[timplot[wpictim[2]],timplot[wpictim[2]]],[-1d30,1d30],lin=1

!p.multi=[5,1,6]
plot,timplot,this_str.hglat,/noerase,/nodata,xsty=4,ysty=4

xyouts,.1,.04,'Days past '+this_str[0].time,/norm,charsize=2

stop

if keyword_set(ps) then closeplotenv

stop

end