function timetest_0,filename,lun=lun,t0=t0

t_0 = keyword_set(t0) ? t0:systime(/seconds)
get_lun= keyword_set(lun) ? 0:1
openu,lun,filename,/append,get_lun=get_lun
printf,lun,'starts: ', systime(1,/seconds)-t_0, memory(/current)
t0=t_0
return,1
end


function timetest_1,lun=lun,t0=t0

printf,lun,'ends:   ',systime(1,/seconds)-t0,memory(/highwater)
close,lun
return,1
end
