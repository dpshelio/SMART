pro bradford_meta, filelist=filelist, outfile=outfile

;IOMEGA
;filelist=file_search(smart_paths(/no_cal,/sav)+'smart*.sav')
;LaCie
;filelist=file_search('/Volumes/LaCie/data/smart2/sav/','smart*.sav*')
;filelist=file_search('/Volumes/LaCie/data/smart2/issi/','smart_2003*.sav*')
if n_elements(filelist) lt 1 then filelist=file_search('/Volumes/IOMEGA HDD/data/smart/sav/','smart_2010????_????.sav')
;restore,'~/science/data/smart_sf_smart_compare/arstr_arr_1pday.sav',/ver

;outfile='~/science/data/smart2/bradford_ar_properties_solarcycle_'+time2file(systim(/utc),/date)+'.txt'
if n_elements(outfile) lt 1 then outfile='./bradford_meta_output_'+time2file(systim(/utc))+'.txt';'/Volumes/LaCie/data/smart2/issi/issi_smart_2003_may_jul.txt'

if (reverse(str_sep(filelist[0],'.')))[0] eq 'gz' then begin
	spawn,'gunzip -f '+filelist[0]
	restore,strjoin((str_sep(filelist[0],'.'))[0:n_elements(str_sep(filelist[0],'.'))-2],'.')
	spawn,'gzip -f '+strjoin((str_sep(filelist[0],'.'))[0:n_elements(str_sep(filelist[0],'.'))-2],'.')
endif else restore,filelist[0]
;restore,filelist[0]

smart_struct2ascii, arstruct, outfile=outfile;, extentstr

for i=1l,n_elements(filelist)-1l do begin

	;restore,filelist[i]
	if (reverse(str_sep(filelist[i],'.')))[0] eq 'gz' then begin
		spawn,'gunzip -f '+filelist[i]
		restore,strjoin((str_sep(filelist[i],'.'))[0:n_elements(str_sep(filelist[i],'.'))-2],'.')
		spawn,'gzip -f '+strjoin((str_sep(filelist[i],'.'))[0:n_elements(str_sep(filelist[i],'.'))-2],'.')
	endif else restore,filelist[i]
if arstruct[0].id ne '' then smart_struct2ascii, arstruct, extentstr, outfile=outfile, /append

endfor

print,'DONE!!'
print,'file is here: '+outfile

stop

end