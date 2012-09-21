function smart_list_mag, fdlist=fdlist

restore,smart_paths(/calibp)

filelist=''
for k=0,n_elements(fdlist)-1 do begin
	fpath=smart_paths(/mdip, date=fdlist[k])

	thisdlist=file_search(fpath,'*maglc*',/fully_qualify)
	filelist=[filelist,thisdlist]
endfor

return,filelist

end