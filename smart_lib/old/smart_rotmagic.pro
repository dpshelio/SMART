;OUTPLOT is filename for output PNG file

function smart_rotmagic,indd, rsundeg=rsundeg, dx=dx,dy=dy, map=inmap, $
	plot=plot,time=maptime, arid=arid, ps=ps,_extra=_extra,debug=debug,outplot=outplot, outps=outps

dd=indd
map=inmap
map.data=dd
dx=map.dx
dy=map.dy


if n_elements(arid) lt 1 then arid='01'

if n_elements(outps) lt 1 then outps=smart_paths(/plotp,/no_cal)+'smart_rotation_ar'+arid+'_'+time2file(map.time)+'.eps'

;Threshold for PSL detection
gradthreshw=50.
gradthreshs=150.

;Threshold for polarity blob counting
smoothpole=5. ;smoothing radius/FWHM for AR prior to polarity counting
threshpole=.1 ;percent of total area a polarity has to be to be counted

rotstr=smart_blanknar(/rotstr)

;for i=0,nfiles-1 do begin

imgsz=size(dd)
blankarr=fltarr(imgsz[1],imgsz[2])

;Do coordinate stuff
dxdy=[dx,dy]
xyrcoord,imgsz,xx,yy,rr
hglatlon_map, hglonmap,hglatmap, dxdy, imgsz, time=maptime, /mdi

;Rotate data to disk center
mm=blankarr
wddn0=where(dd ne 0)
if wddn0[0] eq -1 then goto,getout
mm[wddn0]=1.

centall=[total(mm*abs(dd)*xx)/total(mm*abs(dd)),total(mm*abs(dd)*yy)/total(mm*abs(dd))]
hgcent=[hglonmap[centall[0],centall[1]],hglatmap[centall[0],centall[1]]]
map2=drot_map(map,-hgcent[0],/degrees,/rigid)

dd=map2.data

;Create polarity masks
if (where(dd ne 0))[0] eq -1 or (where(dd gt 0))[0] eq -1 or (where(dd lt 0))[0] eq -1 then goto,getout
mm=blankarr
mm[where(dd ne 0)]=1.
mp=blankarr
mp[where(dd gt 0)]=1
mn=blankarr
mn[where(dd lt 0)]=1

;Crop all arrays to the feature detection boundary
dd=smart_crop_ar(dd, mm, 1)
;xx=smart_crop_ar(xx, mm, 1)
;yy=smart_crop_ar(yy, mm, 1)
;rr=smart_crop_ar(rr, mm, 1)
hglonmap=smart_crop_ar(hglonmap, mm, 1)
hglatmap=smart_crop_ar(hglatmap, mm, 1)
blankarr=smart_crop_ar(blankarr, mm, 1)
mp=smart_crop_ar(mp, mm, 1)
mn=smart_crop_ar(mn, mm, 1)
mm=smart_crop_ar(mm, mm, 1)

;After crop, recreate coordinate arrays
imgsz=size(dd)
xyrcoord,imgsz,xx,yy,rr

;Calculate number of polarity blobs
smdd=smart_grow(dd,/gaus,rad=smoothpole)
smddp=blankarr
smddn=blankarr
if (where(smdd gt 0))[0] ne -1 then smddp[where(smdd gt 0)]=1.
if (where(smdd lt 0))[0] ne -1 then smddn[where(smdd lt 0)]=1.
smddp=smart_cont_sep(smddp, contlevel=.5)
smddn=smart_cont_sep(smddn, contlevel=.5)
if (where(smddn gt 0))[0] ne -1 then smddn[where(smddn gt 0)]=smddn[where(smddn gt 0)]+max(smddp)
smddcont=smddp+smddn
dummy=smart_largest_blob(smddcont,/nozero,narr=contnarr,/nosep)
wsm=where(contnarr ge threshpole*total(contnarr))
npole=n_elements(wsm)
rotstr.npole=npole

mp=smart_largest_blob(mp,dd,/flux)
mn=smart_largest_blob(mn,dd,/flux)

centall=[total(mm*abs(dd)*xx)/total(mm*abs(dd)),total(mm*abs(dd)*yy)/total(mm*abs(dd))]
centpos=[total(mp*dd*xx)/total(mp*dd),total(mp*dd*yy)/total(mp*dd)]
centneg=[total(mn*dd*xx)/total(mn*dd),total(mn*dd*yy)/total(mn*dd)]
;distpos=shift(rr,centpos[0]-imgsz[1]/2.,centpos[1]-imgsz[2]/2.)
;distneg=shift(rr,centneg[0]-imgsz[1]/2.,centneg[1]-imgsz[2]/2.)

;Calculate bipole connection line length
lbcl=sqrt((centpos[0]-centneg[1])^2.+(centpos[1]-centneg[1])^2)*smart_mdipxarea(/mmppx)
rotstr.lbcl=lbcl

;hc_lb=[(((centall[0]-100) > 0)-imgsz[1]/2.)*dxdy[0],(((centall[1]-100) > 0)-imgsz[2]/2.)*dxdy[1]]
;hc_rt=[(((centall[0]+100) < 1023)-imgsz[1]/2.)*dxdy[0],(((centall[1]+100 < 1023))-imgsz[2]/2.)*dxdy[1]]

;hg_lb=conv_a2h(hc_lb,maptime)
;hg_rt=conv_a2h(hc_rt,maptime)

;Create contour mask of latitude line through centroid
hglatmask=blankarr
hglonposmask=blankarr
hglonnegmask=blankarr

contour,hglatmap,findgen(imgsz[1]),findgen(imgsz[2]),level=hglatmap[centall[0],centall[1]],path_info=path_info,/path_data_coords,path_xy=hglatcontxy
hglatmask[hglatcontxy[0,*],hglatcontxy[1,*]]=1.
hglatmask=hglatmask*mm

contour,hglonmap,findgen(imgsz[1]),findgen(imgsz[2]),level=hglonmap[centpos[0],centpos[1]],path_info=path_info,/path_data_coords,path_xy=hglonposcontxy
hglonposmask[hglonposcontxy[0,*],hglonposcontxy[1,*]]=1.
hglonposmask=hglonposmask*mm
hglonposmask=smart_grow(hglonposmask,radius=5)+hglatmask
if (where(hglonposmask ne 2))[0] eq -1 or (where(hglonposmask eq 2))[0] eq -1 then goto,getout
hglonposmask[where(hglonposmask ne 2)]=0 & hglonposmask[where(hglonposmask eq 2)]=1.

contour,hglonmap,findgen(imgsz[1]),findgen(imgsz[2]),level=hglonmap[centneg[0],centneg[1]],path_info=path_info,/path_data_coords,path_xy=hglonnegcontxy
hglonnegmask[hglonnegcontxy[0,*],hglonnegcontxy[1,*]]=1.
hglonnegmask=hglonnegmask*mm
hglonnegmask=smart_grow(hglonnegmask,radius=5)+hglatmask
if (where(hglonnegmask ne 2))[0] eq -1 or (where(hglonnegmask eq 2))[0] eq -1 then goto,getout
hglonnegmask[where(hglonnegmask ne 2)]=0 & hglonnegmask[where(hglonnegmask eq 2)]=1.

centhgpos=[total(hglonposmask*xx)/total(hglonposmask),total(hglonposmask*yy)/total(hglonposmask)]
centhgneg=[total(hglonnegmask*xx)/total(hglonnegmask),total(hglonnegmask*yy)/total(hglonnegmask)]

;Calculate angle between HG centroid arc and bipole connecting line 
alpha=vangle([(centpos[0]-centneg[0]),(centpos[1]-centneg[1]),0],[(centhgpos[0]-centhgneg[0]),(centhgpos[1]-centhgneg[1]),0])/!dtor
rotstr.thetabcl=alpha

;Find main PSL
pslmp=smart_grow(mp,rad=4)
pslmn=smart_grow(mn,rad=4)
pslmm=blankarr
if (where((pslmp+pslmn) eq 2.))[0] eq -1 then goto,getout
pslmm[where((pslmp+pslmn) eq 2.)]=1
pslmm=m_thin(pslmm)

;Create B field weak gradient mask
gradb=abs(deriv(dd))/smart_mdipxarea(/mmppx)
gradbmaskw=blankarr
if (where(gradb ge gradthreshw))[0] eq -1 then goto,getout
gradbmaskw[where(gradb ge gradthreshw)]=1.
pslmmw=pslmm*gradbmaskw

;Find line through PSL and angle to HG arc
;weak psl
wpsl=where(pslmmw eq 1)
pslx=wpsl mod imgsz[1]
psly=wpsl/imgsz[1]
pslbm=linfit(pslx,psly)
pslx12=[min(pslx),max(pslx)]
psly12=pslbm[0]+pslbm[1]*pslx12
wpslalpha=vangle([pslx12[0]-pslx12[1], psly12[0]-psly12[1], 0],[(centhgpos[0]-centhgneg[0]),(centhgpos[1]-centhgneg[1]),0])/!dtor
rotstr.thetanl=wpslalpha

;Create B field strong gradient mask
gradbmasks=blankarr
if (where(gradb ge gradthreshs))[0] eq -1 then goto,skipstrong
gradbmasks[where(gradb ge gradthreshs)]=1.
pslmms=pslmm*gradbmasks

;strong psl
wpsl=where(pslmms eq 1)
pslx=wpsl mod imgsz[1]
psly=wpsl/imgsz[1]
pslbm=linfit(pslx,psly)
pslx12=[min(pslx),max(pslx)]
psly12=pslbm[0]+pslbm[1]*pslx12
spslalpha=vangle([pslx12[0]-pslx12[1], psly12[0]-psly12[1], 0],[(centhgpos[0]-centhgneg[0]),(centhgpos[1]-centhgneg[1]),0])/!dtor
rotstr.thetasnl=spslalpha

skipstrong:

if keyword_set(plot) then begin
if keyword_set(ps) then setplotenv,/ps,file=outplot
	loadct,0
	plot_image,dd,_extra=_extra
	setcolors,/sys
	if keyword_set(debug) then oplot,[centhgpos[0],centhgneg[0]],[centhgpos[1],centhgneg[1]],ps=-4,color=!red
	oplot,[centpos[0],centneg[0]],[centpos[1],centneg[1]],ps=-1,color=!red
	oplot,hglatcontxy[0,*],hglatcontxy[1,*],lines=1
	oplot,hglonposcontxy[0,*],hglonposcontxy[1,*],lines=1
	oplot,hglonnegcontxy[0,*],hglonnegcontxy[1,*],lines=1
	contour,pslmm,level=.5,/over,color=!white
	oplot,pslx12,psly12,color=!red,lines=2
;	dumm=''
;	help,rotstr,/str
;	read,dumm
if keyword_set(ps) then closeplotenv else $
	window_capture,file=outplot,/png
endif


;{thetanl:0d, thetabcl:0d, lbcl:0d, npole:0d, polarity:0d}

getout:
return,rotstr

end

;------------------------------------------------------------------------------>