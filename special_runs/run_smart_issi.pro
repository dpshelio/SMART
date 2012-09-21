;Run issi shite for the paper data set

pro run_smart_issi

ff=file_search(smart_paths(/sav,/no_cal)+'smart_2003*')

smart_persistence_issi, filelist=ff

smart_add_properties, ff, /nl_prop, /rotation_prop, /ising_prop;, /extent_prop

ffising=file_search('/Volumes/LaCie/data/smart2/issi_ising/ising_*')
smart_struct2ascii_issi, ff, inoutfile, FRM_PARAMSET=FRM_PARAMSET, fileising=ffising

print,"FINISHED!!!"
stop

end