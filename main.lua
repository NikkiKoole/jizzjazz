local inspect = require "inspect"


function love.keypressed(key)
   if key == 'escape' then
      love.event.quit()
   end
   
end
function love.wheelmoved(a,b)
   local x, y = love.mouse.getPosition( )
   --print(x,y)

   -- ok what pulse am i over

   --local m =((pulses_per_quarter_note*scale)/((pulses_per_quarter_note)*4))
   local pulseIndex = math.ceil(x / (scale/4))
   
   if b < 0 then
      scaleIndex = scaleIndex -1
   else
      scaleIndex = scaleIndex + 1
   end
   --print(scaleIndex)
   scaleIndex = math.max(1, scaleIndex)
   scaleIndex = math.min(scaleIndex, #niceScales)
   scale = niceScales[scaleIndex]

   local pulseIndexAfer = math.ceil(x / (scale/4))
   --print(pulseIndex, pulseIndexAfer)
   
end

function love.load()
   love.window.setMode(1800, 800)
   pulses_per_quarter_note = 96
   niceScales = { 1.0, 2.0, 4.0, 8.0, 16, 32}
   scaleIndex = 1
   scale = niceScales[scaleIndex]

   drawn = {{length=10, expr="1.1.5"}, {length=3, expr="1.2.70"}}

   local arr = {[1]="1",[100]="100",[3]="3",[33]="33",[1111]="1111"}

   for k,v in pairs(arr) do
      print(k,v)
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

function love.draw()
   love.graphics.clear(0.9, 0.9, 0.9)
   

   local w = love.graphics.getWidth()
  
   
   love.graphics.setColor(1, 0.8, 0.8)
   if scale > 4 then
      love.graphics.setColor(0.8, 0.8, 0.8)

   end
   
   local m =((pulses_per_quarter_note*scale)/((pulses_per_quarter_note)*4))
  
   for i=1, w / m do
      love.graphics.line(i*m,0,i*m,100)
   end

   if (scale > 0.25) then
      love.graphics.setColor(0.7,0.7,0.7)
      m =((pulses_per_quarter_note*scale)/16)
      for i=1, w / m do
         love.graphics.line(i*m,0,i*m,100)
      end
   end
   
   if (scale > 0.125) then
      love.graphics.setColor(0.5,0.5,.5)
      m =((pulses_per_quarter_note*scale)/4)
      for i=1, w / m do
         love.graphics.line(i*m,0,i*m,100)  --1/16
      end
   end

   love.graphics.setColor(0,0,0)
   m =((pulses_per_quarter_note*scale)/1)  -- 1/4
   for i=1, w / m do
      love.graphics.line(i*m,0,i*m,120)
   end
   
   love.graphics.setColor(1,0,0, 0.25)
   for i = 1, #drawn do
      local split = mysplit(drawn[i].expr, '.')
      
      local xQuarter = (split[2]-1 ) * (pulses_per_quarter_note * scale)
      local xBar = (split[1]-1 ) * (pulses_per_quarter_note  * 4 * scale)
      local xPulse = (split[3]-1 ) * (pulses_per_quarter_note  * (1.0/96)/4 * scale)
      
      love.graphics.rectangle("fill", xBar + xQuarter + xPulse, 0, (drawn[i].length /4) * scale,100)
    --  print(inspect(drawn[i]), inspect(split))
   end
   
   
end
