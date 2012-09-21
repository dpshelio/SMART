pro smart_cycle_23_candidate_save

path='~/science/data/smart_sav/candidates/smart*.sav'
flist=file_search(path)
nfile=n_Elements(flist)

ar_struct_arr=smart_blanknar(/arstr)
for i=0,nfile-1 do begin

	restore,flist[i]
	
	ar_struct_arr=[ar_struct_arr,arstruct]

endfor

ar_struct_arr=ar_struct_arr[1:*]

save,ar_struct_arr,file='~/science/data/smart_sav/cycle_23_distributions.sav'

stop

end