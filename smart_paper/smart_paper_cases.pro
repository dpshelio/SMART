pro smart_paper_cases

!p.background=255
;window,xs=800,ys=800

path='~/science/papers/active_regions_1/review/'
setplotenv,file=path+'detection_test_cases.eps',/ps, xs=10,ys=10

xychar=1.4
pchar=3

setcolors,/sys

!p.multi=[0,3,3]

;smart_plot_detections,smart_paths(/resav,/no_cal)+'smart_20031029_1251.sav', id='20031026_1423.mg.11',xmargin=[0,0],ymargin=[0,0]
!x.margin=[-10,-10]
!y.margin=[1,1]
!x.tickname=strarr(10)+' '
!y.tickname=strarr(10)+' '
!x.ticklen=.0001
!y.ticklen=.0001
restore,smart_paths(/resav,/no_cal)+'smart_20031003_0803.sav'
dd=smart_crop_ar(mdimap.data, armask, '01', arstruct=arstruct,/plot,color=0,xmargin=[5,5],ymargin=[2,2],/cont,subtitle='',title='',xtitle='',ytitle='',/iso,boxdim=[400,400],charsize=pchar,/limb)
xyouts,.09,.95,mdimap.time,/norm,color=0,charsize=xychar

restore,smart_paths(/resav,/no_cal)+'smart_20031005_1424.sav'
dd=smart_crop_ar(mdimap.data, armask, '01', arstruct=arstruct,/plot,color=0,xmargin=[5,5],ymargin=[2,2],/cont,subtitle='',title='',xtitle='',ytitle='',/iso,boxdim=[400,400],charsize=pchar,/limb)
xyouts,.36,.95,mdimap.time,/norm,color=0,charsize=xychar

restore,smart_paths(/resav,/no_cal)+'smart_20031009_1115.sav'
dd=smart_crop_ar(mdimap.data, armask, '01', arstruct=arstruct,/plot,color=0,xmargin=[5,5],ymargin=[2,2],/cont,subtitle='',title='',xtitle='',ytitle='',/iso,boxdim=[400,400],charsize=pchar,/limb)
xyouts,.64,.95,mdimap.time,/norm,color=0,charsize=xychar

restore,smart_paths(/resav,/no_cal)+'smart_20020502_1247.sav'
dd=smart_crop_ar(mdimap.data, armask, '03', arstruct=arstruct,/plot,color=0,xmargin=[5,5],ymargin=[2,2],/cont,subtitle='',title='',xtitle='',ytitle='',/iso,boxdim=[400,400],charsize=pchar,/limb)
xyouts,.09,.62,mdimap.time,/norm,color=0,charsize=xychar

restore,smart_paths(/resav,/no_cal)+'smart_20020504_1247.sav'
dd=smart_crop_ar(mdimap.data, armask, '02', arstruct=arstruct,/plot,color=0,xmargin=[5,5],ymargin=[2,2],/cont,subtitle='',title='',xtitle='',ytitle='',/iso,boxdim=[400,400],charsize=pchar,/limb)
xyouts,.36,.62,mdimap.time,/norm,color=0,charsize=xychar

restore,smart_paths(/resav,/no_cal)+'smart_20020507_1248.sav'
dd=smart_crop_ar(mdimap.data, armask, '01', arstruct=arstruct,/plot,color=0,xmargin=[5,5],ymargin=[2,2],/cont,subtitle='',title='',xtitle='',ytitle='',/iso,boxdim=[400,400],charsize=pchar,/limb)
xyouts,.64,.62,mdimap.time,/norm,color=0,charsize=xychar

restore,smart_paths(/resav,/no_cal)+'smart_20040802_1247.sav'
dd=smart_crop_ar(mdimap.data, armask, '02', arstruct=arstruct,/plot,color=0,xmargin=[5,5],ymargin=[2,2],/cont,subtitle='',title='',xtitle='',ytitle='',/iso,boxdim=[400,400],charsize=pchar,/limb)
xyouts,.09,.29,mdimap.time,/norm,color=0,charsize=xychar

restore,smart_paths(/resav,/no_cal)+'smart_20040803_2047.sav'
dd=smart_crop_ar(mdimap.data, armask, '02', arstruct=arstruct,/plot,color=0,xmargin=[5,5],ymargin=[2,2],/cont,subtitle='',title='',xtitle='',ytitle='',/iso,boxdim=[400,400],charsize=pchar,/limb)
xyouts,.36,.29,mdimap.time,/norm,color=0,charsize=xychar

restore,smart_paths(/resav,/no_cal)+'smart_20040805_2047.sav'
dd=smart_crop_ar(mdimap.data, armask, '01', arstruct=arstruct,/plot,color=0,xmargin=[5,5],ymargin=[2,2],/cont,subtitle='',title='',xtitle='',ytitle='',/iso,boxdim=[400,400],charsize=pchar,/limb)
xyouts,.64,.29,mdimap.time,/norm,color=0,charsize=xychar


closeplotenv

!p.multi=0
stop






















end