function contour_nogap,path_xy,debug=debug
;+
; NAME:
;         CONTOUR_NOGAP
;
; PURPOSE:
;         Obtains all the pixels from a contour path which
;         are skipped when the vertices are further than a pixel
;         *There is another way to obtain the same using z buffers
;         look at the bottom (TODO a routine for that method)
;
;
; PROJECT:
;
;       HELIO (HELiophysics Integrated Observatory)
;       Solar Feature Catalog
;
; CALLING SEQUENCE:
;         indices = contour_nogap(path_xy)
;
; INPUT
;         path_xy      path obtained from contour of a closed region
;
;
; OUTPUTS
;         Output is the whole boundary of the region without skipping
;         any pixel.
;
; AUTHOR:
;
;       David Perez-Suarez
;       ARG
;       Trinity College Dublin (TCD)
;       Ireland
;       E-mail: dps.helio -at- gmail.com
;       This program is free software; you can redistribute it and/or modify it under the terms of the
;       GNU General Public License as published by the Free Software Foundation;
;
; HISTORY:
;         Created by DPS. May 2010
;-

  ;### Check input! Is it a 2D [2,n] array?
  sz=size(path_xy)
  if sz[0] gt 1 then begin
     if sz[1] ne 2 or sz[2] lt 3 then begin
        print,'#### WRONG DIMENSIONS, it must need to be [2,n]' ;message?
        return,-1
     endif
     endif else begin
        print,'#### WRONG DIMENSIONS, it must need to be [2,n]' ;message?
        return,-1
  endelse

  ;### Compute distance between points
  spath_xy=shift(path_xy,-2)
  dff=path_xy-spath_xy
  dist=sqrt(total(dff^2,1))
  if dist[sz[2]-1] ne 0 then begin
     print,'### Wrong contour, it need to be closed, i.e. first and last element must be the same'
     return,-1
  endif


  ;### Number of gaps
  nlong=where(dist ge 2,clong)
  if keyword_set(debug) then print,'Number of gaps'+ string(clong,format='(I3)')

  ;### Calculate pixels of the gaps and insert them on the new path_xy array
  npath_xy=path_xy
  if clong gt 0 then begin

     for i=clong-1,0,-1 do begin

        px = dff[0,nlong[i]] gt 1 ? path_xy[0,nlong[i]]+findgen(round(abs(spath_xy[0,nlong[i]]-path_xy[0,nlong[i]]-1)))+1 : (path_xy[0,nlong[i]]+spath_xy[0,nlong[i]])/2.
        ;### Linear interpolation of py for the respective px
        py=dspline([path_xy[0,nlong[i]],spath_xy[0,nlong[i]]],[path_xy[1,nlong[i]],spath_xy[1,nlong[i]]],px,interp=0)

        pp=transpose([[px],[py]]) ; pp=[2,n]

        if keyword_set(debug) then print,path_xy[*,nlong[i]],spath_xy[*,nlong[i]],dff[*,nlong[i]],dist[nlong[i]],pp

        npath_xy=[[npath_xy[*,0:nlong[i]]],[[pp]],[npath_xy[*,nlong[i]+1:*]]]

     endfor ;i contour far pixels

  endif ;clong>0

return,round(npath_xy)  ;gives the closest integer px value.

end


;#################################################################
; This way shown here obtain all the pixel positions using zbuffer
;it is Paul's way!
;; IDL> set_plot,'z'                                                   
;; IDL> device,set_resolution=[600,600]  ;image is 600x600px
;; IDL> contour,image,levels=[1],position=[0,0,1,1],color=0,c_color=255
;; IDL> b=tvrd()
;; IDL> set_plot,'x'
;; IDL> IND = where(b)  ;they need to be sorted as a contour $
;; (egso_sfc_order_ind can do that)
