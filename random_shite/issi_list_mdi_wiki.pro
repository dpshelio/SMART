pro issi_list_mdi_wiki

porig='/Volumes/LaCie/data/mdi_mag_orig/'
pfilt='/Volumes/LaCie/data/mdi_mag2/'
pgrian='http://grian.phy.tcd.ie/issi_soldyneuro/mdi_mag/'

listo=file_search(porig,'*.fits')
listf=file_search(pfilt,'*.fits*')

timrng=[anytim('12-may-2003 00:00:00'),anytim('24-jun-2003 00:00:00')]
tlist=anytim(file2time(listf))

wtim=where(tlist ge timrng[0] and tlist le timrng[1])

listo2=listo[wtim]
listf2=listf[wtim]

wnomiss=where(strlen(listf2) lt 32)

;listnomiss=listo2[wnomiss]
listall=strmid(listo2,33,strlen(listo2[0])-1)

txtall='~/science/data/issi/mdi_mag_url_20030512_20030624.txt'
;txtall='~/science/data/issi/mdi_mag_datemapping_20030512_20030624.txt'
;txtall='~/science/data/issi/mdi_mag_20030512_20030624.txt'
;;txtnomiss='~/science/data/issi/mdi_mag_20030512_20030624_nomiss.txt'

;spawn,'echo "'+listnomiss[0]+'" > '+txtnomiss[0]
spawn,'echo "'+pgrian+listall[0]+'" > '+txtall[0]

;for i=1,n_elements(listnomiss)-1 do spawn,'echo "'+listnomiss[i]+'" >> '+txtnomiss

;for i=1,n_elements(listall)-1 do spawn,'echo "'+listall[i]+' '+file2time(listf2[i])+'" >> '+txtall

for i=1,n_elements(listall)-1 do spawn,'echo "'+pgrian+listall[i]+'" >> '+txtall


stop



end