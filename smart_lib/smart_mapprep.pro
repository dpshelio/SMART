;+
; History:   Created by P.A. Higgins as smart_mdimagprep
;            Modified by D. Perez-Suarez - 23 July 2012 - different approach.
;
;-

function smart_mapprep,map,nonfinite=nonfinite,limb=limb,noise=noise,smooth=smooth, los=los,$
                       drot=drot, mask_limb=mask_limb, mask_los=mask_los
  outmap = map
  ; Check for finite/infinite data 
  wnotfinite=where(finite(map.data) ne 1,num_nan)
  wfinite=where(finite(map.data) eq 1)
  sz = size(map.data,/dim)
  blank_image = fltarr(sz[0],sz[1])
  
  ; Check whether masks have been set
  if n_elements(mask_limb) eq 0 then mask_limb = blank_image
  if n_elements(mask_los)  eq 0 then mask_los  = blank_image
  t_mask_limb = total(mask_limb)
  t_mask_los  = total(mask_los) 

  ; Extract parameters valid for more than one options
  if (keyword_set(limb) or keyword_set(los))  and (t_mask_limb eq 0 or t_mask_los eq 0) then begin
     xx_map_2 = rebin((get_map_xp(map,/oned))^2,sz[0],sz[1],/sample)
     yy_map_2 = rotate(rebin((get_map_yp(map,/oned))^2,sz[0],sz[1],/sample),1)
     rr_map = sqrt(xx_map_2 + yy_map_2) ; r^2 = x^2 + y^2
  endif

  ; Replace NON-FINITE data with 0.
  if (keyword_set(nonfinite)) and (num_nan gt 0) then outmap.data[wnotfinite] = 0

  ; Set values out of limb to 0 -- clip limb
  if n_elements(limb) ne 0 then begin
     if t_mask_limb ne 0 then begin
        outmap.data *= mask_limb
     endif else begin
        ; Create limb based on data
        if limb eq 1 then begin
           ; take limb from radius info in map
           if tag_exist(map,'RSUN') then begin
              limb = map.rsun
           endif else begin
              message, ' This map does not contain RSun info'
           endelse
        endif else begin
           print, '%SMART_MAPPREP: Using limb input as set on input.'
        endelse
        out_limb = where(abs(rr_map) ge limb,num_out,complement=in_limb,ncomplement=num_in)
        if num_out gt 1 then begin
           outmap.data[out_limb]=0
           if num_in gt 0 then mask_limb[in_limb] = 1
        endif
     endelse
  endif

  ; Smooth the image with input smooth size
  if n_elements(smooth) gt 0 then begin
     data=smart_grow(map.data, /gaus, rad=smooth)
     outmap.data = data
  endif

  ; Set values below noise threshold -- Get rid of low level noise
  if n_elements(noise) gt 0 then begin
     noise_px = where(abs(map.data) lt noise,num_noise)
     if num_noise gt 0 then outmap.data[noise_px] = 0
  endif

  ; LOS correction: 1st order LOS correction, using McAteer et al. 2005, (eqn. 1)
  if keyword_set(los) then begin
     if t_mask_los eq 0 then begin
        if n_elements(limb) eq 0 then limb=1000. ;arcsecs
        rad = (rr_map+1.) < limb
        loscor = sin(acos(rad/float(max(rad))))
        loscor_px = where(finite(loscor) and (loscor gt 0),num_loscor)
     
        ; find the angle susstented in the last pixel (Documentation S.??)
        rsun_px = limb/map.dx   ; TODO: check if tag exist and allow dx as input?
        limit_angle = asin((rsun_px-1)/rsun_px)

        if num_loscor gt 0 then $
           mask_los[loscor_px] = ((1/loscor[loscor_px]) < 1./cos(limit_angle))
     endif
     outmap.data *= mask_los
    endif

  ;Diff Rotation of the map a certain number of seconds
  if n_elements(drot) ne 0 then begin
     outmap_rot = drot_map(outmap,drot,/seconds,/keep_center)
     outmap = outmap_rot
  endif

  ; Return outmap
  return,outmap
end
