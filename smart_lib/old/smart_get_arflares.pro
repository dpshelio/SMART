;Get all events associated with an active region
;choose from different catalogs
;seeds, cactus, rhessi, sam's latest, sec, ... etc?

function smart_get_arflares, arfile

;find first date and last date of AR
;what is ranges when on disk?

;parse w/e database thing

;put in carrington coordinates to associate locations?

;load mask and arstr for each time of ar detection
;diff rot closest mask to flare times
;overlay event detection

;if match then put event in structure array of events 
;{type, id, time, locationx, locationy, source, magnitude?, peak counts?}
;{flare, 001838, 20100401, -300, 500, latest events, X1.3, 324252}
;location in carrington coords?






return, eventstr

end