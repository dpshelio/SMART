pro clear_data_dir, outpath=outpath, instrument=instrument, filter=filter, date=date

dir=outpath+'/'+strtrim(date)+'/fits/'
files=instrument+'_'+filter+'*'
cmd=dir+files

if cmd eq '' then stop
if cmd eq '*' then stop

spawn,'rm '+cmd

end