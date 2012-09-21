;---------------------------------------------------------------------->

function smart_paths, mdip=mdip, hmip=hmip, calmdip=calmdip, logp=logp,savp=savp,fitsp=fitsp, resavetrackp=resavetrackp, arsavp=arsavp, $
	resmapp=resmapp, plotp=plotp, arplotsp=arplotsp, voevents=voevents, $ ;htmlp=htmlp, $
	nardb=nardb, calibp=calibp, flarep=flarep, psplotp=psplotp, summaryp=summaryp, $
	pngp=pngp, statplotp=statplotp, date=date, threshp=threshp,$
	no_calib=no_calib,db=db

;TODO: Make these path externals
; HELIO
gridroot='/opt/exp_soft/helio/processing-codes/smart-code/smart_system_test'
;gridroot='/tmp/smart_storage' ;not grid
localroot='.'
; HEK
root='/data1/home/rtimmons/workspace/smart_ar/'
temppath=root+'/data/temp/'
; SMART_sci
;root = ''


if keyword_set(calibp) then begin 
	retval='docalib.tmp.sav' 
	return,retval
endif

if not keyword_set(no_calib) then restore,smart_paths(/calibp)

if keyword_set(threshp) then retval=temppath+'dothresh.tmp.sav'


;FULL SOLAR CYCLE ARCHIVE (sci/hek/grid)
if keyword_set(mdip) then retval='/Volumes/LaCie/data/mdi_mag2/'
if keyword_set(mdip) then retval=root+'/data/hmi/'
if keyword_set(mdip) then retval=gridroot+'/data/mdi/'

if keyword_set(logp) then retval='/Volumes/IOMEGA HDD/data/smart/logs/'
if keyword_set(logp) then retval=root+'/data/smart_logs/'
if keyword_set(logp) then retval=localroot+'/data/logs/'

if keyword_set(savp) then retval='/Volumes/IOMEGA HDD/data/smart/sav/'
if keyword_set(savp) then retval=root+'/data/smart_sav/'
if keyword_set(savp) then retval=localroot+'/data/sav/'

;;if keyword_set(plotp) then retval='/Volumes/LaCie/data/smart2/plots/tracked/'
if keyword_set(plotp) then retval='/Volumes/IOMEGA HDD/data/smart/plots/'
if keyword_set(plotp) then retval=root+'/data/smart_plots/'
if keyword_set(plotp) then retval=localroot+'/data/plots/'

if keyword_set(voevents) then retval='/Volumes/IOMEGA HDD/data/smart/voevents/'
if keyword_set(voevents) then retval=root+'/data/smart_voevents/'
if keyword_set(voevents) then retval=localroot+'/data/voevent/'

if keyword_set(fitsp) then retval='/Volumes/IOMEGA HDD/data/smart/fits/'
if keyword_set(fitsp) then retval=root+'/data/smart_fits/'
if keyword_set(fitsp) then retval=localroot+'/data/fits/'

;;if keyword_set(resavetrackp) then retval='/Volumes/LaCie/data/smart2/sav_tracked/'
if keyword_set(resavetrackp) then retval='/Volumes/IOMEGA HDD/data/smart/sav_arstr/'
if keyword_set(resavetrackp) then retval=root+'/data/smart_sav/'
if keyword_set(resavetrackp) then retval=localroot+'/data/sav/'

if keyword_set(arsavp) then retval='/Volumes/IOMEGA HDD/data/smart/ars/'
if keyword_set(arplotsp) then retval='/Volumes/IOMEGA HDD/data/smart/arplots/'



;DESKTOP ARCHIVE
;if keyword_set(mdip) then retval='~/science/data/smart2/mdi/'
;if keyword_set(logp) then retval='~/science/data/smart2/logs/'
;if keyword_set(savp) then retval='~/science/data/smart2/sav/'
;if keyword_set(plotp) then retval='~/science/data/smart2/plots/'

;BRADFORD STUFF
;if keyword_set(mdip) then retval='~/science/data/temp_mdi_data2/'
;;if keyword_set(mdip) then retval='~/science/data/temp_mdi_data/'
;if keyword_set(savp) then retval='~/science/bradford/sipwork_paper/smart_sav2/'
;;if keyword_set(savp) then retval='~/science/bradford/sipwork_paper/smart_sav/'
;if keyword_set(logp) then retval='~/science/bradford/sipwork_paper/smart_logs/'
;if keyword_set(plotp) then retval='~/science/bradford/sipwork_paper/smart_plots/'
;if keyword_set(resavetrackp) then retval='~/science/bradford/sipwork_paper/smart_sav/'

;ISSI STUFF
;if keyword_set(savp) then retval='/Volumes/LaCie/data/smart2/issi2/'
;if keyword_set(logp) then retval='/Volumes/LaCie/data/smart2/issi2/'
;if keyword_set(plotp) then retval='/Volumes/LaCie/data/smart2/issi_plots/rotation/'
;if keyword_set(resavetrackp) then retval='/Volumes/LaCie/data/smart2/issi2/'

;OTHER ARCHIVES
if keyword_set(resmapp) then retval='~/science/data/restore_maps/'
if keyword_set(resmapp) then retval=root+'/data/restore_maps/'
if keyword_set(resmapp) then retval=gridroot+'/calib/'

if keyword_set(flarep) then retval='~/Sites/phiggins/smart/flare/'

if keyword_set(hmip) then retval='~/science/data/sdo/hmi/'
if keyword_set(hmip) then retval=root+'/data/hmi/jsoc/'

   ;Just HEK
if keyword_set(tempp) then retval=temppath

   ;Just Grid
if keyword_set(calmdip) then retval=gridroot+'/data/mdi/'
if keyword_set(psplotp) then retval=localroot+'/data/plots/'
if keyword_set(summaryp) then retval=localroot+'/data/plots/'
if keyword_set(pngp) then retval=localroot+'/data/plots/'
if keyword_set(statplotp) then retval=localroot+'/data/plots/'
if keyword_set(db) then retval=localroot+'/data/database/'

;summaryp=summaryp

if keyword_set(no_calib) then goto,skipgrian

if grianlive eq 1 then begin
;	if keyword_set(mdip) then retval='~/Sites/data/'+strtrim(date,2)+'/fits/smdi/'
;	if keyword_set(logp) then retval='~/Sites/smart/log/'
;	if keyword_set(savp) then retval='~/Sites/smart/sav/'
;	if keyword_set(flarep) then retval='~/Sites/smart/flare/'
;	if keyword_set(summaryp) then retval='~/Sites/data/'+strtrim(date,2)+'/meta/'
endif


skipgrian:

return, retval

end

;---------------------------------------------------------------------->
