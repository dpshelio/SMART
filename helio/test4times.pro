@timetest.pro

pro test4times
  for i=0,100 do begin
     a=timetest_0('runing_times.dat',lun=lun,t0=t0)
     bbb=findgen(100,i+1)
     ccc=fltarr(i+1,100)+(15*(i+1))
     ddd=bbb#ccc
     plot_image,ddd

    a=timetest_1(lun=lun,t0=t0)
  endfor
end


