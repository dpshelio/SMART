;+
; SMART_FIND_AR
;
; Descrip:   From a two maps input (in_map1,in_map2) produces a
;            structure with the different properties of the SMART
;            detections.  Produces a structure which each of the 
;            properties of the different ARs found.
;
; Inputs:    in_map1 - magnetogram map at t1
;            in_map2 - magnetogram map at t2
;            parameters_str=parameters_structure  - structure with the
;                                                   parameters needed.
;                          .noise_thresh  - noise threshold used for
;                                           the detection. (eg. 70)
;                          .grow_mask     - grow mask size (eg. 10)
;                          .smooth        - smooth size    (eg. 5)
;                          .contlevel     - ????
;                          .vthresh       - ????
;                          .areathresh    - ????
;                          .fluxthresh    - ????
;                          .tpnfract      - ????
;                          .savpath       - path where to save the
;                                           files (exist?)
;                          .?????         - ????
;
; Outputs:   arstruct - structure with all the info of the detections.
;            [savfile]- where the maps and structure are saved if
;                       /save keyword is input.
;
; History:   Created by P.A. Higgins (TCD)
;            Modified by D. Perez-Suarez (TCD-HELIO) - 21 Sept 2012 - different approach.
;
;-

function smart_find_ar, in_map1, in_map2, parameters_str=parameters_str,error=error,$
                        save=save, savfile = savfile

  ;TODO
  ;IF ~parameters_str => run script that read or generates default
  ;                      based on map's instrument

  time=in_map2.time
  noregions=''

  ;----------------------------------
  ;Create NOAA structure for the day.
  ;----------------------------------
  noaastr=smart_blanknar()
  indate=time2file(time,/date)
  ;noaastr_daily=smart_rdnar(indate)
  noaastr_daily=noaastr

  ;Generate coordinate maps.
  dxdy=[in_map2.dx,in_map2.dy]

  ;Calculate the area of a pixel in Mm^2
  pixarea=smart_hmipxarea(in_map2, /mmsqr) ;Mm^2

  ;-------------------------------------------------->
  ;Detect and measure the ARs
  maskstruc=smart_region_extract(in_map1, in_map2, parameters_str=parameters_str, $
                                 error=error, out_map1cor=map1cor)

  ;Zero the NANs in the maps.
  outdata1=smart_mapprep(in_map1,/nonfinite,/limb)
  in_map1=outdata1
  outdata2=smart_mapprep(in_map2,/nonfinite,/limb )
  in_map2=outdata2


  ;Extract Maps
  xcoord=maskstruc.xcoord       ;0 -> Nx pixels horizontally
  ycoord=maskstruc.ycoord       ;0 -> Ny pixels vertically
  rcoord=maskstruc.rcoord       ;0 in center, Npx from center every where else
  cosmap=maskstruc.mapcos       ;Area correction
  losmap=maskstruc.maplos       ;LOS correction
  mapdiff=maskstruc.mapdiff     ;Noise, LOS, non-finite corrected
  mapcal=maskstruc.mapcal       ;Noise, LOS, non-finite corrected
  arstack=maskstruc.mask        ;Mask with different detections having intg values

  nar=max(arstack)              ;number of detections
  if nar eq 0 then nar=1

  ;Initialize structure array.
  blankar=smart_blanknar(/arstr)
  arstruct=REPLICATE(blankar, nar) 

  ;Initialize NL structure array.
  blanknl=smart_blanknar(/nlstr, blank=blank)
  nlstruct=blanknl              ;REPLICATE(blanknl, nar) 

  
  ;TODO: enable this check!!
  ;if err eq -1 then begin 
  ;   noregions=1
  ;   goto,no_regions_visible
  ;endif

  ;TODO: certain fields like coordinates can be done outside the loop
  nids=1
  for k=0,nar-1 do begin

     ; TODO: Refactorize this with histogram or single where! 
     thismask=arstack
     wnotstack=where(arstack ne k+1.)
     warstack=where(arstack eq k+1.)
     if wnotstack[0] ne -1 then thismask[wnotstack]=0.
     if warstack[0] ne -1 then thismask[warstack]=1.
     
;Use LOS corrected B values; COS() correct mask
     thisar=thismask*mapcal*1d              ;in Gauss
     thismaskcos=thismask*cosmap*pixarea    ;in Mm^2
     thisdiffar=thismask*mapdiff
     
;Uncalibrated AR values
     warc=where(thismask ne 0)
     if warc[0] ne -1 then arvals=(thismask*in_map2.data*1d)[warc] else arvals=[0.d,0.d] ;in Gauss

;Area of AR
     thisarea=total(thismaskcos) ;in Mm^2

;B Flux
     thisbfluxpos=total(abs(thisar > 0)*thismaskcos)    ;in Gauss Mm^2
     thisbfluxneg=total(abs(thisar < 0)*thismaskcos)    ;in Gauss Mm^2
     thisbflux=thisbfluxpos+thisbfluxneg                ;in Gauss Mm^2
                                ;thisbfluxfrac=(thisbfluxpos < abs(thisbfluxneg))/(thisbfluxpos > abs(thisbfluxneg)) ;fraction
     if thisbflux eq 0 then thisbfluxfrac=0. else thisbfluxfrac=abs(thisbfluxpos-thisbfluxneg)/thisbflux
     
;B min, max
     thisbminval=min(thisar)
     thisbmaxval=max(thisar)

;Flux emergence
                                ;thisflxemrg=total(thisdiffar*thismaskcos) ;in Gauss Mm^2 / second
     thisar1=thismask*map1cor.data*1d
     thisflxemrg=(thisbflux-total(abs(thisar1)*thismaskcos))/float(anytim(in_map2.time)-anytim(in_map1.time))

;Find statistical moments of each AR candidate.
     thismean=mean(arvals)
     thisstd=stddev(arvals)
     thiskurt=kurtosis(arvals)
     thisabsmean=mean(abs(arvals))
     thisabsstd=stddev(abs(arvals))
     thisabskurt=kurtosis(abs(arvals))

     thisnarval=n_elements(arvals)*1d

;AR XY position in px
                                ;thisxpos=total(thismaskcos*xcoord)/total(thismaskcos)
                                ;thisypos=total(thismaskcos*ycoord)/total(thismaskcos)
     if total(thisar) ne 0 then thisxpos=total(abs(thisar)*thismaskcos*xcoord)/total(abs(thisar)*thismaskcos) else thisxpos=0
     if total(thisar) ne 0 then thisypos=total(abs(thisar)*thismaskcos*ycoord)/total(abs(thisar)*thismaskcos) else thisypos=0

;AR XY barycenter in px
     if total(thisar) ne 0 then thisxbary=total(thismaskcos*xcoord)/total(thismaskcos) else thisxbary=0
     if total(thisar) ne 0 then thisybary=total(thismaskcos*ycoord)/total(thismaskcos) else thisybary=0

;AR Solar X,Y position (Heliocentric) in arcsec (from pixels)
     imgsz = size(in_map2.data,/dim)
     if total(thisar) ne 0 then begin
        thishclon=(thisxpos-imgsz[0]/2.)*dxdy[0]
        thishclat=(thisypos-imgsz[1]/2.)*dxdy[1]
     endif else begin
        thishclon=0
        thishclat=0
     endelse
;AR HG position in deg
     if total(thisar) ne 0 then begin
        thishg=arcmin2hel(thishclon/60.,thishclat/60.,date=in_map2.time)
        thishglat=thishg[0]
        thishglon=thishg[1]
     endif else begin
        thishglon=0 
        thishglat=0
     endelse
        
;AR Carrington position in deg
     if total(thisar) ne 0 then begin
        thiscarlon=(conv_h2c([thishglon,thishglat],in_map2.time))[0]
        thiscarlat=thishglat
     endif
     
                                ;thislat=hglat[thisxpos,thisypos]*1d else thislat=0
                                ;if total(thisar) ne 0 then thislon=hglon[thisxpos,thisypos]*1d else thislon=0

;Create an ID for each candidate that is expected to be an AR.
     thisid=string(k+1., format='(I02)')

;Perform classification algorithm.
;type -> [U/M,B/S,E/D] ;uni/multipolar, big/small, emerging/decaying
     thistype=['','','']

     ;Differentiate UNIPOLAR and MULTIPOLAR
     thistype[0]=(thisbfluxfrac lt parameters_str.tpnfract[0])?'M':'U'
     ;Differentiate BIG and SMALL
     thistype[1]=(thisbflux ge parameters_str.fluxthresh)?'B':'S'
     ;Differentiate EMERGING and DECAYING
     thistype[2]=(thisflxemrg gt 0)?'E':'D'

     case strjoin(thistype) of
        'MBE' : thisclass='AR'
        'MBD' : thisclass='AR'
        'UBE' : thisclass='PL'
        'UBD' : thisclass='PL'
        'MSE' : thisclass='BE'
        'MSD' : thisclass='BD'
        'USE' : thisclass='UE'
        'USD' : thisclass='UD'
     endcase

;NL Characteristics, shrijver-R calculation, WLSG falconer value etc.
     if thistype[0] ne 'M' then thisnlstruct=blanknl else $
        thisnlstruct=blanknl ;smart_nlmagic, map2, nlvals, nlmask, thisnlstruct, data=thisar, maskcos=cosmap, maskarea=cosmap*pixarea;, ps=ps, plot=plot
;!!!TEMP comment out nl finder.

;Fill AR property structure
;Naming
     arstruct[k].smid=thisid
     arstruct[k].id=thisid
     arstruct[k].class=thisclass
     arstruct[k].type=thistype
;Position
     arstruct[k].hglon=thishglon 
     arstruct[k].hglat=thishglat
     arstruct[k].xpos=thisxpos 
     arstruct[k].ypos=thisypos 
     arstruct[k].xbary=thisxbary
     arstruct[k].ybary=thisybary
     arstruct[k].hclon=thishclon
     arstruct[k].hclat=thishclat 
     arstruct[k].carlon=thiscarlon
     arstruct[k].carlat=thiscarlat
;Statistical
     arstruct[k].meanval=thismean 
     arstruct[k].stddv=thisstd
     arstruct[k].kurt=thiskurt
     arstruct[k].narpx=thisnarval
;Magnetic Properties
     arstruct[k].bflux=thisbflux
     arstruct[k].bfluxpos=thisbfluxpos
     arstruct[k].bfluxneg=thisbfluxneg
     arstruct[k].bfluxemrg=thisflxemrg
     arstruct[k].time=time
     arstruct[k].area=thisarea
     arstruct[k].bmin=thisbminval
     arstruct[k].bmax=thisbmaxval
;NOAA Structure
;	arstruct[k].noaa=noaastr

;Polarity Separation Line	
     arstruct[k].nlstr=thisnlstruct

;Extended structure
	restore,smart_paths(/resmap,/no_calib)+'mdi_rorsun_map.sav' ;TODO: What happens if file is >1024x1024?
	rsundeg=asin(rorsun)/!dtor                                  ;Fix path or create image!
     thisextstr=smart_arextent(thismask, rsundeg=rsundeg, dx=dxdy[0],dy=dxdy[1],date=in_map2.time)
     arstruct[k].extstr = thisextstr

;Chaincode
     chain_code = smart_mask2chaincode(thismask,cc_px=cc_px, cc_len=cc_len)
     cc_arc=(cc_px-imgsz/2.)*dxdy
     arstruct[k].chaincode=chain_code
     arstruct[k].cc_px = cc_px
     arstruct[k].cc_arc = cc_arc
     arstruct[k].cc_len = cc_len
  endfor

;Check for NO REGIONS
  if (where(arstruct.id ne ''))[0] eq -1 then noregions=1 

;Deal with case of no regions on disk.
no_regions_visible:
  if noregions eq 1 then begin
     arstruct=blankar
     error_status=2
     exit_status=0
  endif

  mdimap=in_map2
  mdimap.data=mapcal
  
;Try to decrease file size.
  armask=fix(round(arstack))
  mdimap.data=float(mdimap.data)
  mapdiff=float(mapdiff)

  savfile=parameters_str.savpath+'smart_'+time2file(time,/seconds)+'.sav'
  if keyword_set(save) then $
     save, mdimap, mapdiff, armask, arstruct, noaastr_daily, file=savfile, /compress

  return, arstruct
end
