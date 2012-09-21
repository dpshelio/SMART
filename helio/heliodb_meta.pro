@smart_struct2heliodb_allinone.pro
pro heliodb_meta,filelist,runname=runname,mdidir=mdidir

pathdb=smart_paths(/no_calib,/db)

if runname eq '' then runname=time2file(systim(/utc))

outfrc=runname+'_ar_frc.csv'
outfits=runname+'_ar_observation.csv'     ;done!
outobservatory=runname+'_ar_observatory.csv'
outresults=runname+'_ar_results.csv'


web=0
solarmonitor=0
sm_archive=0

for i=0,n_elements(filelist)-1 do begin

   smart_struct2heliodb_allinone,struct_filename=filelist[i],save_path=pathdb, $
                                 mdi_num=mdi_num,t_mdi_num=mdi_num_t,mdi_file_obs=outfits,/mdi_insearch,/mdi_check_num,mdi_data_dir=mdidir,mdi_save_path=pathdb, $
                                 file_ars=outresults,ars_nst=chs_nst, /ars_check_num,$
                                 solarmonitor=solarmonitor,web_path=web,sm_archive=sm_archive


endfor

smart_struct2heliodb_frcinfo,outfrc=pathdb+outfrc

smart_struct2heliodb_obsinfo,outobs=pathdb+outobservatory


print,'DBs files DONE!!'
print,'files are here: '+pathdb


end
