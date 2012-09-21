;-------------------------------------------------->

pro smart_external_mdi_rename

path='/Volumes/LaCie/data/mdi_mag/'
path2='/Volumes/LaCie/data/mdi_mag2/'
filelist=file_search(path+'*.fits')
nfiles=n_elements(filelist)

for i=0l,nfiles-1l do begin

mreadfits,filelist[i],index

t=index.t_obs
t2=str_sep(t,'_')
td=strjoin(str_sep(t2[0],'.'))
tt=strjoin(str_sep(t2[1],':'))

ftime=strjoin([td,tt],'_')

;time=anytim(index.t_obs,/vms)
;ftime=file2time(time)
missvalue=index.MISSVALS
if missvalue gt 0l then misstxt='.miss' else misstxt=''
newfile='smdi_fd_'+ftime+misstxt+'.fits'

spawn,'cp '+filelist[i]+' '+path2+newfile
if (file_search(path2+newfile))[0] eq '' then begin
	print,'File not copied!'
	stop
endif
mreadfits,path2+newfile,index2

spawn,'gzip '+path2+newfile

endfor


end

;-------------------------------------------------->

pro smart_external_mdi_archive

url='http://soi.stanford.edu/magnetic/mag/'

path='/Volumes/LaCie/data/mdi_mag/'

tempp='~/science/data/temp_mdi_external/'

;sock_list,url,page
;wgood=where(strmid(page,0,4) eq '<img')
;page=page[wgood[1:*]]
;pos=strpos(page[0],'href="')

;folderlist=strmid(page,pos+6,20)
;nfolder=n_elements(folderlist)
nfolder=6031l-1200l+2l

;stop

for i=4167l,nfolder-1l do begin

;print,url+'fd_M_96m_01d.00'+strtrim((1200l+i),2)+'/'
	sock_list,url+'fd_M_96m_01d.00'+strtrim((1200l+i),2)+'/',page2;folderlist[i],page2
	;sock_list,url+folderlist[i],page2
;stop

;help,page2
	if n_elements(page2) lt 2 and page2[0] eq '' then goto,skipfolder
	
	wgood2=stregex(page2,'.fits')

;help,wgood2	
	;if wgood2[0] eq -1 then goto,skipfolder

	wnn1=where(wgood2 ne -1)

;help,wnn1	

;stop

	if wnn1[0] eq -1 then goto,skipfolder
	
;stop
	
	wgood2=wgood2[wnn1]
	page2=page2[wnn1]

filelist=strarr(n_elements(page2))
wfil=strpos(page2,'.fits')
for k=0,n_elements(page2)-1 do filelist[k]=strmid(page2[k],wfil[k]-22,27)

;stop

;	filelist=strmid(page2,wgood2-22,27)

	for j=0,n_elements(filelist)-1 do begin
	
print,'Downloading files...'
		spawn,'echo "#! /bin/csh -f" > filelacie'
		spawn,'echo "source ~/.tcshrc" >> filelacie'
		;spawn,'echo "wget '+url+'/'+folderlist[i]+'/'+filelist[j]+' -P '+path+'" >> filelacie'
		spawn,'echo "wget '+url+'/'+'fd_M_96m_01d.00'+strtrim((1200l+i),2)+'/'+filelist[j]+' -P '+path+'" >> filelacie'
    	;;spawn,'echo "EOF" >> filelacie'

		spawn, 'chmod 777 filelacie'
		spawn, './filelacie'

;stop
		spawn, 'rm filelacie'
		

		;;spawn,'wget '+url+'/'+folderlist[i]+'/'+filelist[j]+' -P '+path
		wait,1

		;;sock_copy,url+'/'+folderlist[i]+'/'+filelist[j]
		;;spawn,'cp '+filelist[j]+' '+path+'/'+filelist[j]
		;;spawn,'rm -f '+filelist[j]
	endfor

skipfolder:

print,systim()
	
endfor

print,'DONE!'

;stop

end