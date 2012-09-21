;+
;
; Name        : smart_get_mag
;
; Purpose     : List all MDI magnetograms on a particular day,
;
; Syntax      : get_mag, date, [,/today]
;
; Examples    : IDL> get_mag, '20040205'
;               IDL> get_mag, /today
;
; Keywords    : 
;
; History     : P.T.Gallagher Written 6-Feb-2001
;				P.A.Higgins Adapted to SMART System and made it just list 
;				things (not copy them) 26-Mar-2009
;
; Contact     : pohuigin@gmail.com
;
;-
;

pro smart_get_mag, date, filename
  
  date_i = date

;--------------------------------------------------------------
; FTP the file list for DATE_I.

	if date_i lt 20070000 then dfolder='/'+strmid(date_i,0,4) else dfolder=''
	remotepath='ftp://sohoftp.nascom.nasa.gov/planning/mdi'+dfolder+'/'

  openw,1,'ftp_data'

    printf, 1 , '#! /bin/csh -f'
    printf, 1 , 'ftp -n sohoftp.nascom.nasa.gov << EOF > ftptemp'
    printf, 1 , 'user anonymous ptg@bbso.njit.edu'
    printf, 1 , 'prompt off'
    printf, 1 , 'binary'
    printf, 1 , 'cd /planning/mdi'+dfolder
    printf, 1 , 'ls smdi_maglc_fd_*' + date_i + '*'
    printf, 1 , 'bye'
    printf, 1 , 'EOF'

  close,1
  
  print, ' '
  print, 'Connecting to the MDI database (sohoftp.nascom.nasa.gov) ...'
  print, 'Locating files on ' + date_i + ' ...'
  spawn, 'chmod 777 ftp_data'
  spawn, './ftp_data'

  ;spawn, 'cat ftptemp | tail -1', flist
  spawn, 'cat ftptemp', flist
  
;--------------------------------------------------------------

;Parse the strings.
  for i=0,n_elements(flist)-1 do flist[i]=(reverse(str_sep(flist[i],' ')))[0]

  wgood=where(strlowcase(strmid(flist,0,4)) eq 'smdi')
  if wgood[0] eq -1 then flist='' else flist=remotepath+(flist[wgood])

  filename=flist

  spawn, 'rm -f ftp_data'
  spawn,'rm -f ftptemp'

return

end
