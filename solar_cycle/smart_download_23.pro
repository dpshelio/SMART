;Download 2 images per day of MDI 96 min data
;and daily flare structures.

pro smart_download_23


tstart='19970101'
tend='20090101'

fdatearr=datearr(tstart, tend)

mdip='~/science/data/mdi_cycle23/'
flarep='~/science/data/smart_flr/'
sfflarep='~/science/data/smart_sf_flr/'

ndate=n_elements(fdatearr)

for i=0,ndate-1 do begin
	flrstr=smart_rdflare(fdatearr[i])
	
	save,flrstr,file=flarep+'flare_'+strtrim(fdatearr[i],2)+'.sav'
	
	sf_flrstr=les_archive_info(anytim(file2time(fdatearr[i]),/date))

	save,sf_flrstr,file=sfflarep+'sf_flare_'+strtrim(fdatearr[i],2)+'.sav'

	smart_allfiles, flist,daylist,timerange=[fdatearr[i],fdatearr[i]]
	
	sock_copy,flist[0]
	spawn,'mv '+(reverse(str_sep(flist[0],'/')))[0]+' '+mdip+'smdi_fd_'+strtrim(fdatearr[i],2)+'_0.fits'

	sock_copy,flist[n_elements(flist)/2]
	spawn,'mv '+(reverse(str_sep(flist[n_elements(flist)/2],'/')))[0]+' '+mdip+'smdi_fd_'+strtrim(fdatearr[i],2)+'_1.fits'

endfor




end