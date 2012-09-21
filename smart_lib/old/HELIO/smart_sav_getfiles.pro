
pro smart_sav_getfiles,savfiles=savfiles,grid=grid

;grid=0
n=n_elements(savfiles)
if (strsplit(savfiles[0],'/'))[0] ne -1 then for i=0,n-1 do savfiles[i]=(strsplit(savfiles[i],'/',/ext,count=nn))[nn-1]
storage_dir=(~keyword_set(grid))?'/tmp/smart_storage/mdi_data/':'/grid/vo.helio-vo.eu/data/smart_output/savfiles/'
mkdir_command=(~keyword_set(grid))?'mkdir -p ':'lfc-mkdir -p '


file_names=savfiles
dates=savfiles
for i=0,n-1 do dates[i]=(strsplit(savfiles[i],'_',/ext))[1]
temptarr=dates
grid_path=temptarr
for i=0,n_elements(temptarr)-1 do grid_path[i]=storage_dir+strmid(temptarr[i],0,4)+'/'+strmid(temptarr[i],4,2)+'/'+strmid(temptarr[i],6,2)+'/'

	paths2check=grid_path[uniq(grid_path)]
    paths_exist=(~keyword_set(grid))?file_exist(paths2check):file_exist_gridstorage(paths2check)

    ;create those that do not exist
    tocreate=where(paths_exist eq 0,n2create,compl=exist,ncomple=exist_n)
    if n2create gt 0 then for i=0,n2create-1 do spawn,mkdir_command+paths2check[tocreate[i]]

; All related with the files
     ;...and copy them to the grid
       for i=0,n-1 do begin
	print,copy_order(local=smart_paths(/savp,/no_calib)+file_names[i],remote=grid_path[i]+file_names[i],/to,grid=grid)
           spawn,copy_order(local=smart_paths(/savp,/no_calib)+file_names[i],remote=grid_path[i]+file_names[i],/to,grid=grid)
        endfor
end
