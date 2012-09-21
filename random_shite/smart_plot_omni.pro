pro smart_plot_omni

path='~/science/data/sep_ace_mdi/'
ff='omni2_2003.dat'

readcol,path+ff,yr,dday,hr,d4,d5,d6,d7,d8,bmagavg,magavgb,d11, $
	d12,d13,d14,d15,d16,d17,d18,d19,d20,d21,d22,iont,ionp,ionv

save,yr,dday,hr,bmagavg,magavgb,iont,ionp,ionv,file=path+'omni_plot.sav'

stop





end