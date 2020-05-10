local inspect = require "inspect"


function love.keypressed(key)
   if key == 'escape' then
      love.event.quit()
   end
   
end
function mysplit (inputstr, sep)
   if sep == nil then
      sep = "%s"
   end
   local t={}
   for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
   end
   return t
end
function love.wheelmoved(a,b)
   local x, y = love.mouse.getPosition( )
   local scaleOld = scale
   local pulseAtMouse =  math.ceil((x - xOff) / (scale))
   
   if b < 0 then
      scaleIndex = scaleIndex -1
   else
      scaleIndex = scaleIndex + 1
   end
   --print(scaleIndex)
   scaleIndex = math.max(1, scaleIndex)
   scaleIndex = math.min(scaleIndex, #niceScales)
   scale = niceScales[scaleIndex]

   local pulseAtMouseLater =  math.ceil((x-xOff) / (scale))
   local d =  pulseAtMouseLater- pulseAtMouse
   xOff = xOff + (d*scale)
end

function love.mousepressed(x,y)
   if x>xOff and x < pulses*scale+xOff then
      if y>0 and y < 150 then
         
         dragging = true
      end
   end

end
function love.mousereleased()
   dragging = false

end
function love.mousemoved(x,y,dx,dy)
   if dragging then
      xOff = xOff + dx
   end
end


function love.load()
   love.window.setMode(1800, 800)

   dragging = false
   
   pulses_per_quarter_note = 96
   niceScales = { 0.0625, 0.125, 0.25, 0.5, 1.0, 2.0, 4.0, 8.0, 16, 32}
   scaleIndex = 1
   scale = niceScales[scaleIndex]

   bars = 8
   beatsInBar = 4
   pulses =  (pulses_per_quarter_note * 4) * beatsInBar * bars
   --print(pulses)
   dict = {}
   for i=1, pulses do
      dict[i] = nil
      if (i % (96) == 1) then
         --print(i)
         dict[i] = {length=math.floor(10)}
      end
      if (i % (96*4) == 1) then
         --print(i)
         dict[i] = {length=math.floor(20)}
      end
   end

   xOff = 0
   --visibleEndPulse = pulses
   
end

function mapInto(x, in_min, in_max, out_min, out_max)
   return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end


function love.draw()
   love.graphics.clear(0.93, 0.89, 0.74)
   love.graphics.setColor(0.7, 0.45, 0.4)
   local m = scale

   -- the grid
   -- the pulses in the grid
  local a =  mapInto(m,  0.0625, 32, 0, .9)
  --love.graphics.setColor(0.60, 0.60, 0.6, a)
  if a>0.05 then
   love.graphics.setColor(0, 0, 0, a)
   for i=1, pulses do
      love.graphics.line(xOff + i*m,0,xOff + i*m, 100)
   end
   end
   
   for i=1, pulses do
      if  (i % (96*4 * beatsInBar) == 0) then   -- bar!
         love.graphics.setColor(0.1, 0.1, 0.1)
         love.graphics.line(xOff + i*m,0,xOff + i*m, 120)
      elseif  (i % (96*4) == 0) then           -- beat !
         love.graphics.setColor(0.52, 0, 0.03)
         love.graphics.line(xOff + i*m,0,xOff + i*m, 105)
      end
   end
   
   -- the notes
   
   for i=1, pulses do
      if dict[i] then
         love.graphics.setColor(.90, .7, .6,0.6)
         love.graphics.rectangle("fill", xOff + (i-1) * m , 0, m * dict[i].length, 100)
         love.graphics.setColor(.20, .2, .2)
         love.graphics.rectangle("line", xOff + (i-1) * m , 0, m * dict[i].length, 100)
      end
   end
   

   love.graphics.setColor(0, 0, 0)
   love.graphics.print(tostring(love.timer.getFPS( )), 11, 11)
   love.graphics.setColor(0.7, 1, 1)
   love.graphics.print(tostring(love.timer.getFPS( )), 10, 10)
end
