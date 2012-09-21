pro smart_detection, file1, file2, parameters_str = parameters_str

;================================
;================  Read the files
  smart_readmdi, map1, file=file1
  smart_readmdi, map2, file=file2

;================================
;======================  Find ARs
  ars_structure = smart_find_ar(map1,map2,parameters_str=parameters_str,/save,savfile=savfile)

;================================
;============  Write the DB files
  ; Per files used

  ; Per detections

;================================
;================= Generate plots
  smart_plot_detections,savfile,/png, outfile=savfile +'.png',$
                        position=[ 0.07, 0.05, 0.99, 0.97 ]
end
