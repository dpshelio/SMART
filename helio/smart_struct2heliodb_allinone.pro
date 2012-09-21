pro obs_table,inst=inst,fits_file=fits_file,file_num=file_num,file_obs=file_obs,infile_search=infile_search,check_num=check_num,save_path=save_path,pathinstr=pathinstr,sm_archive=sm_archive,sm_file=sm_file
;+
;-
;; General properties
  if not keyword_set(file_num) then file_num=1l
  if not keyword_set(save_path) then save_path='./'
 
  entry='>'
  if not keyword_set(file_obs) then begin
     fileobs=save_path+'obs_table_'+inst+'_'+time2file(systim(/utc))+'.csv'
  endif else begin
     fileobs=save_path+file_obs  
     if file_test(fileobs) then begin 
        entry='>>'
        if keyword_set(infile_search) then begin
           ;Look if inst_filename entry exist
           spawn,"grep "+fits_file+" "+fileobs+ " | awk -F ';' '{print $1}' | sed 's/;//'",out
           file_num=(out+0l ne 0)?(out+0l):file_num    ;file_NUM changes if entry was found.
           entry=(out+0 ne 0)?'x':entry        ;entry is not created if file entry exist
        endif
        if (keyword_set(check_num) and entry eq '>>') then begin
           ;Look if eit_num is the proper one
           ;spawn,"wc -l "+file_obs, out
           spawn,"tail -n1 "+fileobs+ " | awk -F ';' '{print $1}' | sed 's/;//'",out
           file_num=(out+1l eq file_num)?file_num:(out+1l)
           print,'obs_table: '+string(file_num)
        endif
     endif 
  endelse
  

  if entry ne 'x' then begin
     extract_fits_info,inst=inst,fits_file=fits_file,outdataline=outdataline,file_num=file_num,tags=tags,pathinstr=pathinstr
     if entry eq '>' then begin
        spawn,'echo ''#'+strjoin(tags,';')+''' ' + entry + fileobs
        entry='>>'
     endif
     spawn,'echo '''+strjoin(outdataline,';')+''' ' + entry + fileobs
  endif
end

;======================================================================================================
;======================================================================================================

pro extract_fits_info,inst=inst,fits_file=fits_file,outdataline=outdataline,file_num=file_num,tags=tags, $
                      pathinstr=instpath,sm_archive=sm_archive,sm_file=sm_file
;+
;-
;; Check if instpath has a slash at the end
instpath=((strpos(instpath,'/',/reverse_search))[0] eq strlen(instpath)-1)?instpath:instpath+'/'

;;
  if inst eq 'mdi' then begin
     ;inst_path='../';***
     obs_id=2
     r_sun='r_sun'
     center_x='center_x'
     center_y='center_y'
     parts=str_sep(fits_file,'.')
     mdi_dir=parts[0]+'.'+string(parts[1]+0,format='(I6.6)')+'/'
     url='"http://soi.Stanford.EDU/magnetic/mag//"+mdi_dir+fits_file'
;     mdi_dir=''
     inst_path=instpath;+mdi_dir
  endif
  if inst eq 'eit' then begin
     ;inst_path='../';***
     obs_id=3
     r_sun='solar_r'
     center_x='crpix1'
     center_y='crpix2'
     url='"http://sohodata.nascom.nasa.gov//archive/soho/private/data/processed/eit/lz/"+yyyy+"/"+mm+"/"+fits_file'
     yyyy=strmid(fits_file,3,4)
     mm=strmid(fits_file,7,2)
     inst_path=instpath+yyyy+'/'+mm+'/'
  endif

  obsstr={id:0l,observatory_id:0l,date_obs:'',date_end:'',jdint:0d, jdfrac:0.,exp_time:0l,c_rotation:0., $
          bscale:0l,bzero:0l,bitpix:0l,naxis1:0l,naxis2:0l,r_sun:0.,center_x:0.,center_y:0.,cdelt1:0.,$
          cdelt2:0.,quality:'',filename:'',date_obs_string:'',date_end_string:'',comment:'',loc_filename:'',id2:''}

fits_file2r=fits_file
;TODO: sm_file must be the solarmonitor filename but in /tmp/...
  if keyword_set(sm_archive) then fits_file2r=sm_file
  mreadfits,inst_path+fits_file2r,remoteind


  obsstr.id=file_num
  obsstr.observatory_id=obs_id

  if (where(strlowcase(tag_names(remoteind)) eq 'date_obs'))[0] eq -1 then begin
     mreadfits,'/Volumes/LaCie/data/mdi_mag_orig/fd_M_96m_01d.1461.0000.fits',remoteind
     remoteind=clear_struct(remoteind) 
     obsstr.date_obs=time 
     obsstr.date_end=time
  endif else begin
     obsstr.date_obs=anytim(remoteind.date_obs,/ccsds)
     obsstr.date_end=anytim(remoteind.date_obs,/ccsds)
  endelse
  
  time=obsstr.date_obs

  ftime=time2file(time,/second)
  yyyy=strmid(ftime,0,4) & mm=strmid(ftime,4,2) & dd=strmid(ftime,6,2) & hh=strmid(ftime,9,2) & mn=strmid(ftime,11,2) & ss=strmid(ftime,13,2)
  julian=julday(mm,dd,yyyy,hh,mn,ss)
  obsstr.jdint=long(julian)
  obsstr.jdfrac=julian-long(julian)
  obsstr.exp_time=(inst eq 'mdi')?0l:remoteind.exptime            ;remoteind.exp_time  !!Check!!
  obsstr.c_rotation=tim2carr(time, /dc)
  obsstr.bscale=(inst eq 'mdi')?1l:remoteind.bscale  
  obsstr.bzero=(inst eq 'mdi')?0l:remoteind.bzero    
  obsstr.bitpix=remoteind.bitpix
  obsstr.naxis1=remoteind.naxis1
  obsstr.naxis2=remoteind.naxis2
  a=execute('obsstr.r_sun=remoteind.'+r_sun)  
  a=execute('obsstr.center_x=remoteind.'+center_x)
  a=execute('obsstr.center_y=remoteind.'+center_y)
  obsstr.cdelt1=remoteind.cdelt1
  obsstr.cdelt2=remoteind.cdelt2
  obsstr.quality=''
  obsstr.filename=fits_file
  obsstr.date_obs_string=remoteind.date_obs
  obsstr.date_end_string=remoteind.date_obs
  obsstr.comment=''             ;remoteind.comment
  a=execute('obsstr.loc_filename='+url)
  obsstr.id2='" "'

outdataline=strarr(n_elements(tag_names(obsstr)))
tags=tag_names(obsstr)

print,'extracts_fits_info: '+strtrim(obsstr.(0),2)

for i=0,n_elements(tags)-1 do outdataline[i]=strtrim(obsstr.(i),2)



end

;======================================================================================================
;======================================================================================================
pro grp_table,grp_str=grp_str,file_grp=file_grp,grp_nst=grp_nst,grp_num=grp_num,save_path=save_path,check_num=check_num
;+
;-
;; General properties
  if not keyword_set(grp_nst) then grp_nst=1l
  if not keyword_set(save_path) then save_path='./'
 
  entry='>'
  if not keyword_set(file_grp) then begin
     filegrp=save_path+'grp_table_'+time2file(systim(/utc))+'.csv'
  endif else begin
     filegrp=save_path+file_grp
     if file_test(filegrp) then begin
        entry='>>'
     endif
     if (keyword_set(check_num) and entry eq '>>') then begin
           ;Look if eit_num is the proper one
           ;spawn,"wc -l "+file_obs, out
        spawn,"tail -n1 "+filegrp+ " | awk -F ';' '{print $1}' | sed 's/;//'",out
        grp_nst=(out+1 eq grp_nst)?grp_nst:(out+1)
     endif

  endelse

  grp_num=indgen(n_elements(grp_str))+grp_nst
  for i=0,n_elements(grp_num)-1 do begin
     extract_grp_info,grpstr=grp_str[i],num=grp_num[i],outdataline=outdataline,tags=tags
     if entry eq '>' then begin
        spawn,'echo ''#'+strjoin(tags,';')+''' ' + entry + filegrp
        entry='>>'
     endif
     spawn,'echo '''+strjoin(outdataline,';')+''' ' + entry + filegrp
  endfor

  grp_nst=grp_num[n_elements(grp_num)-1]+1
end

;======================================================================================================
;======================================================================================================
pro extract_grp_info,grpstr=grpstr,num=grpnum,outdataline=outdataline,tags=tags
;+
;-

  group={id:0l,ch_nums:'',chgr_br_pix:'',chgr_br_deg:'',chgr_br_arc:'',$
         chgr_cbr_pix:'',chgr_cbr_deg:'',chgr_cbr_arc:'',$
         chgr_lat_width_deg:0.,chgr_lon_width_deg:0.,chgr_lat_width_arc:0.,chgr_lon_width_arc:0.,$
         chgr_area_pix:0l,chgr_mean_bz:0.}
  
  group.id=grpnum
  group.ch_nums=strcompress(strjoin(grpstr.ch_nums[where(grpstr.ch_nums ne 0)],','),/remove_all)
  group.chgr_br_pix=strcompress(strjoin(grpstr.chgr_br_pix,','),/remove_all)
  group.chgr_br_deg=strcompress(strjoin(grpstr.chgr_br_deg,','),/remove_all)
  group.chgr_br_arc=strcompress(strjoin(grpstr.chgr_br_arc,','),/remove_all)
  group.chgr_cbr_pix=strcompress(strjoin(grpstr.chgr_cbr_pix,','),/remove_all)
  group.chgr_cbr_deg=strcompress(strjoin(grpstr.chgr_cbr_deg,','),/remove_all)
  group.chgr_cbr_arc=strcompress(strjoin(grpstr.chgr_cbr_arc,','),/remove_all)
  group.chgr_lat_width_deg=grpstr.chgr_lat_width_deg
  group.chgr_lon_width_deg=grpstr.chgr_lon_width_deg
  group.chgr_lat_width_arc=grpstr.ch_lat_width_arc
  group.chgr_lon_width_arc=grpstr.ch_lon_width_arc
  group.chgr_area_pix=grpstr.chgr_npix
  group.chgr_mean_bz=grpstr.chgr_mean_bz


outdataline=strarr(n_elements(tag_names(group)))
tags=tag_names(group)
for i=0,n_elements(tags)-1 do outdataline[i]=strtrim(group.(i),2)

end

;======================================================================================================
;======================================================================================================

pro ars_table, ar_str=ar_str, file_ars=file_ars, ars_nst=ars_nst, check_num=check_num, $
               mdi_file_t=mdi_num_t,mdi_file_0=mdi_num,save_path=save_path,file_str=infostr, $
               ars_mask=ars_mask,smlake=smlake,lrlake=lrlake,lakemorph=lakemorph,struct_filename=struct_filename  ;extra output info 

;+
;-
;; General properties
  if not keyword_set(ars_nst) then ars_nst=1l
  if not keyword_set(save_path) then save_path='./'
 
  entry='>'
  if not keyword_set(file_ars) then begin
     filears=save_path+'ars_table_'+time2file(systim(/utc))+'.csv'
  endif else begin
     filears=save_path+file_ars
     if file_test(filears) then begin
         entry='>>'
     endif
     if (keyword_set(check_num) and entry eq '>>') then begin
           ;Look if eit_num is the proper one
           ;spawn,"wc -l "+file_obs, out
        spawn,"tail -n1 "+filears+ " | awk -F ';' '{print $1}' | sed 's/;//'",out
        ars_nst=(out+1 eq ars_nst)?ars_nst:(out+1)
     endif

  endelse

  ars_num=indgen(n_elements(ar_str))+ars_nst
  for i=0,n_elements(ars_num)-1 do begin
     thismask=ars_mask
     thismask[where(thismask ne i+1)]=0
     thismask[where(thismask ne 0)]=1
     extract_ars_info,arstr=ar_str[i],  num=ars_num[i], $
                      mdi_file_0=mdi_num,mdi_file_t=mdi_num_t,outdataline=outdataline,$
                      tags=tags,infostr=infostr, $
                      ar_mask=thismask,smlake=smlake,lrlake=lrlake,lakemorph=lakemorph,$
                      str_filename=struct_filename,inum=i
     if entry eq '>' then begin
        spawn,'echo ''#'+strjoin(tags,';')+''' ' + entry + filears
        entry='>>'
     endif
     spawn,'echo '''+strjoin(outdataline,';')+''' ' + entry + filears
  endfor

  ars_nst=ars_num[n_elements(ars_num)-1]+1
end

;======================================================================================================
;======================================================================================================

pro extract_ars_info,arstr=arstr, num=num, $
                     mdi_file_0=mdi_file,mdi_file_t=mdi_file_t, $
                     outdataline=outdataline,tags=tags,infostr=infostr, $
                     ar_mask=ar_mask,smlake=smlake,lrlake=lrlake,lakemorph=lakemorph,str_filename=str_filename, inum=numi
;+
;-

  AR={id:0l,frc_info:0l, mdi_file:0l, mdi_file_t:0l,run_date:'',obs_date:'',obs_date_t:'', $
      arc_arc_x:0.,arc_arc_y:0.,arc_car_lat:0.,arc_car_lon:0., $
      ar_npix:0l,ar_area:0., $
      br_arc_x1:0., br_arc_y1:0., br_arc_x2:0., br_arc_y2:0., $
      br_pix_x1:0, br_pix_y1:0, br_pix_x2:0, br_pix_y2:0,$
      ar_max_int:0.,ar_min_int:0.,ar_mean_int:0.,$
      ar_lnl:0.,ar_lsg:0.,ar_grad_max:0.,ar_grad_mean:0.,ar_grad_median:0., $
      ar_rval:0.,ar_wlsg:0.,$
      enc_met:'',cc_pix_x:0l,cc_pix_y:0l,cc_arc_x:0.,cc_arc_y:0., $
      chain_code:'',cc_length:0l, $
      snapshot_filename:'',snapshot_path:''}
 

  ar.id=num
  ar.frc_info=       2
  ar.mdi_file=       mdi_file
  ar.mdi_file_t=     mdi_file_t
  ar.run_date=       anytim(infostr.run_date,/ccsds)
  ar.obs_date=       anytim(infostr.date_obs,/ccsds)
  ar.obs_date_t=     anytim(infostr.date_obs_t,/ccsds)

  ar.arc_arc_x=      arstr.hclon
  ar.arc_arc_y=      arstr.hclat
  ar.arc_car_lat=    arstr.carlat
  ar.arc_car_lon=    arstr.carlon

  ar.ar_npix=        arstr.narpx
  ar.ar_area=        arstr.narpx*(.014)  ;area in deg
;;TODO: BREAK bound box into four coordinates
  ar.br_arc_x1=      (fix(round(([arstr.exstr.XYLON]-512)*1.984)))[0]
  ar.br_arc_y1=      (fix(round(([arstr.exstr.XYLAT]-512)*1.984)))[0]
  ar.br_arc_x2=      (fix(round(([arstr.exstr.XYLON]-512)*1.984)))[1]
  ar.br_arc_y2=      (fix(round(([arstr.exstr.XYLAT]-512)*1.984)))[1] 
  ar.br_pix_x1=      (fix(round([arstr.exstr.XYLON])))[0] 
  ar.br_pix_y1=      (fix(round([arstr.exstr.XYLAT])))[0] 
  ar.br_pix_x2=      (fix(round([arstr.exstr.XYLON])))[1] 
  ar.br_pix_y2=      (fix(round([arstr.exstr.XYLAT])))[1] 

  ar.ar_max_int=     arstr.bmax
  ar.ar_min_int=     arstr.bmin
  ar.ar_mean_int=    arstr.meanval

  ar.ar_lnl=         arstr.nlstr.lnl
  ar.ar_lsg=         arstr.nlstr.lsg
  ar.ar_grad_max=    arstr.nlstr.gradmax
  ar.ar_grad_mean=   arstr.nlstr.gradmean
  ar.ar_grad_median= arstr.nlstr.gradmedian

  ar.ar_rval=        arstr.nlstr.rval
  ar.ar_wlsg=        arstr.nlstr.wlsg

  ar.enc_met=        'CHAIN CODE'
  ar.cc_pix_x=       arstr.cc_px[0]
  ar.cc_pix_y=       arstr.cc_px[1]
  ar.cc_arc_x=       arstr.cc_arc[0]
  ar.cc_arc_y=       arstr.cc_arc[1]
  ar.chain_code=     arstr.chaincode
  ar.cc_length=      arstr.cc_len

  ar.snapshot_filename='smart_'+time2file(arstr.time)+'.png'
  ar.snapshot_path=  'http://solarmonitor.org/phiggins/smart_plots/'

  
  outdataline=strarr(n_elements(tag_names(ar)))
tags=tag_names(ar)
for i=0,n_elements(tags)-1 do outdataline[i]=strtrim(ar.(i),2)

end
;======================================================================================================
;======================================================================================================

pro grp_webtable,grp_str=grp_str,file_str=file_str,web_path=web_path
;+
;
;-
;file_name
date=strmid(file_str.eit_filename,3,13) ;efz20080103.103609 => 20080103.1036
date=str_replace(date,'.','_')  ; 20080103.1036 => 20080103_1036

outfile=web_path+'charm_'+date+'_chgrp.html'


;writing file
 ;writing header
	spawn,'echo "<html>" > '+outfile
	spawn,'echo "<body>" >> '+outfile
        spawn,'echo "<div class=charmt>" >> ' + outfile
	spawn,'echo "<table rules=rows width=100% align=center cellspacing=0 cellpadding=0 bgcolor=#f0f0f0>" >> '+outfile
        spawn,'echo "<tr align=center class=chtit background=common_files/brushed-metal.jpg><td colspan=6 border=0> CHARM Coronal Holes Groups </td></tr>" >> '+outfile
        spawn,'echo "<tr align=center class=chcolumns background=common_files/brushed-metal.jpg><td>Group ID</td><td> HG Lon,Lat</td><td>E/W-most points [Deg]</td><td>Area [10<sup>7</sup>Mm<sup>2</sup>]</td><td>B<sub>z</sub> [G]</td><td>&Phi; [10<sup>23</sup>Mx]</td></tr>"  >> '+outfile
 ;writing data
	ngr=n_elements(grp_str)
	for i=0,ngr-1 do begin
		thisgr=grp_str[i]
                spawn,'echo "<tr class=chresults align=center><td>'+string(thisgr.chgr_num,format='(I2)')+'</td><td>'+string(thisgr.chgr_cbr_DEG[0],form='(F5.1)')+','+string(thisgr.chgr_cbr_DEG[1],form='(F5.1)')+'</td><td>'+string(thisgr.chgr_br_deg[0])+'/'+string(thisgr.chgr_br_deg[2])+'</td><td>'+string(thisgr.chgr_grea_mm/1e7,format='(F7.2)')+'</td><td>'+string(thisgr.chgr_mean_bz,form='(F7.2)')+'</td><td>'+string(thisgr.chgr_mean_bz*thisgr.chgr_grea_mm/1e7,form='(F7.2)')+'</td></tr>" >> '+outfile
	endfor
 ;writing footer
	spawn,'echo "</table>" >> '+outfile
	spawn,'echo "</div>" >> '+outfile		
	spawn,'echo "</body>" >> '+outfile
	spawn,'echo "</html>" >> '+outfile



end

;======================================================================================================
;======================================================================================================
pro smart_struct2heliodb_frcinfo,outfrc=outfrc

frc={id:0l,institut:'',name_code:'',version_code:'',feature:'',Person:''}

frc.id=   2
frc.institut='TCD'
frc.name_code='SMART'
frc.version_code='1.0'
frc.feature='ACTIVE REGIONS'
frc.Person='PAUL HIGGINS'

outdataline=strarr(n_elements(tag_names(frc)))
tags=tag_names(frc)
for i=0,n_elements(tags)-1 do outdataline[i]=strtrim(frc.(i),2)


spawn,'echo ''#'+strjoin(tags,';')+''' ' + '>' + outfrc
spawn,'echo '''+strjoin(outdataline,';')+''' ' + '>>' + outfrc
 

end

;======================================================================================================
;======================================================================================================


pro smart_struct2heliodb_obsinfo,outobs=outobs

obs={id:0l,Observat:'',Instrument:'',Telescope:'',Units:'',Wavelnth:0.,Wavename:'',Waveunit:'',Obs_type:'',Comment:''}

obs.id=   2
obs.Observat='SoHO'
obs.Instrument='MDI'
obs.Telescope='Magnetogram'
obs.Units='Gauss'
obs.Wavelnth=676.8
obs.wavename='Ni I'
obs.waveunit='nm'
obs.Obs_type='line_of_sight magnetic field'
obs.Comment='96-min fd'

outdataline=strarr(n_elements(tag_names(obs)))
tags=tag_names(obs)
for i=0,n_elements(tags)-1 do outdataline[i]=strtrim(obs.(i),2)


spawn,'echo ''#'+strjoin(tags,';')+''' ' + '>' + outobs
spawn,'echo '''+strjoin(outdataline,';')+''' ' + '>>' + outobs
 
end


;======================================================================================================
;======================================================================================================

pro smart_struct2heliodb_allinone,struct_filename=struct_filename,save_path=save_path, $
                                   mdi_num=mdi_num,mdi_file_obs=mdi_file_obs, $
                                  t_mdi_num=mdi_num_t, $
                                  mdi_insearch=mdi_insearch,mdi_check_num=mdi_check_num, mdi_data_dir=mdipath,mdi_save_path=mdi_save_path, $ ;MDI inputs
                                  file_ars=file_ars,ars_nst=ars_nst,ars_check_num=ars_check, $;ARs inputs
                                  solarmonitor=solarmonitor,web_path=web_path,sm_archive=sm_archive

;;TODO: add area in Mm (Lar has added to the structures).


;+
;-


;; General properties
  if not keyword_set(save_path) then save_path='./'
  if not keyword_set(web_path) then web_path=save_path


;; Reading structure sav file
  if not keyword_set(struct_filename) then begin
     print,'Needed file!'
     ;TODO: allow to ask for a file..
  endif


;; Restoring sav files
if (reverse(str_sep(struct_filename,'.')))[0] eq 'gz' then begin
	spawn,'gunzip -f '+struct_filename
	restore,strjoin((str_sep(struct_filename,'.'))[0:n_elements(str_sep(struct_filename,'.'))-2],'.'),/v
	spawn,'gzip -f '+strjoin((str_sep(struct_filename,'.'))[0:n_elements(str_sep(struct_filename,'.'))-2],'.')
endif else restore,struct_filename;,/v

if arstruct[0].id eq '' then goto,nodata

;; MDI FILE NUMBERING AND OUTPUT
  obs_table,inst='mdi',fits_file=s_f.mdi_filename_t,file_num=mdi_num_t,file_obs=mdi_file_obs,infile_search=mdi_insearch,check_num=mdi_check_num,save_path=mdi_save_path,pathinstr=mdipath,sm_archive=sm_archive,sm_file=s_f.mdi_solarm_t

  obs_table,inst='mdi',fits_file=s_f.mdi_filename,file_num=mdi_num,file_obs=mdi_file_obs,infile_search=mdi_insearch,check_num=mdi_check_num,save_path=mdi_save_path,pathinstr=mdipath,sm_archive=sm_archive,sm_file=s_f.mdi_solarm

;; CHs numbering and output
  ars_table,ar_str=arstruct, file_ars=file_ars,ars_nst=ars_nst,check_Num=ars_check, $ ;ARs inputs
            mdi_file_t=mdi_num_t,mdi_file_0=mdi_num,file_str=s_f,save_path=save_path, $  ;files info
            ars_mask=armask,struct_filename=struct_filename ;extra output info 


;; Create files for solar monitor
 if keyword_set(solarmonitor) then grp_webtable,grp_str=s_gr,file_str=s_f,web_path=web_path


;; Rest of program...

;mdi_num+=1l  ;unless file from other source used.
;mdi_num_t+=1l  
nodata:
end



 ;; .r smart_struct2heliodb_allinone.pro
 ;;  filelist='smart_20070101_0135.sav'
 ;;  i=0
 ;;  spath=smart_paths(/no_calib,/db,outdatadir=outdatadir)
 ;;  rundate=time2file(systim(/utc))
 ;;   outfrc=rundate+'_ar_frc.csv'
 ;;   outfits=rundate+'_ar_observation.csv'     ;done!
 ;;   outobservatory=rundate+'_ar_observatory.csv'
 ;;   outresults=rundate+'_ar_results.csv'
 ;;   print,spath
 ;;  ;; ./database/
 ;;  ;; IDL> $mkdir database
 ;;   mdidir='/tmp/'
 ;;   outlake2='./lake2.txt'
 ;;   outlake7='./lake7.txt'
 ;;   outmorph='./lakemorph.txt'
 ;;   web=0
 ;;   solarmonitor=0
 ;;   sm_archive=0
 ;;   print,outfrc
 ;;  ;; 20101027_2050_ar_frc.csv
 ;;    smart_struct2heliodb_allinone,struct_filename=filelist[i],save_path=spath, $
 ;;                                  mdi_num=mdi_num,mdi_file_obs=outfits,/mdi_insearch,/mdi_check_num,mdi_data_dir=mdidir,mdi_save_path=spath, $
 ;;                                  file_ars=outresults,ars_nst=chs_nst, /ars_check_num, smlake=outlake2,lrlake=outlake7,lakemorph=outmorph,$
 ;;                                  solarmonitor=solarmonitor,web_path=web,sm_archive=sm_archive
