pro smart_concat_sav, all=all, file=file, outfile=outfile

savp=smart_paths(/savp,/no_cal)

if n_elements(outfile) ne 1l then outfile='./smart_sav_all_'+time2file(systim(/utc))+'.sav'

if n_elements(file) lt 2l then begin
	if keyword_set(all) then ff=file_search('/Volumes/IOMEGA HDD/data/smart/sav_arstr/smart_*')
	
	;TEMP!!!
	if n_elements(ff) lt 2l then begin
		print,'INPUT FILENAMES OR SET A KEYWORD!'
		return
	endif
endif else ff=file

nf=n_elements(ff)
arstruct_all=smart_blanknar(/arstr)

for i=0l,nf-1l do begin

	restore,ff[i]
	
	arstruct_all=[arstruct_all,arstruct]

endfor

arstruct_all=arstruct_all[1:*]

save,arstruct_all,file=outfile

end