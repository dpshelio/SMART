pro smart_paper2_plots

savpath=smart_paths(/sav,/no_cal)
filelist=savpath+['','']
smart_disk_display, filelist=filelist, /xwin;,psplot=psplot

stop












end