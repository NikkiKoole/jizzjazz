
function pointInRect(x,y, rx, ry, rw, rh)
   if x < rx or y < ry then return false end
   if x > rx+rw or y > ry+rh then return false end
   return true
end
function distance(x, y, x1, y1)
   local dx = x - x1
   local dy = y - y1
   local dist = math.sqrt(dx * dx + dy * dy)
   return dist
end

function pointInCircle(x,y, cx, cy, radius)

   if distance(x,y,cx,cy) < radius then
      return true
   else
      return false
   end
end


function getMouseWheelableArea(id, x,y, w, h)
   local mx, my = love.mouse:getPosition()
end


function getUIRect(id, x,y,w,h)
  local result = false
  if mouseState.click then
     local mx, my = love.mouse.getPosition( )
     if pointInRect(mx,my,x,y,w,h) then


        result = true
     end
   end
  
   return {
      clicked=result
   }
end


function charButton(id , char, x, y, w, h)
   --local buttonWidth = 90
   --local cellHeight = 32
   local result = false
   love.graphics.setColor(0,0,0)
   love.graphics.rectangle('fill',x,y,w,h)
   love.graphics.setColor(1,1,1)

   love.graphics.print(char, x, y)
  

   if mouseState.click then
      local mx, my = love.mouse.getPosition( )
      if pointInRect(mx,my,x,y,w,h) then
         result = true
      end
   end

   return {
      clicked=result
   }
end


function imgbutton(id, img, x, y, w, h, color)
   scale = scale or 1
   color = color or {1,1,1,1}
   local mx, my = love.mouse:getPosition()

   
   local imgW, imgH = img:getDimensions()
   local imgScaleX = w/imgW
   local imgScaleY = h/imgH

   local clicked = false

   love.graphics.setColor(0,0,0,color[4] or .75)
   love.graphics.rectangle("fill", x, y, w, h)
  

   if (pointInRect(mx, my, x,y,w, h ) )then
      mouseState.hoveredSomething = true
   --    love.graphics.setColor(1,1,1,.5)
   --    love.mouse.setCursor(cursors.hand)
       if (mouseState.click) then
          clicked = true
       end
   -- else
   --    love.graphics.setColor(1,1,1, .3)
   end
 

   love.graphics.setColor(color[1], color[2], color[3], color[4])
   love.graphics.draw(img, x, y, 0, imgScaleX, imgScaleY)

   return {
      clicked = clicked
   }
end

function draw_button(x,y,p, run)
   local result= false
   if not p then
      love.graphics.rectangle('fill',x,y,cellWidth,cellHeight )
   else
      love.graphics.rectangle('line',x,y,cellWidth,cellHeight )

   end

 
   if run then
      local mx, my = love.mouse.getPosition( )
      if pointInRect(mx,my, x,y,cellWidth,cellHeight) then
         result = true
      end
   end

   return {
      clicked=result
   }
end
function draw_label_button(x,y, label, p)
   --local buttonWidth = 90
   --local cellHeight = 32
   local result= false
   local w = font:getWidth( label )
   local h = font:getHeight( label )

   love.graphics.setColor(0,0,0)
   love.graphics.rectangle('fill',x-5,y-2,w+10,h+4)
   
   love.graphics.setColor(red[1], red[2], red[3])
   love.graphics.rectangle('line',x-5,y-2,w+10,h+4)
   love.graphics.setColor(1,1,1)
   love.graphics.print(label, x, y)

   if mouseState.click then
      local mx, my = love.mouse.getPosition( )
      if pointInRect(mx,my, x,y,w,h) then
         result = true
      end
   end

   return {
      clicked=result
   }
end


function angle(x1,y1, x2, y2)
   local dx = x2 - x1
   local dy = y2 - y1
   return math.atan2(dx,dy)
end
function angleAtDistance(x,y,angle, distance)
   local px = math.cos( angle ) * distance
   local py = math.sin( angle ) * distance
   return px, py
end
function lerp(a, b, t)
   return a + (b - a) * t
end


function mapInto(x, in_min, in_max, out_min, out_max)
   return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end


-- function draw_horizontal_slider(id, x, y, width, v, min, max, mouseClicked)
--    love.graphics.setColor(0.3, 0.3, 0.3)
--    love.graphics.rectangle('fill',x,y+8,width,3 )
--    love.graphics.setColor(0, 0, 0)
--    local xOffset = mapInto(v, min, max, 0, width)
--    love.graphics.rectangle('fill',xOffset + x,y,20,20 )

--    local result= nil
--    local draggedResult = false

--    if mouseClicked then
--       local mx, my = love.mouse.getPosition( )
--       if pointInRect(mx,my, xOffset+x,y,20,20) then
--          lastDraggedElement = {id=id}
--       end
--    end
--    if love.mouse.isDown(1 ) then
--       if lastDraggedElement and lastDraggedElement.id == id then
--          local mx, my = love.mouse.getPosition( )
--          result = mapInto(mx, x, x+width, min, max)
--          result = math.max(result, min)
--          result = math.min(result, max)
--       end
--    end
--    return {
--       value=result
--    }
-- end

function handleMouseClickStart()
   mouseState.hoveredSomething = false
   mouseState.down = love.mouse.isDown(1 )
   mouseState.click = false
   mouseState.released = false
   if mouseState.down ~= mouseState.lastDown then
      if mouseState.down  then
         mouseState.click  = true
      else
	 mouseState.released = true
      end
   end
   mouseState.lastDown =  mouseState.down
end



function drawToggle(id, x,y, state)

   if state then
      love.graphics.rectangle("fill", x,y,24,24)
   else
      
      love.graphics.rectangle("line", x,y,24,24)
   end
   local mx, my = love.mouse.getPosition( )

   if mouseState.click then
      if pointInRect(mx,my, x,y,20,20) then
         return {value= not state}
      end
   end
   
   return {value=nil}

end


function pianoRollNote(id,x,y,width,height, original)
    local mx, my = love.mouse.getPosition()
   love.graphics.setColor(1,1,1)
   love.graphics.rectangle("fill", x,y,width,height)
   love.graphics.setColor(0,0,0)
   local hover = false
   if pointInRect(mx,my,x,y,width,height) then
      hover = true
      love.graphics.setColor(0,1,0)
      lastDraggedElement = {id=id, type='pianorollnote', original=original}
      mouseState.hoveredSomething = true

   end

   local drag = false
   if love.mouse.isDown(1 ) then
      if lastDraggedElement and lastDraggedElement.id == id then
         drag = true
      end
   end
   
         
   love.graphics.rectangle("fill", x+3,y+3,width-6,height-6)

   return {
      click=hover and mouseState.click,
      drag = drag
   }
end

function scrollbarV(id, x,y, height, contentHeight, scrollOffset)
   

   -- the thumb
   local scrollBarThumbH = height
   if contentHeight > height then
      scrollBarThumbH = (height / contentHeight) * height
   end

   local pxScrollOffset = mapInto(scrollOffset, 0, contentHeight-height, 0, height-scrollBarThumbH)

   local result= nil
   local draggedResult = false
   local mx, my = love.mouse.getPosition( )
   local hover = false
   if pointInRect(mx, my, x, y+pxScrollOffset,32,scrollBarThumbH) then
       hover = true
   end
   
   local alpha =  (lastDraggedElement and lastDraggedElement.id == id or hover ) and 0.8 or 0.5 
   love.graphics.setColor(0,0,0,alpha)
   love.graphics.setLineWidth(2)
   love.graphics.rectangle("line",x, y, 32, height)
   love.graphics.rectangle("fill", x, y+pxScrollOffset, 32, scrollBarThumbH)
   
   

   if hover then
      mouseState.hoveredSomething = true
      love.mouse.setCursor(cursors.hand)
      if mouseState.click then
         lastDraggedElement = {id=id}
	 mouseState.hoveredSomething = true
	 mouseState.offset = {x=x - mx, y=(pxScrollOffset+y)-my}
      end
   end

    if love.mouse.isDown(1 ) then
      if lastDraggedElement and lastDraggedElement.id == id then
	 mouseState.hoveredSomething = true
	 love.mouse.setCursor(cursors.hand)

         local mx, my = love.mouse.getPosition( )
         result = mapInto(my + mouseState.offset.y,
                          y, y+height-scrollBarThumbH,
                          0, height-scrollBarThumbH)
	 if result < 0 then
	     result = 0
	 end
         if result > height-scrollBarThumbH then
            result = height-scrollBarThumbH
         end

         result = mapInto(result, 0, height-scrollBarThumbH, 0, contentHeight-height )
      end

      
    end

   
    
 return {
      value=result
   }


   
end


function v_slider(id, x, y, height, v, min, max)
   love.graphics.setColor(0.3, 0.3, 0.3)
   love.graphics.rectangle('fill',x+8,y,3,height )
   love.graphics.setColor(0, 0, 0)
   local yOffset = mapInto(v, min, max, 0, height-20)
   love.graphics.rectangle('fill',x, yOffset + y,20,20 )
   love.graphics.setColor(1,1,1,1)
   love.graphics.rectangle("line", x,yOffset + y,20,20)

   local result= nil
   local draggedResult = false
   local mx, my = love.mouse.getPosition( )
   local hover = false
   if pointInRect(mx,my, x, (yOffset +y),20,20) then
      hover = true
   end

   if hover then
      mouseState.hoveredSomething = true
      love.mouse.setCursor(cursors.hand)
      if mouseState.click then
         lastDraggedElement = {id=id}
	 mouseState.hoveredSomething = true
	 mouseState.offset = {x=x - mx, y=(yOffset+y)-my}
      end
   end

   if love.mouse.isDown(1 ) then
      if lastDraggedElement and lastDraggedElement.id == id then
	 mouseState.hoveredSomething = true
	 love.mouse.setCursor(cursors.hand)

         local mx, my = love.mouse.getPosition( )
         result = mapInto(my + mouseState.offset.y, y, y+height-20, min, max)
	 if result < min then
	    result = min
	 else

         result = math.max(result, min)
         result = math.min(result, max)
	 end

      end
   end
   return {
      value=result
   }
end

function h_slider(id, x, y, width, v, min, max)
   love.graphics.setColor(0.3, 0.3, 0.3)
   love.graphics.rectangle('fill',x,y+8,width,3 )
   love.graphics.setColor(0, 0, 0)
   local xOffset = mapInto(v, min, max, 0, width-20)
   love.graphics.rectangle('fill',xOffset + x,y,20,20 )
   love.graphics.setColor(1,1,1,1)
   love.graphics.rectangle("line", xOffset + x,y,20,20)

   local result= nil
   local draggedResult = false
   local mx, my = love.mouse.getPosition( )
   local hover = false
   if pointInRect(mx,my, xOffset+x,y,20,20) then
      hover = true
   end

   if hover then
      mouseState.hoveredSomething = true
      love.mouse.setCursor(cursors.hand)
      if mouseState.click then
         lastDraggedElement = {id=id}
	 mouseState.hoveredSomething = true

	 mouseState.offset = {x=(xOffset+x) - mx, y=my-y}

      end
   end

   if love.mouse.isDown(1 ) then
      if lastDraggedElement and lastDraggedElement.id == id then
	 mouseState.hoveredSomething = true
	 love.mouse.setCursor(cursors.hand)
         local mx, my = love.mouse.getPosition( )
         result = mapInto(mx + mouseState.offset.x, x, x+width-20, min, max)
	 if result < min then
	    result = nil
	 else

         result = math.max(result, min)
         result = math.min(result, max)
	 end

      end
   end
   return {
      value=  result
   }
end



function draw_vertical_slider(id, x, y, height, v, min, max, mouseClicked)
   love.graphics.rectangle('fill',x+8,y,3,height )
   local yOffset = mapInto(v, min, max, 0, height)
   love.graphics.rectangle('fill',x,y +height - yOffset - 10,20,20 )

   local result= nil
   local draggedResult = false

   -- if mouseClicked then
   --    local mx, my = love.mouse.getPosition( )
   --    if pointInRect(mx,my, x,y+height-yOffset,20,20) then
   --       lastDraggedElement = {id=id}
   --    end
   -- end

   if love.mouse.isDown(1 ) then
      local mx, my = love.mouse.getPosition( )
      if (lastDraggedElement and lastDraggedElement.id == id) or
      (mx <= x+20 and mx >x) then

         result = mapInto(my, y+height+10, y, min, max)
         result = math.max(result, min)
         result = math.min(result, max)

      end
   end
   return {
      value=result
   }
end

function draw_knob(id, x,y, v, min, max)
   local cellHeight = 32
   local result = nil
   local r,g,b,a = love.graphics.getColor()
   love.graphics.setColor(0, 0, 0)
   love.graphics.circle("fill", x, y, cellHeight/2, 100) -- Draw white circle with 100 segments.

   love.graphics.setColor(1, 1, 1)
   local mx, my = love.mouse.getPosition( )

   a = -math.pi/2
   ax, ay = angleAtDistance(x,y,-a, cellHeight/2)
   bx, by = angleAtDistance(x,y,-a, cellHeight/4)
   love.graphics.setColor(1, 1, 1, 0.5)
   love.graphics.line(x+ax,y+ay,x+bx,y+by)
   love.graphics.setColor(1, 1, 1, 1)

   a = mapInto(v, min, max, 0 + math.pi/2, math.pi*2 + math.pi/2)
   ax, ay = angleAtDistance(x,y,a, cellHeight/2)
   bx, by = angleAtDistance(x,y,a, cellHeight/4)
   love.graphics.setColor(1, 1, 1)
   love.graphics.line(x+ax,y+ay,x+bx,y+by)
   love.graphics.setColor(r,g,b,a)
   if mouseState.click then
      local mx, my = love.mouse.getPosition( )
      -- click to start dragging
      if pointInCircle(mx,my, x,y,cellHeight/2) then
         lastDraggedElement = {id=id, lastAngle=angle(mx, my, x, y), rolling=0}
      end
   end

   if love.mouse.isDown(1 ) then
      if lastDraggedElement and lastDraggedElement.id == id then
         local mx, my = love.mouse.getPosition( )
         local a = angle(mx, my, x, y)

         result = mapInto(a, math.pi, -math.pi, min, max)

         local diff = (lastDraggedElement.lastAngle -  a)

         if math.abs(diff) > math.pi or diff == 0 then
            if v > result then
               result = max 
            elseif v < result then
               result = min
            end
         else
            lastDraggedElement.lastAngle = a;
         end

         -- so it doesnt send similar data twice!
         if a ~= lastDraggedElement.rolling then
            lastDraggedElement.rolling = a
         else
            result = nil
         end
         
         love.graphics.line(mx,my,x,y)

      end
   end
  
   return {
      value=result
   }
end
