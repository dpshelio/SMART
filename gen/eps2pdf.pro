pro eps2pdf, infile, outfile, err=err

file=infile
ofile=outfile

spawn,'ps2pdf --AutoPositionEPSFiles '+infile+' '+outfile, err

end
