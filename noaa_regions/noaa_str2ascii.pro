pro noaa_str2ascii

rootp='~/science/data/issi/noaa_compare/'

restore,rootp+'srs_str_1997_2008.sav',/ver

;   SRS_DATE        STRING    '1997-01-05'
 ;  NAME            STRING    '08009'
  ; LOC             STRING    'S02W05'
;   MTWIL           STRING    'b  '
;   MCINT           STRING    'BXO'
;   AREA            INT             10
;   LONLEN          INT              3
;   NSPOTS          INT              3
;   MU              DOUBLE           8.7767282
;   COR_AREA        DOUBLE           10.118483

srsasciifile=rootp+'srs_ascii_1997_2008.txt'

spawn,'echo ''#SRS_DATE, NAME, LOC, MTWIL, MCINT, AREA, LONLEN, NSPOTS, MU, COR_AREA.'' > '+srsasciifile

for i=0,n_elements(SRS_STR_1997_2008)-1 do begin
	
	srs_date=strtrim(SRS_STR_1997_2008[i].SRS_DATE,2)+' '
	name=strtrim(SRS_STR_1997_2008[i].name,2)+' '
	loc=strtrim(SRS_STR_1997_2008[i].loc,2)+' '
	mtwil=strtrim(SRS_STR_1997_2008[i].mtwil,2)+' '
	mcint=strtrim(SRS_STR_1997_2008[i].mcint,2)+' '
	area=strtrim(SRS_STR_1997_2008[i].area,2)+' '
	lonlen=strtrim(SRS_STR_1997_2008[i].lonlen,2)+' '
	nspots=strtrim(SRS_STR_1997_2008[i].nspots,2)+' '
	mu=strtrim(SRS_STR_1997_2008[i].mu,2)+' '
	cor_area=strtrim(SRS_STR_1997_2008[i].cor_area,2)+' '
	
	spawn,'echo '''+srs_date+name+loc+mtwil+mcint+area+lonlen+nspots+mu+cor_area+''' >> '+srsasciifile

endfor

stop

end