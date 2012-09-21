pro smart_tracked_region_props

datapath='/Volumes/IOMEGA HDD/data/smart/ars/'
filelist=file_search(datapath+'*.mg.*.sav')

nfile=n_elements(filelist)

restore,filelist[0]
arstruct_arr=arstr_arr[0]

for i=0,nfile-1l do begin

	restore,filelist[i]

	wgood=where(arstr_arr.hglon ge (-60.) and arstr_arr.hglon le 60.)
	
	if wgood[0] eq -1 then continue

	wmax=where(arstr_arr.bflux eq max(arstr_arr.bflux))
	arstr_arr=arstr_arr[wmax]
	
	arstruct_arr=[arstruct_arr,arstr_arr]
endfor

arstruct_arr=arstruct_arr[1:*]


print,'DONE!'





stop
end