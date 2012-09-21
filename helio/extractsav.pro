pro extractsav
datestart=systime(/s)
savdir='/Volumes/HELIO/SAV/'
eitdir='/Volumes/SOHO_EIT/EIT/lz/'
mdidir='/Volumes/LARA_WORK/MDI/mdi_mag2/'
spath='/Users/dps/Documents/HELIO/Codes/SQL/CHs/final_res_allinone/'
web=spath+'web/'
;mdipath='/Users/dps/Documents/HELIO/Codes/SQL/smart/smart_out/final_res/final_res/'

solarmonitor=1

OBSfile='OBS_table_'+year+'.csv'
grpfile='CHGrpTable_'+year+'.csv'
chsfile='CHTable_'+year+'.csv'



savfiles=findfile(savdir+'chgr_'+year+'*sav')

  for i=0,n_elements(savfiles)-1 do begin
     smart_struct2heliodb_allinone,struct_filename=savfiles[i],save_path=spath, $
                          eit_num=eit_num,eit_file_obs=obsfile,eit_data_dir=eitdir,eit_save_path=spath,/eit_insearch,/eit_check_num,$
                          mdi_num=mdi_num,mdi_file_obs=obsfile,/mdi_insearch,/mdi_check_num,mdi_data_dir=mdidir,mdi_save_path=spath, $
                          file_grp=grpfile,grp_nst=grp_nst, $
                          file_chs=chsfile,chs_nst=chs_nst, $
                          solarmonitor=solarmonitor,web_path=web

  endfor
dateend=systime(/s)
print,'********** TOTAL TIME: '+string((dateend-datestart)/3600.) +' hours, for '+string(n_elements(savfiles))+' files ********'

end
