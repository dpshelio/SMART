pro stage_smart_arg,start_date,end_date,grid=grid,runname=runname

;datadir=string(systime(/utc,/s)/100000.,format='(I6.6)')
;but more sofisticated is how is done in make_str.pro
sec10yr=315360000
datadir='smart_'+string(long(systime(2)) mod sec10yr, format='(i9.9)') 

mdidir='/tmp/'+datadir

spawn,'mkdir -p '+mdidir
;=========== Normal Run!
mdi_getfiles,start_date=start_date,end_date=end_date,dirname=datadir,grid=grid

filelist=file_search('/tmp/'+datadir+'/'+['*fits','*fits.gz'])
run_smart_arg,filelist=filelist,mdidir=mdidir,runname=runname

filelist=file_search(smart_paths(/savp,/no_calib)+'*.sav')
smart_sav_getfiles,savfiles=filelist,grid=grid

;============ Update values
run_update_smart,start_date=start_date,end_date=end_date,mdidir=mdidir,runname=runname,datadir=datadir,grid=grid


end
