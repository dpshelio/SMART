function issitime, intime

time=time2file(intime)
outtime=strmid(time,0,4)+'.'+strmid(time,4,2)+'.'+strmid(time,6,2)+'_'+strmid(time,9,2)+':'+strmid(time,11,2)+':00';+strmid(time,13,2)

return,outtime

end

;filename, FRM_PARAMSET=FRM_PARAMSET, no_sav=no_sav, no_xml=no_xml, votable=votable, outvotable=outvotable

;------------------------------------------------>

function smart_voevent_fill, inarstruct, inevstruct,extentstr=inextentstr, FRM_PARAMSET=FRM_PARAMSET;, jsoc=jsoc

nan='NaN'

arstruct=inarstruct
evstruct=inevstruct
extentstr=inextentstr

;str={Event_Type: 'ActiveRegion', SMID: '', ID: '', CLASS: '', TYPE: '', Event_CoordSys: 'UTC-HPC-TOPO', $
;Event_CoordUnit: 'arcsecs', Event_EndTime: '', Event_StartTime: '', Event_Coord1: 0D, Event_Coord2: 0D, Event_C1Error: 0D, Event_C2Error: 0D, $
;HCLON: 0D, HCLAT: 0D, HGLON: 0D, HGLAT: 0D, CARLON: 0D, CARLAT: 0D, XPOS: 0D, YPOS: 0D, $
;FRM_Contact: 'pohuigingmail', FRM_DateRun: '', FRM_HumanFlag: 'F', FRM_Identifier: 'phiggins', FRM_Institute: 'TCD', FRM_Name: 'SMART', FRM_ParamSet: '', FRM_URL: 'SM/smart_disk', $
;OBS_Observatory: 'SOHO', OBS_ChannelID: 'V band', OBS_Instrument: 'MDI', OBS_MeanWavel: 6768, OBS_WaveUnit: 'angstroms', $
;Bound_CCNsteps: 0D, Bound_CCStartC1: 0D, Bound_CCStartC2: 0D, Bound_ChainCode: '', ChainCodeType: 'ordered list', $
;BoundBox_C1LL: 0D, BoundBox_C2LL: 0D, BoundBox_C1UR: 0D, BoundBox_C2UR: 0D, $ 
;XYLON: '', XYLAT: '', RDEGLON: '', RDEGLAT: '', HGLON: '', HGLAT: '', XYMEAN10LON: '', XYMEAN10LAT: '', HGLONWIDTH: 0D, HGLATWIDTH: 0D, $
;MEANVAL: 0D, STDDV: 0D, KURT: 0D, Event_Npixels: 0D, BFLUX: 0D, BFLUXPOS: 0D, BFLUXNEG: 0D, BFLUXEMRG: 0D, Area_AtDiskCenter: 0D, Area_Unit: 'Mm^2', BMIN: 0D, BMAX: 0D, $
;LNL: 0D, LSG: 0D, GRADMAX: 0D, GRADMEAN: 0D, GRADMEDIAN: 0D, RVAL: 0D, WLSG: 0D, R_STAR: 0D, WLSG_STAR: 0D}

evstruct.SMID=arstruct.smid
evstruct.ID=arstruct.id
evstruct.CLASS=arstruct.class
evstruct.TYPE=strjoin(arstruct.type,'')
;evstruct.Event_EndTime=strjoin(str_sep(arstruct.time,' '),'T')
;evstruct.Event_StartTime=strjoin(str_sep(arstruct.time,' '),'T')
evstruct.Event_EndTime=issitime(arstruct.time)
evstruct.Event_StartTime=issitime(arstruct.time)
evstruct.Event_Coord1=(arstruct.xbary-512.)*1.9780144
evstruct.Event_Coord2=(arstruct.ybary-512.)*1.9780144
evstruct.Event_C1Error=1.9780144
evstruct.Event_C2Error=1.9780144
evstruct.hclon=arstruct.hclon
evstruct.hclat=arstruct.hclat
;evstruct.FRM_DateRun=strjoin(str_sep(systim(/utc),' '),'T')
evstruct.FRM_DateRun=issitime(systim(/utc))
evstruct.FRM_ParamSet=FRM_PARAMSET

x1x2=(extentstr.xylon-512.)*1.9780144
y1y2=(extentstr.xylat-512.)*1.9780144

evstruct.BoundBox_C1LL=x1x2[0]
evstruct.BoundBox_C2LL=y1y2[0]
evstruct.BoundBox_C1UR=x1x2[1]
evstruct.BoundBox_C2UR=y1y2[1]
bndhg1=conv_a2h([x1x2[0],y1y2[0]],arstruct.time)
bndhg2=conv_a2h([x1x2[1],y1y2[1]],arstruct.time)
evstruct.BoundHg_C1LL=bndhg1[0]
evstruct.BoundHg_C2LL=bndhg1[1]
evstruct.BoundHg_C1UR=bndhg2[0]
evstruct.BoundHg_C2UR=bndhg2[1]
evstruct.BOUND_CHAINCODE=nan
evstruct.X1X2=nan
evstruct.Y1Y2=nan
evstruct.RDEGLON12=nan
evstruct.RDEGLAT12=nan
evstruct.HGLON12=nan
evstruct.HGLAT12=nan
evstruct.X1X2MEAN10=nan
evstruct.Y1Y2MEAN10=nan

evstruct.MEANVAL=arstruct.meanval
evstruct.STDDV=arstruct.STDDV
evstruct.KURT=arstruct.KURT
evstruct.Event_Npixels=arstruct.narpx
evstruct.BFLUX=arstruct.BFLUX
evstruct.BFLUXPOS=arstruct.BFLUXPOS
evstruct.BFLUXNEG=arstruct.BFLUXNEG
evstruct.BFLUXEMRG=arstruct.BFLUXEMRG
evstruct.Area_AtDiskCenter=arstruct.area
evstruct.BMIN=arstruct.BMIN
evstruct.BMAX=arstruct.BMAX
evstruct.LSG=arstruct.nlstr.LSG
evstruct.GRADMAX=arstruct.nlstr.GRADMAX
evstruct.GRADMEAN=arstruct.nlstr.GRADMEAN
evstruct.GRADMEDIAN=arstruct.nlstr.GRADMEDIAN
evstruct.RVAL=arstruct.nlstr.RVAL
evstruct.WLSG=arstruct.nlstr.WLSG

;** Structure <2143404>, 8 tags, length=2108, data length=2108, refs=1:
;   REQUIRED        STRUCT    -> <Anonymous> Array[1]
;   OPTIONAL        STRUCT    -> <Anonymous> Array[1]
;   SPECFILE        STRING    '/Users/phiggins/science/procedures/hek_ont'...
;   REFERENCE_NAMES STRING    Array[20]
;   REFERENCE_LINKS STRING    Array[20]
;   REFERENCE_TYPES STRING    Array[20]
;   DESCRIPTION     STRING    ''
;   CITATIONS       STRUCT    -> <Anonymous> Array[20]

;** Structure <2143004>, 30 tags, length=288, data length=288, refs=2:
;   EVENT_TYPE      STRING    'AR: ActiveRegion'
;   KB_ARCHIVDATE   STRING    'Reserved for KB archivist: KB entry date'
;   KB_ARCHIVID     STRING    'Reserved for KB archivist: KB entry identi'...
;   KB_ARCHIVIST    STRING    'Reserved for KB archivist: KB entry made b'...
;   KB_ARCHIVURL    STRING    'Reserved for KB archivist: URL to suppl. i'...
;   EVENT_COORDSYS  STRING    'UTC-HPC-TOPO'
;   EVENT_COORDUNIT STRING    'blank'
;   EVENT_ENDTIME   STRING    '1492-10-12 00:00:00'
;   EVENT_STARTTIME STRING    '1492-10-12 00:00:00'
;   EVENT_COORD1    FLOAT               Inf
;   EVENT_COORD2    FLOAT               Inf
;   EVENT_C1ERROR   FLOAT               Inf
;   EVENT_C2ERROR   FLOAT               Inf
;   FRM_CONTACT     STRING    'blank'
;   FRM_DATERUN     STRING    'blank'
;   FRM_HUMANFLAG   STRING    'blank'
;   FRM_IDENTIFIER  STRING    'blank'
;   FRM_INSTITUTE   STRING    'blank'
;   FRM_NAME        STRING    'blank'
;   FRM_PARAMSET    STRING    'blank'
;   FRM_URL         STRING    'blank'                         
;   OBS_OBSERVATORY STRING    'blank'
;   OBS_CHANNELID   STRING    'blank'
;   OBS_INSTRUMENT  STRING    'blank'
;   OBS_MEANWAVEL   FLOAT               Inf
;   OBS_WAVELUNIT   STRING    'blank'
;   BOUNDBOX_C1LL   FLOAT               Inf
;   BOUNDBOX_C2LL   FLOAT               Inf
;   BOUNDBOX_C1UR   FLOAT               Inf
;   BOUNDBOX_C2UR   FLOAT               Inf

return, evstruct

end

;------------------------------------------------>

function smart_ascii_fill,struct

nfield=n_elements(tag_names(struct))

asciiarr=strarr(nfield)
for i=0,nfield-1 do begin
	thisval=struct.(i)
	thistyp=var_type(thisval)
	case thistyp of
		2: thisstring=strtrim(thisval,2)
		3: thisstring=strtrim(thisval,2)
		4: thisstring=strtrim(string(thisval,form='(E10.2)'),2)
		5: thisstring=strtrim(string(thisval,form='(E10.2)'),2)
		7: thisstring=strtrim(thisval,2)
	endcase
	
	if thistyp eq 7 and (strpos(thisstring,' '))[0] ne -1 then thisstring=''''+thisstring+''''
	
	asciiarr[i]=thisstring
endfor

asciistring=strjoin(asciiarr,' ')

return,asciistring

end

;------------------------------------------------>

pro smart_struct2ascii_issi, filename, inoutfile, FRM_PARAMSET=FRM_PARAMSET;outstruct, no_sav=no_sav, outvotable=outvotable

;no_sav=1
;no_xml=1
;votable=1

if n_elements(FRM_PARAMSET) ne 1 then FRM_PARAMSET='calib=1,psplot=0,tgrowmsk=10.,trsmooth=5.,tflux=1d5,tpnfract=.9,tnoise=70.'

savp='/Volumes/LaCie/data/smart2/issi/'
filename=file_search(savp+'smart_2003*.sav')

;savp=smart_paths(/no_cal, /sav)
;voeventp=smart_paths(/voevents,/no_cal)

if n_elements(inoutfile) lt 1 then outfile='./smart_issi_output_'+time2file(systim(/utc)) else outfile=inoutfile

blankstruct = smart_blanknar(/issi) ;struct4event('AR')
evstructarr=blankstruct
;outvotable='~/science/data/issi/votable_'+file2time(filename[0])+'_'+file2time(filename[n_elements(filename)-1])+'.sav'

headerstring='#'+strjoin(tag_names(evstructarr),', ')+'.'
spawn,'echo "'+headerstring+'" > '+outfile

nfile=n_elements(filename)
for j=0,nfile-1 do begin

	if (reverse(str_sep(filename[j],'.')))[0] eq 'gz' then begin
		spawn,'gunzip -f '+filename[j]
		restore,strjoin((str_sep(filename[j],'.'))[0:n_elements(str_sep(filename[j],'.'))-2],'.')
		spawn,'gzip -f '+strjoin((str_sep(filename[j],'.'))[0:n_elements(str_sep(filename[j],'.'))-2],'.')
	endif else restore,filename[j]
	
	nar=n_elements(arstruct)
	
	evstruct = blankstruct
	evstruct = replicate(evstruct,nar)
	
	for i=0,nar-1 do begin
		;Create VO Event IDL structure
		narstruct=n_elements(arstruct)
		nextra=narstruct-n_elements(extentstr)
		if nextra gt 0 then extentstr=[extentstr,replicate(smart_blanknar(/ext),nextra)]
		evstruct[i]=smart_voevent_fill(arstruct[i], evstruct[i],extentstr=extentstr[i],FRM_PARAMSET=FRM_PARAMSET)

		asciistring=smart_ascii_fill(evstruct[i])
		spawn,'echo "'+asciistring+'" >> '+outfile

		;Write XML VO Event
;		if not keyword_set(no_xml) then export_event, evstruct[i], /write_file, $
;			outdir=voeventp, $
;			suff=time2file(arstruct[i].time)+'_'+string(arstruct[i].id, format='(I03)'), $
;			outfil='smart_voevent_'+time2file(arstruct[i].time)+'_id'+strtrim(arstruct[i].id,2)+'.xml'
	endfor
	
	;Write IDL SAV file
;	if not keyword_set(no_sav) then save, evstruct, file=voeventp+'smart_voevent_'+time2file(arstruct[0].time)+'.sav'
	
	evstructarr=[evstructarr, evstruct]
	
endfor

evstructarr=evstructarr[1:*]
outstruct=evstructarr

return

;save,evstructarr,file=outvotable

end