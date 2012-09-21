pro smart_struct2heliodb, arstruct, extentstr, armask,obsstr,filenumber=fnumber,file=file, wrpath=wrpath, outfile=outfile, append=append, no_nl=no_nl, no_ext=no_ext, numid=numid,smlake=outlake2,lrlake=outlake7,lakemorph=outmorph

if n_elements(file) lt 1 then file=time2file(arstruct[0].time)

for j=0,n_elements(file)-1 do begin
	thisfile=file[j]
	
	;print,thisfile
	
	if n_elements(arstruct) lt 1 then begin
		if (reverse(str_sep(thisfile,'.')))[0] eq 'gz' then begin
			spawn,'gunzip -f '+thisfile
			restore,strjoin((str_sep(thisfile,'.'))[0:n_elements(str_sep(thisfile,'.'))-2],'.')
			spawn,'gzip -f '+strjoin((str_sep(thisfile,'.'))[0:n_elements(str_sep(thisfile,'.'))-2],'.')
		endif else restore,thisfile
	endif
	
	if not keyword_set(wrpath) then wrpath='';smart_paths(/log,/no_calib)
	;wrpath='~/science/data/issi_data/'
	
	if n_elements(outfile) lt 1 then outfile='smart_meta_'+time2file(file2time(thisfile))+'.dat'
	;if not keyword_set(outfile) then outfile=wrpath+'smart_meta_'+time2file(file2time(thisfile))+'.dat'
	
	;print,outfile
	
	if not keyword_set(append) then begin
		fields=[string(['#FRC_INFO_ID','OBSERVATION_ID','RUN_DATE','AR_DATE','ARC_ARC_X','ARC_ARC_Y','ARC_CAR_LAT','ARC_CAR_LON', $ ;8
			'FEAT_NPIX','FEAT_AREA'],format='(A13)'),string(['BR_ARC_X_Y','BR_PIX_X_Y'],format='(A26)'),string(['FEAT_MAX_INT', $ ;27
			'FEAT_MIN_INT','FEAT_MEAN_INT','ENC_MET','CC_PIX_X','CC_PIX_Y','CC_ARC_X', $
			'CC_ARC_Y','CHAIN_CODE','CCODE_LNTH'],format='(A13)'),'SNAPSHOT_FILENAME','SNAPSHOT_PATH']
;			'ID_ASCII',,'CCODE_SKE_LNTH','PR_LOCFNAME']
		formarr=[string([strarr(4)+'(A14)',strarr(7)+'(E14.5)'],form='(A14)'),string(strarr(2)+'(A27)',form='(A27)'),string([strarr(16)+'(E14.5)',strarr(6)+'(A14)'],form='(A14)')]
;		if not keyword_set(no_nl) then begin
;			nlfields=string(['Lnl_Mm','Lsg_Mm','MxGrad_GpMm','MeanGrad','MednGrad','Rval_Mx','WLsg_GpMm','R_Str','WLsg_Str'],format='(A13)')
;			fields=[fields,nlfields]
;		endif
;		if not keyword_set(no_ext) then begin
;			extfields=string(['HGlon_wdth','HGlat_wdth','RdegE','RdegW'],format='(A13)')
;			fields=[fields,extfields]
;		endif
;		spawn,'echo "'+strjoin(formarr,';')+'" > '+wrpath+outfile
		spawn,'echo "'+strjoin(fields,';')+'" > '+wrpath+outfile
	endif
	
	nar=n_elements(arstruct)
	for i=0,nar-1 do begin
;	print,i
	
		formdata='(E13.5)'	
		formdatabound='(A26)'
		blnkenter=string(0d,format='(A13)')
	
		thisar=arstruct[i]
		if not keyword_set(no_ext) then thisext=extentstr[i]
	
		;DO CHAINCODE STUFF
		thismask=armask
		thismask[where(thismask ne i+1)]=0
		wmask=where(thismask eq i+1)
                thismask[wmask]=1
                omask=thismask
                thismask=morph_close(thismask,replicate(1,3,3))
                if total(thismask-omask) gt 0 then spawn,'echo "'+'filenumber: '+string(fnumber)+' AR: '+string(i)+'" >> '+outmorph
		masksz=size(thismask)
		wmask=where(thismask eq 1)

;		contour,thismask,lev=.5,path_xy=thisxypath,/PATH_DATA_COORDS
;		thisxypath=[[thisxypath],[thisxypath[*,0]]]
;		thisindices = contour_nogap(thisxypath)
		
; stop               
		chboxind = wmask
                ;#### Check if the blob inside box
                ;#### contains holes and fill them

;stop

                chboxind2 = EGSO_SFC_LAKE2BAY(chboxind,masksz[1],masksz[2]) 

        chbound_ind  = EGSO_SFC_inner_BOUNDARY(chboxind,masksz[1],masksz[2]) 
        chbound_ind  = EGSO_SFC_M_CONNECT(chbound_ind,masksz[1],masksz[2])
          ;To fix the pixels of internal corners as
          ;ooo   oooo
          ;   o o
          ;    o
          ;     o  <- this one should dissapear: value=2 from pixcumul
          values = EGSO_SFC_PIXCUMUL(chbound_ind,masksz[1],masksz[2])
          labval2=where(values eq 2,numval2)
          while numval2 gt 0 do begin
             values[labval2]=0
             chbound_ind=where(values ne 0)
             chbound_ind  = EGSO_SFC_M_CONNECT(chbound_ind,masksz[1],masksz[2])
             values = EGSO_SFC_PIXCUMUL(chbound_ind,masksz[1],masksz[2])
             labval2=where(values eq 2,numval2)
                spawn,'echo "'+'filenumber: '+string(fnumber)+' AR: '+string(i)+'" >> '+outlake2
          endwhile

          ;To fix problem as internal corners as
          ;       
          ;          1111111111                  1111111111
          ;          111111 111                  1111110111
          ;          11111 1111    ====>         1111101111      ===0-1==>so they are M connected!
          ;          1111 11111                  1111 11111
          ;          1    11111                  1    11111
          ;  
          ;  It's done finding which white spaces has 7 
          ;  pixels around belonging to the mask (then that pixel is a hole!)
          ;  and converted those to 1 (0 in the drawing so they are identified).
          new_mask=thismask
          new_mask[chboxind]=1b
          labval4=where(values eq 4,numval4)
          neigh8=[-1-masksz[1],-masksz[1],+1-masksz[1],-1,0,+1,-1+masksz[1],masksz[1],1+masksz[1]]
          while numval4 gt 0 do begin
             for nn4=0,numval4-1 do begin
                iind=labval4[nn4]+neigh8
                posinn=where(new_mask[iind] eq 0,nposinn)
                if nposinn lt 3 then begin
                   for nn7=0,nposinn-1 do begin
                      if total(new_mask[iind[posinn[nn7]]+neigh8]) eq 7 then new_mask[iind[posinn[nn7]]]=1
 ;                     plot_image,new_mask[600:660,660:700]
                spawn,'echo "'+'filenumber: '+string(fnumber)+' AR: '+string(i)+'" >> '+outlake7

                   endfor
                endif
             endfor
             chboxind=where(new_mask ne 0)
             chbound_ind  = EGSO_SFC_inner_BOUNDARY(chboxind,masksz[1],masksz[2]) 
             chbound_ind  = EGSO_SFC_M_CONNECT(chbound_ind,masksz[1],masksz[2])
             values = EGSO_SFC_PIXCUMUL(chbound_ind,masksz[1],masksz[2])
             labval4=where(values eq 4,numval4)
          endwhile

;stop
;if i eq 0 then stop

        chbound_ind  = EGSO_SFC_ORDER_IND(chbound_ind,masksz[1],masksz[2])
        chbnd_chain_strt  = chbound_ind[0]
        chbnd_chain  = EGSO_SFC_CHAIN_CODE(chbound_ind,masksz[1],masksz[2])
		
		cc_px=array_indices(thismask,chbound_ind[0])
                cc_arc=(cc_px-512)*1.984
                chaincode=string(chbnd_chain,format='('+strtrim(n_elements(chbnd_chain),2)+'I1)') 
;		chainy=
;stop
	
	;Naming
;		if strlen(thisar.smid) lt 3 then smid=string(thisar.smid,format='(A19)') else begin
;			if keyword_set(numid) then smid=string(thisar.smid, form='(A19)') $
;				else smid=string(strmid(thisar.smid,4,4)+'.'+strmid(thisar.smid,9,4)+'.'+(str_sep(thisar.smid,'.'))[2], form='(A19)')
;		endelse
		class=thisar.class
		type=strjoin(thisar.type,'')
		time=time2file(thisar.time)
;print,time
		
	;Position Properties	
		xcen=string(thisar.xpos,form=formdata)      ;XY center from the image! (0,0) is bottom left corner.
		ycen=string(thisar.ypos,form=formdata)
		xbary=string(thisar.xbary,form=formdata)    ;?????
		ybary=string(thisar.ybary,form=formdata)
		hcenx=string(thisar.hclon,form=formdata)    ;XY center from the center of the disk! (0,0) is sun center.
		hceny=string(thisar.hclat,form=formdata)
		hglat=string(thisar.hglat,form=formdata)    ;Lat-Lon in heliographic coordinates.
		hglon=string(thisar.hglon,form=formdata)
		carlon=string(thisar.carlon,form=formdata)  ;Lat-Lon carrington coordinates
		carlat=string(thisar.carlat,form=formdata)
		boundxy=string(strjoin(strtrim(fix([thisext.XYLON,thisext.XYLat]),2),','),form=formdatabound)
		boundarc=string(strjoin(strtrim(fix(round(([thisext.XYLON,thisext.XYLat]-512)*1.984)),2),','),form=formdatabound)
	;Magnetic Properties
		npix=string(thisar.NARPX,form=formdata)
		area=string(thisar.area,form=formdata)
		areadeg=string(thisar.narpx*(.014),form=formdata)
		flux=string(thisar.bflux*1d16,form=formdata)
		fluxp=string(thisar.bfluxpos*1d16,form=formdata)
		fluxn=string(thisar.bfluxneg*1d16,form=formdata)
		fluximb=string(abs(thisar.bfluxpos-thisar.bfluxneg)/thisar.bflux,form=formdata)
		fluxemg=string(thisar.bfluxemrg*1d16,form=formdata)
		bmin=string(thisar.bmin,form=formdata)
		bmax=string(thisar.bmax,form=formdata)
		bmean=string(thisar.meanval,form=formdata)

        ;File properties
                frc_info=2 ;0 filaments, 1 AR.
                image_numb=fnumber
		
;		thismeta=[smid+' ', string([time,class,type,xcen,ycen,xbary,ybary, $
;			hcenx,hceny,hglon,hglat,carlon,carlat, $
;			area,flux,fluxp,fluxn,fluximb,fluxemg,bmin,bmax,bmean],form='(A13)')]
                
;; 		fields=[string(['FRC_INFO_ID','OBSERVATION_ID','RUN_DATE','AR_DATE','ARC_ARC_X','ARC_ARC_Y','ARC_CAR_LAT','ARC_CAR_LON', $ ;8

               thismeta=[string(frc_info),string(fnumber),anytim(systim(/utc),/ccsd),anytim(thisar.time,/ccsd),string(hcenx),string(hceny),string(carlat),string(carlon), $ ;8
;; 			'FEAT_NPIX','FEAT_AREA'],format='(A13)'),string(['BR_ARC_X_Y','BR_PIX_X_Y'],format='(A26)'),string(['FEAT_MAX_INT', $
                          string(npix),string(areadeg),string(boundarc),string(boundxy),string(bmax),$
;; 			'FEAT_MIN_INT','FEAT_MEAN_INT','ENC_MET','CC_PIX_X','CC_PIX_Y','CC_ARC_X', $
                           string(bmin), string(bmean),'CHAIN CODE',string(cc_px[0],format='(I4)'),string(cc_px[1],format='(I4)'),string(cc_arc[0],format='(F8.2)'), $
;; 			'CC_ARC_Y','CHAIN_CODE','CCODE_LNTH'] $
                          string(cc_arc[1],format='(I4)'),chaincode,string(n_elements(chbnd_chain)),'smart_'+time2file(thisar.time)+'.png','http://solarmonitor.org/phiggins/smart_plots/']


	;PIL Properties
;	if not keyword_set(no_nl) then begin
;		lnl=string((thisar.nlstr).lnl,form=formdata)
;		lsg=string((thisar.nlstr).lsg,form=formdata)
;		maxgrad=string((thisar.nlstr).gradmax,form=formdata)
;		meangrad=string((thisar.nlstr).gradmean,form=formdata)
;		mediangrad=string((thisar.nlstr).gradmedian,form=formdata)
;		rval=string((thisar.nlstr).rval,form=formdata)
;		wlsg=string((thisar.nlstr).wlsg,form=formdata)
;		r_star=string((thisar.nlstr).r_star,form=formdata)
;		wlsg_star=string((thisar.nlstr).wlsg_star,form=formdata)

;		thisnlmeta=string([lnl,lsg,maxgrad,meangrad,mediangrad,rval,wlsg,r_star,wlsg_star],form='(A13)')
;		thismeta=[thismeta,thisnlmeta]
;	endif

	;Extent Properties
;	if not keyword_set(no_ext) then begin
;		hglonwd=string(thisext.HGLONWIDTH,form=formdata)
;		hglatwd=string(thisext.HGLATWIDTH,form=formdata)
;		rdeglone=string((thisext.RDEGLON)[0],form=formdata)
;		rdeglonw=string((thisext.RDEGLON)[1],form=formdata)
;
;		thisextmeta=string([hglonwd,hglatwd,rdeglone,rdeglonw],form='(A13)')
;		thismeta=[thismeta,thisextmeta]
;	endif

		spawn,'echo "'+strjoin(thismeta,';')+'" >> '+outfile ;wrpath+'smart_meta_'+time2file(file2time(thisfile))+'.dat'
	
	endfor
endfor
end
