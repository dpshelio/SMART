pro hline,y,_extra=_extra, log=log

if n_elements(y) lt 1 then y=0

xcran=!x.crange
if keyword_set(log) then xcran=10.^(!x.crange)

ny=n_elements(y)
for i=0,ny-1 do oplot,xcran,[min(y[i]),max(y[i])],_extra=_extra

end