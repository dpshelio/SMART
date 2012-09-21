pro smart_server, filelist, parameter_file = parameter_file

  parameters_str = smart_read_parameters(parameter_file)

  for i=1,n_elements(filelist)-1 do begin
     smart_detection,filelist[i-1],filelist[i],parameters_str=param
  endfor



end
