function update_smart_file,file,localpath=localpath,remotepath=remotepath,grid=grid,err=err,verbose=verbose
  if file eq '' then begin
     err='Not file set'
     return,-1
  endif
  dir=(strsplit(file,'/'))
  ndir=n_elements(dir)-1
  if ndir gt 1 then begin
     remotepath=strmid(file,0,dir[ndir])
     file = strmid(file,dir[ndir])
  endif
  if ~keyword_set(localpath) then localpath='./'
  if remotepath eq '' then begin
     err='%update_smart_file: Not remote path set for file '+file
     print,err
     return,-1
  endif
  if keyword_set(verbose) then print,'%UPDATE_SMART_FILE '+file+' local:'+localpath+' remote:'+remotepath+' grid:'+string(grid)

;Copy file (from the grid)
  spawn,copy_order(local=localpath+'/'+file,remote=remotepath+file,/from,grid=grid)
  if keyword_set(verbose) then print,copy_order(local=localpath+'/'+file,remote=remotepath+file,/from,grid=grid)
;restore file
  restore,localpath+'/'+file,verbose=verbose

;-------------------------------
;Update what needs to be updated.
print,'UPDATING FILE '+FILE
;-------------------------------
nars=n_elements(arstruct)
for i=0,nars-1 do begin
   x=(arstruct[i].exstr.XYLON - 512)*1.9859
   Y=(arstruct[i].exstr.XYLAT - 512)*1.9859
   ll=conv_a2h([x[0],Y[0]],arstruct[i].time)
   ur=conv_a2h([X[1],Y[1]],arstruct[i].time)
   hglon=[ll[0],ur[0]]
   hglat=[ll[1],ur[1]]
   arstruct[i].exstr.HGLON=hglon
   arstruct[i].exstr.HGLAT=hglat
   arstruct[i].exstr.hglonwidth=abs(hglon[1]-hglon[0])
   arstruct[i].exstr.hglatwidth=abs(hglat[1]-hglat[0])
endfor

;-------------------------------
;save new file locally
  save,file=localpath+file,/compress,arstruct, noaastr_daily, armask,s_f,verbose=verbose
;Update file of the grid
     ;remove file from storage
      spawn,rm_order(file=remotepath+file,grid=grid)
      if keyword_set(verbose) then print,rm_order(file=remotepath+file,grid=grid)
      ;copy new file
      spawn,copy_order(local=localpath+'/'+file,remote=remotepath+file,/to,grid=grid)
      if keyword_set(verbose) then print,copy_order(local=localpath+'/'+file,remote=remotepath+file,/to,grid=grid)

;copy locally the mdi files used by this detection
path_mdi='/grid/vo.helio-vo.eu/data/mdi_mag/'
path_fits=path_mdi+mdi_file2date(s_f.mdi_filename)+'/'
if ~file_exist(localpath+'/'+s_f.mdi_filename+'*') then spawn,copy_order(local=localpath+'/'+s_f.mdi_filename+'.gz',remote=path_fits+s_f.mdi_filename+'.gz',/from,grid=grid)
path_fits_t=path_mdi+mdi_file2date(s_f.mdi_filename_t)+'/'
if ~file_exist(localpath+'/'+s_f.mdi_filename_t+'*') then spawn,copy_order(local=localpath+'/'+s_f.mdi_filename_t+'.gz',remote=path_fits_t+s_f.mdi_filename_t+'.gz',/from,grid=grid)
return,1
end
