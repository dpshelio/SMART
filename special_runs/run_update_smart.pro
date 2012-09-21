@smart_server.pro
pro run_update_smart,start_date=start_date,end_date=end_date,mdidir=mdidir,runname=runname,datadir=datadir,grid=grid

localpath=mdidir
verbose=1
  
savlist=list_files_grid(start_date=start_date,end_date=end_date,/smart)
if savlist[0] eq '' then begin
   print,'Files missing, skipping rest of the program'
   goto,fin
endif

;for each sav name: update
  for i=0,n_elements(savlist)-1 do begin
     aa=update_smart_file(savlist[i],localpath=localpath,grid=grid,err=err,verbose=verbose)
  endfor

;generate database files
savlist=file_search(localpath,'smart*.sav')
spawn,'gunzip '+localpath+'/*gz'
heliodb_meta,savlist,runname=runname,mdidir=mdidir
fin:

end
