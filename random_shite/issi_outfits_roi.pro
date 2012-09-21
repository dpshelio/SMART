;time in sec (anytim)

pro issi_rot_mask, inmaskmap,files, wrpath, thisnoaa

pathsav='~/science/data/issi_data/sav/'

maskmap=inmaskmap
ntim=n_Elements(files)
for i=0,ntim-1 do begin
	meastim=anytim(maskmap.time)
	newtim=anytim(file2time(files[i]))
	dtim=newtim-meastim

	newmask=drot_map(maskmap,dtim,/seconds)
	
	newmask.time=anytim(newtim,/vms)
	map2index,newmask,newindex
	mwritefits, newindex, fix(newmask.data), $
		outfile=wrpath+thisnoaa+'/static_mask/smart_'+thisnoaa+'_static_mask_'+time2file(newmask.time)+'.fits', $
		/flat_fits
	
	mdimapfile=pathsav+'smart_'+time2file(file2time(files[i]))+'.sav'
	restore,mdimapfile
	plot_map,mdimap,drange=[-500,500],/limb
	plot_map,newmask,level=.5,/over
	window_capture,file=wrpath+thisnoaa+'/static_movie/smart_'+thisnoaa+'_static_mask_'+time2file(newmask.time),/png
	
endfor

end

;-------------------------------------------------------------->

pro issi_outfits_roi, nofits=nofits, res1tore=res1tore

pathsav='~/science/data/issi_data/sav/'
pathdata='~/science/data/issi_data/fits_roi/'

setplotenv,/xwin
!p.background=255
!p.color=0

;DO 10365 -> 20030520_1911.mg.13
;thisroi='20030520_1911.mg.13'
;thisnoaa='10365'
;DO 10377 -> 20030605_0450.mg.06
;thisroi='20030605_0450.mg.06'
;thisnoaa='10377'
;DO 10375 -> 20030602.1911.04
thisroi='20030602_1911.mg.04'
thisnoaa='10375'
ff=file_search(pathsav+'*.sav')

if keyword_Set(res1tore) then goto,skipforloop

nsav=n_elements(ff)
for i=0,nsav-1 do begin
	restore,ff[i]
	war=where(strmid(arstruct.smid,0,19) eq thisroi)
	if war[0] ne -1 then begin
		nwar=n_elements(war)
		for j=0,nwar-1 do armask[where(armask eq (war[j]+1))]=war[j]+1001
		for j=0,nwar-1 do armask[where(armask lt 500)]=0
		armask[where(armask gt 500)]=armask[where(armask gt 500)]-1000
		loadct,0
		plot_map,mdimap,/quiet,/limb,drange=[-500,500]
		maskmap=mdimap & maskmap.data=armask
		setcolors,/sys,/silent,/quiet
		plot_map,maskmap,level=.5,/over
		window_capture,file=pathdata+thisnoaa+'/movie/smart_'+thisnoaa+'_mask_'+time2file(arstruct[0].time),/png
		
		if keyword_set(nofits) then goto,skipfits
		map2index,mdimap,thisindex
	
		mwritefits, thisindex, fix(armask), $
			outfile=pathdata+thisnoaa+'/smart_'+thisnoaa+'_mask_'+time2file(arstruct[0].time)+'.fits', $
			/flat_fits
		skipfits:
		print,(time2file(arstruct[0].time))
	endif	

endfor

stop

skipforloop:
;NOAA 10365
;files=file_Search(pathdata+thisnoaa+'/*.fits')
;if thisnoaa eq '10365' then begin & fits2map,pathdata+thisnoaa+'/smart_'+thisnoaa+'_mask_20030528_0626.fits',staticmaskmap & endif
;second disk passage
;files=file_Search(pathdata+thisnoaa+'/smart_10365_mask_200306*.fits')
;if thisnoaa eq '10365' then fits2map,pathdata+thisnoaa+'/smart_'+thisnoaa+'_mask_20030620_2046.fits',staticmaskmap

;NOAA 10377
files=file_Search(pathdata+thisnoaa+'/*.fits')
if thisnoaa eq '10377' then fits2map,pathdata+thisnoaa+'/smart_'+thisnoaa+'_mask_20030610_1910.fits',staticmaskmap

issi_rot_mask, staticmaskmap,files, pathdata, thisnoaa

end