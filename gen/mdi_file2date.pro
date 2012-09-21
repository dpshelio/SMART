function mdi_file2date,filelist,fileday=fileday,filenames=filenames
;
;+
;  Name: mdi_file2date
;
;  Purpose: Produce the date in 'ecs' format for each file(or with path) input
;
;  Input Parameters:
;      filelist - MDI file name
;
;  Output Parameters:
;      fileday - number of the file in that day (as the original file)
;
;  History:
;     2011-Feb-08  David PS - Finally the conversion that everyone was expecting!
;                          to create catalogue in HELIO
;-

;defining some variables
  day0='1-jan-93'
  tref=anytim(day0,/utc_int)
  temptarr=tref

; How many files are you asking to convert?
  nfiles=n_elements(filelist)
  dates=filelist
  fileday=filelist
  filenames=filelist
; Are they just files or paths?
  paths=(strpos(filelist[0],'/') eq -1)?0:1

  for i=0,nfiles-1 do begin

     ; extract filenames from the paths
     filename=(paths eq 1)?(reverse(strsplit(filelist[i],'/',/ext)))[0]:filelist[i]
     filenames[i]=filename
     ; take from the filename the day number
     daynumber=(strsplit(filename,'.',/ext))
     temptarr.mjd=tref.mjd+daynumber[1]
     dates[i]=(strsplit(anytim(temptarr,out_style='ecs'),/ext))[0]
     fileday[i]=daynumber[2]
  endfor

  return,dates
end
