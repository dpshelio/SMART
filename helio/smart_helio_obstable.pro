function smart_helio_obstable,time,append=append,outfile=outfile, num=num, mdi_file_info=mdi_file_info

thistim=anytim(systim(/utc))

blnkstruct={id:0l,observatory_id:0l,date_obs:'',date_end:'',jdint:0d, jdfrac:0.,exp_time:0l,c_rotation:0.,bscale:0l,bzero:0l,bitpix:0l,naxis1:0l,naxis2:0l,r_sun:0.,center_x:0.,center_y:0.,cdelt1:0.,cdelt2:0.,quality:'',filename:'',date_obs_string:'',date_end_string:'',comment:'',loc_filename:'',id2:''}

;remotemdi=(mdi_time2file(time,/stanford))[0]
mditims=mdi_file_info.tim
mdifiles=mdi_file_info.file
remoteind=mdi_file_info.index
wbestremote=(where(abs(mditims-anytim(time)) eq min(abs(mditims-anytim(time)))))[0]
remotemdi=mdifiles[wbestremote]
remoteind=remoteind[wbestremote]
;;remoteind=sock_hread(filelist=remotemdi, wgood=wgood, err=error)

;mreadfits,'/Volumes/LaCie/data/mdi_mag_orig/'+(reverse(str_sep(remotemdi,'/')))[0],remoteind
if var_type(remoteind) ne 8 then begin & mreadfits,'/Volumes/LaCie/data/mdi_mag_orig/fd_M_96m_01d.1461.0000.fits',remoteind & remoteind=clear_struct(remoteind) & endif
;if error ne '' then print,'UNSUCCESSFUL REMOTE INDEX FOR: '+remotemdi

obsstr=blnkstruct

obsstr.id=num
obsstr.observatory_id=2
if (where(strlowcase(tag_names(remoteind)) eq 'date_obs'))[0] eq -1 then begin & mreadfits,'/Volumes/LaCie/data/mdi_mag_orig/fd_M_96m_01d.1461.0000.fits',remoteind & remoteind=clear_struct(remoteind) & obsstr.date_obs=time & obsstr.date_end=time & endif else begin
;anytim(remoteind.t_obs,/vms)
;anytim(remoteind.t_obs,/vms)
	obsstr.date_obs=anytim(remoteind.date_obs,/vms)
	obsstr.date_end=anytim(remoteind.date_obs,/vms)
endelse
ftime=time2file(time,/second)
yyyy=strmid(ftime,0,4) & mm=strmid(ftime,4,2) & dd=strmid(ftime,6,2) & hh=strmid(ftime,9,2) & mn=strmid(ftime,11,2) & ss=strmid(ftime,13,2)
julian=julday(mm,dd,yyyy,hh,mn,ss)
obsstr.jdint=long(julian)
obsstr.jdfrac=julian-long(julian)
obsstr.exp_time=0l;remoteind.exp_time
obsstr.c_rotation=tim2carr(time, /dc)
obsstr.bscale=1l;remoteind.bscale
obsstr.bzero=0l;remoteind.bzero
obsstr.bitpix=remoteind.bitpix
obsstr.naxis1=remoteind.naxis1
obsstr.naxis2=remoteind.naxis2
obsstr.r_sun=remoteind.r_sun;remoteind.r_sun
obsstr.center_x=remoteind.center_x
obsstr.center_y=remoteind.center_y
obsstr.cdelt1=remoteind.cdelt1
obsstr.cdelt2=remoteind.cdelt2
obsstr.quality=''
obsstr.filename=(reverse(str_sep(remotemdi,'/')))[0]
obsstr.date_obs_string=remoteind.date_obs
obsstr.date_end_string=remoteind.date_obs
obsstr.comment='';remoteind.comment
obsstr.loc_filename=remotemdi
obsstr.id2='" "'

if not keyword_set(append) then spawn,'echo "'+strjoin(tag_names(obsstr),';')+'" > '+outfile

outdataline=strarr(n_elements(tag_names(obsstr)))
for i=0,n_elements(tag_names(obsstr))-1 do outdataline[i]=strtrim(obsstr.(i),2)

spawn,'echo '''+strjoin(outdataline,';')+''' >> '+outfile

spawn,'echo "'+strtrim(abs(thistim-anytim(systim(/utc))),2)+', '+systim(/utc)+'" >> testtims_optimize.txt'

return,obsstr

end
