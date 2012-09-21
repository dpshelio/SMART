;INPUT:		An SDO fits file
;OUTPUT: 	RETURNS - 	1 means image was rejected
;						0 means image was OK
;			reject_code	- 	(-1) means QUALITY keyword was not 0-31 bits
;							(-2) means QUALITY keyword was not present in header
;							[0-31] the array of quality codes corresponding to the chart below

;Bit Meaning 
;--- ------------------------- 
;0 FLAT_REC == MISSING; Flatfield data not available 
;1 ORB_REC == MISSING; Orbit data not available 
;2 ASD_REC == MISSING; Ancillary Science Data not available 
;3 MPO_REC == MISSING; Master pointing data not available 
;4 RSUN_LF == MISSING or 
;X0_LF == MISSING or 
;Y0_LF == MISSING; HMI Limb fit not acceptable 
;5 
;6 
;7 
;8 MISSVALS > 0 
;9 MISSVALS > 0.01*TOTVALS 
;10 MISSVALS > 0.05*TOTVALS 
;11 MISSVALS > 0.25*TOTVALS 
;12 ACS_MODE != 'SCIENCE'; Spacecraft not in science pointing mode 
;13 ACS_ECLP == 'YES'; Spacecraft eclipse flag set 
;14 ACS_SUNP == 'NO'; Spacecraft sun presence flag not set 
;15 ACS_SAFE == 'YES'; Spacecraft safemode flag set 
;16 IMG_TYPE == 'DARK'; Dark image 
;17 HWLTNSET == 'OPEN' HMI ISS loop open 
;or AISTATE == 'OPEN'; AIA ISS loop Open 
;18 (FID >= 1 and FID <= 9999) HMI Calibration Image 
;or (AIFTSID >= 0xC000) AIA Calibration Image 
;19 HCFTID == 17; HMI CAL mode image; 
;20 (AIFCPS <= -20 or 
;AIFCPS >= 100); AIA focus out of range 
;21 AIAGP6 != 0; AIA register flag  (Note: this vague text means reject.  Was a safety item 
;implemented around eclipses where 
;22 
;23 
;24 
;25 
;26 
;27 
;28 
;29 
;30 Quicklook image 
;31 Image not available 

function smart_reject_image, file, header, reject_code

read_sdo, file, header, /uncomp_delete,/nodata;,only_tags='quality'

;ForbiddenBits=[0,1,2,3,4,5,6,7,9,10,11,12,13,14,15,16,17,18,19,20,21,31] ;if any of these bits is set - reject the image 
;ForbiddenBits=[0,1,2,3,4,5,6,7,11,12,13,14,15,16,17,18,19,20,21,31] ;if any of these bits is set - reject the image 
ForbiddenBits=[8,11,12,13,14,15,16]

IF tag_exist(header,'QUALITY') THEN BEGIN  
 
      ;create an array of number such that the j-th elementh as bit j set to 1 and all others set to 0 
      ;i.e. 1,2,4,8,...,2^J,... 
      BitArray=2UL^ulindgen(32) 
      BitSet=(header.quality AND BitArray) NE 0 
 
;output quality codes
reject_code=where(BitSet ne 0)
 
      IF total(BitSet[ForbiddenBits]) GT 0 THEN BEGIN  
         RETURN,1  ;;; ie reject image 
      ENDIF 
       
ENDIF else begin
	reject_code=-2
	print,'% SMART_REJECT_IMAGE: Quality keyword not present in fits header.'
   	return,1
endelse

;Check for missed vals (currently set to reject: MISSVALS > 0.01*TOTVALS)
;   if tag_exist (header, "percentd") then begin 
;     if header.percentd lt 99.9999 then begin 
;         return, 1    ;ie reject image 
;      endif 
;  endif 


return,0

end
