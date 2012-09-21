;History:
;	20120125 - 	changed default VTHRESH to 0 rather than 2 - PAH.
;	20120127 - 	changed contour separation to rely on LABEL_REGION instead of CONTOUR. 
;				VTHRESH is now DEFUNCT- PAH.

;DATA = array to be contoured
;CONTLEVEL = value to contour at
;VTHRESH = minimum number of vertices for a given contour (DEFUNCT!!!)
;AREATHRESH = minimum number of pixels contained in a given contour
;
;Returns a mask of the same dimensions as DATA. 

function smart_cont_sep, indata, contlevel=contlevel, vthresh=vthresh, areathresh=areathresh

data=indata
imgsz=size(data)
blank=fltarr(imgsz[1],imgsz[2])
mask=blank

if not keyword_set(contlevel) then contlevel=.5
if not keyword_set(vthresh) then vthresh=0 ;10
if not keyword_set(areathresh) then areathresh=0 ;10

;Create binary mask
mask=fltarr(imgsz[1],imgsz[2])
mask[where(data ge contlevel)]=1.

;Separate out the blobs
masksep=label_region([[fltarr(imgsz[1]+2)],[([transpose(fltarr(imgsz[2])),mask,transpose(fltarr(imgsz[2]))])],[fltarr(imgsz[1]+2)]])
masksep=float(masksep[1:imgsz[1],1:imgsz[2]])

;Re-order the blob numbers by size
nblob=max(masksep)

;test
;mask=fltarr(20,20) & mask[0:4,0:4]=1 & mask[8:19,8:19]=1 & mask[0:4,8:19]=1 & mask[8:19,0:4]=1 & mask[1:2,6]=1 & mask[5:8,6]=1 & mask[10:17,6]=1
;plot_image,masksep,xticks=20,yticks=20,color=0,xticklen=1,yticklen=1
;plot_image,masksep,xticks=20,yticks=20,/xsty,/ysty,color=255,xticklen=.01,yticklen=.01,/nodata,/noerase;xran=[0,20],yran=[0,20],/iso

;threshold the area of blobs

;stop

blobn=(histogram(masksep,bin=1))
wbad=where(blobn lt areathresh)
if wbad[0] ne -1 then for i=0,n_elements(wbad)-1 do masksep[where(masksep eq wbad[i])]=0.

;remake labeled mask so that labels go from 1 to max with no missing numbers
masksep=label_region([[fltarr(imgsz[1]+2)],[([transpose(fltarr(imgsz[2])),masksep,transpose(fltarr(imgsz[2]))])],[fltarr(imgsz[1]+2)]])
masksep=float(masksep[1:imgsz[1],1:imgsz[2]])

;reorder labels so that they go in size order
nblob=max(masksep)
blobn=(histogram(masksep,bin=1))[1:*]
blobind=findgen(nblob)+1.
sblob=reverse(sort(blobn))
blobn=blobn[sblob]
blobind=blobind[sblob]

for i=0,nblob-1 do begin
	wthis=where(masksep eq blobind[i])
	masksep[wthis]=-(i+1.)
endfor
;for i=0,nblob-1 do begin & wthis=where(masksep eq blobind[i]) & masksep[wthis]=-(i+1.) & endfor
masksep=-masksep

return,masksep





;OLD VERSION!!!!!

print,'ENTERING OLD VERSION!!!'
stop
contour,data,findgen(imgsz[1]),findgen(imgsz[2]),level=contlevel,path_info=path_info,/path_data_coords,path_xy=path_xy

if n_elements(path_info) gt 0 then begin 
	
	;Get rid of noise pixels.
	;pixmask=fltarr(imgsz[1],imgsz[2])
	wgoodcont=where(path_info.n gt vthresh)
	if wgoodcont[0] eq -1 then return, blank else infos=path_info[wgoodcont]
	ninfos=n_elements(infos)
	
	;Reverse sort by size...blah
	;infos=[reverse(sort(infos.high_low))]
	;infos=infos[reverse(findgen(n_elements(infos)))]
	
	maskval=0
	for j=0,ninfos-1 do begin
		info1=infos[j]
		xx=path_xy[0,info1.offset:info1.offset+info1.n-1]
		yy=path_xy[1,info1.offset:info1.offset+info1.n-1]
		poly1=polyfillv(xx,yy,imgsz[1],imgsz[2])
		;;if n_elements(poly1) le 1 then pixmask[poly1]=1
		;if n_elements(poly1) le areathresh then datacont[reform(path_xy[0,*]+path_xy[1,*]*imgsz[1])]=3

		if n_elements(poly1) gt areathresh then begin 
			if info1.HIGH_LOW eq 1 then begin
				maskval=maskval+1 & mask[poly1]=mask[poly1]+maskval 
			endif else begin
				holeval=mask[poly1[n_elements(poly1)/2.]]*(-1.)
				mask[poly1]=mask[poly1]+holeval
			endelse
		endif
;	tvscl,rebin(mask,512,512)
;	print,n_elements(poly1),' vs ',areathresh
	endfor

endif else return,fltarr(imgsz[1],imgsz[2])

;Compensate for weird 1px shift down and left
mask=shift(mask,1,1)

return,mask
		
end


	
;	;wnoise=where(pixmask eq 1)
;	;if wnoise[0] ne -1 then datacont[wnoise]=3
;	datacont=datacont*limbmask
;
;	wpen=where(datacont eq 2)
;	wum=where(datacont eq 1)
;	
;	;Count sun spots.
;	thisnsunspots=0.
;	spotinfos=path_info
;	for j=0,n_elements(spotinfos)-1 do begin
;		info1=spotinfos[j]
;		xx=path_xy[0,info1.offset:info1.offset+info1.n-1]
;		yy=path_xy[1,info1.offset:info1.offset+info1.n-1]
;		poly1=polyfillv(xx,yy,imgsz[1],imgsz[2])
;		;if n_elements(poly1) le 1 then pixmask[poly1]=1
;		if n_elements(poly1) ge spotthresh then thisnsunspots=thisnsunspots+1.
;	endfor
;	
;endif else 
;		
;end