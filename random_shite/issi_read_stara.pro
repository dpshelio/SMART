function issi_read_stara, map=mdimap, filelist=filelist

blnkstara={time:'', tim:0, hglon:0, hglat:0, hg:[0,0], hc:[0,0], car:[0,0], xy:[0,0], area:0}
starastr_arr=blnkstara

nfile=n_elements(filelist)

for i=0,nfile-1 do begin

	fstaraall=filelist[i]
	readcol,datapath+fstaraall,y1,y2,y3,y4,y5,y6,y7,y8,y9,y10,y11,delim=' ',format='A,A,A,A,A,A,A,A,A,F,F',skip=2
	readcol,datapath+fstaraall,yall,delim='€',format='A',skip=2
	
	for l=0,n_elements(y8)-1 do y8[l]=strjoin(str_sep(strjoin(str_sep(y8[l],'.'),'-'),'_'),'T')
	staratime=anytim(y8,/vms)
	staratim=anytim(y8)
	starautim=staratim[uniq(staratim)]
	starahglon=y10
	starahglat=y11
	starahg=[transpose(y11),transpose(y10)]
	starahc=conv_h2a(starahg,anytim(staratime,/vms))
	staracar=conv_h2c(starahg,anytim(staratime,/vms))
	staraxy=(starahc/mdimap.dx)+512
	;staraarea=float(strmid(yall,strlen(yall)-13,9))
	nstara=n_elements(staratim)
	staraarea=fltarr(nstara)
	for k=0,nstara-1 do staraarea[k]=(str_sep(yall[k],' '))[29]
	
	thisstruct=replicate(blnkstara,nstara)
	thisstruct.time=staratime
	thisstruct.tim=staratim
	thisstruct.hglon=starahglon
	thisstruct.hglat=starahglat
	thisstruct.hg=starahg
	thisstruct.hc=starahc
	thisstruct.car=staracar
	thisstruct.xy=staraxy
	thisstruct.area=staraarea
	
	starastr_arr=[starastr_arr,thisstruct]
	
endfor

starastr_arr=starastr_arr[1:*]

return,starastr_arr

end
