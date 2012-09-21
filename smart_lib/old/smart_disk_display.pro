pro smart_disk_display, filelist=filelist, xwin=xwin, psplot=psplot, outplotfile=outimgfile

outimgfile=''

pathfits=smart_paths(/fits,/no_cal)
plotpath=smart_paths(/plot,/no_cal)

nfile=n_elements(filelist)

for i=0,nfile-1 do begin
	thisfile=filelist[i]
	thisfdate=time2file(file2time(thisfile))
	
	mreadfits,pathfits+'smart_mask_'+thisfdate+'.fits.gz',ind,mask
	fits2map,pathfits+'smart_mdimag_'+thisfdate+'.fits.gz',datamap
	restore,thisfile

	outimgfile=plotpath+'smart_'+time2file(file2time(thisfile))+'.eps'
	if keyword_set(psplot) then setplotenv,/ps,xs=10,ys=10,file=outimgfile else begin
           if not keyword_set(xwin) then begin 
              setplot,'z' 
              device, set_resolution = [1500,1500]
           endif
        endelse
        !p.background=255
	!p.color=0
	!p.charsize=1.8
	!p.thick=3
	!x.thick=3
	!y.thick=3

	smart_plot_detections, /catalog,position=[ 0.07, 0.05, 0.99, 0.97 ], grid=10, $
                               arstruct=arstruct, datamap=datamap, mask=mask

	if keyword_set(psplot) then closeplotenv else begin
		if not keyword_set(xwin) then begin 
			outimgfile=plotpath+'smart_'+time2file(file2time(thisfile))+'.png'
			zb_plot = tvrd()
			wr_png, outimgfile, zb_plot
			setplot,'x'
		endif
	endelse
	
endfor










end
