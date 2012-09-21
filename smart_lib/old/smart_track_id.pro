;Extract the AR structures from a load of archived savs that match the IDTRACK you supply.
;For instance,
;IDL> strarr=smart_track_id('20031026_1247.ar.13',path='~/',time=['26-oct-2003','28-oct-2003'])
;will output an array of structures for the active region with catalog id, '20031026_1247.ar.13' 
;between the specified dates for files in the home directory.

;arstr=smart_track_id('20091026_1423.mg.11', path='~/science/data/smart2/sav_track/', timerange=['26-oct-2003','4-nov-2003'])

function smart_track_id, idtrack, path=path, timerange=timerange, extstr=extstr

if not keyword_set(path) then $
	path=smart_paths(/resavetrackp);'~/science/data/smart_sav_10488/candidates/'

outfiles=file_search(path+'smart_*.sav')
		
if keyword_set(timerange) then begin
	ftim=anytim(file2time(outfiles))
	timrange=anytim(timerange)
	wgood=where(ftim gt timrange[0] and ftim lt timrange[1])
	outfiles=outfiles[wgood]
endif

nfile=n_elements(outfiles)
;if not keyword_set(nostruct) then begin
	struct_arr=smart_blanknar(/arstr)
	extent_arr=smart_blanknar(/extentstr)
	
	for i=0l,nfile-1l do begin
		restore,outfiles[i]
		if n_elements(idtrack) gt 0 then begin
			basename=strmid(arstruct.smid,0,19)
			if (where(basename eq idtrack))[0] eq -1 then goto,skipstr
			arstruct=arstruct[where(basename eq idtrack)]
			if n_elements(extentstr) gt 0 then extentstr=extentstr[where(basename eq idtrack)]
		endif
		struct_arr=[struct_arr,arstruct]
		if n_elements(extentstr) gt 0 then extent_arr=[extent_arr,extentstr]
		skipstr:
	endfor
	if n_elements(struct_arr) lt 2 then begin & print,'NO MATCHES TO: '+idtrack & return,struct_arr & endif
	struct_arr=struct_arr[1l:*]
	structure=struct_arr
	if n_elements(extentstr) gt 0 then begin
		extent_arr=extent_arr[1l:*]
		extstr=extent_arr
	endif else begin
		extstr=replicate(extent_arr, n_elements(structure))
	endelse
;endif



return, structure 

end