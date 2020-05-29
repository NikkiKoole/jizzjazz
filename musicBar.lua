-- MUSICBAR uses scale, xOff, dict, dragging

function createMusicBar()
   
   local pulses_per_quarter_note = 96
   local beatsInBar = 4       --  4/x
   local quarters_in_beat = 4 --  x/4  -- this doesnt work as expected . when you put in 3 it works but when you put 8 it doenmx   ,st
   local bars = 4
   
   
   local pulses =  (pulses_per_quarter_note * quarters_in_beat) * beatsInBar * bars

   
   local dict = {}
   for i=1, pulses do
      dict[i] = nil
      if (i % (pulses_per_quarter_note) == 1) then
         dict[i] = {length=math.floor(pulses_per_quarter_note)}
      end
      if (i % (pulses_per_quarter_note*beatsInBar) == 1) then
         dict[i] = {length=math.floor(20)}
      end
   end

   local niceScales = {0.03125, 0.0625, 0.125, 0.25, 0.5, 1.0, 2.0, 4.0, 8.0, 16, 32}
   local scaleIndex = math.floor(#niceScales/2)
   --local scaleIndex = math.floor(#niceScales/2)
   --local scale = niceScales[scaleIndex]

   --local xOff = 0

   
   
   return {
      pulses_per_quarter_note = pulses_per_quarter_note,
      beatsInBar = beatsInBar,       --  4/x
      quarters_in_beat =  quarters_in_beat, --  x/4  -- this doesnt work as expected . when you put in 3 it works but when you put 8 it doenmx   ,st
      bars = bars,
      xOff = 0,
      pulses=pulses,
      niceScales = niceScales,
      scaleIndex = scaleIndex,
      scale=niceScales[scaleIndex],
      dict=dict
   }
end


function getDictIndexAt(bar, x,y)
   --print(bar.pulses, bar.scale, bar.xOff, x, y)
   if x>bar.xOff and x < bar.pulses*bar.scale+bar.xOff then
      if y>0 and y < 150 then

         local index = math.ceil((x-bar.xOff)/bar.scale)
         local hitIndex = 0
         local hit = false
         
         for i=1, bar.pulses do
            if (bar.dict[i]) then
               if index >= i and index < i+bar.dict[i].length then
                  return i 
               end
            end
         end
      end
   end
   return -1
end

function handleMusicBarWheelMoved(bar, a,b)
   local x, y = love.mouse.getPosition( )

   local pulseAtMouse =  math.ceil((x - bar.xOff) / (bar.scale))
   
   if b < 0 then
      bar.scaleIndex = bar.scaleIndex -1
   else
      bar.scaleIndex = bar.scaleIndex + 1
   end

   bar.scaleIndex = math.max(1, bar.scaleIndex)
   bar.scaleIndex = math.min(bar.scaleIndex, #bar.niceScales)
   bar.scale = bar.niceScales[bar.scaleIndex]

   local pulseAtMouseLater =  math.ceil((x-bar.xOff) / (bar.scale))
   local d =  pulseAtMouseLater- pulseAtMouse
   bar.xOff = bar.xOff + (d*bar.scale)
end


function posIsOverNoteEnding(bar, x,y)
   local hitIndex = getDictIndexAt(bar, x,y)
   local realIndex = (math.ceil((x-bar.xOff)/bar.scale)) - hitIndex + 1
   local moveEnd = false
   if hitIndex > 0 then
      local d = bar.dict[hitIndex]
      if realIndex == d.length then
         return true
      end
   end
   return false
end


function handleMusicBarMouseMoved(bar,x,y,dx,dy)
    if dragging == 'all' then
      bar.xOff = bar.xOff + dx
   elseif dragging ~= false then
      if dragging.moveEnd or dragging.moveStart  then
         dragging.widthOffset = dragging.widthOffset + dx/bar.scale
         
      elseif dragging.moveWhole then
         dragging.pulseOffset = dragging.pulseOffset + dx/bar.scale
         
      end
      
   else
      
      -- not dragging but moving over
      --print(#bar.dict)
      local hitIndex = getDictIndexAt(bar, x,y)
      local moveEnd = posIsOverNoteEnding(bar, x,y)
      local pulseAtMouse =  math.ceil((x - bar.xOff) / (bar.scale))
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

function handleMusicBarMouseReleased(bar, x,y)
   local pulses_per_quarter_note = bar.pulses_per_quarter_note

   
    if dragging and dragging.moveWhole then
      bar.dict[dragging.wasAt] = nil

      local newIndex = dragging.wasAt + math.floor(dragging.pulseOffset)
      local quantize = pulses_per_quarter_note/pulses_per_quarter_note
      
      newIndex = (round(newIndex / quantize) * quantize)
      
      if quantize ~= 1 then
         newIndex = newIndex + 1
      end

      bar.dict[newIndex] = dragging.note
   end
   if dragging and dragging.moveEnd   then
      if bar.dict[dragging.wasAt] then
         local l = bar.dict[dragging.wasAt].length  + math.floor(dragging.widthOffset)
         if l > 0 then
            bar.dict[dragging.wasAt].length = l
         else
            bar.dict[dragging.wasAt] = nil
            bar.dict[dragging.wasAt + l] = dragging.note
            bar.dict[dragging.wasAt + l].length = math.abs(l)
         end
      end
   end
   if dragging and dragging.moveStart   then
      bar.dict[dragging.wasAt] = nil
      
      local l =  dragging.note.length -  math.floor(dragging.widthOffset)
      if l > 0 then
         local newIndex = dragging.wasAt + (math.floor(dragging.widthOffset))
         bar.dict[newIndex] = dragging.note
         bar.dict[newIndex].length = l
      else
         local newerIndex = dragging.wasAt + dragging.note.length
         bar.dict[newerIndex] = dragging.note
         local newLength = math.floor(dragging.widthOffset) -  dragging.note.length
         bar.dict[newerIndex].length = newLength
      end
   end
   
end


function handleMusicBarClicked(bar, x,y)
   local hitIndex = getDictIndexAt(bar, x,y)
   if hitIndex > -1 then
      love.mouse.setCursor(cursors.hand)
      local moveEnd =  posIsOverNoteEnding(bar, x,y)
      
      local pulseAtMouse =  math.ceil((x - bar.xOff) / (bar.scale))
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
                  note=bar.dict[hitIndex],
                  moveWhole= not moveEnd and not moveStart,
                  moveStart=moveStart,
                  moveEnd=moveEnd}
   else
      love.mouse.setCursor(cursors.arrow)
      if y < 100 then
         dragging = 'all'
      end
      
   end

end



function renderMusicBar(bar)
   local m = bar.scale
   local xOff = bar.xOff
   local dict = bar.dict  -- it doesnt write so its fine
   local pulses = bar.pulses
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
      if  (i % (bar.pulses_per_quarter_note *
                   bar.quarters_in_beat *
                bar.beatsInBar) == 0 or i==1) then   -- bar!
         love.graphics.setLineWidth(3)
         love.graphics.setColor(0.1, 0.1, 0.1)
         love.graphics.line(xOff + i*m,0,xOff + i*m, 120)
         love.graphics.setLineWidth(1)

      elseif  (i % (bar.pulses_per_quarter_note * bar.quarters_in_beat) == 0) then           -- beat !
         love.graphics.setColor(red[1], red[2], red[3])
         love.graphics.line(xOff + i*m,0,xOff + i*m, 110)
      end

      if a > 0.05 then
         if  (i % (bar.pulses_per_quarter_note/4) == 0) then           -- 16th !
            love.graphics.setColor(red[1],red[2],red[3], a)
            love.graphics.line(xOff + i*m,0,xOff + i*m, 100)
         end
      end
      
   end

   
   local fill = {.90, .7, .6}
   local line = {.32, 0.5, 0.5 }
   
   for i=1, pulses do
      if bar.dict[i] then
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
end
