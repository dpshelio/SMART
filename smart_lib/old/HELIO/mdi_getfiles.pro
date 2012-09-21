pro mdi_getfiles,start_date=start_date,end_date=end_date,dirname=dirname,grid=grid

;start_date='2-apr-2004'
;end_date='3-apr-2004'
;dirname='smart_dataset'
;grid=0

storage_dir=(~keyword_set(grid))?'/tmp/smart_storage/mdi_data/':'/grid/vo.helio-vo.eu/data/mdi_mag/'
mkdir_command=(~keyword_set(grid))?'mkdir -p ':'lfc-mkdir -p '
;cp_command=(~keyword_set(grid))?'cp ':'lfc-cp '
wget_command='wget -N -i ';'/sw/bin/wget -i '


file_list=mdi_time2file(start_date,end_date,/stanford)

dates=mdi_file2date(file_list,filenames=file_names)

;All related with the PATHS
    grid_path=strcompress(storage_dir+dates+'/',/remove_all)

    ; check if the paths exist
    paths2check=grid_path[uniq(grid_path)]
    paths_exist=(~keyword_set(grid))?file_exist(paths2check):file_exist_gridstorage(paths2check)

    ;create those that do not exist
    tocreate=where(paths_exist eq 0,n2create,compl=exist,ncomple=exist_n)
    if n2create gt 0 then for i=0,n2create-1 do spawn,mkdir_command+paths2check[tocreate[i]]

; All related with the files
    ;check if the files needed have to be downloaded
    grid_files=strcompress(grid_path+file_names+'.gz',/remove_all)
    files_exist=(~keyword_set(grid))?file_exist(grid_files):file_exist_gridstorage(grid_files)

    ;download those that does not exist...
    todownload=where(files_exist eq 0, n2down, compl=nodownl,ncompl=n2nodown)
    if n2down gt 0 then begin
       openw,unit,'/tmp/'+dirname+'/filelist.dat',/get_lun
       printf,unit,file_list[todownload]
       close,unit
       spawn,wget_command+'/tmp/'+dirname+'/filelist.dat -P /tmp/'+dirname
    ;...and copy them to the grid
       for i=0,n2down-1 do begin
          spawn,'gzip '+'/tmp/'+dirname+'/'+file_names[todownload[i]]
          spawn,copy_order(local='/tmp/'+dirname+'/'+file_names[todownload[i]]+'.gz',remote=grid_path[todownload[i]]+file_names[todownload[i]]+'.gz',/to,grid=grid)
          ;cp_command+'/tmp/'+dirname+'/'+file_names[todownload[i]]+'.gz'+' '+grid_path[todownload[i]]+file_names[todownload[i]]
		  spawn,'gunzip '+'/tmp/'+dirname+'/'+file_names[todownload[i]]+'.gz'
       endfor
    endif


    ; copy to the local directory does that have been downloaded before
;    print,grid_files[nodownl]
    if n2nodown gt 0 then begin
    	for i=0,n2nodown-1 do begin
    		spawn,copy_order(local='/tmp/'+dirname+'/'+file_names[nodownl[i]]+'.gz',remote=grid_files[nodownl[i]],/from,grid=grid)
    		spawn,'gunzip '+'/tmp/'+dirname+'/'+file_names[nodownl[i]]+'.gz'
    		;cp_command+grid_files[nodownl[i]]+' '+'/tmp/'+dirname+'/'
    	endfor
	endif
end
