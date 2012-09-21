pro smart_struct2ascii_all_clear, arstruct, extentstr, file=file, wrpath=wrpath, outfile=outfile, append=append, $
	no_nl=no_nl, no_ext=no_ext, numid=numid, ac_file=ac_file

if n_elements(file) lt 1 then file=time2file(arstruct[0].time)

for j=0,n_elements(file)-1 do begin
	thisfile=file[j]
	
	;print,thisfile
	
	if n_elements(arstruct) lt 1 then begin
		if (reverse(str_sep(thisfile,'.')))[0] eq 'gz' then begin
			spawn,'gunzip -f '+thisfile
			restore,strjoin((str_sep(thisfile,'.'))[0:n_elements(str_sep(thisfile,'.'))-2],'.')
			spawn,'gzip -f '+strjoin((str_sep(thisfile,'.'))[0:n_elements(str_sep(thisfile,'.'))-2],'.')
		endif else restore,thisfile
	endif
	
	extentstr=arstruct.extstr
;	if not keyword_set(no_ext) and n_elements(extentstr) eq 0 then extentstr=arstruct.extstr
	
	if not keyword_set(wrpath) then wrpath=smart_paths(/log,/no_calib)
	;wrpath='~/science/data/issi_data/'
	
	if n_elements(outfile) lt 1 then outfile=wrpath+'smart_meta_'+time2file(file2time(thisfile))+'.dat'
	;if not keyword_set(outfile) then outfile=wrpath+'smart_meta_'+time2file(file2time(thisfile))+'.dat'
	
	;print,outfile
	
	if not keyword_set(append) then begin
		fsmid=string('ID',format='(A19)')
		fields=[fsmid, string(['Time','Class','Type','Xcen_px','Ycen_px','Xbarycen','Ybarycen', $
			'Hcx_asec','Hcy_asec','Hglon_deg','Hglat_deg','CarLon','CarLat', $
			'Area_Mmsq','Bflux_Mx','Bfluxp_Mx','Bfluxn_Mx','Bfluximb','DBfluxDt_Mx', $
			'Bmin_G','Bmax_G','Bmean_G'],format='(A13)')]
		if not keyword_set(no_nl) then begin
			nlfields=string(['Lnl_Mm','Lsg_Mm','MxGrad_GpMm','MeanGrad','MednGrad','Rval_Mx','WLsg_GpMm','R_Str','WLsg_Str'],format='(A13)')
			fields=[fields,nlfields]
		endif
		if not keyword_set(no_ext) then begin
			extfields=string(['HGlon_wdth','HGlat_wdth','RdegE','RdegW'],format='(A13)')
			fields=[fields,extfields]
		endif
		spawn,'echo "'+strjoin(fields,'')+'" > '+outfile
	endif
	
	nar=n_elements(arstruct)
	
	for i=0,nar-1 do begin
	
		formdata='(E13.5)'	
	
		thisar=arstruct[i]
		if not keyword_set(no_ext) then thisext=extentstr[i]
	
	;Naming
		smid=string(thisar.id,format='(A19)')
		;if strlen(thisar.smid) lt 3 then smid=string(thisar.smid,format='(A19)') else begin
		;	if keyword_set(numid) then smid=string(thisar.smid, form='(A19)') $
		;		else smid=string(strmid(thisar.smid,4,4)+'.'+strmid(thisar.smid,9,4)+'.'+(str_sep(thisar.smid,'.'))[2], form='(A19)')
		;endelse
		class=thisar.class
		type=strjoin(thisar.type,'')
		time=time2file(thisar.time)
print,(reverse(str_sep(ac_file[j],'/')))[0];time
		
	;Position Properties	
		xcen=string(thisar.xpos,form=formdata)
		ycen=string(thisar.ypos,form=formdata)
		xbary=string(thisar.xbary,form=formdata)
		ybary=string(thisar.ybary,form=formdata)
		hcenx=string(thisar.hclon,form=formdata)
		hceny=string(thisar.hclat,form=formdata)
		hglat=string(thisar.hglat,form=formdata)
		hglon=string(thisar.hglon,form=formdata)
		carlon=string(thisar.carlon,form=formdata)
		carlat=string(thisar.carlat,form=formdata)
	;Magnetic Properties
		area=string(thisar.area,form=formdata)
		flux=string(thisar.bflux*1d16,form=formdata)
		fluxp=string(thisar.bfluxpos*1d16,form=formdata)
		fluxn=string(thisar.bfluxneg*1d16,form=formdata)
		fluximb=string(abs(thisar.bfluxpos-thisar.bfluxneg)/thisar.bflux,form=formdata)
		fluxemg=string(thisar.bfluxemrg*1d16,form=formdata)
		bmin=string(thisar.bmin,form=formdata)
		bmax=string(thisar.bmax,form=formdata)
		bmean=string(thisar.meanval,form=formdata)
		
		thismeta=[smid+' ', string([time,class,type,xcen,ycen,xbary,ybary, $
			hcenx,hceny,hglon,hglat,carlon,carlat, $
			area,flux,fluxp,fluxn,fluximb,fluxemg,bmin,bmax,bmean],form='(A13)')]

	;PIL Properties
	if not keyword_set(no_nl) then begin
		lnl=string((thisar.nlstr).lnl,form=formdata)
		lsg=string((thisar.nlstr).lsg,form=formdata)
		maxgrad=string((thisar.nlstr).gradmax,form=formdata)
		meangrad=string((thisar.nlstr).gradmean,form=formdata)
		mediangrad=string((thisar.nlstr).gradmedian,form=formdata)
		rval=string((thisar.nlstr).rval,form=formdata)
		wlsg=string((thisar.nlstr).wlsg,form=formdata)
		r_star=string((thisar.nlstr).r_star,form=formdata)
		wlsg_star=string((thisar.nlstr).wlsg_star,form=formdata)

		thisnlmeta=string([lnl,lsg,maxgrad,meangrad,mediangrad,rval,wlsg,r_star,wlsg_star],form='(A13)')
		thismeta=[thismeta,thisnlmeta]
	endif

	;Extent Properties
	if not keyword_set(no_ext) then begin
		hglonwd=string(thisext.HGLONWIDTH,form=formdata)
		hglatwd=string(thisext.HGLATWIDTH,form=formdata)
		rdeglone=string((thisext.RDEGLON)[0],form=formdata)
		rdeglonw=string((thisext.RDEGLON)[1],form=formdata)

		thisextmeta=string([hglonwd,hglatwd,rdeglone,rdeglonw],form='(A13)')
		thismeta=[thismeta,thisextmeta]
	endif

		spawn,'echo "'+strjoin(thismeta,'')+' '+(reverse(str_sep(ac_file[j],'/')))[0]+'" >> '+outfile ;wrpath+'smart_meta_'+time2file(file2time(thisfile))+'.dat'
	
	endfor
endfor
end

;------------------------------------------------------------------------------------->

pro bradford_meta_all_clear, filelist=filelist, outfile=outfile

pathallclear='/Volumes/IOMEGA HDD/data/all_clear/'

;IOMEGA
;filelist=file_search(smart_paths(/no_cal,/sav)+'smart*.sav')
;LaCie
;filelist=file_search('/Volumes/LaCie/data/smart2/sav/','smart*.sav*')
;filelist=file_search('/Volumes/LaCie/data/smart2/issi/','smart_2003*.sav*')
if n_elements(filelist) lt 1 then filelist=file_search(pathallclear+'sav/allclear*')
;restore,'~/science/data/smart_sf_smart_compare/arstr_arr_1pday.sav',/ver

ac_file=[file_search(pathallclear+'mdi/2000/*'), $
		file_search(pathallclear+'mdi/2001/*'), $
		file_search(pathallclear+'mdi/2002/*'), $
		file_search(pathallclear+'mdi/2003/*'), $
		file_search(pathallclear+'mdi/2004/*'), $
		file_search(pathallclear+'mdi/2005/*')]

stop

;outfile='~/science/data/smart2/bradford_ar_properties_solarcycle_'+time2file(systim(/utc),/date)+'.txt'
if n_elements(outfile) lt 1 then outfile='./bradford_meta_output_2000-2005.txt';'+time2file(systim(/utc))+'.txt';'/Volumes/LaCie/data/smart2/issi/issi_smart_2003_may_jul.txt'

;if (reverse(str_sep(filelist[0],'.')))[0] eq 'gz' then begin
;	spawn,'gunzip -f '+filelist[0]
;	restore,strjoin((str_sep(filelist[0],'.'))[0:n_elements(str_sep(filelist[0],'.'))-2],'.')
;	spawn,'gzip -f '+strjoin((str_sep(filelist[0],'.'))[0:n_elements(str_sep(filelist[0],'.'))-2],'.')
;endif else restore,filelist[0]
restore,filelist[0]

smart_struct2ascii_all_clear, arstruct, outfile=outfile, ac_file=ac_file[0];, extentstr

for i=1l,n_elements(filelist)-1l do begin

	;restore,filelist[i]
;	if (reverse(str_sep(filelist[i],'.')))[0] eq 'gz' then begin
;		spawn,'gunzip -f '+filelist[i]
;		restore,strjoin((str_sep(filelist[i],'.'))[0:n_elements(str_sep(filelist[i],'.'))-2],'.')
;		spawn,'gzip -f '+strjoin((str_sep(filelist[i],'.'))[0:n_elements(str_sep(filelist[i],'.'))-2],'.')
;	endif else restore,filelist[i]
restore,filelist[i]

;if arstruct[0].id ne '' then $
	smart_struct2ascii_all_clear, arstruct, extentstr, outfile=outfile, /append, ac_file=ac_file[i]

endfor

print,'DONE!!'
print,'file is here: '+outfile

stop

end