local inspect = require "inspect"
local thread -- Our thread object.
--luamidi = require "luamidi"
-- upright bass in emu hiphop

function love.keypressed(key)
   if key == 'escape' then
      channel.main2audio:push ( "quit" );
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

   scaleIndex = math.max(1, scaleIndex)
   scaleIndex = math.min(scaleIndex, #niceScales)
   scale = niceScales[scaleIndex]

   local pulseAtMouseLater =  math.ceil((x-xOff) / (scale))
   local d =  pulseAtMouseLater- pulseAtMouse
   xOff = xOff + (d*scale)
end



function getDictIndexAt(x,y)
   if x>xOff and x < pulses*scale+xOff then
      if y>0 and y < 150 then

         local index = math.ceil((x-xOff)/scale)
         local hitIndex = 0
         local hit = false
         
         for i=1, pulses do
            if (dict[i]) then
               if index >= i and index < i+dict[i].length then
                  return i 
               end
            end
         end
      end
   end
   return -1
end

function love.update(dt)
    local error = thread:getError()
    assert( not error, error )
    local v = channel.audio2main:pop ();
    if v then
       if v == 'quit' then
          love.event.quit()
       end
    end
end



function love.mousepressed(x,y)

   local hitIndex = getDictIndexAt(x,y)
   if hitIndex > -1 then
      love.mouse.setCursor(cursors.hand)
      local moveEnd =  posIsOverNoteEnding(x,y)
      
      local pulseAtMouse =  math.ceil((x - xOff) / (scale))
      local moveStart = pulseAtMouse == hitIndex
      if moveEnd or moveStart then
         love.mouse.setCursor(cursors.sizewe)
      end
      if moveStart and moveEnd then
         moveStart = false
      end
      
      dragging = {wasAt=hitIndex,
                  pulseOffset=0,
                  widthOffset=0,
                  note=dict[hitIndex],
                  moveWhole= not moveEnd and not moveStart,
                  moveStart=moveStart,
                  moveEnd=moveEnd}
   else
      love.mouse.setCursor(cursors.arrow)
      dragging = 'all'
   end
end

function round(num, numDecimalPlaces)
   local mult = 10^(numDecimalPlaces or 0)
   return math.floor(num * mult + 0.5) / mult
end

function love.mousereleased()

   if dragging and dragging.moveWhole then
      dict[dragging.wasAt] = nil

      local newIndex = dragging.wasAt + math.floor(dragging.pulseOffset)
      local quantize = pulses_per_quarter_note/pulses_per_quarter_note
      
      newIndex = (round(newIndex / quantize) * quantize)
      
      if quantize ~= 1 then
         newIndex = newIndex + 1
      end

      dict[newIndex] = dragging.note
   end
   if dragging and dragging.moveEnd   then
      if dict[dragging.wasAt] then
         local l = dict[dragging.wasAt].length  + math.floor(dragging.widthOffset)
         if l > 0 then
            dict[dragging.wasAt].length = l
         else
            dict[dragging.wasAt] = nil
            dict[dragging.wasAt + l] = dragging.note
            dict[dragging.wasAt + l].length = math.abs(l)
         end
      end
   end
   if dragging and dragging.moveStart   then
      dict[dragging.wasAt] = nil
      
      local l =  dragging.note.length -  math.floor(dragging.widthOffset)
      if l > 0 then
         local newIndex = dragging.wasAt + (math.floor(dragging.widthOffset))
         dict[newIndex] = dragging.note
         dict[newIndex].length = l
      else
         local newerIndex = dragging.wasAt + dragging.note.length
         dict[newerIndex] =  dragging.note
         local newLength = math.floor(dragging.widthOffset) -  dragging.note.length
         dict[newerIndex].length = newLength
      end
   end
   
   
   dragging = false
   love.mouse.setCursor(cursors.arrow)

end

function posIsOverNoteEnding(x,y)
   local hitIndex = getDictIndexAt(x,y)
   local realIndex = (math.ceil((x-xOff)/scale)) - hitIndex + 1
   local moveEnd = false
   if hitIndex > 0 then
      local d = dict[hitIndex]
      if realIndex == d.length then
         return true
      end
   end
   return false
end


function love.mousemoved(x,y,dx,dy)
   if dragging == 'all' then
      xOff = xOff + dx
   elseif dragging ~= false then
      if dragging.moveEnd or dragging.moveStart  then
         dragging.widthOffset = dragging.widthOffset + dx/scale
         
      elseif dragging.moveWhole then
         dragging.pulseOffset = dragging.pulseOffset + dx/scale
         
      end
      
   else

      -- not dragging but moving over
      local hitIndex = getDictIndexAt(x,y)
      local moveEnd = posIsOverNoteEnding(x,y)
      local pulseAtMouse =  math.ceil((x - xOff) / (scale))
      local moveStart = pulseAtMouse ==  hitIndex
      if hitIndex > 0  then
         love.mouse.setCursor(cursors.hand)
      else
         love.mouse.setCursor(cursors.arrow)
      end
      if moveEnd or moveStart then
         love.mouse.setCursor(cursors.sizewe)
      end
   end
   
end

function recursiveEnumerate(folder, fileTree)
   local lfs = love.filesystem
   local filesTable = lfs.getDirectoryItems(folder)
   for i,v in ipairs(filesTable) do
      local file = folder.."/"..v
      if lfs.isFile(file) then
         fileTree = fileTree.."\n"..file
      elseif lfs.isDirectory(file) then
         fileTree = fileTree.."\n"..file.." (DIR)"
         fileTree = recursiveEnumerate(file, fileTree)
      end
   end
   return fileTree
end
 

function love.load()
   thread = love.thread.newThread( 'thread.lua' )
   thread:start( )
   channel		= {};
   channel.audio2main	= love.thread.getChannel ( "audio2main" ); -- from thread
   channel.main2audio	= love.thread.getChannel ( "main2audio" ); -- from main
   
   
   love.window.setMode(1800, 800)
   cursors = {hand=love.mouse.getSystemCursor("hand"),
              arrow=love.mouse.getSystemCursor("arrow"),
              sizewe = love.mouse.getSystemCursor("sizewe")}
   dragging = false
   font = love.graphics.newFont( "resources/fonts/WindsorBT-Roman.otf", 48)
   love.graphics.setFont(font)

   
   niceScales = {0.03125, 0.0625, 0.125, 0.25, 0.5, 1.0, 2.0, 4.0, 8.0, 16, 32}
   scaleIndex = math.floor(#niceScales/2)
   scale = niceScales[scaleIndex]

   pulses_per_quarter_note = 96
   beatsInBar = 4       --  4/x
   quarters_in_beat = 4 --  x/4  -- this doesnt work as expected . when you put in 3 it works but when you put 8 it doenst
   bars = 4
   
   
   pulses =  (pulses_per_quarter_note * quarters_in_beat) * beatsInBar * bars

   dict = {}
   -- for i=1, pulses do
   --    dict[i] = nil
   --    if (i % (pulses_per_quarter_note) == 1) then
   --       dict[i] = {length=math.floor(pulses_per_quarter_note)}
   --    end
   --    if (i % (pulses_per_quarter_note*beatsInBar) == 1) then
   --       dict[i] = {length=math.floor(20)}
   --    end
   -- end

   xOff = 0

  filesString = recursiveEnumerate("", "")
  print(filesString)

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
      love.graphics.setColor(0.4, 0.4, 0.4, a)
      for i=1, pulses do
         love.graphics.line(xOff + i*m,0,xOff + i*m, 100)
      end
   end


   -- 
   for i=1, pulses do
      if  (i % (pulses_per_quarter_note * quarters_in_beat * beatsInBar) == 0 or i==1) then   -- bar!
         love.graphics.setLineWidth(3)
         love.graphics.setColor(0.1, 0.1, 0.1)
         love.graphics.line(xOff + i*m,0,xOff + i*m, 120)
         love.graphics.setLineWidth(1)

      elseif  (i % (pulses_per_quarter_note * quarters_in_beat) == 0) then           -- beat !
         love.graphics.setColor(0.52, 0, 0.03)
         love.graphics.line(xOff + i*m,0,xOff + i*m, 110)
      end

      if a > 0.05 then
         if  (i % (pulses_per_quarter_note/4) == 0) then           -- 16th !
            love.graphics.setColor(0.52, 0, 0.03, a)
            love.graphics.line(xOff + i*m,0,xOff + i*m, 100)
         end
      end
      
   end
   
   -- the notes

   function drawRectangle(x,y,w,h, alpha, fill, out)
      love.graphics.setColor(fill[1], fill[2], fill[3], alpha)
      love.graphics.rectangle("fill", x , y, w, h)
      love.graphics.setColor(out[1], out[2], out[3], alpha)
      love.graphics.rectangle("line", x , y, w, h)
   end
   

   local fill = {.90, .7, .6}
   local line = {.32, 0.5, 0.5 }
   
   for i=1, pulses do
      if dict[i] then
         local alpha = 0.75
         if dragging and dragging.wasAt == i then
            alpha = 0.25
         end
         drawRectangle( xOff + (i-1) * m ,0, m * dict[i].length, 100, alpha, fill, line)
      end
   end

   if dragging and dragging.note then
      local dnl = dragging.note.length
      local wo = math.floor(dragging.widthOffset)
      local po =  math.floor(dragging.pulseOffset)
      local i = dragging.wasAt
      
      if dragging and dragging.moveWhole == true then
         drawRectangle(xOff + (i-1 + po) * m, 0, m * dnl, 100, .75, fill, line)
      end
      if dragging and dragging.moveEnd == true then
         drawRectangle(xOff + (i-1) * m , 0, m * (dnl + wo), 100, 0.75, fill, line )
      end
      if dragging and dragging.moveStart == true then
         drawRectangle(xOff + (i-1 +wo) * m  , 0, m * (dnl - wo), 100, 0.75, fill, line )
      end
   end

   love.graphics.setColor(0.2, 0.2, 0.2)
   love.graphics.print(tostring(love.timer.getFPS( )), 10, 10)
   love.graphics.setColor(1,1,1)
   love.graphics.print(tostring(love.timer.getFPS( )), 11, 11)
   love.graphics.setColor(0.2, 0.2, 0.2)
   love.graphics.print(tostring(love.timer.getFPS( )), 12, 12)
   love.graphics.print("C maj 7 dim", 12, 120)
end
