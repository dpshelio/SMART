pro smart_write_ar_table, filelist

logpath=smart_paths(/log,/no_calib)
nfile=n_elements(filelist)

for i=0,nfile-1 do begin

	thisfile=filelist[i]

	restore,thisfile

	locfile=(reverse(str_sep(thisfile,'/')))[0]
	thistable=logpath+(str_sep(locfile,'.'))[0]+'_ar.txt'
	spawn,'echo "<html>" > '+thistable
	spawn,'echo "<body>" >> '+thistable
	spawn,'echo "<table rules=rows width=100% align=center cellspacing=0 cellpadding=0 bgcolor=#f0f0f0>" >> '+thistable
		spawn,'echo "<tr align=center><td colspan=8 align=center background=common_files/brushed-metal.jpg>" >> '+thistable
		spawn,'echo "<table width=100% height=100% border=0 align=center cellspacing=0 cellpadding=0>" >> '+thistable
			spawn,'echo "<tr class=artitl><td colspan=8 align=center>SMART Magnetic Features</td></tr>" >> '+thistable
			spawn,'echo "<tr align=center valign=top class=arhead><td>ID</td><td>Type</td><td>HG Lon,Lat</td><td>&Phi; [Mx]</td><td>L<sub>PIL</sub> [Mm]</td><td>R* [Mx]</td><td>WL<sub>SG</sub> [G/Mm]</td></tr>" >> '+thistable
		spawn,'echo "</tr></table></td></tr>" >> '+thistable
		
	nar=n_elements(arstruct)
	for j=0,nar-1 do begin
		thisar=arstruct[j]
			plotid=thisar.smid
			if strlen(thisar.smid) gt 2 then begin
				plotid=strmid(plotid,4,strlen(plotid)-4)
				plotid=strmid(plotid,0,4)+'.'+strmid(plotid,5,4)+'.'+(str_sep(plotid,'.'))[2]
			endif
			
			trackimg='~/Sites/phiggins/smart_plots_tracked/'+thisar.smid+'.png'
			tracklink='./phiggins/smart_plots_tracked/'+thisar.smid+'.png'
			if file_exist(trackimg) then tableidstr='<a href='+tracklink+' target=_blank>'+plotid+'</a>' else tableidstr=plotid
			spawn,'echo "<tr class=artext align=center><td>'+tableidstr+'</td><td>'+strjoin(thisar.type)+'</td><td>'+string(thisar.hglon,form='(F5.1)')+','+string(thisar.hglat,form='(F5.1)')+'</td><td>'+string(thisar.bflux*1d16,form='(E8.2)')+'</td><td>'+string((thisar.nlstr).lnl,form='(E8.2)')+'</td><td>'+string((thisar.nlstr).r_star,form='(E8.2)')+'</td><td>'+string((thisar.nlstr).wlsg,form='(E8.2)')+'</td></tr>" >> '+thistable
	endfor

	spawn,'echo "</table>" >> '+thistable	
	spawn,'echo "</body>" >> '+thistable
	spawn,'echo "</html>" >> '+thistable

endfor

end