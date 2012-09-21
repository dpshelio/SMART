function file_exist_gridstorage,paths
 input_paths=paths
 n=n_elements(input_paths)
 out=bytarr(n)

 for i=0,n-1 do begin
	spawn,'lfc-ls '+paths[i],lsout,/stderr
	out[i]=((strpos(lsout,'No such file or directory'))[0] eq -1)?1:0
 endfor

 return,out
end
