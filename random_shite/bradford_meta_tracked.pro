pro bradford_meta_tracked

;IOMEGA
;filelist=file_search(smart_paths(/no_cal,/sav)+'smart*.sav')
;LaCie
filelist=file_search('/Volumes/LaCie/data/smart2/issi/','smart*.sav*')
;filelist=file_search('/Volumes/LaCie/data/smart2/sav/','smart*.sav*')
;restore,'~/science/data/smart_sf_smart_compare/arstr_arr_1pday.sav',/ver

outfile='~/science/data/smart2/bradford_ar_properties_issiset_tracked_'+time2file(systim(/utc),/date)+'.txt'

if (reverse(str_sep(filelist[0],'.')))[0] eq 'gz' then begin
	spawn,'gunzip -f '+filelist[0]
	restore,strjoin((str_sep(filelist[0],'.'))[0:n_elements(str_sep(filelist[0],'.'))-2],'.')
	spawn,'gzip -f '+strjoin((str_sep(filelist[0],'.'))[0:n_elements(str_sep(filelist[0],'.'))-2],'.')
endif else restore,filelist[0]
;restore,filelist[0]

arstruct=bradford_smid2num(arstruct)
smart_struct2ascii, arstruct, extentstr, outfile=outfile,/numid

for i=1l,n_elements(filelist)-1l do begin

	;restore,filelist[i]
	if (reverse(str_sep(filelist[i],'.')))[0] eq 'gz' then begin
		spawn,'gunzip -f '+filelist[i]
		restore,strjoin((str_sep(filelist[i],'.'))[0:n_elements(str_sep(filelist[i],'.'))-2],'.')
		spawn,'gzip -f '+strjoin((str_sep(filelist[i],'.'))[0:n_elements(str_sep(filelist[i],'.'))-2],'.')
	endif else restore,filelist[i]
if arstruct[0].id ne '' then begin & arstruct=bradford_smid2num(arstruct) & smart_struct2ascii, arstruct, extentstr, outfile=outfile, /append,/numid & endif

endfor

print,'DONE!!'
print,'file is here: '+outfile

stop

end