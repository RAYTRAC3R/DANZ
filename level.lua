love.draw = function()
  local rectangle = {100, 450, 100, 550, 500, 550, 500, 450}
  love.graphics.polygon('line', rectangle)
  return
end