;Restore all files in list and stack variables. 
;Return stacks.

function smart_persistence_stackar, flist, maskstack, indarr ;, mgstack
print,'SMART_PERSISTENCE_STACKAR'

nfile=n_elements(flist)
restore,flist[0]

;imgstack=replicate(mdimap,nfile)
;diffstack=replicate(mapdiff,nfile)
maskstack=replicate(armask,nfile)   ;!!!! is this a map? or img?
arstack=arstruct;replicate(arstruct,nfile)
;noaastack=replicate(noaastr_daily,nfile)
indarr=n_elements(arstack)

for i=1,nfile-1

	maskstack[i]=armask
	;arstack[i]=arstruct
	arstack=[arstack, arstruct]
	indarr=[indarr,n_elements(arstack)]

endfor

return, arstack

end

;---------------------------------------------------------------->

pro smart_persistence
print,'SMART_PERSISTENCE'

restore,smart_paths(/calibp)

fcan='candidates/'
far='ars/'

;Find all candidate and active region files
canlist=file_search(smart_paths(/savp)+fcan,'*.sav',/fully_qualify)
arlist=file_search(smart_paths(/savp)+far,'*.sav',/fully_qualify)

if canlist[0] eq '' then begin & print,'NO CANDIDATES FOUND' & return & endif

;Count number of months to run through
ftlist=time2file(file2time(canlist),/date)
monthlist=strmid(ftlist,0,6)
umonths=monthlist[sort(monthlist[uniq(monthlist)])]
nmonths=n_elements(umonths)

for i=0,nmonths-2 do begin

;Find files in 2 month range.
	if i eq 0 then wrngcan=where(monthlist eq umonths[i]) else 
		wrngcan=where(monthlist eq umonths[i+1])
	thiscanlist=canlist[wrngcan]
	wrngar=where(strmid(time2file(file2time(arlist),/date),0,6) eq umonths[i])
	if arlist[0] eq '' then thisarlist='' else thisarlist=arlist[wrngar]

;Create structure stacks of all candidates and active regions.
	canstack=smart_persistence_stackar(thiscanlist, canmask, caninds)
	ncan=n_elements(canlist)
	
	if thisarlist[0] ne '' then begin
		arstack=smart_persistence_stackar(thisarlist, armask, arinds)
		nar=n_elements(arlist)
	endif

	idarr=canstack.id

	war=where(strlen(idarr) lt 5)
	nnumar=n_elements(war)
	nmasks=n_elements(canmask)
	
	for j=0,nnumar-1 do begin
		thisar=canstack[war[j]]
		thismask=canmask[caninds[war[j]]]
		
		;Do forward comparison of masks. (with #'d ARs and ?????'s)
		
		;Do backward comparison of masks. (with named ARs and ?????'s)
		
	endfor
	
stop




;Find "association time".
	asstim=anytim(arstack[0].time)

;Run through next 2 months and create catalog names until everything has a name or end of data is reached.
	for j=0,ncan-1 do begin
		
	endfor


endfor













;--------------------------------------------------------->

ncan=n_elements(canlist)
restore, canlist[0]
thistruct=arstruct

if prevcan ne '' then restore, prevcan,/verb
prevstruct=arstruct
;lastdate=time2file(ar_struct[0].time,/date)
nid=1 ;Keep track of number of new ARs named each day
for i=0,ncan-1 do begin
	restore, canlist[i]
	thistruct=arstruct
	thismask=armask
	thismdi=mdimap
	thisnoaa=noaastr_daily
	
	if i gt 0 then begin
		restore, canlist[i-1]
		prevstruct=arstruct
	endif
	
;Associate regions named in PREVSTRUCT with candidates in THISTRUCT.

	smart_newar,nid,thistruct,prevstruct,time=thistruct.time
	
	arstruct=thistruct
	armask=thismask
	mdimap=thismdi
	noaastr_daily=thisnoaa
	save, mdimap, armask, arstruct, noaastr_daily, file=canlist[i]
	
;Replot stuff without NOISE and associated ARs.

if grianlive eq 0 then begin
	if keyword_set(reverse) then begin 
		if psplot eq 1 then setplotenv,/ps,xs=15,ys=15, file=smart_paths(/psplotp)+'/ar_smart_'+time2file(file2time(canlist[i]))+'.eps'
		smart_plotarscont, mdimap, armask, arstruct, canlist[i], strnoaa=noaastr_daily, /noaa
		if grianlive eq 1 then begin
			;zb_plot = tvrd()
			;wr_png, smart_paths(/plotp)+'ars/smart_'+time2file(file2time(canlist[i]))+'.png', zb_plot
		endif else begin
			if psplot eq 1 then closeplotenv else window_capture,file=smart_paths(/plotp)+'ars/smart_'+time2file(file2time(canlist[i])),/png
		endelse
	endif
endif

;NOTE Make daily summary DATs and php tables to just stick in SM.

endfor

;if grianlive eq 0 then begin
;	spawn,'rm -rf '+smart_paths(/htmlp)+'ars'
;	spawn,'cp -r '+smart_paths(/plotp)+'ars '+smart_paths(/htmlp)+'ars'
;endif

;---------------------------------------------------------->

tarmatch=smart_thresh(/tarmatch)
namenew=0

;Search through AR_STRUCT for non-cataloged, but numbered, EFRs.
;THIS will be uncataloged ARs, PREV will be cataloged ARs.

thisid=thistruct.id
thislat=thistruct.hglat
thislon=thistruct.hglon
thistim=thistruct.time
ftim=thistim[0]

wnoname=where(strlen(thisid) le 5 and strlen(thisid) gt 1) ;Exclude cataloged ARs and blank structures.
wnamed=where(strlen(thisid) gt 5)
if wnoname[0] eq -1 then goto,nonewar ;if nothing new to associate.
if wnamed[0] ne -1 then begin
	thislat[wnamed]=-1d4
	thislon[wnamed]=-1d4
endif

if var_type(prevstruct[0]) ne 8 then begin
	namenew=1
	goto,gonewar ;if nothing in the previous file
endif

wprevar=where(strlen(prevstruct.id) gt 5) ;Exclude non-cataloged ARs.
if wprevar[0] eq -1 then begin
	namenew=1
	goto,gonewar ;if no cataloged ARs in previous file
endif

previd=prevstruct[wprevar].id
prevlat=prevstruct[wprevar].hglat
prevlon=prevstruct[wprevar].hglon
prevtim=prevstruct[wprevar].time

;Loop through and check each current un-catloged AR against all the previous 
;file's cataloged ARs.
for j=0,n_elements(wprevar)-1 do begin
	dtimedays=(anytim(thistim[0])-anytim(prevtim[j]))/(3600.*24.) ;Time diff in days btwn this img and prev img. 
	dlons=DIFF_ROT(dtimedays,prevlon) ;IS THIS FOR HG OR HC?
	ilons=prevlon+dlons

	angdist=((ilons[j]-thislon)^2.+(prevlat[j]-thislat)^2.)^(.5)
	wlt5deg=(where(angdist eq min(angdist)))[0]
	
	if angdist[wlt5deg] le tarmatch then begin
;Rename the candidate as a cataloged AR.
		thistruct[wlt5deg].id=previd[j]
		prevlat[j]=1d4
		prevlon[j]=1d4
	endif else begin
;Associate ARs.
		if strlen(strtrim(thistruct[wlt5deg].id,2)) lt 3 then begin
			thistruct[wlt5deg].id=time2file(ftim,/date)+'.ar.'+string(nid,format='(I02)')
			nid=nid+1
		endif
;Associate PLAGEs.
		if thistruct[wlt5deg].id eq 'PLAGE' then begin
			thistruct[wlt5deg].id=time2file(ftim,/date)+'.pl.'+string(nid,format='(I02)')
			nid=nid+1
		endif
	endelse
	
endfor

gonewar:

if not keyword_Set(reverse) then begin

if (where(strlen(thistruct.id) lt 3))[0] ne -1 then namenew=1

if namenew eq 1 then begin

print,'NAMING NEW'

;Name new ARs.
	wnum=where(strlen(thistruct.id) lt 3)	
	if wnum[0] ne -1 then begin
		for m=0,n_elements(wnum)-1 do begin
			thisw=wnum[m]
			thistruct[thisw].id=time2file(ftim,/date)+'.ar.'+string(nid,format='(I02)')
			nid=nid+1	
		endfor
	endif
	
;Name new Plage regions.
	wnum=where(thistruct.id eq 'PLAGE')	
	if wnum[0] ne -1 then begin
		for m=0,n_elements(wnum)-1 do begin
			thisw=wnum[m]
			thistruct[thisw].id=time2file(ftim,/date)+'.pl.'+string(nid,format='(I02)')
			nid=nid+1
		endfor
	endif
endif

endif

nonewar:

end