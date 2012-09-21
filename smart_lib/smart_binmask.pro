function smart_binmask, map,grow=grow, mask_out = mask_out, $
                        mask_countlevel=mask_countlevel, mask_areathresh=mask_areathresh
  
  if n_elements(mask_countlevel) eq 0 then mask_countlevel = 0.5
  if n_elements(mask_areathresh) eq 0 then mask_areathresh = 50.
  sz = size(map.data,/dim)
  mask = intarr(sz[0],sz[1])

  ; Don't know what's going on here...
  ceros = where(map.data eq 0,numceros,complement=nonceros,ncomplement=num_nonceros)
  if num_nonceros gt 0 then mask[nonceros] = 1
  mask = smart_cont_sep(mask, contlevel=mask_countlevel, areathresh = mask_areathresh)
  gtceros = where(map.data gt 0, numgtceros)
  if numgtceros gt 0 then mask[gtceros] = 1

  ; Grow mask
  maskgr = smart_grow(mask, radius=grow)
  mask_out = mask
  return, maskgr
end
