;Resolution in Dots/Inch

pro eps2png, infile, outfile, resolution=resolution, err=err

file=strtrim(infile,2)
if n_elements(outfile) lt 1 then ofile=file+'.png' else ofile=strtrim(outfile,2)
if n_elements(resolution) lt 1 then resolution='100' else resolution=strtrim(resolution,2)

spawn,'convert -density '+resolution+' '+infile+' -flatten '+ofile, err

end
