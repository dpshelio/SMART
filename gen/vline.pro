pro vline,x,_extra=_extra,log=log

if n_elements(x) lt 1 then x=0

ycran=!y.crange
if keyword_set(log) then ycran=10.^(!y.crange)

nx=n_elements(x)
for i=0,nx-1 do oplot,[min(x[i]),max(x[i])],ycran,_extra=_extra

end