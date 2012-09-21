function bradford_smid2num, inarstruct

arstruct=inarstruct
smidarr=arstruct.smid

numidarr=strmid(smidarr,0,8)+strmid(smidarr,9,4)+strmid(smidarr,17,2)

arstruct.smid=numidarr

outarstruct=arstruct
return, outarstruct

end