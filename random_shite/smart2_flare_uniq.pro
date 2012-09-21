pro smart2_flare_uniq

flarep='~/science/data/smart_eventcat/sav/'

;flare_arr
restore,flarep+'flare_arr_all_sec_20091201.sav',/verb
;arx...flrc
restore,flarep+'plotable_arstr_xmc_20091201.sav',/verb
;arstr_arr
restore,'~/science/data/smart_eventcat/sav/arstr_arr_1pday.sav',/verb

for i=0,n_elements(flrc)-1 do begin
	wevent=where(flare_arr.eventnum eq flrc[i].eventnum)
	if wevent[0] ne -1 then $
		thisregion=flare_arr[wevent[0]].region else thisregion=''
	flrc[i].region=thisregion
endfor

stop

for i=0,n_elements(flrm)-1 do begin
	wevent=where(flare_arr.eventnum eq flrm[i].eventnum)
	if wevent[0] ne -1 then $
		thisregion=flare_arr[wevent[0]].region else thisregion=''
	flrm[i].region=thisregion
endfor

for i=0,n_elements(flrx)-1 do begin
	wevent=where(flare_arr.eventnum eq flrx[i].eventnum)
	if wevent[0] ne -1 then $
		thisregion=flare_arr[wevent[0]].region else thisregion=''
	flrx[i].region=thisregion
endfor

stop

;arx,arm,arc,flrx,flrm,flrc

ars=[arx,arm,arc]
flrs=[flrx,flrm,flrc]

regions=flrs.region













end