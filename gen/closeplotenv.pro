pro closeplotenv, xwin=xwin, psfile=psfile, default=default, file=file

!x.thick = 0
!y.thick = 0
!p.thick = 0
!p.charsize = 0
!p.charthick = 0
!p.psym = 0
!p.font = -1

print,[[' '],['Environment variables have been set to default.'],[' ']]

psclose
;restore,'tmp_ct_store.sav'
;tvlct,rr,gg,bb
;spawn,'rm -rR tmp_ct_store.sav'

print,[[' '],['PostScript file closed.'],[' ']]

end
