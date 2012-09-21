;Extract the AR structures from a load of archived savs that match the IDTRACK you supply.
;For instance,
;IDL> strarr=smart_track_id('20031026_1247.ar.13',path='~/',time=['26-oct-2003','28-oct-2003'])
;will output an array of structures for the active region with catalog id, '20031026_1247.ar.13' 
;between the specified dates for files in the home directory.

;arstr=smart_track_id('20091026_1423.mg.11', path='~/science/data/smart2/sav_track/', timerange=['26-oct-2003','4-nov-2003'])

pro run_track_id, file=file, res1tore=res1tore
print,'RUN_TRACK_ID'

savpath=smart_paths(/sav,/no_cal);'~/Sites/phiggins/smart/sav/'
trackpath=smart_paths(/arsav,/no_cal);'~/Sites/phiggins/smart/tracked_sav/'
plotpath=smart_paths(/arplots,/no_cal);'~/Sites/phiggins/smart_plots_tracked/'

if not keyword_set(res1tore) then begin

	lastfile=(reverse(file))[0]
	
	thistim=anytim(file2time(lastfile),/vms)
	
	for j=0l,n_elements(file)-1l do begin
		restore,file[j]
		if j eq 0 then arstruct_arr=arstruct
		if j gt 0 then arstruct_arr=[arstruct_arr,arstruct]
	endfor
	arstruct=arstruct_arr
	smidarall=strmid(arstruct.smid,0,19)
	smidar=smidarall[uniq(smidarall)]
	
	wgood=where(strlen(smidar) gt 2)
	if wgood[0] eq -1 then begin
		print,'NOTHING TO TRACK!!'
		return
	endif
	smidar=smidar[wgood]
	smidtim=anytim(file2time(strmid(smidar,0,13)),/vms) 
	
	save,arstruct,smidarall,smidar,smidtim,file='run_track_id_structs.sav'

endif else restore,'run_track_id_structs.sav',/ver

for i=0l,n_elements(smidar)-1l do begin
	wthisar=where(smidarall eq smidar[i])
	arstr_arr=arstruct[wthisar]

;if smidtim[i] eq thistim then goto,gotoskiptrack
	;timerange=[smidtim[i],thistim]
	;idtrack=strmid(smidar[i],0,19)

	;arstr_arr=smart_track_id(idtrack, path=savpath, timerange=timerange, extstr=extstr_arr)
	
	;smart_plot_track_id, arstr_arr, extstr=extstr_arr, path=plotpath

	save,arstr_arr,file=trackpath+smidar[i]+'.sav'
	
;gotoskiptrack:

endfor

print,'DONE!!!'
stop

end