pro plotit, data, outfile, line=line, mask=mask

path='~/science/plots/helio/feature_paper/'
file=path+outfile

loadct,0,/silent

!x.margin=[-10,-10] & !y.margin=[-10,-10]
if not keyword_set(mask) then $
	plot_image,data[350:650,425:725] > (-1000) < 1000, ystyle=4, xstyle=4 $
else $
	plot_image,data[350:650,425:725]*(-1.), ystyle=4, xstyle=4
if keyword_set(line) then begin
	vline,(650-350)/2.
	hline,(725-425)/2.
endif
window_capture,file=file,/png

end

;---------------------------------->

pro feature_paper_plots

window,xs=900,ys=900
!p.background=255

;1) A nice AR with a few ephemeral regions around

file0=smart_paths(/mdi,/no_cal)+'smdi_fd_20031124_204830.fits.gz'
file1=smart_paths(/mdi,/no_cal)+'smdi_fd_20031125_000030.fits.gz'
mreadfits,file0,ind0,dat0
mreadfits,file1,ind1,dat1

plotit, dat0, 'raw_dat0'
plotit, dat1, 'raw_dat1'

plotit, dat0, 'raw_dat0_line',/line
plotit, dat1, 'raw_dat1_line',/line

;2) the same one after the smooth process

plotit,smart_mdimagprep( dat0,/nonoise,/nolos,/nolimb),'smooth_dat0'
plotit,smart_mdimagprep( dat1,/nonoise,/nolos,/nolimb),'smooth_dat1'

;3) the bakground removed

plotit,smart_mdimagprep( dat0,/nolos,/nolimb),'smooth_bg_dat0'
plotit,smart_mdimagprep( dat1,/nolos,/nolimb),'smooth_bg_dat1'

;4) M_t and M_t-Dt

dd0=smart_mdimagprep( dat0,/nolos,/nolimb)
dd1=smart_mdimagprep( dat1,/nolos,/nolimb)

index2map,ind0,dd0,map0
t0=file2time(strmid(ind0.t_obs,0,4)+strmid(ind0.t_obs,5,2)+strmid(ind0.t_obs,8,2)+'_'+strmid(ind0.t_obs,11,2)+strmid(ind0.t_obs,14,2)+strmid(ind0.t_obs,17,2))
t1=file2time(strmid(ind1.t_obs,0,4)+strmid(ind1.t_obs,5,2)+strmid(ind1.t_obs,8,2)+'_'+strmid(ind1.t_obs,11,2)+strmid(ind1.t_obs,14,2)+strmid(ind1.t_obs,17,2))
map0d=drot_map(map0,anytim(t1)-anytim(t0),/seconds,/keep_center)
dd0=map0d.data

mm0=dd0
mm0[where(abs(dd0) gt 0)]=1
mm1=dd1
mm1[where(abs(dd1) gt 0)]=1

plotit,mm0,'mask0',/mask
plotit,mm1,'mask1',/mask

;5) each of them dilated 10 px and without the features smaller than 50 px

ga0=smart_cont_sep(mm0, contlevel=.5, areathresh=50.)
ga0[where(ga0 gt 0)]=1
ga1=smart_cont_sep(mm1, contlevel=.5, areathresh=50.)
ga1[where(ga1 gt 0)]=1

plotit,ga0,'mask0_area',/mask
plotit,ga1,'mask1_area',/mask

gmm0=smart_grow(ga0,rad=10)
gmm0[where(gmm0 gt 0)]=1
gmm1=smart_grow(ga1,rad=10)
gmm1[where(gmm1 gt 0)]=1

plotit,gmm0,'mask0_grow',/mask
plotit,gmm1,'mask1_grow',/mask

;6) the substraction of them both

mdiff=abs(gmm0-gmm1)

plotit,mdiff,'mask_diff',/mask

;7) original M_t with the subtraction of the transient feature mask

w0=where(mdiff eq 1)
mt=ga1
mt[w0]=0

plotit,mt,'mask_notrans',/mask

;8) dilation by 10

mtdil=smart_grow(mt,rad=10)

plotit,mtdil,'mask_final',/mask

;9) the original image with the extracting contours (or as a transparent layer... I think I could do that in Gimp if you give me an image with the regions)

plotit,dat1,'data_contoured'
setcolors,/sys
contour,mtdil[350:650,425:725],level=.5,c_color=!red,c_thick=2,/over
window_capture,file='~/science/plots/helio/feature_paper/data_contoured',/png



stop

gmm0=smart_mdimagprep( mm0,/nonoise,/nolos,/nolimb)
gmm0[where(abs(gmm0) gt 0)]=1
gamm0=smart_cont_sep(gmm0, contlevel=.5, areathresh=50.)
gamm0[where(abs(gamm0) gt 0)]=1
gmm1=smart_mdimagprep( mm1,/nonoise,/nolos,/nolimb)
gmm1[where(abs(gmm1) gt 0)]=1
gamm1=smart_cont_sep(gmm1, contlevel=.5, areathresh=50.)
gamm1[where(abs(gamm1) gt 0)]=1

plotit,gamm0,'mask_grow_area0'
plotit,gamm1,'mask_grow_area1'

stop

imgsz=size(dat1)
xyrcoord, imgsz, xcoord, ycoord, rcoord

restore,smart_paths(/resmap)+'mdi_px_area_map.sav'
areacor=cosmap
;limit the mask to 89 degree correction
areacor=areacor < 1./cos(86.32*!dtor)

loscor=areacor

map1d=smart_mdimagprep( map1d,  /nosmooth,/nonoise,/nolos,/nolimb)
map2d=smart_mdimagprep( map2d,  /nosmooth,/nonoise,/nolos,/nolimb)

map1d=map1d*limbmask
map2d=map2d*limbmask

;THRESHOLDING

nthresh=70

map1d[where(map1d gt (-1.*nthresh) and map1d lt nthresh)]=0.
map2d[where(map2d gt (-1.*nthresh) and map2d lt nthresh)]=0.

;LINE OF SIGHT AND AREA CORRECTION

map1cor=map1d*loscor
map2cor=map2d*loscor

;DIFF ROT

map1_d=map1
map1_d.data=map1cor
map1_d=drot_map(map1_d,anytim2-anytim1,/seconds,/keep_center)
map1cor=map1_d.data

;BINARY MASKS

rsmooth=5

map1smth=smart_mdimagprep(map1.data, threshnoise=nthresh, nsmooth=rsmooth);, nosmooth=nosmooth, nonoise=nonoise, nolos=nolos, nofinite=nofinite
map2smth=smart_mdimagprep(map2.data, threshnoise=nthresh, nsmooth=rsmooth)

map1smthrot=map1
map1smthrot.data=map1smth
map1smthrot=drot_map(map1smthrot,anytim2-anytim1,/seconds,/keep_center)
map1smth=map1smthrot.data

mask1=blank
mask2=blank
if (where(map1smth ne 0))[0] ne -1 then mask1[where(map1smth ne 0)]=1
if (where(map2smth ne 0))[0] ne -1 then mask2[where(map2smth ne 0)]=1
mask1=smart_cont_sep(mask1, contlevel=.5, areathresh=50.)
mask2=smart_cont_sep(mask2, contlevel=.5, areathresh=50.)
if (where(mask1 gt 0))[0] ne -1 then mask1[where(mask1 gt 0)]=1 
if (where(mask2 gt 0))[0] ne -1 then mask2[where(mask2 gt 0)]=1   

stop



stop

end