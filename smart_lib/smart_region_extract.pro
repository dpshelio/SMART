;+
; SMART_REGION_EXTRACT
;
; Descrip:   From a two maps input (in_map1,in_map2) produces a
;            structure with the different properties of the SMART
;            detections.
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
; Outputs:   Structure cointaining all the different masks prouduced.
;               maskstruc.mask    -
;                        .mapcos  -
;                        .maplos  -
;                        .mapdiff -
;                        .mapcal  -
;                        .xcoord  -
;                        .ycoord  -
;                        .rcoord  -
;
;            out_map1cor = out_map1cor  - corrected map used for
;                                         further steps.
;
;            error  - contains all the information related with the
;                     different possible errors.
;            
; History:   Created by P.A. Higgins (TCD)
;            Modified by D. Perez-Suarez (TCD-HELIO) - 23 July 2012 - different approach.
;
;-


function smart_region_extract,in_map1,in_map2,parameters_str=parameters_str,error=error,$
                              out_map1cor=out_map1cor

  error = (n_elements(error) gt 0)?error:['SMART_REGION_EXTRACT']

  
  ; Check input maps
  if (var_type(in_map1) ne 8) or (var_type(in_map2) ne 8) then begin
     message, " two images map structure needs to be input.",/continue
     error = [error, 'SMART_REGION_EXTRACT: Not two images input']
     return, -1
  endif else begin 
     if NOT (((size(in_map1.data,/dim))[0] eq (size(in_map2.data,/dim))[0]) OR $
             (((size(in_map1.data,/dim))[1] eq (size(in_map2.data,/dim))[1]))) then begin
        message, " The size of the input images has to be the same.",/continue
        error = [error,'SMART_REGION_EXTRACT: Not same sizes in the two images input']
        return, -1 
     endif 
  endelse


  ; Get/check properties has been input.
  if n_elements(parameters_str) eq 0 then begin
     message, " This routine needs a structure with the values to be used for the detection.",/continue
     error = [error, 'SMART_REGION_EXTRACT: Not parameters input']
     return, -1
  endif else begin
     if var_type(parameters_str) ne 8 then begin
        message, " The input values has to be set as an structure.  Look on the documentation for details of such structure.",/continue
        error = [error, 'SMART_REGION_EXTRACT: Input is not as structure']
        return, -1
     endif else begin
        ; Check whether the structure has the needed values... so far:
        ; noise_thresh, 
     endelse
  endelse

  ; Define structure that it's sent out.
  imgsz = size(in_map1.data,/dim)
  blank = fltarr(imgsz[0],imgsz[1])
  blankstruc = {mask:blank, mapcos:blank, maplos:blank, mapdiff:blank, mapcal:blank, $
                xcoord:blank, ycoord:blank, rcoord:blank}
  maskstruc=blankstruc

  ;correct images
  diff_time = float(anytim(in_map2.time)-anytim(in_map1.time))
  map1cor = smart_mapprep(in_map1,/nonfinite,/limb,mask_limb=mask_limb,noise=parameters_str.noise_thresh,$
                          /los,mask_los=mask_los,drot=diff_time)
  map2cor = smart_mapprep(in_map2,/nonfinite,/limb,mask_limb=mask_limb,noise=parameters_str.noise_thresh,$
                          /los,mask_los=mask_los)

  maskstruc.maplos = mask_los
  maskstruc.mapcos = mask_los
  out_map1cor = map1cor

  ;Create difference map - shows flux emergence
  maskstruc.mapdiff=(map2cor.data-map1cor.data)/diff_time ;Gauss / second

  maskstruc.mapcal = map2cor.data

  ;=====  Active Region detections  ======

  ;FOR BINARY MASK MAKING (Smoothing, Thresh, Los)
  ;------------------------------------------------> 
  ;Generate Smoothed -Thresh -LOS Data for binary maps
  map1smt = smart_mapprep(in_map1,/nonfinite,smooth=parameters_str.smooth,noise=parameters_str.noise_thresh,$
                          /los, mask_los=mask_los, /limb, mask_limb=mask_limb, drot=diff_time)
  map2smt = smart_mapprep(in_map2,/nonfinite,smooth=parameters_str.smooth,noise=parameters_str.noise_thresh,$
                          /los, mask_los=mask_los, /limb, mask_limb=mask_limb)

  mask1gr =  smart_binmask(map1smt,grow=parameters_str.grow_mask)
  mask2gr =  smart_binmask(map2smt,grow=parameters_str.grow_mask,mask_out = mask2)
  
  ;Difference masks and find constant pixels
  diffmask=abs(mask2gr-mask1gr)

  ;Clear transient pixels from final mask
  maskar=mask2
  wnotar=where(diffmask ne 0, num_notcero)
  if num_notcero gt 0 then maskar[wnotar]=0

  ;Grow final mask
  maskar=smart_grow(maskar, radius=parameters_str.grow_mask)

  ;Limb clip the final mask.
  maskar=maskar*mask_limb

  ;Contour to separate out the separate detections
  if parameters_str.contlevel eq 0 then parameters_str.contlevel = .5
  if parameters_str.vthresh eq 0 then parameters_str.vthresh = 2.
  if parameters_str.areathresh eq 0 then parameters_str.areathresh = 2.
  maskstack=smart_cont_sep(maskar, contlevel=parameters_str.contlevel, $
                           vthresh=parameters_str.vthresh, $
                           areathresh=parameters_str.areathresh)

  if total(maskstack) eq 0 then begin 
     err=-1
     error = [error,'SMART_REGION_EXTRACT: masksstack is eq 0']
     return,maskstruc
  endif

 maskstruc.mask=maskstack
 return, maskstruc
end
 
