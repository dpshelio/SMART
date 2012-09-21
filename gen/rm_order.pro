function rm_order,file=file,grid=grid
  rm_grid='lcg-del --vo vo.helio-vo.eu -a lfn:'+file
  rm_local='rm -f '+file
  rm_command=(keyword_set(grid))?rm_grid:rm_local
  return,rm_command
end
