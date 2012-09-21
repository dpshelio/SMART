;create an archive of arstruct idl structures in save files, without all the images, in order to do the tracking

pro smart_arstruct_archive, res1tore=res1tore

savpath='/Volumes/IOMEGA HDD/data/smart/sav/'
arstrpath='/Volumes/IOMEGA HDD/data/smart/sav_arstr/'

firsttim=systim(/utc)

if not keyword_set(res1tore) then filelist=file_search(savpath,'smart*.sav') $
	else restore,'/Volumes/IOMEGA HDD/data/smart/sav_arstr/filelist.sav'
nfile=n_elements(filelist)

for i=54665l,nfile-1l do begin
	
	restore,filelist[i]
	
	thisarfile=(reverse(str_sep(filelist[i],'/')))[0]
	
	save,arstruct,file=arstrpath+thisarfile

endfor

print,'DONE!!! '+firsttim+' '+systim(/utc)

end