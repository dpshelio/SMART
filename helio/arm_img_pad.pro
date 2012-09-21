;Written 20-may-2009 - P.A.Higgins
;Pad the image for displaying on SolarMoitor.

function arm_img_pad, map
	
	map0=map
    data=map0.data
    value=data[0,0]
    imgsz=size(data)
    xbuff=fltarr(150,imgsz[2])+value
    data=[data,xbuff]
    data=[xbuff,data]
    ybuff=fltarr(imgsz[1]+150+150,150)+value
    data=[[data],[ybuff]]
    data=[[ybuff],[data]]
    add_prop, map0, data = data, /replace

return,map0

end
