;+
; SMART_READ_PARAMETERS
;
; Descrip:   Read input file with the prarameters possible to set for
;            run SMART.
;
; Input:     filename - filename including the parameters.
;                       It has to follow the following structure:
;                       
;
; Output:    parameters_str=parameters_structure  - structure with the
;                                                   parameters needed.
;                          .noise_thresh  - noise threshold used for
;                                           the detection. (eg. 70)
;                          .grow_mask     - grow mask size (eg. 10)
;                          .smooth        - smooth size    (eg. 5)
;                          .contlevel     - ????
;                          .vthresh       - ????
;                          .areathresh    - ????
;                          .fluxthresh    - ????
;                          .tpnfract      - ????
;                          .savpath       - path where to save the
;                                           files (exist?)
;                          .?????         - ????
;
; History:   Created by D. Perez-Suarez (TCD-HELIO) - 21 Sept 2012 
;-
function smart_read_parameters, file, instrument = instrument

  if (n_elements(file) ne 0) then begin
     ; Check file exist + error
     ; return -1 ??
     
     ;read file (what's the best option??)


  endif

  if (n_elements(file) eq 0) and (n_elements(instrument) ne 0) then begin
     ; fill the structure with default values for instrument
     case instrument of
        'MDI'  : parameters_str = {$
                                  }
        'HMI'  : parameters_str = {$
                                  }
        'GONG' : parameters_str = {$
                                  }
     endcase
     return, parameters_str
  endif


  return, parameters_str
end
