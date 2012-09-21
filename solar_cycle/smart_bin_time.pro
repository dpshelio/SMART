;TIME = anytim array corresponding to data
;DATA = data points to bin
;BIN = custom bin in seconds

;temporally bin data (ie. sunspot number)
;returns average number of sunspots on disk during course of bin.

pro smart_bin_time, data, time, odata, otime, bin=bin, hour=hour, day=day, week=week, month=month, year=year

time1=time

time1=time1-max(time1)

if keyword_set(hour) then bin=3600l
if keyword_set(day) then bin=3600l*24l
if keyword_set(week) then bin=3600l*24l*7l
if keyword_set(month) then bin=long(3600.*24.*30.5)
if keyword_set(year) then bin=3600l*24l*365l

if n_elements(bin) lt 1 then bin=3600l*24l

npts=floor(max(time1))/bin

timebin=findgen(npts)
databin=fltarr(max(floor(time1))/bin)

for i=0,npts-1 do begin
	
	wthisbin=where(time1 ge float(i)*bin and time1 lt float(i+1)*bin)
	
	databin[i] = mean(data1[wthisbin])

end

otime=timebin
odata=databin

;sum points in each bin to make new array.

end