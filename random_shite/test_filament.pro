;test detecting filaments

pro test_filament

mreadfits,'~/science/data/eit_plan/halpha_filament_test.fts',index
fits2map,'~/science/data/eit_plan/halpha_filament_test.fts',map

map.data=shift(map.data,22,38)
map.dx=1.52 & map.dy=1.52
crpix1=1500/2.
crpix2=1340/2.

plot_map,map,/limb

dat=map.data

;limb_correction
dat=dat-min(dat)

darklimb_correct, dat, odata, lambda = 15000., limbxyr = [crpix1,crpix2,map.rsun/map.dx]
dat=odata

plot_image,dat

stop

dd=dat[380:1000,180:800]



ddi=(dd-max(dd))*(-1.)

;ddf=smart_grow(ddi^(3.),/gaus,fwhm=3)
;ddf[where(ddf lt 1.8d6)]=0
;ddf[where(ddf ne 0)]=1

plot_image,smart_grow(ddi^(2.),/gaus,fwhm=3) > 2d6

stop

xx=smart_grow(ddi^(2.),/gaus,fwhm=3)
xx[where(xx lt 5d6)]=0
xx[where(xx ne 0)]=1
plot_image,xx

stop

plot_image,ddf

end