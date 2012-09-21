function chaincode_creation,mask,cc_arc=cc_arc,cc_px=cc_px,cc_len=cc_len

  thismask=mask 
  thismask=morph_close(thismask,replicate(1,3,3))
  ;if total(thismask-mask) gt 0 then spawn,'echo "'+'filenumber: '+string(fnumber)+' AR: '+string(i)+'" >> '+outmorph
  masksz=size(thismask)
  wmask=where(thismask eq 1)
  
  chboxind = wmask
  ;#### Check if the blob inside box
  ;#### contains holes and fill them
  
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
;     spawn,'echo "'+'filenumber: '+string(fnumber)+' AR: '+string(i)+'" >> '+outlake2
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
 ;                       plot_image,new_mask[600:660,660:700]
 ;             spawn,'echo "'+'filenumber: '+string(fnumber)+' AR: '+string(i)+'" >> '+outlake7
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
  cc_len=n_elements(chbnd_chain)
  chaincode=string(chbnd_chain,format='('+strtrim(n_elements(chbnd_chain),2)+'I1)') 
  
 return,chaincode
end
;---------------------------------------------------------------------->
                