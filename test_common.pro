pro define_variables
  common smart_paths, spath
  mdi = '/tmp/mdi'
  eit = '/tarari/'
  spath = {mdi:mdi, eit:eit}
end
pro run_test,date
  common smart_paths, spath
  print,date
  print, spath.mdi
  print, spath.eit
  spath.mdi = 'tt'  ; This changes the global variable!
end
pro thisistest2
  common smart_paths, spath
  print, spath.mdi
end
pro test_common,date
  if n_elements(date) eq 0 then date='1980-Mar-12'
  define_variables
  run_test,date
  print, n_elements(spath)
  thisistest2  ; this print the variable changed.
end
