


function drawRectangle(x,y,w,h, alpha, fill, out)
   love.graphics.setColor(fill[1], fill[2], fill[3], alpha)
   love.graphics.rectangle("fill", x , y, w, h)
   love.graphics.setColor(out[1], out[2], out[3], alpha)
   love.graphics.rectangle("line", x , y, w, h)
end





function renderLabel(str, x,y)
   love.graphics.setColor(0,0,0)
   love.graphics.rectangle('fill', x-5, y-2, getStringWidth(str)+10, 20+4 )
   love.graphics.setColor(1,1,1)
   love.graphics.print(str, x, y)
end



function renderEQ(x, y)

     local runningY = y
     local knob
     renderLabel('Hz', x+110 - getStringWidth('Hz')/2 , y-50)
     renderLabel('Q', x+175  - getStringWidth('Q')/2, y-50)
     renderLabel('gain', x+240 -  getStringWidth('gain')/2 , y-50)
     renderLabel('wet', x+305 -  getStringWidth('wet')/2 , y-50)

     local labels = {'lowpass', 'highpass', 'bandpass','lowshelf', 'highshelf' }
     love.graphics.setLineWidth(3)
     for i =1, #labels do
        runningY = y+ (i-1)*50
        renderLabel(labels[i], x, runningY-10)
        local e = eq[labels[i]]
       
        if e.frequency then
           local max = 48000/2
           local min = 10

           if labels[i] == 'highpass' then
              max = 48000/4
           end
           if labels[i] == 'lowpass' then
              max = 48000/64
           end
           if labels[i] == 'bandpass' then
              max = 48000/64
           end
            if labels[i] == 'notch' then
              max = 48000/64
           end

           
           knob = draw_knob(labels[i]..'Hz', x+110, runningY,  eq[labels[i]].frequency, min, max)
           if knob.value ~= nil then
              eq[labels[i]].frequency = knob.value
              channel.main2audio:push ( {eq = eq} );
           end
        end
        if e.q then
           knob = draw_knob(labels[i]..'q', x+175, runningY,  eq[labels[i]].q, 1, 100)
           if knob.value ~= nil then
              eq[labels[i]].q = knob.value
              channel.main2audio:push ( {eq = eq} );
           end
        end
        if e.gain then
           knob = draw_knob(labels[i]..'gain', x+240, runningY,  eq[labels[i]].gain, -60, 60)
           if knob.value ~= nil then
              eq[labels[i]].gain = knob.value
              channel.main2audio:push ( {eq = eq} );
           end
        end
        if e.wet then
           knob = draw_knob(labels[i]..'wet', x+305, runningY,  eq[labels[i]].wet, 0, 1)
           if knob.value ~= nil then
              eq[labels[i]].wet = knob.value
              channel.main2audio:push ( {eq = eq} );
           end
        end
        
     end
     runningY = runningY + 50

     renderLabel('fade out', x, runningY-10)
     knob = h_slider('fade out', x + 100, runningY-10, 200, eq.fadeout, 0.0, activeSoundData:getDuration()-0.001 )
     if knob.value ~= nil then
        eq.fadeout = knob.value
        channel.main2audio:push ( {eq = eq} );
     end
     runningY = runningY + 50
     renderLabel('fade in', x, runningY-10)
     knob = h_slider('fade in', x + 100, runningY-10, 200, eq.fadein, 0.0, activeSoundData:getDuration()-0.001 )
     if knob.value ~= nil then
        eq.fadein = knob.value
        channel.main2audio:push ( {eq = eq} );
     end

     love.graphics.setLineWidth(1)

  end

function renderADSREnvelope(x, y, width, height)
     love.graphics.setLineWidth(3)
     love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
     love.graphics.rectangle("fill", x, y, width, height)


       -- render the envelope

     local sustainDuration = 1 -- this is the toggle for useSustain should be 0 otherwise
     local totalDuration = adsr.attack + adsr.decay + adsr.release + sustainDuration
     local attackWidth = (adsr.attack / totalDuration) * width
     local decayWidth = (adsr.decay / totalDuration) * width
     local releaseWidth = (adsr.release / totalDuration) * width
     local sustainWidth = (sustainDuration / totalDuration) * width
     

     love.graphics.setColor(red[1], red[2], red[3])
     love.graphics.line(x,y+height, x+attackWidth, y+height-((adsr.max)*height))
     love.graphics.line(x+attackWidth, y+height-((adsr.max)*height), x+attackWidth+decayWidth, y+height - ((adsr.sustain)*height))

     love.graphics.line(x+attackWidth+decayWidth, y+height - ((adsr.sustain)*height), x+attackWidth+decayWidth+sustainWidth, y+height - ((adsr.sustain)*height))

     love.graphics.line(x+attackWidth+decayWidth+sustainWidth, y+height - ((adsr.sustain)*height), x+width, y+height )
     
     x = x + 15

     renderLabel('max', x + 10 - getStringWidth('max')/2, y+height+10)
     local knob = v_slider('maxAmplitude', x, y+ height + 40, height, 1.00-adsr.max, 0, 1.00)
     if knob.value ~= nil then
        adsr.max = 1.00 - knob.value
        channel.main2audio:push ( {adsr = adsr} );
     end
     
     renderLabel('sus', x + 50 + 10 - getStringWidth('sus')/2, y+height+10)
     knob = v_slider('sustainAmplitude', x + 50 , y+ height + 40, height, 1.00 - adsr.sustain, 0, 1.00)
     if knob.value ~= nil then
        adsr.sustain = 1.00 - knob.value
        channel.main2audio:push ( {adsr = adsr} );

     end
     renderLabel('atk', x + 100 + 10 - getStringWidth('atk')/2, y+height+10)
      knob = draw_knob('attackDuration', x+100+10, y+height+40+20,  adsr.attack, 0.00001, 5)
     if knob.value ~= nil then
        adsr.attack = knob.value
        channel.main2audio:push ( {adsr = adsr} );

     end
     renderLabel('dec', x + 150 + 10 - getStringWidth('dec')/2, y+height+10)
     knob = draw_knob('decayDuration', x+150+10, y+height+40+20,  adsr.decay, 0, 5)
     if knob.value ~= nil then
        adsr.decay = knob.value
        channel.main2audio:push ( {adsr = adsr} );

     end
     renderLabel('rel', x + 200 + 10 - getStringWidth('rel')/2, y+height+10)
     --knob = v_slider('releaseDuration', x + 200 , y+ height + 40, height*2, adsr.release, 0.0001, 5)
     knob = draw_knob('releaseDuration', x+200+10, y+height+40+20,  adsr.release, 0, 1)
     if knob.value ~= nil then
        adsr.release = knob.value
        channel.main2audio:push ( {adsr = adsr} );

     end


   
     love.graphics.setLineWidth(1)
  end
  
  

function renderWave(data,  xOff, yOff, width, height)
   local count = data:getSampleCount( )
   local endPos = count-1 
   local startPos = 0

   love.graphics.setColor(1,1,1,0.6)
   love.graphics.rectangle("fill", xOff-2, yOff-height/2, width, height)
   
   local step = ((endPos - startPos)/width)
   love.graphics.setColor(red[1], red[2], red[3])

   for i = 0, width-1 do
      local min = 0
      local max = 0
      local pos = startPos + math.floor(step * (i))
      local s = 0
      for i =  -math.floor(step/2), math.floor(step/2) do
         if (pos + i >= 0 and pos + i <= count) then
            s = data:getSample(pos+i)
            if s < min then min = s end
            if s > max then max = s end
         end
      end
 

      
      love.graphics.line(xOff+i-1, yOff+math.floor((min * (height/2))), xOff+i-1, yOff)
      love.graphics.line(xOff+i-1, yOff+math.floor((max * (height/2))), xOff+i-1,  yOff)
   end


end

function fileBrowser(rootPath, subdir)
   local all
   local path

   if subdir then
      path = rootPath..'/'..subdir
      --all = love.filesystem.getDirectoryItems(rootPath..'/'..subdir);
   else
      path = rootPath
      --all = love.filesystem.getDirectoryItems(rootPath);
   end
   all = love.filesystem.getDirectoryItems(path);
   local result = {root=rootPath, subdir=subdir, files={}, directories={}}

   if subdir then
      table.insert(result.directories, '..')
   end
   
   for i= 1, #all do
      local t = love.filesystem.getInfo(path..'/'..all[i]).type
      if t == 'file' then
         table.insert(result.files, all[i])
      end
      if t == 'directory' then
         table.insert(result.directories, all[i])
      end
   end
   return result
   --print(inspect(love.filesystem.getDirectoryItems(rootPath)))
end

function renderBrowser()
   local runningX, runningY
   runningX = 20
   runningY = 200
   maxY = 700
   local buttonWidth = 200
   local buttonHeight = 20
   if browser then
      
      if #browser.directories > 0 then
         for i =1,  #browser.directories do

            love.graphics.setColor(red[1],red[2],red[3], 0.2)
            love.graphics.rectangle('fill', runningX, runningY, buttonWidth, buttonHeight)
            love.graphics.setColor(1,1,1)
            love.graphics.print(browser.directories[i], runningX, runningY )
            runningY = runningY + 20
            if runningY > maxY then
               runningX = runningX + 200
               runningY = 200
            end
         end
      end
      if #browser.files > 0 then
         for i =1,  #browser.files do
            love.graphics.setColor(.1,.1,.1)
            if (lastClickedFile == browser.files[i]) then
               love.graphics.setColor(.5,.1,.1)
            end
            
            love.graphics.print(string.gsub(browser.files[i], '.wav', ''), runningX, runningY )
            runningY = runningY + 20
            if runningY > maxY then
               runningX = runningX + 200
               runningY = 200
            end
         end
      end
   end
end


function handleBrowserClick(x,y)
   if x> 20 and y > 200 then
      local index = (math.floor((x-20)/200) * 26) + math.floor((y-200)/20) + 1
      if (index <= #browser.directories) then
         if (browser.directories[index] == '..') then
            browser = fileBrowser("assets/oscillators" )
         else
            browser = fileBrowser("assets/oscillators",  browser.directories[index] )
         end
      else
         local file =  browser.files[index - #browser.directories]
         local path
         if file then
            if browser.subdir then
               path = browser.subdir..'/'..file
            else
               path = file
            end
         end
         if path then
            if (stringEndsWith(path, '.wav')) then
               lastClickedFile = file
               channel.main2audio:push({osc= "assets/oscillators/"..path})
            end
         end
      end
   end
end
