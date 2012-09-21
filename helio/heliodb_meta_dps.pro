pro heliodb_meta_dps,filelist

wrpath='./'
;fpath=smart_paths(/sav,/no_cal);'/Volumes/IOMEGA HDD/data/smart/sav/';'/Volumes/LaCie/data/smart2/sav/'
outfile='./data/smart_heliodb_test_'+time2file(systim(/utc))+'.txt'
outlake2='./data/logs/lake2.txt'
outlake7='./data/logs/lake7.txt'
outmorph='./data/logs/lakemorph.txt'

;ff=file_search(fpath,'*');'smart_199607*')
;filelist=ff
;filelist=file_search('/Volumes/dps/Documents/MDIdata09/sav/sav/*.sav')
;filelist=file_search('./*.sav')

;;ff=ff[75:*]
;ffdate=time2file(file2time(ff),/date)
;uffdate=uniq(ffdate)
;ffdate=ffdate[uffdate]
;filelist=ff[uffdate]

if (reverse(str_sep(filelist[0],'.')))[0] eq 'gz' then begin
	spawn,'gunzip -f '+filelist[0]
	restore,strjoin((str_sep(filelist[0],'.'))[0:n_elements(str_sep(filelist[0],'.'))-2],'.'),/v
	spawn,'gzip -f '+strjoin((str_sep(filelist[0],'.'))[0:n_elements(str_sep(filelist[0],'.'))-2],'.')
endif else restore,filelist[0],/v

smart_struct2heliodb, arstruct, extentstr, armask, filenumber=1,outfile=wrpath+outfile,smlake=outlake2,lrlake=outlake7,lakemorph=outmorph;,wrpath=wrpath, append=append

;stop
nfile=n_elements(filelist)
for i=1,nfile-1 do begin
;print,'filenumber',i
	if (reverse(str_sep(filelist[i],'.')))[0] eq 'gz' then begin
		spawn,'gunzip -f '+filelist[i]
		restore,strjoin((str_sep(filelist[i],'.'))[0:n_elements(str_sep(filelist[i],'.'))-2],'.')
		spawn,'gzip -f '+strjoin((str_sep(filelist[i],'.'))[0:n_elements(str_sep(filelist[i],'.'))-2],'.')
	endif else restore,filelist[i]

	if arstruct[0].id ne '' then begin & smart_struct2heliodb, arstruct, extentstr, armask,filenumber=i+1, outfile=outfile, /append,smlake=outlake2,lrlake=outlake7,lakemorph=outmorph & endif ;, wrpath=wrpath

endfor

print,'DONE!!'
print,'file is here: '+outfile

;stop

	








end
