pro smart_concat_arstr, res1tore=res1tore

savpath=smart_paths(/sav,/no_cal)

if not keyword_set(res1tore) then begin

	restore,'/Volumes/LaCie/data/smart2/smartsavlist.sav',/verb

;Get AR properties between first and last flare.
	timlist=anytim(file2time(savlist))

	timrng=anytim(['3-feb-1997 11:11:00','8-jan-2008 14:49:00'])

	wgood=where(timlist gt timrng[0] and timlist lt timrng[1])

	savlist=savlist[wgood]

;Take one save file per day
	ftimelist=strmid(savlist,37,8)
	savlist=savlist[uniq(ftimelist)]
endif else restore,'/Volumes/LaCie/data/smart2/smartsavlist_1pday_97_08.sav'

arstr_arr=smart_blanknar(/arstr)
nfile=n_elements(savlist)

for i=0,nfile-1 do begin
	spawn,'gunzip -f '+savlist[i]
	restore,strjoin((str_sep(savlist[i],'.'))[0l:1l],'.')
	
	arstr_arr=[arstr_arr,arstruct]
	
	spawn,'gzip -f '+strjoin((str_sep(savlist[i],'.'))[0l:1l],'.')
endfor

stop

arstr_arr=arstr_arr[1:*]

save,arstr_arr, file='~/science/data/smart_eventcat/sav/arstr_arr_1pday.sav'


stop

end