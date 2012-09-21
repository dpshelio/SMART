;FILELIST = smart sav files

pro track_movie, filelist, skip_jpeg=skip_jpeg

;if n_elements(filelist) lt 2 then filelist=file_search(smart_paths(/plot,/no_calib)+'track_????????_????.png')
if n_elements(filelist) lt 2 then filelist=file_search(smart_paths(/resavetrack,/no_calib)+'smart_????????_????.sav')

if keyword_set(skip_jpeg) then goto,gotoskip_jpeg

window,2,xs=800,ys=800

nfile=n_elements(filelist)
for i=0,nfile-1 do begin
	filesimp=(reverse(str_sep(filelist[i],'/')))[0]
	thisfile=filelist[i]
	restore,thisfile
	
;	spawn,'convert '+filelist[i]+' '+smart_paths(/plot,/no_calib)+strmid(filesimp,0,19)+'.jpg'

	loadct,0
	!p.background=255
	!p.color=0
	plot_map,mdimap,dran=[-300,300], thick=3,charsize=1.4, charthick=2
	maskmap=mdimap                     
	maskmap.data=armask
	setcolors,/sys
	plot_map,maskmap,level=.5,/over,color=!green, c_thick=2
	for k=0,n_elements(arstruct)-1 do begin
		if strlen(arstruct[k].smid) lt 3 then thisplotid=arstruct[k].smid else $
			thisplotid=strmid(arstruct[k].smid,4,4)+'.'+strmid(arstruct[k].smid,9,4)+'.'+(str_sep(arstruct[k].smid,'.'))[2]
		xyouts,(arstruct[k].xpos-512.)*mdimap.dx,(arstruct[k].ypos-512.)*mdimap.dy,thisplotid,/data,color=!blue, charsize=1.2, charthick=3
		xyouts,(arstruct[k].xpos-512.)*mdimap.dx,(arstruct[k].ypos-512.)*mdimap.dy,thisplotid,/data,color=!white, charsize=1.2, charthick=1
	endfor
	window_capture,file=smart_paths(/plot,/no_calib)+'track_'+time2file(mdimap.time),/jpeg

endfor

stop

gotoskip_jpeg:

jpeglist=file_search(smart_paths(/plot,/no_calib)+'track_????????_????.jpg')
moviefilename='~/science/data/smart2/movie/smart_track_200910.mpg'

mk_mpeg,jpeglist,moviefilename,/jpeg

end