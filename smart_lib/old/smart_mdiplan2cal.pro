;Do a fudge (linear calibration) for mdi planning data to get something like calibrated data.

pro smart_mdiplan2cal, planin, calout

plan=planin
if (where(finite(plan) ne 1))[0] ne -1 then plan[where(finite(plan) ne 1)]=0.

;Using a comparison of 20080518_1026 planning and 1.8 calibrated data:

bm=[3.23658,4.60567]
cal=plan*bm[1]+bm[0]

calout=cal






end