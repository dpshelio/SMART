pro smart_plot_track_all, filelist=filelist

nfile=n_elements(filelist)

for i=0,nfile-1 do begin
	
	restore,filelist[i]
	
	smart_plot_track_id, arstruct_arr

endfor

















end