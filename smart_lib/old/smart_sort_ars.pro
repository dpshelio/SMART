pro smart_sort_ars,filelist=filelist

savpath=smart_paths(/sav,/no_cal)
arpath=smart_paths(/arsav,/no_cal)

nfile=n_elements(filelist)

for i=0,nfile-1 do begin

	restore,filelist[i]
	
	nar=n_elements(arstruct)
	
	;help,arstruct
	
	for j=0,nar-1 do begin
		
		thisarstruct=arstruct
		thisar=thisarstruct[j]
		thisid=strmid(thisar.smid,0,19)
		thistime=thisar.time
		
		if strlen(thisid) lt 3 then goto,gotoskipar
		
		thisfile=(file_search(arpath+thisid+'.sav'))[0]
		
		if thisfile ne '' then begin
		
			restore,thisfile;,/ver
			
			wmatch=where(thisar.smid eq arstruct_arr.smid and thistime eq arstruct_arr.time)
			if wmatch[0] ne -1 then goto,gotoskipar
			
			arstruct_arr=[arstruct_arr,thisar]
			noaa_arr=[noaa_arr,noaastr_daily]
			
			print,thisar.smid
			print,'concat'
		endif else begin
			thisfile=arpath+thisid+'.sav'
			arstruct_arr=thisar
			noaa_arr=noaastr_daily
			
			print,thisar.smid
			print,'make new'
		endelse
	
		save,arstruct_arr,noaa_arr,file=thisfile
		
		thisfile=''
		
		gotoskipar: print,'GOTO'
		
	endfor



endfor





end