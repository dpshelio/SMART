pro smart_rename_mdi_soi, filelist, gzip=gzip

if n_elements(filelist) lt 1 then begin
	mdip='~/science/data/temp_mdi_data/';~/science/data/mdi_cycle23/'
	filelist=file_Search(mdip,'fd_M_96m_01d.????.????.fits',/fully);file_Search(mdip,'smdi*',/fully)
endif else mdip=''

nfile=n_elements(filelist)

for i=0,nfile-1 do begin

	mreadfits,filelist[i],ind
	if ind.missvals gt 0 then misstr='.miss' else misstr=''
	;fits2map,filelist[i],map
	;time=map.time
	tobs=ind.t_obs
	time=strmid(strjoin(str_sep(strjoin(str_sep(tobs,'.'),''),':'),''),0,15);anytim(ind.t_obs,/vms)
	
	spawn,'mv '+filelist[i]+' '+mdip+'smdi_fd_'+time+misstr+'.fits' ;mdip+'smdi_fd_'+time2file(time)+misstr+'.fits'
	if keyword_set(gzip) then spawn,'gzip -f '+mdip+'smdi_fd_'+time+misstr+'.fits';time2file(time)+misstr+'.fits'
endfor

end