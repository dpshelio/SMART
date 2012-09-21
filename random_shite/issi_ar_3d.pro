pro issi_ar_3d

datapath='~/science/data/issi_data/bradford_3d/'

ff=file_search('~/science/data/issi_data/sav/smart_2003*')

fwrite=datapath+'smart_bradford_3d_2003.txt'

spawn,'echo "" > '+fwrite

nfile=n_elements(ff)
for i=0,nfile-1 do begin
	thisf=ff[i]
	restore,thisf,/ver
	
	;thisw=datapath+'smart_bradford_3d_'+time2file(arstruct.time)+'.dat'
	spawn,'echo "IMAGE 111'+strmid(strjoin((str_sep(thisf,'_'))[2:3],''),0,12)+' SMART " >> '+fwrite ;...
	spawn,'echo "C 1 1.0 1.0 1.0" >> '+fwrite
	spawn,'echo "C 2 1.0 1.0 0.0" >> '+fwrite
	
	an=0
	en=0
	nar=n_elements(arstruct)
	for j=0,nar-1 do begin
		if (arstruct[j].type)[1] eq 'B' then begin
			spawn,'echo "AR 1 '+string(arstruct[j].hglat,form='(f5.1)')+' '+string(arstruct[j].hglon,form='(f5.1)')+' AcReg'+strtrim(an+1,2)+'" >> '+fwrite
			an=an+1
		endif
		if (arstruct[j].type)[1] eq 'S' then begin
			spawn,'echo "AR 2 '+string(arstruct[j].hglat,form='(f5.1)')+' '+string(arstruct[j].hglon,form='(f5.1)')+' Ephem'+strtrim(en+1,2)+'" >> '+fwrite
			en=en+1
		endif
	;write header
	;string(i*100l+j,form='(I07)')	
	
	endfor
	
	spawn,'echo "IMAGEEND" >> '+fwrite
	spawn,'echo " " >> '+fwrite







endfor















end