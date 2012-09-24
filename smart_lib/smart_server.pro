;+
; SMART_SERVER
;
; Descrip:   Wrapper that run smart over a set of files, with the 
;            parameters set in the parameter_file
;
; Inputs:    filelist  -  list of files to run SMART with.
;            parameter_file - file cointaining the parameters
;                             check smart_param.demo as a template
;
; Output:    ??
;
; History:   Created by D. Perez-Suarez (TCD-HELIO) - 24 Sept 2012 
;                          Based on P.A. Higgins (TCD) work.
;-

pro smart_server, filelist, parameter_file = parameter_file

  parameters_str = smart_read_parameters(parameter_file)

  for i=1,n_elements(filelist)-1 do begin
     smart_detection,filelist[i-1],filelist[i],parameters_str=param
  endfor



end
