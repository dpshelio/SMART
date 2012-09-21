pro bradford_ar_ising

writepath='~/science/data/issi/bradford/'

datapath='/Volumes/LaCie/data/smart2/issi/'

restore,datapath+'smart_20030528_2222.sav',/ver
arid='03'

arcrop0=smart_crop_ar(mdimap.data, armask, arid, arstruct=arstruct, /zerother)

arcrop=smart_crop_ar(mdimap.data, armask, arid, arstruct=arstruct)

WRITE_GIF, writepath+'bradford_test_ising.gif', bytscl(arcrop)

WRITE_GIF, writepath+'bradford_test_ising_0.gif', bytscl(arcrop0)

map2index,mdimap,index
mdidata=mdimap.data

index.naxis1=(size(arcrop))[1]
index.naxis2=(size(arcrop))[2]
index.CRPIX1=(size(arcrop))[1]/2.
index.CRPIX2=(size(arcrop))[2]/2.

mwritefits, index, arcrop, $
	outfile=writepath+'bradford_test_ising.fits', /flat_fits

mwritefits, index, arcrop0, $
	outfile=writepath+'bradford_test_ising_0.fits', /flat_fits
	
stop











end