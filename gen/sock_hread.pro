;----------------------------------------------->

function sock_hread, filelist=files, wgood=wgood, err=error

indexarr=''
error=''
wgood=-1

nfiles=n_elements(files)
for i=0l,nfiles-1l do begin

;sock_fits,'http://proba2.oma.be/swap/data/bsd/2010/05/17/swap_lv1_20100517_012108.fits',dummy,header=header,/nodata,err=err
	sock_fits,files[i],dummy,header=header,/nodata,err=err
	if err ne '' then begin & error='Not all files were successfully read.' & continue & endif

	if i gt 0l and var_type(indexarr) eq 8 then begin
		thisind=fitshead2struct(header, indexarr[0])
		if var_type(thisind) eq 8 then indexarr=[indexarr,thisind]
		if var_type(thisind) eq 8 then wgood=[wgood,i]
	endif
	
	if var_type(indexarr) ne 8 then begin 
		indexarr=fitshead2struct(header)
		if var_type(indexarr) eq 8 then wgood=i
	endif

endfor

if error ne '' then begin & print,[[' '],['Not all files were successfully read. Check WGOOD keyword.'],[' ']] & return, indexarr & endif

;http=obj_new('http',err=err)
;http->hset,_extra=extra
;http->list,url,page,_extra=extra,err=err
;obj_destroy,http

;*(self.filelist)=files[wgood]
;*(self.index)=indexarr

return, indexarr

end





;----------------------------------------------->
